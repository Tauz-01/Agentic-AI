import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/l10n.dart';
import '../data/backend.dart';
import '../data/intent_and_validate.dart';
import '../domain/models.dart';

class RoamController extends ChangeNotifier {
  RoamController({LocalConciergeBackend? backend}) : backend = backend ?? LocalConciergeBackend();

  final LocalConciergeBackend backend;

  AppLang lang = AppLang.en;
  JourneyStage stage = JourneyStage.input;
  S get s => S(lang);

  String? sessionId;
  String inputText = '';
  String? transcript;
  bool listening = false;
  bool busy = false;
  String? error;

  TripIntent? intent;
  List<String> missing = [];
  List<Itinerary> results = [];
  Itinerary? selected;
  JourneyRecord? journey;
  List<RecoveryProposal> recoveries = [];
  RecoveryProposal? focusedProposal;
  Timer? _sim;

  void setLang(AppLang v) {
    lang = v;
    notifyListeners();
  }

  Future<void> ensureSession({InputMode mode = InputMode.text}) async {
    sessionId ??= backend.startSession(language: lang, mode: mode).sessionId;
  }

  Future<void> simulateVoice() async {
    listening = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    transcript = lang == AppLang.te
        ? 'రేపు ఉదయం 9 గంటలలోపు విశాఖపట్నం నుంచి హైదరాబాద్ చేరాలి. నా బడ్జెట్ ₹1,500. ఏసీ స్లీపర్ బస్సు కావాలి.'
        : 'I need to travel from Vizag to Hyderabad tomorrow. I must reach before 9 AM. My budget is ₹1,500, and I prefer an AC sleeper.';
    inputText = transcript!;
    listening = false;
    notifyListeners();
  }

  Future<void> submitInput({InputMode mode = InputMode.text}) async {
    error = null;
    await ensureSession(mode: mode);
    if (inputText.trim().isEmpty) return;
    busy = true;
    notifyListeners();
    final parsed = backend.parse(sessionId: sessionId!, text: inputText.trim(), mode: mode);
    lang = parsed.language;
    intent = parsed.intent;
    missing = parsed.missing;
    stage = missing.isEmpty ? JourneyStage.validated : JourneyStage.clarification;
    busy = false;
    notifyListeners();
  }

  void patchIntent({
    String? origin,
    String? destination,
    String? date,
    String? deadline,
    String? travelers,
    String? budget,
    String? coach,
    String? berth,
    String? buffer,
  }) {
    if (intent == null) return;
    final fields = <String, String>{};
    if (origin != null) fields['origin'] = origin;
    if (destination != null) fields['destination'] = destination;
    if (date != null) fields['travelDate'] = date;
    if (deadline != null) fields['arrivalDeadline'] = deadline;
    if (travelers != null) fields['travelers'] = travelers;
    if (budget != null) fields['maxBudgetINR'] = budget;
    if (coach != null) fields['coachPreference'] = coach;
    if (berth != null) fields['berthPreference'] = berth;
    if (buffer != null) fields['minimumTransferMinutes'] = buffer;
    missing = backend.applyClarification(intent!.tripId, fields);
    intent = backend.trips[intent!.tripId];
    notifyListeners();
  }

  Future<void> search() async {
    if (intent == null) return;
    if (missing.isNotEmpty) {
      error = s.missing;
      notifyListeners();
      return;
    }
    stage = JourneyStage.searching;
    busy = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    try {
      results = backend.search(intent!.tripId);
      stage = JourneyStage.optionsReady;
      error = null;
    } catch (e) {
      error = e.toString();
      stage = JourneyStage.clarification;
    }
    busy = false;
    notifyListeners();
  }

  void selectOption(Itinerary it) {
    if (it.feasibility != Feasibility.feasible) return;
    selected = it;
    journey = backend.selectItinerary(it.id);
    stage = JourneyStage.itinerarySelected;
    notifyListeners();
  }

  void openCheckout() {
    if (journey == null) return;
    journey = backend.openCheckout(journey!.id);
    stage = JourneyStage.demoConfirmation;
    notifyListeners();
  }

  void confirmDemo() {
    if (journey == null) return;
    journey = backend.confirmDemo(journey!.id);
    stage = journey!.stage;
    _startSim();
    notifyListeners();
  }

  void _startSim() {
    _sim?.cancel();
    _sim = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (journey == null) return;
      journey = backend.tick(journey!.id);
      stage = journey!.stage;
      notifyListeners();
      if (stage == JourneyStage.disrupted || stage == JourneyStage.completed) {
        _sim?.cancel();
      }
    });
  }

  void loadRecovery() {
    if (journey == null) return;
    recoveries = backend.recoveryOptions(journey!.id);
    journey = backend.journeys[journey!.id];
    if (recoveries.isNotEmpty) {
      focusedProposal = recoveries.first;
      stage = JourneyStage.proposalReady;
    }
    notifyListeners();
  }

  void focusProposal(RecoveryProposal p) {
    focusedProposal = p;
    notifyListeners();
  }

  void approveFocused() {
    if (focusedProposal == null) return;
    journey = backend.approve(focusedProposal!.id);
    stage = JourneyStage.demoChangeConfirmation;
    notifyListeners();
  }

  void rejectFocused() {
    if (focusedProposal == null) return;
    journey = backend.reject(focusedProposal!.id);
    stage = JourneyStage.disrupted;
    notifyListeners();
  }

  void backToOptions() {
    stage = JourneyStage.optionsReady;
    notifyListeners();
  }

  void backToItinerary() {
    stage = JourneyStage.itinerarySelected;
    notifyListeners();
  }

  void backToRecovery() {
    stage = JourneyStage.proposalReady;
    notifyListeners();
  }

  void backToTracking() {
    stage = JourneyStage.disrupted;
    notifyListeners();
  }

  void reset() {
    _sim?.cancel();
    stage = JourneyStage.input;
    intent = null;
    results = [];
    selected = null;
    journey = null;
    recoveries = [];
    focusedProposal = null;
    sessionId = null;
    inputText = '';
    transcript = null;
    error = null;
    notifyListeners();
  }

  List<String> clarificationQuestions() => [
        for (final f in missing) ClarificationCopy.question(f, lang),
      ];

  @override
  void dispose() {
    _sim?.cancel();
    super.dispose();
  }
}
