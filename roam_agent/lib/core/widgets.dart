import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'l10n.dart';
import 'theme.dart';

final inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final hm = DateFormat('HH:mm');
final day = DateFormat('EEE d MMM');

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key, required this.s});
  final S s;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.demoFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineStrong),
      ),
      child: Text(
        s.demoBadge,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.muted),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.kind = 'info'});
  final String label;
  final String kind;
  @override
  Widget build(BuildContext context) {
    final bg = switch (kind) {
      'ok' => AppColors.successSoft,
      'warn' => AppColors.emberSoft,
      _ => AppColors.skySoft,
    };
    final bd = switch (kind) {
      'ok' => AppColors.successBorder,
      'warn' => AppColors.emberBorder,
      _ => AppColors.skyBorder,
    };
    final fg = switch (kind) {
      'ok' => AppColors.successText,
      'warn' => AppColors.delayText,
      _ => const Color(0xFF0369A1),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.disruptive = false,
    this.enabled = true,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool disruptive;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: disruptive ? AppColors.ember : AppColors.navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

class OutlinedAction extends StatelessWidget {
  const OutlinedAction({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.outlineStrong, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [
          BoxShadow(color: Color(0x0F0F172A), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class StickyFooter extends StatelessWidget {
  const StickyFooter({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
        boxShadow: [BoxShadow(color: Color(0x1F0F172A), blurRadius: 24, offset: Offset(0, -4))],
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.title,
    required this.s,
    required this.body,
    this.footer,
    this.onBack,
  });
  final String title;
  final S s;
  final Widget body;
  final Widget? footer;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: onBack == null ? null : IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: Text(title),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12), child: Center(child: DemoBanner(s: s))),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: body),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}
