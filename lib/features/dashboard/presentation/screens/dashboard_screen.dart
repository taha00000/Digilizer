import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/bottom_tab_bar.dart';
import '../../../../shared/widgets/pill_row.dart';
import '../../../../shared/widgets/profile_sheet.dart';
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
/// card with Donut/Bars/Share, sortable top-brands table, today's calls, and
/// the hide-on-scroll bottom tab bar.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scroll = ScrollController();
  late final HideOnScroll _hideOnScroll = HideOnScroll(_scroll);
  int _trendView = 0; // 0 = 6M, 1 = 4Q

  @override
  void dispose() {
    _hideOnScroll.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(dashboardSummaryProvider);
    await ref.read(dashboardSummaryProvider.future);
  }

  void _openProfile() {
    final session = ref.read(currentSessionProvider);
    ProfileSheet.show(
      context,
      displayName: session?.displayName ?? 'Signed in',
      subtitle: session == null
          ? ''
          : '${session.company} · ACC ${session.accountCode}',
      initials: session?.initials ?? '?',
      onSignOut: () {
        Navigator.of(context).pop();
        ref.read(signOutProvider)();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final async = ref.watch(dashboardSummaryProvider);
    final session = ref.watch(currentSessionProvider);

    return Scaffold(
      backgroundColor: t.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _Header(
                  greeting: 'Good morning',
                  subtitle: session == null
                      ? '—'
                      : '${session.displayName.split(' ').first} · '
                          '${session.company} · ACC ${session.accountCode}',
                  initials: session?.initials ?? '?',
                  onAvatarTap: _openProfile,
                ),
                Expanded(
                  child: async.when(
                    loading: () => const _DashboardSkeleton(),
                    error: (e, _) => _ErrorState(
                      message: '$e'.replaceFirst('Exception: ', ''),
                      onRetry: _refresh,
                    ),
                    data: (summary) => RefreshIndicator(
                      onRefresh: _refresh,
                      color: t.primary,
                      backgroundColor: t.surface,
                      child: _body(summary),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _hideOnScroll,
                builder: (context, _) => BottomTabBar(
                  current: AppTab.home,
                  visible: _hideOnScroll.visible,
                  onTabSelected: (tab) {
                    if (tab == AppTab.home) return;
                    _comingSoon('${tab.label} arrives in a later phase.');
                  },
                  onFabPressed: () =>
                      _comingSoon('Call reporting arrives in a later phase.'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _body(DashboardSummary s) {
    final period = ref.watch(dashboardPeriodProvider);

    return ListView(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, BottomTabBar.height + 32),
      children: [
        PillRow(
          labels: DashboardPeriod.values.map((p) => p.label).toList(),
          selectedIndex: DashboardPeriod.values.indexOf(period),
          onChanged: (i) => ref.read(dashboardPeriodProvider.notifier).state =
              DashboardPeriod.values[i],
        ),
        const SizedBox(height: 14),
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
            onTap: () => _comingSoon('Reports arrives in a later phase.'),
          ),
        ),
        SalesMixCard(slices: s.salesMix),
        SectionTitle(
          'Top brands',
          trailing: SectionLink(
            'Details',
            onTap: () => _comingSoon('Brand detail arrives in a later phase.'),
          ),
        ),
        BrandTable(brands: s.topBrands),
        SectionTitle(
          "Today's calls",
          trailing: SectionLink(
            'Open',
            onTap: () => _comingSoon('Call reporting arrives in a later phase.'),
          ),
        ),
        _CallsRow(calls: s.calls),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.subtitle,
    required this.initials,
    required this.onAvatarTap,
  });

  final String greeting;
  final String subtitle;
  final String initials;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: t.sub, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 21,
              backgroundColor: t.primarySoft,
              child: Text(
                initials,
                style: TextStyle(
                  color: t.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
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
                    style: TextStyle(
                      color: t.good,
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
                      color: t.good,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: t.sub, size: 38),
            const SizedBox(height: 14),
            Text(
              'Could not load the dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: t.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.sub, fontSize: 12.5),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: t.primary),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton shown while the summary loads — same rhythm as the real layout so
/// the screen does not jump when data arrives.
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget block(double height, {double radius = 20}) => Container(
          height: height,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    return IgnorePointer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
        children: [
          block(36, radius: 999),
          const SizedBox(height: 2),
          block(150, radius: 24),
          Row(
            children: [
              Expanded(child: block(120)),
              const SizedBox(width: 12),
              Expanded(child: block(120)),
            ],
          ),
          const SizedBox(height: 16),
          block(200),
          const SizedBox(height: 16),
          block(240),
        ],
      ),
    );
  }
}
