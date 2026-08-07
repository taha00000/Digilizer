import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/dashboard_summary.dart';

/// The `.chartcard` trend chart.
///
/// Built by hand rather than with fl_chart: the prototype pins the bar to 74%
/// of its column, colours the selected bar `--pri-d` against `--pri`, and
/// floats a value tip above it. Matching that through a charting library's
/// tooltip and sizing model costs more than drawing it directly.
///
/// ```css
/// .chart{align-items:flex-end;gap:10px;height:140px;padding-top:18px}
/// .col .stack{height:118px}
/// .col .barfill{width:74%;border-radius:6px 6px 0 0;background:var(--pri)}
/// .col.act .barfill{background:var(--pri-d)}
/// .col .tip{top:-12px;font-size:10.5px;font-weight:800;color:var(--aink)}
/// .col .xl{font-size:10.5px;color:var(--asub);font-weight:700}
/// ```
class TrendCard extends StatefulWidget {
  const TrendCard({super.key, required this.points});

  final List<TrendPoint> points;

  @override
  State<TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<TrendCard> {
  static const double _stackHeight = 118;
  static const double _tipHeight = 16;

  int? _selected;

  @override
  void didUpdateWidget(TrendCard old) {
    super.didUpdateWidget(old);
    // Switching 6M <-> 4Q changes the series length; drop a stale selection.
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

    // The prototype marks the most recent bar active by default.
    final active = _selected ?? points.length - 1;
    final maxValue = points.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < points.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selected = i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: _tipHeight,
                      child: i == active
                          ? FittedBox(
                              child: Text(
                                '${points[i].value.toStringAsFixed(0)}M',
                                style: TextStyle(
                                  color: t.ink,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(
                      height: _stackHeight,
                      child: FractionallySizedBox(
                        widthFactor: 0.74,
                        heightFactor:
                            (points[i].value / maxValue).clamp(0.02, 1.0),
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            color: i == active ? t.primaryDark : t.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      points[i].label,
                      style: TextStyle(
                        color: t.sub,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
