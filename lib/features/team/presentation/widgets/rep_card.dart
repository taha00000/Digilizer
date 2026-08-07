import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/team.dart';

/// `.repcard` — a rep's achievement bar with sales/target/GoLM/GoLY beneath.
///
/// ```css
/// .repcard{background:var(--surface);border:1px solid var(--aline);
///          border-radius:18px;padding:14px;margin-bottom:11px}
/// .repcard .pf{width:40px;height:40px;border-radius:12px;
///              background:var(--pri-soft);color:var(--pri-d);font-weight:800}
/// .repcard .achip{margin-left:auto;font-size:11px;font-weight:800;
///                 padding:5px 10px;border-radius:999px}
/// .repcard .track{height:8px;border-radius:8px;background:var(--canvas)}
/// .repcard .mini b{color:var(--aink);font-weight:800;font-size:12.5px}
/// ```
class RepCard extends StatelessWidget {
  const RepCard({super.key, required this.member, this.onTap});

  final TeamMember member;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    // Grading maps onto the same soft/text pairs the badges use.
    final (barColor, chipBg) = switch (member.tone) {
      AchievementTone.good => (t.primaryDark, t.primarySoft),
      AchievementTone.watch => (t.warnText, t.warnSoft),
      AchievementTone.behind => (t.roseText, t.roseSoft),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: t.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        member.initials,
                        style: TextStyle(
                          color: t.primaryDark,
                          fontSize: 14,
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
                            member.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${member.role} · ${member.code}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: t.sub, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${member.achPct}% ACH',
                        style: TextStyle(
                          color: barColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: t.canvas),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          heightFactor: 1,
                          widthFactor: (member.achPct / 100).clamp(0.0, 1.0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    _mini(context, 'Sales', member.sales),
                    _mini(context, 'Target', member.target),
                    _mini(context, 'GoLM', member.goLM),
                    _mini(context, 'GoLY', member.goLY),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mini(BuildContext context, String label, String value) {
    final t = context.tokens;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(color: t.sub, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: t.ink,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
