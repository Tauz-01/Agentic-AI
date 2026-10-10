import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/widgets.dart';
import '../domain/models.dart';
import '../state/roam_controller.dart';
import 'map_view.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoamController>();
    final s = c.s;
    final it = c.selected!;
    return ScreenScaffold(
      title: s.itinerary,
      s: s,
      onBack: c.backToOptions,
      footer: StickyFooter(
        child: PrimaryButton(label: s.checkout, onPressed: c.openCheckout),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          JourneyMap(catalog: c.backend.catalog, itinerary: it, s: s, height: 240),
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              children: [
                Text(inr.format(it.totalFareInr), style: tabular(GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700))),
                const Spacer(),
                Text(
                  it.legs.map((l) => '₹${l.fareInr}').join(' + '),
                  style: tabular(GoogleFonts.inter(color: AppColors.muted)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(child: Timeline(itinerary: it, catalog: c.backend.catalog)),
        ],
      ),
    );
  }
}

class Timeline extends StatelessWidget {
  const Timeline({super.key, required this.itinerary, required this.catalog, this.clock});
  final Itinerary itinerary;
  final dynamic catalog;
  final DateTime? clock;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < itinerary.legs.length; i++) {
      final leg = itinerary.legs[i];
      final v = catalog.vehicles[leg.vehicleId];
      final op = catalog.operatorOf(leg.vehicleId);
      children.add(_node(
        hm.format(leg.departure),
        catalog.stops[leg.originStopId].name,
        '${op.name} · ${v.model} · ${v.ageYears}y · ₹${leg.fareInr}',
        done: clock != null && !clock!.isBefore(leg.departure),
      ));
      if (i < itinerary.transfers.length) {
        final x = itinerary.transfers[i];
        children.add(_node(
          '${x.availableMinutes}m',
          '${catalog.stops[x.fromStopId].name} → ${catalog.stops[x.toStopId].name}',
          'Walk ${x.walkMinutes}m · required buffer ${x.requiredMinutes}m',
          transfer: true,
        ));
      }
      children.add(_node(
        hm.format(leg.arrival),
        catalog.stops[leg.destinationStopId].name,
        'ETA',
        done: clock != null && !clock!.isBefore(leg.arrival),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _node(String time, String title, String sub, {bool done = false, bool transfer = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: done ? AppColors.success : (transfer ? AppColors.ember : AppColors.sky),
                  shape: BoxShape.circle,
                  border: done ? null : Border.all(color: AppColors.sky, width: 2),
                ),
              ),
              Container(width: 2, height: 36, color: AppColors.outline),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: tabular(GoogleFonts.inter(fontWeight: FontWeight.w700))),
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(sub, style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
