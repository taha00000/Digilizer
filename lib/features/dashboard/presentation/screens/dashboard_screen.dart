import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/bottom_tab_bar.dart';
import '../../../../shared/widgets/pill_row.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/seg_control.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/brand_table.dart';
import '../widgets/hero_card.dart';
import '../widgets/kpi_cards.dart';
import '../widgets/sales_mix_card.dart';
import '../widgets/trend_card.dart';

/// Main dashboard — the home screen from the approved prototype: period pills,
/// hero achievement card with gauge, KPI pair, interactive trend, sales-mix
/// card with Donut/Bars/Share, sortable top-brands table and today's calls.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _trendView = 0; // 0 = 6M, 1 = 4Q

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(dashboardSummaryProvider);
    final session = ref.watch(currentSessionProvider);
    final period = ref.watch(dashboardPeriodProvider);

    return AppShell(
      title: 'Good morning',
      subtitle: session == null
          ? '—'
          : '${session.displayName.split(' ').first} · ${session.company} · '
              'ACC ${session.accountCode}',
      tab: AppTab.home,
      onRefresh: () async {
        ref.invalidate(dashboardSummaryProvider);
        await ref.read(dashboardSummaryProvider.future);
      },
      children: [
        PillRow(
          labels: DashboardPeriod.values.map((p) => p.label).toList(),
          selectedIndex: DashboardPeriod.values.indexOf(period),
          onChanged: (i) => ref.read(dashboardPeriodProvider.notifier).state =
              DashboardPeriod.values[i],
        ),
        const SizedBox(height: 14),
        AsyncView<DashboardSummary>(
          value: async,
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
          loadingHeights: const [150, 130, 200, 240],
          data: (s) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeroCard(summary: s),
              const SizedBox(height: 12),
              KpiCardRow(summary: s),
              SectionTitle(
                'Sales trend',
                trailing: SegControl(
                  labels: const ['6M', '4Q'],
                  selectedIndex: _trendView,
                  onChanged: (i) => setState(() => _trendView = i),
                ),
              ),
              TrendCard(
                points: _trendView == 0 ? s.trendMonthly : s.trendQuarterly,
              ),
              SectionTitle(
                'Sales mix',
                trailing: SectionLink(
                  'Reports',
                  onTap: () => context.go('/reports'),
                ),
              ),
              SalesMixCard(slices: s.salesMix),
              SectionTitle(
                'Top brands',
                trailing: SectionLink(
                  'Details',
                  onTap: () => context.go('/team'),
                ),
              ),
              BrandTable(brands: s.topBrands),
              SectionTitle(
                "Today's calls",
                trailing: SectionLink(
                  'Open',
                  onTap: () => context.go('/calls'),
                ),
              ),
              _CallsRow(calls: s.calls),
            ],
          ),
        ),
      ],
    );
  }
}

class _CallsRow extends StatelessWidget {
  const _CallsRow({required this.calls});
  final CallsSummary calls;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLANNED DONE',
                    style: TextStyle(
                      color: t.sub,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      text: '${calls.plannedDone}',
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      children: [
                        TextSpan(
                          text: '/${calls.plannedTotal}',
                          style: TextStyle(color: t.sub, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${calls.planCompletionPct}% of plan',
                    // .up{color:var(--pri)}
                    style: TextStyle(
                      color: t.primary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL DONE',
                    style: TextStyle(
                      color: t.sub,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${calls.totalDone}',
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '▲ +${calls.unplanned} unplanned',
                    style: TextStyle(
                      color: t.primary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
