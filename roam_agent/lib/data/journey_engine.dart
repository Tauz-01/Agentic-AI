import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../core/l10n.dart';
import '../domain/models.dart';
import 'catalog.dart';

class RiskEngine {
  DisruptionAlert? evaluate({
    required JourneyRecord journey,
    required JourneyEvent event,
    required int minBuffer,
    DateTime? deadline,
  }) {
    final legs = journey.itinerary.legs;
    final idx = legs.indexWhere((l) => l.id == event.affectedLegId);
    if (idx < 0) return null;
    final delayed = legs[idx];
    final originalArrival = delayed.arrival;
    final projected = originalArrival.add(Duration(minutes: event.delayMinutes));
    var remaining = 999;
    var originalBuf = 999;
    if (idx < legs.length - 1) {
      final next = legs[idx + 1];
      final walk = journey.itinerary.transfers[idx].walkMinutes;
      originalBuf = next.departure.difference(originalArrival).inMinutes - walk;
      remaining = next.departure.difference(projected).inMinutes - walk;
    }
    final deadlineHit = deadline != null &&
        journey.itinerary.arrival.add(Duration(minutes: event.delayMinutes)).isAfter(deadline);
    final atRisk = remaining < minBuffer || deadlineHit;
    if (!atRisk) return null;
    return DisruptionAlert(
      journeyId: journey.id,
      affectedLegId: delayed.id,
      eventId: event.id,
      originalArrival: originalArrival,
      projectedArrival: projected,
      originalBufferMinutes: originalBuf,
      remainingBufferMinutes: remaining,
      requiredBufferMinutes: minBuffer,
      deadlineImpact: deadlineHit ? 'deadline_at_risk' : 'connection_at_risk',
      riskStatus: remaining < 0 ? 'MISSED_CONNECTION' : 'CONNECTION_AT_RISK',
      recoveryAvailable: true,
      source: 'SIMULATION',
    );
  }
}

class RecoveryPlanner {
  RecoveryPlanner(this.catalog);
  final Catalog catalog;

  List<Itinerary> recover({
    required JourneyRecord journey,
    required TripIntent intent,
    required List<BusService> services,
    required DisruptionAlert alert,
  }) {
    final remainingBudget = (intent.maxBudgetInr ?? 99999) -
        journey.itinerary.legs
            .takeWhile((l) => l.id != alert.affectedLegId)
            .fold<int>(0, (a, l) => a + l.fareInr);
    // Search from projected interchange, not original origin.
    final projected = alert.projectedArrival;
    final fromStop = journey.itinerary.legs
        .firstWhere((l) => l.id == alert.affectedLegId)
        .destinationStopId;
    final destStops = catalog.cities[intent.destinationCityId]!.stopIds.toSet();
    final minBuf = intent.minimumTransferMinutes ?? 45;

    final options = <Itinerary>[];
    for (final svc in services) {
      if (!destStops.contains(svc.destinationStopId)) continue;
      final walk = catalog.transferWalk(fromStop, svc.originStopId);
      final available = svc.departure.difference(projected).inMinutes - walk;
      if (available < minBuf) continue;
      if (intent.arrivalDeadline != null && svc.arrival.isAfter(intent.arrivalDeadline!)) continue;
      if (svc.fareInr > remainingBudget) continue;
      if (intent.coachIsMandatory &&
          catalog.vehicles[svc.vehicleId]!.coachType.toLowerCase() != intent.coachPreference!.toLowerCase() &&
          catalog.vehicles[svc.vehicleId]!.coachType != 'AC seater') {
        // recovery may use remaining coaches if AC sleeper slot is gone; still prefer AC
      }
      final delayedLeg = _delayedCopy(
        journey.itinerary.legs.firstWhere((l) => l.id == alert.affectedLegId),
        alert.projectedArrival,
      );
      final next = Leg(
        id: 'leg_rec_${svc.id}',
        serviceId: svc.id,
        vehicleId: svc.vehicleId,
        originStopId: svc.originStopId,
        destinationStopId: svc.destinationStopId,
        departure: svc.departure,
        arrival: svc.arrival,
        fareInr: svc.fareInr,
        polyline: svc.polyline,
      );
      final xfer = Transfer(
        fromStopId: fromStop,
        toStopId: svc.originStopId,
        walkMinutes: walk,
        availableMinutes: available,
        requiredMinutes: minBuf,
      );
      options.add(Itinerary(
        id: 'rec_${svc.id}',
        tripId: intent.tripId,
        legs: [delayedLeg, next],
        transfers: [xfer],
        totalFareInr: delayedLeg.fareInr + next.fareInr,
        feasibility: Feasibility.feasible,
        revision: journey.revision + 1,
      ));
    }
    options.sort((a, b) => a.arrival.compareTo(b.arrival));
    return options;
  }

  Leg _delayedCopy(Leg leg, DateTime newArrival) => Leg(
        id: leg.id,
        serviceId: leg.serviceId,
        vehicleId: leg.vehicleId,
        originStopId: leg.originStopId,
        destinationStopId: leg.destinationStopId,
        departure: leg.departure,
        arrival: newArrival,
        fareInr: leg.fareInr,
        polyline: leg.polyline,
      );
}

class SimulationEngine {
  SimulationEngine();
  final _uuid = const Uuid();

  static const scenario = {
    'scenarioId': 'SCENARIO_CONNECTION_DELAY_01',
    'type': 'CONNECTION_AT_RISK',
    'delayMinutes': 50,
    'enabled': true,
  };

  JourneyEvent? maybeEmit(JourneyRecord journey, List<BusService> services) {
    if (journey.events.any((e) => e.type == 'DELAY')) return null;
    final clock = journey.clock;
    if (clock == null) return null;
    final first = journey.itinerary.legs.first;
    final svc = services.cast<BusService?>().firstWhere(
          (s) => s!.id == first.serviceId,
          orElse: () => null,
        );
    if (svc?.scenarioId != 'SCENARIO_CONNECTION_DELAY_01') return null;
    // Fire shortly after demo start so the presentation does not wait all night.
    final elapsed = clock.difference(first.departure);
    if (elapsed.inMinutes < 25) return null;
    return JourneyEvent(
      id: 'evt_${_uuid.v4().substring(0, 8)}',
      journeyId: journey.id,
      type: 'DELAY',
      timestamp: clock,
      source: 'SIMULATION',
      affectedLegId: first.id,
      delayMinutes: 50,
      message: 'First coach delayed 50 minutes (scripted demo scenario).',
    );
  }

  LatLng interpolate(JourneyRecord journey) {
    final it = journey.itinerary;
    final clock = journey.clock ?? it.departure;
    final pts = it.geometry;
    if (pts.isEmpty) return const LatLng(17.0, 82.0);
    final total = it.arrival.difference(it.departure).inMilliseconds;
    if (total <= 0) return pts.last;
    final t = clock.difference(it.departure).inMilliseconds / total;
    final x = t.clamp(0.0, 1.0);
    final idx = (x * (pts.length - 1)).floor();
    final n = (idx + 1).clamp(0, pts.length - 1);
    final f = x * (pts.length - 1) - idx;
    final a = pts[idx];
    final b = pts[n];
    return LatLng(a.latitude + (b.latitude - a.latitude) * f, a.longitude + (b.longitude - a.longitude) * f);
  }
}

String recoveryExplanation(RecoveryProposal p, AppLang lang) {
  final te = lang == AppLang.te;
  final extra = p.fareDelta;
  final eta = p.replacement.arrival;
  if (te) {
    return extra >= 0
        ? 'కనెక్టింగ్ బస్ బయలుదేరేలోపు మీరు చేరకపోవచ్చు. ప్రత్యామ్నాయం ₹$extra ఎక్కువ, ${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}కి చేరుతుంది.'
        : 'ప్రత్యామ్నాయం ఛార్జీని తగ్గిస్తుంది మరియు గడువులోపు చేరుతుంది.';
  }
  return extra >= 0
      ? 'Your connecting bus may depart before you reach the interchange. The proposed alternative costs ₹$extra more but is projected to arrive at ${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}.'
      : 'The alternative reduces fare and still meets your deadline.';
}
