import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/bottom_tab_bar.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/seg_control.dart';
import '../../domain/entities/team.dart';
import '../providers/team_providers.dart';
import '../widgets/rep_card.dart';

/// My Team (`teamScreen`) — zone achievement plus the sortable rep list.
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(teamProvider);
    final sort = ref.watch(teamSortProvider);

    return AppShell(
      title: 'My Team',
      subtitle: 'Zonal Sales · 10 members',
      tab: AppTab.team,
      onRefresh: () async {
        ref.invalidate(teamProvider);
        await ref.read(teamProvider.future);
      },
      children: [
        AsyncView<TeamSnapshot>(
          value: async,
          onRetry: () => ref.invalidate(teamProvider),
          loadingHeights: const [150, 130, 130],
          data: (s) {
            final members = ref.watch(sortedMembersProvider);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ZoneHero(zone: s.zone),
                SectionTitle(
                  'Representatives',
                  trailing: SegControl(
                    labels: const ['Achievement', 'Name'],
                    selectedIndex: TeamSort.values.indexOf(sort),
                    onChanged: (i) => ref
                        .read(teamSortProvider.notifier)
                        .state = TeamSort.values[i],
                  ),
                ),
                for (final m in members)
                  RepCard(
                    member: m,
                    onTap: () => context.go('/team/rep/${m.code}'),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// The zone header reuses `.hero` but on `--info-soft`, as the prototype does.
class _ZoneHero extends StatelessWidget {
  const _ZoneHero({required this.zone});
  final ZoneSummary zone;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.infoSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ZONE ACHIEVEMENT',
            style: TextStyle(
              color: t.info,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.46,
            ),
          ),
          const SizedBox(height: 7),
          Text.rich(
            TextSpan(
              text: zone.achievementPct.toStringAsFixed(2),
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
                    color: t.info,
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
              _stat(context, 'Sales', zone.sales, null),
              const SizedBox(width: 20),
              _stat(context, 'Target', zone.target, null),
              const SizedBox(width: 20),
              _stat(context, 'GoLY', zone.goLY, t.primary),
            ],
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
