import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../state/roam_controller.dart';

class ConciergeScreen extends StatefulWidget {
  const ConciergeScreen({super.key});
  @override
  State<ConciergeScreen> createState() => _ConciergeScreenState();
}

class _ConciergeScreenState extends State<ConciergeScreen> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: context.read<RoamController>().inputText);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoamController>();
    final s = c.s;
    if (_text.text != c.inputText && c.transcript != null) {
      _text.text = c.inputText;
    }
    return ScreenScaffold(
      title: s.appName,
      s: s,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(s.landingTitle, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700)),
              SegmentedButton<AppLang>(
                segments: const [
                  ButtonSegment(value: AppLang.en, label: Text('EN')),
                  ButtonSegment(value: AppLang.te, label: Text('TE')),
                ],
                selected: {c.lang},
                onSelectionChanged: (v) => c.setLang(v.first),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(s.landingSub, style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted, height: 1.4)),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _text,
                  minLines: 4,
                  maxLines: 6,
                  onChanged: (v) => c.inputText = v,
                  decoration: InputDecoration(
                    hintText: s.hint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                if (c.listening)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(s.listening, style: const TextStyle(color: AppColors.sky)),
                  ),
                if (c.transcript != null) ...[
                  const Divider(),
                  Text(s.reviewTranscript, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(c.transcript!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedAction(label: s.speak, onPressed: () => c.simulateVoice())),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: s.send,
                  enabled: !c.busy,
                  onPressed: c.busy ? null : () => c.submitInput(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
