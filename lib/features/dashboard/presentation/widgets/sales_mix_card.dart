import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/donut_gauge.dart';
import '../../../../shared/widgets/seg_control.dart';
import '../../domain/entities/dashboard_summary.dart';

/// "Sales by type" card with the three views the client specifically asked
/// for: **Donut**, ranked **Bars**, and a 100% **Share** bar. Bars is the
/// default, matching the prototype.
class SalesMixCard extends StatefulWidget {
  const SalesMixCard({super.key, required this.slices});

  final List<SalesMixSlice> slices;

  @override
  State<SalesMixCard> createState() => _SalesMixCardState();
}

class _SalesMixCardState extends State<SalesMixCard> {
  int _view = 1; // 0 = donut, 1 = bars, 2 = share

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final slices = widget.slices;
    final total = slices.fold<double>(0, (a, s) => a + s.valueM);
    final totalLabel = '${total.toStringAsFixed(1)}M';

    return AppCard(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sales by type',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SegControl(
                labels: const ['Donut', 'Bars', 'Share'],
                selectedIndex: _view,
                onChanged: (i) => setState(() => _view = i),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: switch (_view) {
              0 => _DonutView(slices: slices, totalLabel: totalLabel),
              1 => _BarsView(slices: slices, totalLabel: totalLabel),
              _ => _ShareView(slices: slices, totalLabel: totalLabel),
            },
          ),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: t.sub,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.slices});
  final List<SalesMixSlice> slices;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      children: [
        for (var i = 0; i < slices.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == slices.length - 1 ? 0 : 9),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: t.series(i),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    slices[i].name,
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${slices[i].valueM}M',
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 34,
                  child: Text(
                    '${slices[i].pct}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: t.sub,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DonutView extends StatelessWidget {
  const _DonutView({required this.slices, required this.totalLabel});
  final List<SalesMixSlice> slices;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DonutGauge(
          size: 120,
          thickness: 20,
          centerLabel: totalLabel,
          centerCaption: 'total',
          centerLabelSize: 19,
          segments: [
            for (var i = 0; i < slices.length; i++)
              DonutSegment(slices[i].pct.toDouble(), t.series(i)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(child: _Legend(slices: slices)),
      ],
    );
  }
}

class _BarsView extends StatelessWidget {
  const _BarsView({required this.slices, required this.totalLabel});
  final List<SalesMixSlice> slices;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ranked = [...slices]..sort((a, b) => b.valueM.compareTo(a.valueM));
    final max = ranked.isEmpty ? 1.0 : ranked.first.valueM;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Caption('Ranked by value · total $totalLabel'),
        for (final s in ranked)
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: t.series(slices.indexOf(s)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.name,
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${s.valueM}M',
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${s.pct}%',
                      style: TextStyle(
                        color: t.sub,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LayoutBuilder(
                    builder: (context, c) => Container(
                      height: 10,
                      color: t.canvas,
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: s.valueM / max),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => Container(
                          width: c.maxWidth * v,
                          decoration: BoxDecoration(
                            color: t.series(slices.indexOf(s)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ShareView extends StatelessWidget {
  const _ShareView({required this.slices, required this.totalLabel});
  final List<SalesMixSlice> slices;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Caption('Composition · 100% of $totalLabel'),
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            height: 30,
            child: Row(
              children: [
                for (var i = 0; i < slices.length; i++)
                  Expanded(
                    flex: slices[i].pct,
                    child: Container(
                      color: t.series(i),
                      alignment: Alignment.center,
                      // Below ~9% the label no longer fits the segment.
                      child: slices[i].pct >= 9
                          ? Text(
                              '${slices[i].pct}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _Legend(slices: slices),
      ],
    );
  }
}
