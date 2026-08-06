import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Colour-coded pill badge. The prototype uses three tones:
/// green (`g`) at >= 100, amber (`a`) at >= 50, rose (`r`) below that.
enum BadgeTone { good, warn, bad }

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, required this.tone});

  final String label;
  final BadgeTone tone;

  /// The prototype's GoLY thresholds, kept in one place so the table and any
  /// future screens grade growth identically.
  factory StatusBadge.growth(int pct, {Key? key}) {
    final tone = pct >= 100
        ? BadgeTone.good
        : pct >= 50
            ? BadgeTone.warn
            : BadgeTone.bad;
    return StatusBadge('+$pct%', key: key, tone: tone);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (bg, fg) = switch (tone) {
      BadgeTone.good => (t.primarySoft, t.primaryDark),
      BadgeTone.warn => (t.warnSoft, t.warn),
      BadgeTone.bad => (t.roseSoft, t.rose),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
