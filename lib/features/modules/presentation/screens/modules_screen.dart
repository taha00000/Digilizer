import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/bottom_tab_bar.dart';
import '../../../../shared/widgets/list_row.dart';
import '../widgets/mod_tile.dart';

/// Modules — the field & management tool launcher (`modScreen`).
///
/// Purely navigational: there is no server data behind this menu, so it has no
/// datasource/repository. Every other feature goes through the service layer.
class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;

    void soon(String what) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$what — opening…')));
    }

    // Tints come straight from the prototype's `tint` map.
    Widget tile({
      required IconData icon,
      required Color fg,
      required Color bg,
      required String title,
      required String subtitle,
      String? route,
    }) {
      return ModTile(
        icon: icon,
        iconColor: fg,
        iconBackground: bg,
        title: title,
        subtitle: subtitle,
        onTap: route == null ? () => soon(title) : () => context.go(route),
      );
    }

    Widget grid(List<Widget> tiles) => GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.22,
          children: tiles,
        );

    return AppShell(
      title: 'Modules',
      subtitle: 'Field & management tools',
      tab: AppTab.modules,
      children: [
        ListRow(
          icon: Icons.people_alt_outlined,
          iconColor: t.primary,
          iconBackground: t.primarySoft,
          title: 'My Team · ZSM (10)',
          subtitle: 'Targets, achievement & rep reports',
          onTap: () => context.go('/team'),
        ),
        const GroupLabel('Daily work'),
        grid([
          tile(
            icon: Icons.assignment_outlined,
            fg: t.primary,
            bg: t.primarySoft,
            title: 'Call Reporting',
            subtitle: 'Log doctor & chemist visits',
            route: '/calls',
          ),
          tile(
            icon: Icons.event_note_outlined,
            fg: t.info,
            bg: t.infoSoft,
            title: 'Work Plan',
            subtitle: 'Plan visits for the week',
            route: '/calls',
          ),
          tile(
            icon: Icons.receipt_long_outlined,
            fg: t.warn,
            bg: t.warnSoft,
            title: 'Sale Module',
            subtitle: 'Orders & invoices',
          ),
          tile(
            icon: Icons.trending_up_rounded,
            fg: t.lav,
            bg: t.lavSoft,
            title: 'ROI Service',
            subtitle: 'Investment return',
          ),
        ]),
        const GroupLabel('Analysis & approvals'),
        grid([
          tile(
            icon: Icons.grid_on_outlined,
            fg: t.primary,
            bg: t.primarySoft,
            title: 'Brick Analysis',
            subtitle: 'Territory performance',
            route: '/team',
          ),
          tile(
            icon: Icons.percent_rounded,
            fg: t.rose,
            bg: t.roseSoft,
            title: 'Extra Discount',
            subtitle: 'Request & approvals',
          ),
          tile(
            icon: Icons.campaign_outlined,
            fg: t.info,
            bg: t.infoSoft,
            title: 'Marketing',
            subtitle: 'Campaign activity',
          ),
          tile(
            icon: Icons.badge_outlined,
            fg: t.warn,
            bg: t.warnSoft,
            title: 'Field Force HR',
            subtitle: 'Team & leave',
            route: '/team',
          ),
        ]),
      ],
    );
  }
}
