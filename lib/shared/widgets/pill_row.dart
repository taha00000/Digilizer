import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Horizontally scrolling period filter pills
/// (`This month / Day / YTD / vs LY`). Selection is presentation-only for now;
/// when the real API lands the selected period becomes a query parameter on
/// the dashboard request.
class PillRow extends StatelessWidget {
  const PillRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final on = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: on ? t.ink : t.surface,
                border: Border.all(color: on ? t.ink : t.line),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: on ? t.canvas : t.sub,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
