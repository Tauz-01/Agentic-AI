import 'package:uuid/uuid.dart';

import '../core/l10n.dart';
import '../domain/models.dart';
import 'catalog.dart';

class IntentExtractor {
  IntentExtractor(this.catalog, {DateTime? now}) : now = now ?? DateTime(2026, 10, 10, 15, 50);
  final Catalog catalog;
  final DateTime now;
  final _uuid = const Uuid();

  AppLang detectLanguage(String text) {
    final telugu = RegExp(r'[\u0C00-\u0C7F]');
    return telugu.hasMatch(text) ? AppLang.te : AppLang.en;
  }

  ParseResult extract(String text, {required String sessionId, AppLang? preferred}) {
    final lang = preferred ?? detectLanguage(text);
    final intent = TripIntent(tripId: 'trip_${_uuid.v4().substring(0, 8)}', language: lang);
    final lower = text.toLowerCase();

    City? origin;
    City? dest;
    for (final city in catalog.cities.values) {
      for (final a in [...city.aliases, city.name.toLowerCase()]) {
        if (lower.contains(a.toLowerCase()) || text.contains(a)) {
          origin ??= city;
          if (origin.id != city.id) dest ??= city;
        }
      }
    }
    // Prefer Vizag as origin and Hyd as dest when both present (demo corridor).
    final vizag = _find('vizag', text);
    final hyd = _find('hyd', text);
    if (vizag != null && hyd != null) {
      origin = vizag;
      dest = hyd;
    }
    if (origin != null) {
      intent.originCityId = origin.id;
      intent.originLabel = origin.name;
    }
    if (dest != null) {
      intent.destinationCityId = dest.id;
      intent.destinationLabel = dest.name;
    }

    if (RegExp(r'tomorrow|రేపు').hasMatch(lower) || text.contains('రేపు')) {
      final d = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      intent.travelDate = d;
    } else {
      final m = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(text);
      if (m != null) {
        intent.travelDate = DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
      }
    }

    final timeMatch = RegExp(
      r'(?:before|by|లోపు)?\s*(\d{1,2})\s*(?::(\d{2}))?\s*(am|pm)?',
      caseSensitive: false,
    ).firstMatch(lower);
    final teTime = RegExp(r'(\d{1,2})\s*గంట').firstMatch(text);
    if (intent.travelDate != null && (timeMatch != null || teTime != null || text.contains('9'))) {
      var hour = 9;
      var minute = 0;
      if (timeMatch != null) {
        hour = int.parse(timeMatch[1]!);
        minute = int.tryParse(timeMatch[2] ?? '') ?? 0;
        final ap = timeMatch[3]?.toLowerCase();
        if (ap == 'pm' && hour < 12) hour += 12;
        if (ap == 'am' && hour == 12) hour = 0;
      } else if (teTime != null) {
        hour = int.parse(teTime[1]!);
      }
      intent.arrivalDeadline = DateTime(
        intent.travelDate!.year,
        intent.travelDate!.month,
        intent.travelDate!.day,
        hour,
        minute,
      );
    }

    final compact = text.replaceAll(',', '');
    final budget = RegExp(
      r'(?:₹|rs\.?|inr|budget|బడ్జెట్)\s*:?\s*([0-9]{3,6})',
      caseSensitive: false,
    ).firstMatch(compact);
    if (budget != null) {
      intent.maxBudgetInr = int.parse(budget[1]!);
    }

    final pax = RegExp(r'(\d+)\s*(traveler|passenger|people|వ్యక్తి)', caseSensitive: false).firstMatch(lower);
    if (pax != null) {
      intent.travelers = int.parse(pax[1]!);
    }

    if (RegExp(r'ac sleeper|ఏసీ స్లీపర్|ఎసి స్లీపర్', caseSensitive: false).hasMatch(text)) {
      intent.coachPreference = 'AC sleeper';
    } else if (RegExp(r'no (coach )?preference|ఏ కోచ్ అయినా').hasMatch(lower)) {
      intent.coachPreference = 'none';
    }

    if (RegExp(r'single berth|సింగిల్').hasMatch(lower) || text.contains('సింగిల్')) {
      intent.berthPreference = 'single';
    } else if (RegExp(r'no berth preference|బెర్త్ పర్వాలేదు').hasMatch(lower)) {
      intent.berthPreference = 'none';
    }

    final buf = RegExp(r'(\d+)\s*(?:min)?(?:ute)?s?\s*(?:transfer|buffer|ట్రాన్స్)').firstMatch(lower);
    if (buf != null) {
      intent.minimumTransferMinutes = int.parse(buf[1]!);
    }

    return ParseResult(intent: intent, missing: missingFields(intent), language: lang);
  }

  City? _find(String id, String text) {
    final city = catalog.cities[id];
    if (city == null) return null;
    final lower = text.toLowerCase();
    for (final a in city.aliases) {
      if (lower.contains(a.toLowerCase()) || text.contains(a)) return city;
    }
    return null;
  }

  static const requiredKeys = [
    'origin',
    'destination',
    'travelDate',
    'arrivalDeadline',
    'travelers',
    'maxBudgetINR',
    'coachPreference',
    'berthPreference',
    'minimumTransferMinutes',
  ];

  List<String> missingFields(TripIntent i) {
    final m = <String>[];
    if (i.originCityId == null) m.add('origin');
    if (i.destinationCityId == null) m.add('destination');
    if (i.travelDate == null) m.add('travelDate');
    if (i.arrivalDeadline == null) m.add('arrivalDeadline');
    if (i.travelers == null) m.add('travelers');
    if (i.maxBudgetInr == null) m.add('maxBudgetINR');
    if (i.coachPreference == null) m.add('coachPreference');
    if (i.berthPreference == null) m.add('berthPreference');
    if (i.minimumTransferMinutes == null) m.add('minimumTransferMinutes');
    return m;
  }
}

class ConstraintValidator {
  ConstraintValidator(this.catalog);
  final Catalog catalog;

  List<String> validate(TripIntent i) {
    final errors = IntentExtractor(catalog).missingFields(i);
    if (i.originCityId != null && !catalog.cities.containsKey(i.originCityId)) {
      errors.add('origin_unknown');
    }
    if (i.destinationCityId != null && !catalog.cities.containsKey(i.destinationCityId)) {
      errors.add('destination_unknown');
    }
    if (i.maxBudgetInr != null && i.maxBudgetInr! < 0) errors.add('budget_invalid');
    if (i.travelers != null && i.travelers! < 1) errors.add('travelers_invalid');
    if (i.minimumTransferMinutes != null && i.minimumTransferMinutes! < 0) {
      errors.add('buffer_invalid');
    }
    if (i.originCityId != null && i.destinationCityId != null && i.originCityId == i.destinationCityId) {
      errors.add('same_city');
    }
    return errors;
  }
}

class ClarificationCopy {
  static String question(String field, AppLang lang) {
    final te = lang == AppLang.te;
    return switch (field) {
      'origin' => te ? 'మీరు ఎక్కడ నుంచి బయలుదేరుతారు?' : 'Where are you departing from?',
      'destination' => te ? 'మీ గమ్యం ఏది?' : 'What is your destination city?',
      'travelDate' => te ? 'ప్రయాణ తేదీ ఏది?' : 'What is your travel / arrival date?',
      'arrivalDeadline' => te ? 'ఎప్పటిలోపు చేరాలి?' : 'What is your latest arrival time?',
      'travelers' => te ? 'ఎంతమంది ప్రయాణికులు?' : 'How many travelers?',
      'maxBudgetINR' => te ? 'గరిష్ట బడ్జెట్ ఎంత (₹)?' : 'What is your maximum total budget (₹)?',
      'coachPreference' => te
          ? 'కోచ్ ప్రాధాన్యం? (AC sleeper / none)'
          : 'Coach preference? (AC sleeper or none)',
      'berthPreference' => te ? 'బెర్త్ ప్రాధాన్యం? (single / none)' : 'Berth preference? (single or none)',
      'minimumTransferMinutes' => te
          ? 'కనీస ట్రాన్స్‌ఫర్ బఫర్ నిమిషాలు?'
          : 'Minimum transfer buffer in minutes?',
      _ => te ? 'దయచేసి ఈ వివరం ఇవ్వండి.' : 'Please provide this detail.',
    };
  }
}
