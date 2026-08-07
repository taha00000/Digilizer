import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/bottom_tab_bar.dart';
import '../../../../shared/widgets/donut_gauge.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../domain/entities/team.dart';
import '../providers/team_providers.dart';
import '../widgets/product_row.dart';

/// Rep · Product Sale (`repScreen`) — one rep's achievement and the
/// brand-by-brand breakdown behind it.
class RepDetailScreen extends ConsumerWidget {
  const RepDetailScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(repDetailProvider(code));

    return AppShell(
      title: async.valueOrNull?.name ?? 'Representative',
      subtitle: async.valueOrNull == null
          ? null
          : '${async.value!.code} · ${async.value!.role}',
      tab: AppTab.team,
      onBack: () => context.go('/team'),
      onRefresh: () async {
        ref.invalidate(repDetailProvider(code));
        await ref.read(repDetailProvider(code).future);
      },
      children: [
        AsyncView<RepDetail>(
          value: async,
          onRetry: () => ref.invalidate(repDetailProvider(code)),
          loadingHeights: const [150, 70, 70, 70],
          data: (r) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RepHero(rep: r),
              SectionTitle(
                'Product-wise sale',
                trailing: SectionLink('${r.products.length} brands'),
              ),
              for (var i = 0; i < r.products.length; i++)
                ProductRow(
                  product: r.products[i],
                  // The prototype opens the leading brand by default.
                  initiallyOpen: i == 0,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RepHero extends StatelessWidget {
  const _RepHero({required this.rep});
  final RepDetail rep;

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
            color: Color(0x59000000),
            blurRadius: 36,
            offset: Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ACHIEVEMENT',
                        style: TextStyle(
                          color: t.eyebrow,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.46,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text.rich(
                        TextSpan(
                          text: '${rep.achPct}',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.14,
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
                          _stat(context, 'Sales', rep.sales, null),
                          const SizedBox(width: 16),
                          _stat(context, 'Target', rep.target, null),
                          const SizedBox(width: 16),
                          _stat(context, 'GoLY', rep.goLY, t.primaryDark),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                DonutGauge.progress(
                  percent: rep.achPct.toDouble(),
                  color: t.primary,
                  trackColor: t.primarySoft2,
                  size: 92,
                  thickness: 11,
                  centerLabel: '${rep.achPct}%',
                  centerCaption: 'ACH',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(
    BuildContext context,
    String label,
    String value,
    Color? valueColor,
  ) {
    final t = context.tokens;
    return Flexible(
      child: Column(
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
              color: valueColor ?? t.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
