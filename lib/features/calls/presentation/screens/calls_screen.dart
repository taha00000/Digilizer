import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/bottom_tab_bar.dart';
import '../../../../shared/widgets/cta_button.dart';
import '../../../../shared/widgets/list_row.dart';
import '../../../../shared/widgets/pill_row.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/visit.dart';
import '../providers/calls_providers.dart';

/// Call Reporting (`callScreen`) — today's visit list with planned/done KPIs.
class CallsScreen extends ConsumerWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final async = ref.watch(callsTodayProvider);
    final audience = ref.watch(callAudienceProvider);

    void addVisit() {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Visit logging arrives with the API.')),
        );
    }

    return AppShell(
      title: 'Call Reporting',
      subtitle: 'Today · 17 Jun 2026',
      tab: AppTab.modules,
      onBack: () => context.go('/modules'),
      onRefresh: () async {
        ref.invalidate(callsTodayProvider);
        await ref.read(callsTodayProvider.future);
      },
      children: [
        PillRow(
          labels: CallAudience.values.map((a) => a.label).toList(),
          selectedIndex: CallAudience.values.indexOf(audience),
          onChanged: (i) => ref.read(callAudienceProvider.notifier).state =
              CallAudience.values[i],
        ),
        const SizedBox(height: 14),
        AsyncView<CallsSnapshot>(
          value: async,
          onRetry: () => ref.invalidate(callsTodayProvider),
          loadingHeights: const [96, 64, 64, 64],
          data: (s) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Kpi(label: 'Planned', value: '${s.planned}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Kpi(
                        label: 'Done',
                        value: '${s.done}',
                        valueColor: t.primary,
                        delta: '${s.completionPct}% rate',
                      ),
                    ),
                  ],
                ),
              ),
              SectionTitle(
                'Visit list',
                trailing: SectionLink('Add', onTap: addVisit),
              ),
              for (final v in s.visits) _VisitRow(visit: v),
              const SizedBox(height: 14),
              CtaButton(
                label: 'Log a new visit',
                icon: Icons.add_rounded,
                onTap: addVisit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    this.valueColor,
    this.delta,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: t.sub,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? t.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.44,
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: 3),
            Text(
              delta!,
              // .up{color:var(--pri)}
              style: TextStyle(
                color: t.primary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit});
  final Visit visit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    // Tint follows the outcome, as the prototype does per row.
    final (fg, bg, icon) = switch (visit.status) {
      VisitStatus.done => (t.primary, t.primarySoft, Icons.badge_outlined),
      VisitStatus.logged => (t.warn, t.warnSoft, Icons.badge_outlined),
      VisitStatus.missed => (t.rose, t.roseSoft, Icons.warning_amber_rounded),
    };

    final (badgeLabel, tone) = switch (visit.status) {
      VisitStatus.done => ('Done', BadgeTone.good),
      VisitStatus.logged => ('Logged', BadgeTone.warn),
      VisitStatus.missed => ('Missed', BadgeTone.bad),
    };

    final typeLabel = visit.type == VisitType.planned ? 'Planned' : 'Unplanned';

    return ListRow(
      icon: icon,
      iconColor: fg,
      iconBackground: bg,
      title: visit.name,
      subtitle: '${visit.specialty} · ${visit.time} · $typeLabel',
      trailing: StatusBadge(badgeLabel, tone: tone),
    );
  }
}
