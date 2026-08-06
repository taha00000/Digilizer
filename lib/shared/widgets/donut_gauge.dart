import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// One slice of a [DonutGauge].
class DonutSegment {
  const DonutSegment(this.value, this.color);
  final double value;
  final Color color;
}

/// The radial donut used by the hero achievement card, the coverage ring and
/// the Sales-mix donut view. Renders an fl_chart [PieChart] with a hollow
/// centre and an optional label/caption stacked in the middle.
///
/// Sweep starts at 12 o'clock and runs clockwise, matching the prototype.
class DonutGauge extends StatelessWidget {
  const DonutGauge({
    super.key,
    required this.segments,
    this.size = 92,
    this.thickness = 11,
    this.centerLabel,
    this.centerCaption,
    this.centerLabelSize,
  });

  final List<DonutSegment> segments;
  final double size;
  final double thickness;
  final String? centerLabel;
  final String? centerCaption;
  final double? centerLabelSize;

  /// A two-segment gauge showing [percent] filled against a muted remainder.
  factory DonutGauge.progress({
    Key? key,
    required double percent,
    required Color color,
    required Color trackColor,
    double size = 92,
    double thickness = 11,
    String? centerLabel,
    String? centerCaption,
    double? centerLabelSize,
  }) {
    final filled = percent.clamp(0.0, 100.0);
    return DonutGauge(
      key: key,
      segments: [
        DonutSegment(filled, color),
        DonutSegment(100 - filled, trackColor),
      ],
      size: size,
      thickness: thickness,
      centerLabel: centerLabel,
      centerCaption: centerCaption,
      centerLabelSize: centerLabelSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // Guard against an all-zero dataset, which fl_chart cannot lay out.
    final total = segments.fold<double>(0, (a, s) => a + s.value);
    final data = total <= 0
        ? [DonutSegment(1, t.line)]
        : segments.where((s) => s.value > 0).toList();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: (size / 2) - thickness,
              pieTouchData: PieTouchData(enabled: false),
              sections: [
                for (final s in data)
                  PieChartSectionData(
                    value: s.value,
                    color: s.color,
                    radius: thickness,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          if (centerLabel != null || centerCaption != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (centerLabel != null)
                  Text(
                    centerLabel!,
                    style: TextStyle(
                      color: t.ink,
                      fontSize: centerLabelSize ?? size * 0.21,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                if (centerCaption != null)
                  Text(
                    centerCaption!,
                    style: TextStyle(
                      color: t.sub,
                      fontSize: size * 0.10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
