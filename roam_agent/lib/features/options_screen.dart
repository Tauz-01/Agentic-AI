import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/widgets.dart';
import '../domain/models.dart';
import '../state/roam_controller.dart';
import 'map_view.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoamController>();
    final s = c.s;
    final feasible = c.results.where((e) => e.feasibility == Feasibility.feasible).toList();
    final misses = c.results.where((e) => e.feasibility == Feasibility.infeasible).toList();
    final preview = feasible.isNotEmpty ? feasible.first : (c.results.isNotEmpty ? c.results.first : null);
    return ScreenScaffold(
      title: s.optionsTitle,
      s: s,
      onBack: () => c.reset(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (preview != null)
            JourneyMap(catalog: c.backend.catalog, itinerary: preview, s: s),
          const SizedBox(height: 12),
          if (feasible.isEmpty)
            AppCard(child: Text(s.noneFeasible, style: GoogleFonts.inter(color: AppColors.delayText))),
          for (final it in feasible) ...[
            _OptionCard(it: it, recommended: it.recommended),
            const SizedBox(height: 12),
          ],
          if (misses.isNotEmpty) ...[
            Text(s.nearMiss, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final it in misses) ...[
              _OptionCard(it: it, recommended: false, blocked: true),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.it, required this.recommended, this.blocked = false});
  final Itinerary it;
  final bool recommended;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final c = context.read<RoamController>();
    final s = c.s;
    final origin = c.backend.catalog.stops[it.legs.first.originStopId]!;
    final dest = c.backend.catalog.stops[it.legs.last.destinationStopId]!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (recommended) StatusChip(label: s.recommended, kind: 'ok'),
              if (blocked) StatusChip(label: s.nearMiss, kind: 'warn'),
              const Spacer(),
              Text(inr.format(it.totalFareInr), style: tabular(GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _timeCol(hm.format(it.departure), origin.name),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${it.duration.inHours}h ${it.duration.inMinutes.remainder(60)}m · ${it.transfers.length} ${s.transfers}',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              _timeCol(hm.format(it.arrival), dest.name, end: true),
            ],
          ),
          const SizedBox(height: 8),
          for (final leg in it.legs)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${c.backend.catalog.operatorOf(leg.vehicleId).name} · ${c.backend.catalog.vehicles[leg.vehicleId]!.model}',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
              ),
            ),
          Text(it.explanation, style: GoogleFonts.inter(fontSize: 13, height: 1.35)),
          const SizedBox(height: 12),
          PrimaryButton(
            label: s.select,
            enabled: !blocked,
            onPressed: blocked ? null : () => c.selectOption(it),
          ),
        ],
      ),
    );
  }

  Widget _timeCol(String t, String place, {bool end = false}) {
    return SizedBox(
      width: 110,
      child: Column(
        crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(t, style: tabular(GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700))),
          Text(place, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}
