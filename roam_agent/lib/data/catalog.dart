import 'package:latlong2/latlong.dart';

import '../domain/models.dart';

class Catalog {
  Catalog();

  final cities = <String, City>{
    'vizag': const City(
      id: 'vizag',
      name: 'Visakhapatnam',
      aliases: ['vizag', 'visakhapatnam', 'vskp', 'విశాఖపట్నం', 'విజాగ్'],
      stopIds: ['vizag_rtc', 'vizag_dwarka'],
    ),
    'hyd': const City(
      id: 'hyd',
      name: 'Hyderabad',
      aliases: ['hyderabad', 'hyd', 'హైదరాబాద్', 'హైదరాబాదు'],
      stopIds: ['hyd_mgbs', 'hyd_jbs'],
    ),
    'vja': const City(
      id: 'vja',
      name: 'Vijayawada',
      aliases: ['vijayawada', 'vja', 'bezawada', 'విజయవాడ'],
      stopIds: ['vja_bs', 'vja_bypass'],
    ),
    'rjy': const City(
      id: 'rjy',
      name: 'Rajahmundry',
      aliases: ['rajahmundry', 'rjy', 'రాజమండ్రి'],
      stopIds: ['rjy_bs'],
    ),
  };

  final stops = <String, Stop>{
    'vizag_rtc': const Stop(
      id: 'vizag_rtc',
      name: 'Visakhapatnam RTC Complex',
      cityId: 'vizag',
      aliases: ['rtc complex', 'vizag rtc'],
      coord: LatLng(17.7225, 83.3040),
    ),
    'vizag_dwarka': const Stop(
      id: 'vizag_dwarka',
      name: 'Dwarka Nagar',
      cityId: 'vizag',
      aliases: ['dwarka', 'dwaraka nagar'],
      coord: LatLng(17.7288, 83.3089),
    ),
    'vja_bs': const Stop(
      id: 'vja_bs',
      name: 'Vijayawada Bus Station',
      cityId: 'vja',
      aliases: ['pandit nehru bus station', 'pnbs'],
      coord: LatLng(16.5170, 80.6220),
    ),
    'vja_bypass': const Stop(
      id: 'vja_bypass',
      name: 'Vijayawada Bypass Boarding Point',
      cityId: 'vja',
      aliases: ['bypass', 'vja bypass'],
      coord: LatLng(16.5485, 80.5980),
    ),
    'rjy_bs': const Stop(
      id: 'rjy_bs',
      name: 'Rajahmundry Bus Station',
      cityId: 'rjy',
      aliases: ['rjy station'],
      coord: LatLng(16.9900, 81.7800),
    ),
    'hyd_mgbs': const Stop(
      id: 'hyd_mgbs',
      name: 'Hyderabad MGBS',
      cityId: 'hyd',
      aliases: ['mgbs', 'imlibun'],
      coord: LatLng(17.3616, 78.4747),
    ),
    'hyd_jbs': const Stop(
      id: 'hyd_jbs',
      name: 'Hyderabad JBS',
      cityId: 'hyd',
      aliases: ['jbs', 'jubilee bus station'],
      coord: LatLng(17.4435, 78.4988),
    ),
  };

  final operators = <String, Operator>{
    'apsrtc': const Operator(id: 'apsrtc', name: 'APSRTC', type: 'state_rtc'),
    'tsrtc': const Operator(id: 'tsrtc', name: 'TSRTC', type: 'state_rtc'),
    'keshava': const Operator(id: 'keshava', name: 'Sri Keshava Travels', type: 'private'),
    'orange': const Operator(id: 'orange', name: 'Orange Tours', type: 'private'),
    'morning': const Operator(id: 'morning', name: 'Morning Star', type: 'private'),
  };

  final vehicles = <String, Vehicle>{
    'v_apsrtc_8': const Vehicle(
      id: 'v_apsrtc_8',
      operatorId: 'apsrtc',
      coachType: 'AC sleeper',
      ageYears: 8,
      model: 'Volvo B11R AC Sleeper 2+1',
      serviceHistoryNote: 'Consistent NH16 overnight duty, documented depot checks.',
      reliabilityScore: 0.86,
    ),
    'v_keshava_5': const Vehicle(
      id: 'v_keshava_5',
      operatorId: 'keshava',
      coachType: 'AC sleeper',
      ageYears: 5,
      model: 'Scania Multi-Axle AC Sleeper 2+1',
      serviceHistoryNote: 'Newer fleet, mixed AC complaint history.',
      reliabilityScore: 0.71,
    ),
    'v_orange_11': const Vehicle(
      id: 'v_orange_11',
      operatorId: 'orange',
      coachType: 'AC sleeper',
      ageYears: 11,
      model: 'Volvo Multi-Axle AC Sleeper',
      serviceHistoryNote: 'Long service history, strong passenger feedback.',
      reliabilityScore: 0.90,
    ),
    'v_tsrtc_3': const Vehicle(
      id: 'v_tsrtc_3',
      operatorId: 'tsrtc',
      coachType: 'AC sleeper',
      ageYears: 3,
      model: 'Bharat Benz AC Sleeper',
      serviceHistoryNote: 'Young vehicle, limited overnight record.',
      reliabilityScore: 0.74,
    ),
    'v_morning_9': const Vehicle(
      id: 'v_morning_9',
      operatorId: 'morning',
      coachType: 'Non-AC seater',
      ageYears: 9,
      model: 'Ashok Leyland Non-AC Seater',
      serviceHistoryNote: 'Budget service, frequent late arrivals on this corridor.',
      reliabilityScore: 0.52,
    ),
    'v_apsrtc_seat': const Vehicle(
      id: 'v_apsrtc_seat',
      operatorId: 'apsrtc',
      coachType: 'AC seater',
      ageYears: 6,
      model: 'Volvo AC Seater',
      serviceHistoryNote: 'Day-duty coach used on overnight recovery slots.',
      reliabilityScore: 0.80,
    ),
  };

  final reviews = <Review>[
    const Review(vehicleId: 'v_apsrtc_8', rating: 4.5, text: 'On-time boarding at RTC Complex.'),
    const Review(vehicleId: 'v_keshava_5', rating: 3.8, text: 'Clean sleeper, AC uneven on last trip.'),
    const Review(vehicleId: 'v_orange_11', rating: 4.7, text: 'Smooth ride despite older coach.'),
    const Review(vehicleId: 'v_tsrtc_3', rating: 4.1, text: 'New seats, slightly rushed transfer window.'),
    const Review(vehicleId: 'v_morning_9', rating: 3.1, text: 'Cheap but often late into Hyderabad.'),
    const Review(vehicleId: 'v_apsrtc_seat', rating: 4.2, text: 'Reliable recovery service from bypass.'),
  ];

  final feedback = <FeedbackItem>[
    const FeedbackItem(vehicleId: 'v_apsrtc_8', category: 'punctuality', label: 'positive'),
    const FeedbackItem(vehicleId: 'v_keshava_5', category: 'ac', label: 'mixed'),
    const FeedbackItem(vehicleId: 'v_orange_11', category: 'comfort', label: 'positive'),
    const FeedbackItem(vehicleId: 'v_morning_9', category: 'delay', label: 'negative'),
    const FeedbackItem(vehicleId: 'v_apsrtc_seat', category: 'recovery', label: 'positive'),
  ];

  /// Walking / interchange minutes between terminals. Same stop = 0.
  int transferWalk(String a, String b) {
    if (a == b) return 0;
    const pairs = {
      'vja_bs|vja_bypass': 25,
      'vja_bypass|vja_bs': 25,
      'vizag_rtc|vizag_dwarka': 18,
      'vizag_dwarka|vizag_rtc': 18,
      'hyd_mgbs|hyd_jbs': 35,
      'hyd_jbs|hyd_mgbs': 35,
    };
    return pairs['$a|$b'] ?? 40;
  }

  double avgRating(String vehicleId) {
    final r = reviews.where((e) => e.vehicleId == vehicleId).toList();
    if (r.isEmpty) return 3.5;
    return r.map((e) => e.rating).reduce((a, b) => a + b) / r.length;
  }

  double feedbackScore(String vehicleId) {
    final items = feedback.where((e) => e.vehicleId == vehicleId);
    if (items.isEmpty) return 0.5;
    var s = 0.5;
    for (final i in items) {
      if (i.label == 'positive') s += 0.2;
      if (i.label == 'negative') s -= 0.2;
    }
    return s.clamp(0.0, 1.0);
  }

  Operator operatorOf(String vehicleId) => operators[vehicles[vehicleId]!.operatorId]!;
}

DateTime t(DateTime day, int h, int m, {int addDays = 0}) =>
    DateTime(day.year, day.month, day.day, h, m).add(Duration(days: addDays));

List<LatLng> line(List<Stop> pts) => [for (final p in pts) p.coord];

/// Overnight window: previous evening through arrival morning.
List<BusService> buildServices(Catalog c, DateTime travelDate) {
  final arriveDay = DateTime(travelDate.year, travelDate.month, travelDate.day);
  final departDay = arriveDay.subtract(const Duration(days: 1));
  final s = c.stops;

  List<LatLng> p(List<String> ids) => line(ids.map((id) => s[id]!).toList());

  return [
    BusService(
      id: 'svc_direct_budget',
      vehicleId: 'v_morning_9',
      originStopId: 'vizag_rtc',
      destinationStopId: 'hyd_mgbs',
      departure: t(departDay, 20, 00),
      arrival: t(arriveDay, 9, 20),
      fareInr: 890,
      polyline: p(['vizag_rtc', 'rjy_bs', 'vja_bs', 'hyd_mgbs']),
    ),
    BusService(
      id: 'svc_direct_ac',
      vehicleId: 'v_keshava_5',
      originStopId: 'vizag_rtc',
      destinationStopId: 'hyd_mgbs',
      departure: t(departDay, 21, 30),
      arrival: t(arriveDay, 8, 45),
      fareInr: 1450,
      polyline: p(['vizag_rtc', 'vja_bs', 'hyd_mgbs']),
    ),
    BusService(
      id: 'svc_vizag_vja',
      vehicleId: 'v_apsrtc_8',
      originStopId: 'vizag_rtc',
      destinationStopId: 'vja_bs',
      departure: t(departDay, 21, 00),
      arrival: t(arriveDay, 2, 40),
      fareInr: 720,
      polyline: p(['vizag_rtc', 'rjy_bs', 'vja_bs']),
      scenarioId: 'SCENARIO_CONNECTION_DELAY_01',
    ),
    BusService(
      id: 'svc_vja_hyd',
      vehicleId: 'v_orange_11',
      originStopId: 'vja_bs',
      destinationStopId: 'hyd_mgbs',
      departure: t(arriveDay, 3, 35),
      arrival: t(arriveDay, 8, 15),
      fareInr: 530,
      polyline: p(['vja_bs', 'hyd_mgbs']),
    ),
    BusService(
      id: 'svc_dwarka_bypass',
      vehicleId: 'v_orange_11',
      originStopId: 'vizag_dwarka',
      destinationStopId: 'vja_bypass',
      departure: t(departDay, 20, 40),
      arrival: t(arriveDay, 2, 20),
      fareInr: 750,
      polyline: p(['vizag_dwarka', 'vja_bypass']),
    ),
    BusService(
      id: 'svc_bypass_hyd',
      vehicleId: 'v_tsrtc_3',
      originStopId: 'vja_bypass',
      destinationStopId: 'hyd_mgbs',
      departure: t(arriveDay, 3, 30),
      arrival: t(arriveDay, 7, 55),
      fareInr: 570,
      polyline: p(['vja_bypass', 'hyd_mgbs']),
    ),
    BusService(
      id: 'svc_vizag_rjy',
      vehicleId: 'v_apsrtc_8',
      originStopId: 'vizag_rtc',
      destinationStopId: 'rjy_bs',
      departure: t(departDay, 19, 00),
      arrival: t(departDay, 23, 30),
      fareInr: 400,
      polyline: p(['vizag_rtc', 'rjy_bs']),
    ),
    BusService(
      id: 'svc_rjy_vja',
      vehicleId: 'v_apsrtc_seat',
      originStopId: 'rjy_bs',
      destinationStopId: 'vja_bs',
      departure: t(arriveDay, 0, 30),
      arrival: t(arriveDay, 3, 00),
      fareInr: 280,
      polyline: p(['rjy_bs', 'vja_bs']),
    ),
    BusService(
      id: 'svc_vja_jbs',
      vehicleId: 'v_keshava_5',
      originStopId: 'vja_bs',
      destinationStopId: 'hyd_jbs',
      departure: t(arriveDay, 4, 00),
      arrival: t(arriveDay, 8, 50),
      fareInr: 420,
      polyline: p(['vja_bs', 'hyd_jbs']),
    ),
    BusService(
      id: 'svc_recovery_bypass',
      vehicleId: 'v_apsrtc_seat',
      originStopId: 'vja_bypass',
      destinationStopId: 'hyd_mgbs',
      departure: t(arriveDay, 4, 40),
      arrival: t(arriveDay, 8, 00),
      fareInr: 780,
      polyline: p(['vja_bypass', 'hyd_mgbs']),
    ),
  ];
}
