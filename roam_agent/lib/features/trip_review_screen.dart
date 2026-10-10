import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/intent_and_validate.dart';
import '../state/roam_controller.dart';

class TripReviewScreen extends StatefulWidget {
  const TripReviewScreen({super.key});
  @override
  State<TripReviewScreen> createState() => _TripReviewScreenState();
}

class _TripReviewScreenState extends State<TripReviewScreen> {
  late final origin = TextEditingController();
  late final dest = TextEditingController();
  late final date = TextEditingController();
  late final deadline = TextEditingController();
  late final pax = TextEditingController();
  late final budget = TextEditingController();
  late final coach = TextEditingController();
  late final berth = TextEditingController();
  late final buffer = TextEditingController();

  @override
  void initState() {
    super.initState();
    final i = context.read<RoamController>().intent;
    origin.text = i?.originLabel ?? '';
    dest.text = i?.destinationLabel ?? '';
    date.text = i?.travelDate == null ? '' : i!.travelDate!.toIso8601String().substring(0, 10);
    deadline.text = i?.arrivalDeadline == null
        ? ''
        : '${i!.arrivalDeadline!.hour.toString().padLeft(2, '0')}:${i.arrivalDeadline!.minute.toString().padLeft(2, '0')}';
    pax.text = '${i?.travelers ?? ''}';
    budget.text = '${i?.maxBudgetInr ?? ''}';
    coach.text = i?.coachPreference ?? '';
    berth.text = i?.berthPreference ?? '';
    buffer.text = '${i?.minimumTransferMinutes ?? ''}';
  }

  @override
  void dispose() {
    origin.dispose();
    dest.dispose();
    date.dispose();
    deadline.dispose();
    pax.dispose();
    budget.dispose();
    coach.dispose();
    berth.dispose();
    buffer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoamController>();
    final s = c.s;
    return ScreenScaffold(
      title: s.reviewTitle,
      s: s,
      onBack: c.reset,
      footer: StickyFooter(
        child: PrimaryButton(
          label: s.searchRoutes,
          enabled: !c.busy,
          onPressed: () {
            c.patchIntent(
              origin: origin.text,
              destination: dest.text,
              date: date.text,
              deadline: deadline.text,
              travelers: pax.text,
              budget: budget.text,
              coach: coach.text.isEmpty ? 'none' : coach.text,
              berth: berth.text.isEmpty ? 'none' : berth.text,
              buffer: buffer.text,
            );
            c.search();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusChip(label: 'AI Concierge Extraction', kind: 'info'),
                const SizedBox(height: 8),
                Text(c.inputText, style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (c.missing.isNotEmpty)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.missing, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.delayText)),
                  const SizedBox(height: 8),
                  for (final q in c.clarificationQuestions())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $q', style: GoogleFonts.inter(fontSize: 13)),
                    ),
                  const SizedBox(height: 8),
                  OutlinedAction(
                    label: c.lang == AppLang.te ? 'మిగిలిన ఫీల్డ్‌లకు డెమో విలువలు' : 'Fill remaining demo defaults',
                    onPressed: () {
                      if (pax.text.isEmpty) pax.text = '1';
                      if (buffer.text.isEmpty) buffer.text = '45';
                      if (berth.text.isEmpty) berth.text = 'none';
                      if (coach.text.isEmpty) coach.text = 'AC sleeper';
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                _f(s.origin, origin),
                _f(s.destination, dest),
                _f(s.date, date, hint: 'YYYY-MM-DD'),
                _f(s.deadline, deadline, hint: 'HH:mm'),
                _f(s.travelers, pax),
                _f(s.budget, budget),
                _f(s.coach, coach, hint: 'AC sleeper or none'),
                _f(s.berth, berth, hint: 'single or none'),
                _f(s.buffer, buffer, hint: '45'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.constraints, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  ClarificationCopy.question('minimumTransferMinutes', c.lang == AppLang.te ? AppLang.te : AppLang.en),
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _f(String label, TextEditingController ctrl, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}
