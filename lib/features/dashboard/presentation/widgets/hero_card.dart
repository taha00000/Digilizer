import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/donut_gauge.dart';
import '../../domain/entities/dashboard_summary.dart';

/// The lead card: one big achievement number, sales/target beneath it, and the
/// 58% radial gauge on the right. Matches `.hero` in the prototype.
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: t.heroGradient,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACHIEVEMENT · MTD',
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 7),
                Text.rich(
                  TextSpan(
                    text: '${summary.achievementPct}',
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                    children: [
                      TextSpan(
                        text: '%',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _stat(context, 'Sales', summary.salesLabel),
                    const SizedBox(width: 22),
                    _stat(context, 'Target', summary.targetLabel),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          DonutGauge.progress(
            percent: summary.achievementPct.toDouble(),
            color: t.primary,
            trackColor: t.primarySoft,
            size: 92,
            thickness: 11,
            centerLabel: '${summary.achievementPct}%',
            centerCaption: 'ACH',
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: t.sub, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: t.ink,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
