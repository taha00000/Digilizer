import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/dashboard_summary.dart';

enum _BrandSort { name, sales, ach, goly }

/// The `.tablecard` top-brands table.
///
/// ```css
/// .tablecard{background:var(--surface);border:1px solid var(--aline);
///            border-radius:20px;overflow:hidden}
/// .tablecard .th{padding:13px 15px;background:var(--pri-soft);
///                border-bottom:1px solid var(--aline);font-size:10.5px;
///                font-weight:800;text-transform:uppercase;color:var(--pri-d)}
/// .th .c,.trow .c{flex:1;text-align:right}
/// .th .c.first,.trow .c.first{flex:1.5;text-align:left}
/// ```
///
/// Flex 1.5 : 1 : 1 : 1 is expressed as 3 : 2 : 2 : 2 since Flutter's flex is
/// an int.
class BrandTable extends StatefulWidget {
  const BrandTable({super.key, required this.brands, this.onRowTap});

  final List<BrandRow> brands;
  final ValueChanged<BrandRow>? onRowTap;

  @override
  State<BrandTable> createState() => _BrandTableState();
}

class _BrandTableState extends State<BrandTable> {
  _BrandSort _key = _BrandSort.sales;
  bool _descending = true;

  void _sortBy(_BrandSort key) {
    setState(() {
      if (_key == key) {
        _descending = !_descending;
      } else {
        _key = key;
        // Names read best A-Z; every numeric column reads best high-low.
        _descending = key != _BrandSort.name;
      }
    });
  }

  int _compare(BrandRow a, BrandRow b) => switch (_key) {
        _BrandSort.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        _BrandSort.sales => a.salesM.compareTo(b.salesM),
        _BrandSort.ach => a.achPct.compareTo(b.achPct),
        _BrandSort.goly => a.golyPct.compareTo(b.golyPct),
      };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rows = [...widget.brands]
      ..sort((a, b) => _compare(a, b) * (_descending ? -1 : 1));
    final maxSales = widget.brands.isEmpty
        ? 1.0
        : widget.brands.map((b) => b.salesM).reduce((a, b) => a > b ? a : b);

    // Colour follows a brand's position in the source list, so it keeps its
    // colour however the table is sorted.
    Color colorFor(BrandRow r) => t.series(widget.brands.indexOf(r));

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _header(t),
          for (var i = 0; i < rows.length; i++)
            _row(
              t,
              rows[i],
              colorFor(rows[i]),
              maxSales,
              isLast: i == rows.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _header(AppTokens t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: t.primarySoft,
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        children: [
          _headerCell(t, 'Brand', _BrandSort.name, flex: 3, first: true),
          _headerCell(t, 'Sales', _BrandSort.sales, flex: 2),
          _headerCell(t, 'Ach', _BrandSort.ach, flex: 2),
          _headerCell(t, 'GoLY', _BrandSort.goly, flex: 2),
        ],
      ),
    );
  }

  Widget _headerCell(
    AppTokens t,
    String label,
    _BrandSort key, {
    required int flex,
    bool first = false,
  }) {
    final active = _key == key;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => _sortBy(key),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment:
              first ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                label.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: t.primaryDark,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.32, // .03em
                ),
              ),
            ),
            if (active)
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Opacity(
                  opacity: 0.7,
                  child: Text(
                    _descending ? '▼' : '▲',
                    style: TextStyle(color: t.primaryDark, fontSize: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    AppTokens t,
    BrandRow r,
    Color color,
    double maxSales, {
    required bool isLast,
  }) {
    return InkWell(
      onTap: widget.onRowTap == null ? null : () => widget.onRowTap!.call(r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            // Brand — dot + name, left aligned, weight 800.
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      r.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Sales — value right aligned with the inline bar beneath it.
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${r.salesM}M',
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(
                        height: 5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: t.canvas),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              // heightFactor is required: Align hands down a
                              // loose height, so without it the childless
                              // DecoratedBox collapses to zero and the fill
                              // never paints.
                              heightFactor: 1,
                              widthFactor:
                                  (r.salesM / maxSales).clamp(0.0, 1.0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${r.achPct}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: t.ink,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: StatusBadge.growth(r.golyPct),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
