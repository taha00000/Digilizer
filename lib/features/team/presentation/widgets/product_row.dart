import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/team.dart';

/// `.exp` — an expandable product row. Collapsed it shows brand/form and
/// achievement; expanded it reveals target, sales and growth.
///
/// ```css
/// .exp{background:var(--surface);border:1px solid var(--aline);
///      border-radius:18px;margin-bottom:10px;overflow:hidden}
/// .exp .head .pf{width:36px;height:36px;border-radius:11px;
///                background:var(--info-soft);color:var(--info)}
/// .exp .head .ach{margin-left:auto;font-size:13px;font-weight:800;
///                 color:var(--pri-d)}
/// .exp.open .head .cv{transform:rotate(180deg)}
/// .exp .kv{border-top:1px solid var(--aline);padding:9px 0;font-size:12.5px}
/// ```
class ProductRow extends StatefulWidget {
  const ProductRow({
    super.key,
    required this.product,
    this.initiallyOpen = false,
  });

  final ProductSale product;
  final bool initiallyOpen;

  @override
  State<ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<ProductRow> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final p = widget.product;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: t.infoSoft,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        p.initial,
                        style: TextStyle(
                          color: t.info,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            p.brand,
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            p.form,
                            style: TextStyle(color: t.sub, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${p.achPct}%',
                      style: TextStyle(
                        color: t.primaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Opacity(
                        opacity: 0.6,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: t.sub,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // The panel is built only when open. AnimatedCrossFade would keep
            // every collapsed row's detail mounted, which costs layout on a
            // long list and makes "is it expanded?" untestable.
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _open
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: Column(
                        children: [
                          _kv(t, 'Target', p.target, '${p.targetUnits} u'),
                          _kv(t, 'Sales', p.sales, '${p.salesUnits} u'),
                          _kv(
                            t,
                            'Growth over last month',
                            '+${p.goLM}%',
                            null,
                            valueColor: t.primary,
                          ),
                          _kv(
                            t,
                            'Growth over last year',
                            '+${p.goLY}%',
                            null,
                            valueColor: t.primary,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(
    AppTokens t,
    String key,
    String value,
    String? unit, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              key,
              style: TextStyle(
                color: t.sub,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? t.ink,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (unit != null)
            Text(
              ' · $unit',
              style: TextStyle(
                color: t.sub,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
