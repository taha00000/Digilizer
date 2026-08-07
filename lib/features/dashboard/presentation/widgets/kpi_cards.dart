import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/donut_gauge.dart';
import '../../domain/entities/dashboard_summary.dart';

/// The `.grid2` pair of `.mcard`s under the hero.
///
/// Left card carries the five-bar sparkline (`.mcard .bars`), right card the
/// inline coverage ring (`.ring-inline`) with its two-line caption.
class KpiCardRow extends StatelessWidget {
  const KpiCardRow({super.key, required this.summary});

  final DashboardSummary summary;

  /// `.mcard .bars{height:36px}`
  static const double _barsHeight = 36;

  /// The coverage ring is `donut(..., 46, 7, '')` in the prototype.
  static const double _ringSize = 46;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MCard(
              label: 'Day to date',
              value: '${summary.dayToDatePct}%',
              delta: '▲ above target',
              // `.up{color:var(--pri)}` — cyan, not a semantic green.
              deltaColor: t.primary,
              trailing: SizedBox(
                height: _barsHeight,
                child: _Bars(values: summary.dayToDateSpark),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MCard(
              label: 'Coverage',
              value: '${summary.coveragePct}%',
              delta: '${_thousands(summary.coveredDoctors)} / '
                  '${_thousands(summary.totalDoctors)}',
              deltaColor: t.sub,
              trailing: SizedBox(
                height: _ringSize,
                child: Row(
                  children: [
                    DonutGauge.progress(
                      percent: summary.coveragePct.toDouble(),
                      color: t.info,
                      trackColor: t.infoSoft,
                      size: _ringSize,
                      thickness: 7,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'doctors\ncovered',
                        style: TextStyle(
                          color: t.sub,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _thousands(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

class _MCard extends StatelessWidget {
  const _MCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaColor,
    required this.trailing,
  });

  final String label;
  final String value;
  final String delta;
  final Color deltaColor;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: t.sub,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35, // .03em
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: t.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.44, // -.02em
            ),
          ),
          const SizedBox(height: 3),
          Text(
            delta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: deltaColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 11),
          trailing,
        ],
      ),
    );
  }
}

/// `.mcard .bars` — equal-width bars filling the card, the last highlighted.
class _Bars extends StatelessWidget {
  const _Bars({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: FractionallySizedBox(
              heightFactor: values[i].clamp(0.05, 1.0),
              alignment: Alignment.bottomCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: i == values.length - 1 ? t.primary : t.primarySoft2,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
