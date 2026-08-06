import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/dashboard_summary.dart';

enum _BrandSort { name, sales, ach, goly }

/// Top-brands table: tap a column header to sort, inline value bars on the
/// Sales column, and colour-coded GoLY growth badges.
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
        // Names read best A→Z; every numeric column reads best high→low.
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

    // Colour follows the brand's rank in the original (unsorted) list so a
    // brand keeps its colour no matter how the table is sorted.
    Color colorFor(BrandRow r) => t.series(widget.brands.indexOf(r));

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _header('Brand', _BrandSort.name, flex: 3),
                _header('Sales', _BrandSort.sales, flex: 3),
                _header('Ach', _BrandSort.ach, flex: 2),
                _header('GoLY', _BrandSort.goly, flex: 2),
              ],
            ),
          ),
          for (final r in rows) ...[
            Divider(height: 1, color: t.line),
            InkWell(
              onTap: widget.onRowTap == null
                  ? null
                  : () => widget.onRowTap!.call(r),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorFor(r),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              r.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              borderRadius: BorderRadius.circular(4),
                              child: LayoutBuilder(
                                builder: (context, c) => Container(
                                  height: 5,
                                  color: t.canvas,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: c.maxWidth * (r.salesM / maxSales),
                                    decoration: BoxDecoration(
                                      color: colorFor(r),
                                      borderRadius: BorderRadius.circular(4),
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
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusBadge.growth(r.golyPct),
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

  Widget _header(String label, _BrandSort key, {required int flex}) {
    final t = context.tokens;
    final active = _key == key;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => _sortBy(key),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? t.ink : t.sub,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 3),
            if (active)
              Icon(
                _descending ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                size: 16,
                color: t.primary,
              ),
          ],
        ),
      ),
    );
  }
}
