import 'package:uuid/uuid.dart';

import '../core/l10n.dart';
import '../domain/models.dart';
import 'catalog.dart';
import 'intent_and_validate.dart';
import 'journey_engine.dart';
import 'planner.dart';

/// In-process backend. Flutter never invents schedules; this module does.
class LocalConciergeBackend {
  LocalConciergeBackend({DateTime? now})
      : now = now ?? DateTime(2026, 10, 10, 15, 50) {
    extractor = IntentExtractor(catalog, now: this.now);
  }

  final DateTime now;
  final catalog = Catalog();
  late final IntentExtractor extractor;
  late final validator = ConstraintValidator(catalog);
  late final planner = RoutePlanner(catalog);
  late final ranker = RecommendationEngine(catalog);
  late final explainer = ExplanationAgent();
  final risk = RiskEngine();
  late final recovery = RecoveryPlanner(catalog);
  final simulation = SimulationEngine();
  final _uuid = const Uuid();

  final sessions = <String, Session>{};
  final trips = <String, TripIntent>{};
  final options = <String, List<Itinerary>>{};
  final itineraries = <String, Itinerary>{};
  final journeys = <String, JourneyRecord>{};
  final proposals = <String, RecoveryProposal>{};

  Session startSession({required AppLang language, required InputMode mode}) {
    final s = Session(
      sessionId: 'session_${_uuid.v4().substring(0, 8)}',
      language: language,
      inputMode: mode,
    );
    sessions[s.sessionId] = s;
    return s;
  }

  ParseResult parse({
    required String sessionId,
    required String text,
    required InputMode mode,
  }) {
    final session = sessions[sessionId]!;
    session.inputMode = mode;
    session.originalText = text;
    session.transcript = text;
    session.language = extractor.detectLanguage(text);
    final result = extractor.extract(text, sessionId: sessionId, preferred: session.language);
    trips[result.intent.tripId] = result.intent;
    return result;
  }

  List<String> applyClarification(String tripId, Map<String, String> fields) {
    final intent = trips[tripId]!;
    if (fields['origin'] != null) {
      final c = _city(fields['origin']!);
      intent.originCityId = c?.id;
      intent.originLabel = c?.name ?? fields['origin'];
    }
    if (fields['destination'] != null) {
      final c = _city(fields['destination']!);
      intent.destinationCityId = c?.id;
      intent.destinationLabel = c?.name ?? fields['destination'];
    }
    if (fields['travelDate'] != null) {
      intent.travelDate = DateTime.tryParse(fields['travelDate']!);
    }
    if (fields['arrivalDeadline'] != null && intent.travelDate != null) {
      final p = fields['arrivalDeadline']!.split(':');
      intent.arrivalDeadline = DateTime(
        intent.travelDate!.year,
        intent.travelDate!.month,
        intent.travelDate!.day,
        int.parse(p[0]),
        p.length > 1 ? int.parse(p[1]) : 0,
      );
    }
    if (fields['travelers'] != null && fields['travelers']!.trim().isNotEmpty) {
      intent.travelers = int.tryParse(fields['travelers']!);
    }
    if (fields['maxBudgetINR'] != null && fields['maxBudgetINR']!.trim().isNotEmpty) {
      intent.maxBudgetInr = int.tryParse(fields['maxBudgetINR']!);
    }
    if (fields['coachPreference'] != null) intent.coachPreference = fields['coachPreference'];
    if (fields['berthPreference'] != null) intent.berthPreference = fields['berthPreference'];
    if (fields['minimumTransferMinutes'] != null) {
      intent.minimumTransferMinutes = int.tryParse(fields['minimumTransferMinutes']!);
    }
    return validator.validate(intent);
  }

  List<Itinerary> search(String tripId) {
    final intent = trips[tripId]!;
    final errors = validator.validate(intent);
    if (errors.isNotEmpty) {
      throw StateError('Search blocked until trip intent is valid: $errors');
    }
    intent.status = 'VALIDATED';
    final services = buildServices(catalog, intent.travelDate!);
    final found = planner.search(intent, services);
    final ranked = ranker.rank(found, intent);
    for (final it in ranked) {
      it.explanation = explainer.explain(it, catalog, intent.language, intent);
      itineraries[it.id] = it;
    }
    options[tripId] = ranked;
    return ranked;
  }

  Itinerary itinerary(String id) => itineraries[id]!;

  JourneyRecord selectItinerary(String itineraryId) {
    final it = itineraries[itineraryId]!;
    final j = JourneyRecord(
      id: 'journey_${_uuid.v4().substring(0, 8)}',
      tripId: it.tripId,
      itinerary: it,
      stage: JourneyStage.itinerarySelected,
      scenarioId: _scenarioFor(it),
    );
    journeys[j.id] = j;
    return j;
  }

  JourneyRecord openCheckout(String journeyId) {
    final j = journeys[journeyId]!;
    j.stage = JourneyStage.demoConfirmation;
    return j;
  }

  JourneyRecord confirmDemo(String journeyId) {
    final j = journeys[journeyId]!;
    if (j.stage == JourneyStage.active) return j;
    if (j.stage != JourneyStage.demoConfirmation &&
        j.stage != JourneyStage.demoChangeConfirmation) {
      throw StateError('Confirmation only from demo checkout');
    }
    if (j.stage == JourneyStage.demoChangeConfirmation) {
      final p = j.proposal;
      if (p == null || !p.valid || p.status != 'APPROVED_PENDING_PAYMENT') {
        throw StateError('Proposal is not awaiting simulated payment');
      }
      _commit(j, p);
      j.stage = JourneyStage.active;
      return j;
    }
    j.stage = JourneyStage.active;
    j.clock = j.itinerary.departure.add(const Duration(minutes: 20));
    j.vehiclePosition = simulation.interpolate(j);
    j.audit.add({'action': 'DEMO_CONFIRMED', 'revision': j.revision});
    return j;
  }

  JourneyRecord tick(String journeyId) {
    final j = journeys[journeyId]!;
    if (j.stage != JourneyStage.active && j.stage != JourneyStage.disrupted) return j;
    j.clock = (j.clock ?? j.itinerary.departure).add(const Duration(minutes: 8));
    j.vehiclePosition = simulation.interpolate(j);
    final intent = trips[j.tripId]!;
    final services = buildServices(catalog, intent.travelDate!);
    final event = simulation.maybeEmit(j, services);
    if (event != null) {
      j.events.add(event);
      final alert = risk.evaluate(
        journey: j,
        event: event,
        minBuffer: intent.minimumTransferMinutes ?? 45,
        deadline: intent.arrivalDeadline,
      );
      if (alert != null) {
        j.alert = alert;
        j.stage = JourneyStage.disrupted;
      }
    }
    if (j.clock!.isAfter(j.itinerary.arrival) && j.alert == null) {
      j.stage = JourneyStage.completed;
    }
    return j;
  }

  List<RecoveryProposal> recoveryOptions(String journeyId) {
    final j = journeys[journeyId]!;
    if (j.alert == null) return [];
    j.stage = JourneyStage.recoveryPending;
    final intent = trips[j.tripId]!;
    final services = buildServices(catalog, intent.travelDate!);
    final found = recovery.recover(
      journey: j,
      intent: intent,
      services: services,
      alert: j.alert!,
    );
    final scored = ranker.rank(found, intent);
    final out = <RecoveryProposal>[];
    for (final it in scored.where((e) => e.feasibility == Feasibility.feasible).take(3)) {
      it.explanation = explainer.explain(it, catalog, intent.language, intent);
      itineraries[it.id] = it;
      final p = RecoveryProposal(
        id: 'proposal_${_uuid.v4().substring(0, 8)}',
        journeyId: j.id,
        original: j.itinerary,
        replacement: it,
        fareDelta: it.totalFareInr - j.itinerary.totalFareInr,
        reason: recoveryExplanation(
          RecoveryProposal(
            id: 'tmp',
            journeyId: j.id,
            original: j.itinerary,
            replacement: it,
            fareDelta: it.totalFareInr - j.itinerary.totalFareInr,
            reason: '',
          ),
          intent.language,
        ),
      );
      p.reason = recoveryExplanation(p, intent.language);
      proposals[p.id] = p;
      out.add(p);
    }
    if (out.isNotEmpty) {
      j.proposal = out.first;
      j.stage = JourneyStage.proposalReady;
    }
    return out;
  }

  JourneyRecord approve(String proposalId) {
    final p = proposals[proposalId]!;
    final j = journeys[p.journeyId]!;
    if (!p.valid || p.status == 'REJECTED') {
      throw StateError('Stale or rejected proposal cannot be approved');
    }
    p.status = 'APPROVED_PENDING_PAYMENT';
    j.proposal = p;
    j.stage = JourneyStage.demoChangeConfirmation;
    return j;
  }

  JourneyRecord reject(String proposalId) {
    final p = proposals[proposalId]!;
    p.status = 'REJECTED';
    final j = journeys[p.journeyId]!;
    j.audit.add({'action': 'REJECTED', 'proposalId': p.id});
    j.stage = JourneyStage.disrupted;
    return j;
  }

  void _commit(JourneyRecord j, RecoveryProposal p) {
    if (j.audit.any((a) => a['proposalId'] == p.id && a['action'] == 'COMMITTED')) {
      return;
    }
    final prev = j.revision;
    j.itinerary = p.replacement;
    j.revision = p.replacement.revision;
    p.status = 'APPROVED';
    j.alert = null;
    j.audit.add({
      'journeyId': j.id,
      'previousRevision': prev,
      'newRevision': j.revision,
      'proposalId': p.id,
      'approvalStatus': 'APPROVED',
      'paymentMode': 'SIMULATED',
      'action': 'COMMITTED',
    });
  }

  City? _city(String raw) {
    final lower = raw.toLowerCase().trim();
    for (final c in catalog.cities.values) {
      if (c.id == lower || c.name.toLowerCase() == lower || c.aliases.contains(lower)) return c;
    }
    return extractor._findLoose(raw);
  }

  String? _scenarioFor(Itinerary it) {
    for (final leg in it.legs) {
      if (leg.serviceId == 'svc_vizag_vja') return 'SCENARIO_CONNECTION_DELAY_01';
    }
    return null;
  }
}

extension on IntentExtractor {
  City? _findLoose(String text) {
    final lower = text.toLowerCase();
    for (final c in catalog.cities.values) {
      if (c.aliases.any((a) => lower.contains(a.toLowerCase()))) return c;
    }
    return null;
  }
}
