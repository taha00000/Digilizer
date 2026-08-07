import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/donut_gauge.dart';
import '../../domain/entities/dashboard_summary.dart';

/// The `.hero` card from the prototype.
///
/// ```css
/// .hero{background:var(--herobg); border:1px solid var(--heroborder);
///       box-shadow:0 14px 36px rgba(0,0,0,.35); border-radius:24px; padding:20px}
/// .hero::after{right:-30px; top:-40px; width:150px; height:150px;
///              border-radius:50%; background:radial-gradient(circle,var(--glow1),transparent 70%)}
/// .hero .donut{position:absolute; right:16px; top:50%; translateY(-50%)}
/// ```
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: t.heroGradient,
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: t.heroBorder),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000), // rgba(0,0,0,.35)
            blurRadius: 36,
            offset: Offset(0, 14),
          ),
        ],
      ),
      // `.hero` is overflow:hidden, which clips the ::after orb to the card.
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ::after — soft orb bleeding off the top-right corner.
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [t.glow1, t.glow1.withValues(alpha: 0)],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
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
                          color: t.eyebrow,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.46, // .04em
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
                            letterSpacing: -1.14, // -.03em
                            height: 1,
                          ),
                          children: [
                            TextSpan(
                              text: '%',
                              style: TextStyle(
                                color: t.primaryDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Flexible(
                            child: _stat(context, 'Sales', summary.salesLabel),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child:
                                _stat(context, 'Target', summary.targetLabel),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                DonutGauge.progress(
                  percent: summary.achievementPct.toDouble(),
                  color: t.primary,
                  trackColor: t.primarySoft2,
                  size: 92,
                  thickness: 11,
                  centerLabel: '${summary.achievementPct}%',
                  centerCaption: 'ACH',
                ),
              ],
            ),
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
        Text(
          label,
          style: TextStyle(
            color: t.sub,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
