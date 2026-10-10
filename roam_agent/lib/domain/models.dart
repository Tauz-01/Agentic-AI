import 'package:latlong2/latlong.dart';

import '../core/l10n.dart';

enum JourneyStage {
  input,
  clarification,
  validated,
  searching,
  optionsReady,
  itinerarySelected,
  demoConfirmation,
  active,
  disrupted,
  recoveryPending,
  proposalReady,
  awaitingApproval,
  demoChangeConfirmation,
  completed,
  cancelled,
}

enum Feasibility { feasible, infeasible, unverified }

enum InputMode { text, voice }

class Stop {
  const Stop({
    required this.id,
    required this.name,
    required this.cityId,
    required this.aliases,
    required this.coord,
  });
  final String id;
  final String name;
  final String cityId;
  final List<String> aliases;
  final LatLng coord;
}

class City {
  const City({required this.id, required this.name, required this.aliases, required this.stopIds});
  final String id;
  final String name;
  final List<String> aliases;
  final List<String> stopIds;
}

class Operator {
  const Operator({required this.id, required this.name, required this.type});
  final String id;
  final String name;
  final String type;
}

class Vehicle {
  const Vehicle({
    required this.id,
    required this.operatorId,
    required this.coachType,
    required this.ageYears,
    required this.model,
    required this.serviceHistoryNote,
    required this.reliabilityScore,
  });
  final String id;
  final String operatorId;
  final String coachType;
  final int ageYears;
  final String model;
  final String serviceHistoryNote;
  final double reliabilityScore;
}

class Review {
  const Review({required this.vehicleId, required this.rating, required this.text});
  final String vehicleId;
  final double rating;
  final String text;
}

class FeedbackItem {
  const FeedbackItem({required this.vehicleId, required this.category, required this.label});
  final String vehicleId;
  final String category;
  final String label;
}

class BusService {
  const BusService({
    required this.id,
    required this.vehicleId,
    required this.originStopId,
    required this.destinationStopId,
    required this.departure,
    required this.arrival,
    required this.fareInr,
    required this.polyline,
    this.scenarioId,
  });
  final String id;
  final String vehicleId;
  final String originStopId;
  final String destinationStopId;
  final DateTime departure;
  final DateTime arrival;
  final int fareInr;
  final List<LatLng> polyline;
  final String? scenarioId;
}

class Session {
  Session({
    required this.sessionId,
    required this.language,
    required this.inputMode,
    this.originalText = '',
    this.transcript = '',
  });
  final String sessionId;
  AppLang language;
  InputMode inputMode;
  String originalText;
  String transcript;
  AppLang get responseLanguage => language;
}

class TripIntent {
  TripIntent({
    required this.tripId,
    this.originCityId,
    this.destinationCityId,
    this.originLabel,
    this.destinationLabel,
    this.travelDate,
    this.arrivalDeadline,
    this.travelers,
    this.maxBudgetInr,
    this.coachPreference,
    this.berthPreference,
    this.minimumTransferMinutes,
    this.language = AppLang.en,
    this.status = 'DRAFT',
    this.timezone = 'Asia/Kolkata',
  });

  final String tripId;
  String? originCityId;
  String? destinationCityId;
  String? originLabel;
  String? destinationLabel;
  DateTime? travelDate;
  DateTime? arrivalDeadline;
  int? travelers;
  int? maxBudgetInr;
  String? coachPreference;
  String? berthPreference;
  int? minimumTransferMinutes;
  AppLang language;
  String status;
  String timezone;

  /// Coach/berth are ranking preferences unless the traveler marked them mandatory.
  bool coachMandatory = false;
  bool berthMandatory = false;
  bool get coachIsMandatory =>
      coachMandatory && coachPreference != null && coachPreference != 'none';
  bool get berthIsMandatory =>
      berthMandatory && berthPreference != null && berthPreference != 'none';

  TripIntent copy() => TripIntent(
        tripId: tripId,
        originCityId: originCityId,
        destinationCityId: destinationCityId,
        originLabel: originLabel,
        destinationLabel: destinationLabel,
        travelDate: travelDate,
        arrivalDeadline: arrivalDeadline,
        travelers: travelers,
        maxBudgetInr: maxBudgetInr,
        coachPreference: coachPreference,
        berthPreference: berthPreference,
        minimumTransferMinutes: minimumTransferMinutes,
        language: language,
        status: status,
        timezone: timezone,
      )..coachMandatory = coachMandatory
        ..berthMandatory = berthMandatory;
}

class Leg {
  const Leg({
    required this.id,
    required this.serviceId,
    required this.vehicleId,
    required this.originStopId,
    required this.destinationStopId,
    required this.departure,
    required this.arrival,
    required this.fareInr,
    required this.polyline,
  });
  final String id;
  final String serviceId;
  final String vehicleId;
  final String originStopId;
  final String destinationStopId;
  final DateTime departure;
  final DateTime arrival;
  final int fareInr;
  final List<LatLng> polyline;
}

class Transfer {
  const Transfer({
    required this.fromStopId,
    required this.toStopId,
    required this.walkMinutes,
    required this.availableMinutes,
    required this.requiredMinutes,
  });
  final String fromStopId;
  final String toStopId;
  final int walkMinutes;
  final int availableMinutes;
  final int requiredMinutes;
}

class ScoreBreakdown {
  const ScoreBreakdown({
    required this.total,
    required this.features,
  });
  final double total;
  final Map<String, double> features;
}

class Itinerary {
  Itinerary({
    required this.id,
    required this.tripId,
    required this.legs,
    required this.transfers,
    required this.totalFareInr,
    required this.feasibility,
    this.violation,
    this.score,
    this.explanation = '',
    this.recommended = false,
    this.revision = 1,
  });

  final String id;
  final String tripId;
  final List<Leg> legs;
  final List<Transfer> transfers;
  final int totalFareInr;
  final Feasibility feasibility;
  final String? violation;
  ScoreBreakdown? score;
  String explanation;
  bool recommended;
  int revision;

  DateTime get departure => legs.first.departure;
  DateTime get arrival => legs.last.arrival;
  Duration get duration => arrival.difference(departure);
  List<LatLng> get geometry => [
        for (final leg in legs) ...leg.polyline,
      ];
}

class JourneyEvent {
  const JourneyEvent({
    required this.id,
    required this.journeyId,
    required this.type,
    required this.timestamp,
    required this.source,
    required this.affectedLegId,
    required this.delayMinutes,
    required this.message,
  });
  final String id;
  final String journeyId;
  final String type;
  final DateTime timestamp;
  final String source;
  final String affectedLegId;
  final int delayMinutes;
  final String message;
}

class DisruptionAlert {
  const DisruptionAlert({
    required this.journeyId,
    required this.affectedLegId,
    required this.eventId,
    required this.originalArrival,
    required this.projectedArrival,
    required this.originalBufferMinutes,
    required this.remainingBufferMinutes,
    required this.requiredBufferMinutes,
    required this.deadlineImpact,
    required this.riskStatus,
    required this.recoveryAvailable,
    required this.source,
  });
  final String journeyId;
  final String affectedLegId;
  final String eventId;
  final DateTime originalArrival;
  final DateTime projectedArrival;
  final int originalBufferMinutes;
  final int remainingBufferMinutes;
  final int requiredBufferMinutes;
  final String deadlineImpact;
  final String riskStatus;
  final bool recoveryAvailable;
  final String source;
}

class RecoveryProposal {
  RecoveryProposal({
    required this.id,
    required this.journeyId,
    required this.original,
    required this.replacement,
    required this.fareDelta,
    required this.reason,
    this.status = 'PENDING',
    this.valid = true,
  });
  final String id;
  final String journeyId;
  final Itinerary original;
  final Itinerary replacement;
  final int fareDelta;
  final String reason;
  String status;
  bool valid;
}

class JourneyRecord {
  JourneyRecord({
    required this.id,
    required this.tripId,
    required this.itinerary,
    required this.stage,
    this.scenarioId,
    this.clock,
    this.vehiclePosition,
  });
  final String id;
  final String tripId;
  Itinerary itinerary;
  JourneyStage stage;
  String? scenarioId;
  DateTime? clock;
  LatLng? vehiclePosition;
  int revision = 1;
  final List<JourneyEvent> events = [];
  DisruptionAlert? alert;
  RecoveryProposal? proposal;
  final List<Map<String, dynamic>> audit = [];
}

class ParseResult {
  ParseResult({required this.intent, required this.missing, required this.language});
  final TripIntent intent;
  final List<String> missing;
  final AppLang language;
}

class ScoringConfig {
  static const weights = <String, double>{
    'schedule': 0.22,
    'transferMargin': 0.18,
    'fare': 0.14,
    'vehicleHistory': 0.12,
    'reviews': 0.14,
    'feedback': 0.08,
    'coachMatch': 0.08,
    'fewerTransfers': 0.04,
  };
}
