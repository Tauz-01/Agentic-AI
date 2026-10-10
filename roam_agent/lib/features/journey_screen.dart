import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/widgets.dart';
import '../domain/models.dart';
import '../state/roam_controller.dart';
import 'itinerary_screen.dart';
import 'map_view.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoamController>();
    final s = c.s;
    final j = c.journey!;
    final disrupted = j.alert != null;
    return ScreenScaffold(
      title: s.tracking,
      s: s,
      footer: disrupted
          ? StickyFooter(
              child: PrimaryButton(label: s.recovery, disruptive: true, onPressed: c.loadRecovery),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (disrupted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.emberSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.emberBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.delayBanner, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.delayText)),
                  const SizedBox(height: 6),
                  Text(
                    'Remaining transfer ${j.alert!.remainingBufferMinutes}m · required ${j.alert!.requiredBufferMinutes}m · source ${j.alert!.source}',
                    style: tabular(GoogleFonts.inter(fontSize: 13, color: AppColors.delayText)),
                  ),
                  Text(
                    'Projected interchange ${hm.format(j.alert!.projectedArrival)} (was ${hm.format(j.alert!.originalArrival)})',
                    style: tabular(GoogleFonts.inter(fontSize: 13)),
                  ),
                ],
              ),
            ),
          if (disrupted) const SizedBox(height: 12),
          JourneyMap(
            catalog: c.backend.catalog,
            itinerary: j.itinerary,
            s: s,
            vehicle: j.vehiclePosition,
            highlightLeg: 0,
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChip(label: j.stage.name, kind: disrupted ? 'warn' : 'ok'),
                const SizedBox(height: 8),
                if (j.clock != null)
                  Text('Simulated clock ${hm.format(j.clock!)}', style: tabular(GoogleFonts.inter(color: AppColors.muted))),
                const SizedBox(height: 12),
                Timeline(itinerary: j.itinerary, catalog: c.backend.catalog, clock: j.clock),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoamController>();
    final s = c.s;
    return ScreenScaffold(
      title: s.recovery,
      s: s,
      onBack: c.backToTracking,
      footer: c.focusedProposal == null
          ? null
          : StickyFooter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(label: s.approve, disruptive: true, onPressed: c.approveFocused),
                  const SizedBox(height: 8),
                  OutlinedAction(label: s.reject, onPressed: c.rejectFocused),
                ],
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (c.recoveries.isEmpty) AppCard(child: Text(s.noneFeasible)),
          for (final p in c.recoveries) ...[
            _CompareCard(p: p, selected: c.focusedProposal?.id == p.id),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard({required this.p, required this.selected});
  final RecoveryProposal p;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.read<RoamController>();
    final s = c.s;
    return GestureDetector(
      onTap: () => c.focusProposal(p),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.ember : AppColors.outline, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.reason, style: GoogleFonts.inter(fontSize: 13, height: 1.35)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _col(s.original, p.original, muted: true)),
                Expanded(child: _col(s.proposed, p.replacement)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _col(String title, Itinerary it, {bool muted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
        Text(
          hm.format(it.arrival),
          style: tabular(GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: muted ? AppColors.muted : AppColors.navy,
            decoration: muted ? TextDecoration.lineThrough : null,
          )),
        ),
        Text(inr.format(it.totalFareInr), style: tabular(GoogleFonts.inter(color: muted ? AppColors.muted : AppColors.navy))),
      ],
    );
  }
}
