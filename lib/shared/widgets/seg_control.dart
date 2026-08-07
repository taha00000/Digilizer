import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The prototype ships two segmented-control looks, and they are not
/// interchangeable:
///
/// * [SegStyle.plain] — `.seg`, used for the trend 6M/4Q toggle. Selected chip
///   is `--surface` with `--aink` text and a soft shadow, so it reads as a
///   raised tab.
/// * [SegStyle.brand] — `.mixhead .seg`, used inside the Sales-mix card.
///   Selected chip is solid `--pri` with white text, and the tray is outlined.
enum SegStyle { plain, brand }

class SegControl extends StatelessWidget {
  const SegControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.style = SegStyle.plain,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final SegStyle style;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final brand = style == SegStyle.brand;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.canvas,
        border: brand ? Border.all(color: t.line) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: brand ? 11 : 13,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: i == selectedIndex
                      ? (brand ? t.primary : t.surface)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: i == selectedIndex && !brand
                      ? const [
                          BoxShadow(
                            color: Color(0x1A000000), // rgba(0,0,0,.10)
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: brand ? 11 : 11.5,
                    fontWeight: FontWeight.w700,
                    color: i == selectedIndex
                        ? (brand ? Colors.white : t.ink)
                        : t.sub,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
