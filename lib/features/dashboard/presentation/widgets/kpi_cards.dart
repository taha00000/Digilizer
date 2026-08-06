import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/donut_gauge.dart';
import '../../domain/entities/dashboard_summary.dart';

/// The `Day to date` + `Coverage` pair. Both carry the inline micro-viz the
/// prototype shows: a five-bar sparkline on the left card, a small ring on the
/// right.
class KpiCardRow extends StatelessWidget {
  const KpiCardRow({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _KpiCard(
              label: 'Day to date',
              value: '${summary.dayToDatePct}%',
              delta: '▲ above target',
              deltaColor: t.good,
              trailing: _Sparkline(
                values: summary.dayToDateSpark,
                height: _KpiCard.trailingHeight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _KpiCard(
              label: 'Coverage',
              value: '${summary.coveragePct}%',
              delta: '${_thousands(summary.coveredDoctors)} / '
                  '${_thousands(summary.totalDoctors)}',
              deltaColor: t.sub,
              trailing: Align(
                alignment: Alignment.centerLeft,
                child: DonutGauge.progress(
                  percent: summary.coveragePct.toDouble(),
                  color: t.primary,
                  trackColor: t.primarySoft,
                  size: 40,
                  thickness: 5.5,
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

class _KpiCard extends StatelessWidget {
  const _KpiCard({
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

  /// Height reserved for the inline micro-viz under each KPI value.
  static const double trailingHeight = 40;

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
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: t.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            delta,
            style: TextStyle(
              color: deltaColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(height: trailingHeight, child: trailing),
        ],
      ),
    );
  }
}

/// Five small bars; the last one is highlighted as the current period.
///
/// Heights are computed from [height] rather than a LayoutBuilder on purpose:
/// this sits inside an [IntrinsicHeight], which cannot measure through a
/// LayoutBuilder and throws during layout if one is present.
class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.values, required this.height});

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Container(
            width: 7,
            height: (height * values[i].clamp(0.0, 1.0)).clamp(4.0, height),
            decoration: BoxDecoration(
              color: i == values.length - 1 ? t.primary : t.primarySoft,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ],
    );
  }
}
