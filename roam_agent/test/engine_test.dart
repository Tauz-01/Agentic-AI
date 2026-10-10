import 'package:flutter_test/flutter_test.dart';
import 'package:roam_agent/core/l10n.dart';
import 'package:roam_agent/data/backend.dart';
import 'package:roam_agent/data/catalog.dart';
import 'package:roam_agent/domain/models.dart';

void main() {
  late LocalConciergeBackend api;

  setUp(() {
    api = LocalConciergeBackend(now: DateTime(2026, 10, 10, 16, 0));
  });

  TripIntent complete(LocalConciergeBackend api) {
    final session = api.startSession(language: AppLang.en, mode: InputMode.text);
    final parsed = api.parse(
      sessionId: session.sessionId,
      text:
          'I need to travel from Vizag to Hyderabad tomorrow. I must reach before 9 AM. My budget is ₹1500, and I prefer an AC sleeper.',
      mode: InputMode.text,
    );
    expect(parsed.intent.originCityId, 'vizag');
    expect(parsed.intent.destinationCityId, 'hyd');
    expect(parsed.intent.maxBudgetInr, 1500);
    expect(parsed.missing, containsAll(['travelers', 'berthPreference', 'minimumTransferMinutes']));
    final errors = api.applyClarification(parsed.intent.tripId, {
      'travelers': '1',
      'berthPreference': 'none',
      'minimumTransferMinutes': '45',
    });
    expect(errors, isEmpty);
    return api.trips[parsed.intent.tripId]!;
  }

  test('does not search until required fields are present', () {
    final session = api.startSession(language: AppLang.en, mode: InputMode.text);
    final parsed = api.parse(
      sessionId: session.sessionId,
      text: 'Vizag to Hyderabad tomorrow before 9 AM budget ₹1500 AC sleeper',
      mode: InputMode.text,
    );
    expect(
      () => api.search(parsed.intent.tripId),
      throwsA(isA<StateError>()),
    );
  });

  test('feasible connecting itinerary outranks deadline miss', () {
    final trip = complete(api);
    final ranked = api.search(trip.tripId);
    final feasible = ranked.where((e) => e.feasibility == Feasibility.feasible).toList();
    final misses = ranked.where((e) => e.feasibility == Feasibility.infeasible).toList();
    expect(feasible, isNotEmpty);
    expect(feasible.first.recommended, isTrue);
    expect(feasible.first.arrival.isAfter(trip.arrivalDeadline!), isFalse);
    expect(misses.any((e) => e.violation == 'arrival_deadline'), isTrue);
    expect(feasible.first.totalFareInr, lessThanOrEqualTo(1500));
  });

  test('multi-leg transfer buffer uses walk time between different terminals', () {
    final catalog = Catalog();
    expect(catalog.transferWalk('vja_bs', 'vja_bypass'), 25);
    expect(catalog.transferWalk('vja_bs', 'vja_bs'), 0);
  });

  test('50 minute delay leaves 5 minute buffer and blocks original connection', () {
    final trip = complete(api);
    final ranked = api.search(trip.tripId);
    final connecting = ranked.firstWhere(
      (e) => e.legs.any((l) => l.serviceId == 'svc_vizag_vja') && e.feasibility == Feasibility.feasible,
    );
    expect(connecting.transfers.first.availableMinutes, 55);
    final journey = api.selectItinerary(connecting.id);
    api.openCheckout(journey.id);
    api.confirmDemo(journey.id);
    JourneyRecord? current;
    for (var i = 0; i < 8; i++) {
      current = api.tick(journey.id);
      if (current.alert != null) break;
    }
    expect(current!.alert, isNotNull);
    expect(current.alert!.remainingBufferMinutes, 5);
    expect(current.alert!.requiredBufferMinutes, 45);
    expect(current.stage, JourneyStage.disrupted);
    final originalRevision = current.revision;
    final options = api.recoveryOptions(current.id);
    expect(options, isNotEmpty);
    expect(current.itinerary.id, connecting.id);
    api.reject(options.first.id);
    expect(api.journeys[current.id]!.revision, originalRevision);
    api.recoveryOptions(current.id);
    final p = api.journeys[current.id]!.proposal!;
    api.approve(p.id);
    expect(api.journeys[current.id]!.itinerary.id, connecting.id);
    api.confirmDemo(current.id);
    final updated = api.journeys[current.id]!;
    expect(updated.revision, 2);
    api.confirmDemo(current.id);
    expect(api.journeys[current.id]!.revision, 2);
  });

  test('telugu and english extract the same corridor', () {
    final en = api.parse(
      sessionId: api.startSession(language: AppLang.en, mode: InputMode.text).sessionId,
      text: 'Vizag to Hyderabad tomorrow before 9 AM. Budget ₹1500. AC sleeper.',
      mode: InputMode.text,
    );
    final te = api.parse(
      sessionId: api.startSession(language: AppLang.te, mode: InputMode.text).sessionId,
      text: 'రేపు ఉదయం 9 గంటలలోపు విశాఖపట్నం నుంచి హైదరాబాద్ చేరాలి. నా బడ్జెట్ ₹1500. ఏసీ స్లీపర్ బస్సు కావాలి.',
      mode: InputMode.text,
    );
    expect(en.language, AppLang.en);
    expect(te.language, AppLang.te);
    expect(en.intent.originCityId, te.intent.originCityId);
    expect(en.intent.destinationCityId, te.intent.destinationCityId);
    expect(en.intent.maxBudgetInr, te.intent.maxBudgetInr);
  });
}
