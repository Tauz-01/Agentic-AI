import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/widgets.dart';
import '../domain/models.dart';
import '../state/roam_controller.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoamController>();
    final s = c.s;
    final it = c.journey!.itinerary;
    final change = c.stage == JourneyStage.demoChangeConfirmation;
    return ScreenScaffold(
      title: s.checkout,
      s: s,
      onBack: change ? c.backToRecovery : c.backToItinerary,
      footer: StickyFooter(
        child: PrimaryButton(
          label: s.pay,
          disruptive: change,
          onPressed: c.confirmDemo,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChip(label: s.noRealPay, kind: 'warn'),
                const SizedBox(height: 12),
                Text(change ? s.updated : s.itinerary, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 8),
                Text(inr.format(it.totalFareInr), style: tabular(GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700))),
                if (change && c.focusedProposal != null)
                  Text(
                    c.focusedProposal!.fareDelta >= 0
                        ? '+ ${inr.format(c.focusedProposal!.fareDelta)}'
                        : inr.format(c.focusedProposal!.fareDelta),
                    style: tabular(GoogleFonts.inter(color: AppColors.ember, fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(height: 16),
                _method('UPI (demo)'),
                _method('Card (demo — do not enter real details)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _method(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineStrong),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.radio_button_checked, color: AppColors.sky),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
