import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Sales trend bar chart. Tapping a bar selects it (the prototype's `.act`
/// column) and surfaces the value; the 6M / 4Q toggle lives in the section
/// header and is passed in via [points].
class TrendCard extends StatefulWidget {
  const TrendCard({super.key, required this.points});

  final List<TrendPoint> points;

  @override
  State<TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<TrendCard> {
  int? _selected;

  @override
  void didUpdateWidget(TrendCard old) {
    super.didUpdateWidget(old);
    // Switching 6M ↔ 4Q changes the series length; drop a stale selection.
    if (old.points.length != widget.points.length) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final points = widget.points;

    if (points.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No trend data for this period.',
            style: TextStyle(color: t.sub, fontSize: 12.5),
          ),
        ),
      );
    }

    // Default the highlight to the most recent bar, as the prototype does.
    final active = _selected ?? points.length - 1;
    final maxValue = points.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
      child: SizedBox(
        height: 178,
        child: BarChart(
          BarChartData(
            maxY: maxValue * 1.25,
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => t.ink,
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                  '${rod.toY.toStringAsFixed(0)}M',
                  TextStyle(
                    color: t.canvas,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
              touchCallback: (event, response) {
                if (!event.isInterestedForInteractions ||
                    response?.spot == null) {
                  return;
                }
                setState(() {
                  _selected = response!.spot!.touchedBarGroupIndex;
                });
              },
            ),
            titlesData: FlTitlesData(
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= points.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        points[i].label,
                        style: TextStyle(
                          color: i == active ? t.ink : t.sub,
                          fontSize: 10.5,
                          fontWeight:
                              i == active ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < points.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: points[i].value,
                      width: points.length > 5 ? 18 : 26,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: i == active
                            ? t.gradient
                            : [t.primarySoft, t.primarySoft],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
