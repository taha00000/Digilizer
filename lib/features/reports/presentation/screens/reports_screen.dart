import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/bottom_tab_bar.dart';
import '../../../../shared/widgets/list_row.dart';

/// Reports (`reportsScreen`) — a grouped, searchable list of report types.
///
/// Navigational only; the report itself is generated on the output screen.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;

    void soon(String name) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$name — opening report…')));
    }

    ListRow row({
      required IconData icon,
      required Color fg,
      required Color bg,
      required String name,
      required String desc,
      bool open = false,
    }) {
      return ListRow(
        icon: icon,
        iconColor: fg,
        iconBackground: bg,
        title: name,
        subtitle: desc,
        onTap: open ? () => context.go('/reports/activity') : () => soon(name),
      );
    }

    return AppShell(
      title: 'Reports',
      subtitle: 'Search & export',
      tab: AppTab.reports,
      children: [
        _SearchField(
          onTap: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Search — type to filter reports.'),
                ),
              );
          },
        ),
        const GroupLabel('Call reports'),
        row(
          icon: Icons.map_outlined,
          fg: t.primary,
          bg: t.primarySoft,
          name: 'Activity Details',
          desc: 'By rep & date',
          open: true,
        ),
        row(
          icon: Icons.place_outlined,
          fg: t.info,
          bg: t.infoSoft,
          name: 'Activity on Map',
          desc: 'Geo-tagged visits',
          open: true,
        ),
        row(
          icon: Icons.badge_outlined,
          fg: t.primary,
          bg: t.primarySoft,
          name: 'Doctor Interaction',
          desc: 'Engagement quality',
          open: true,
        ),
        row(
          icon: Icons.warning_amber_rounded,
          fg: t.warn,
          bg: t.warnSoft,
          name: 'Visit Deviation',
          desc: 'Off-plan visits',
          open: true,
        ),
        const GroupLabel('Chemist & bonus'),
        row(
          icon: Icons.shield_outlined,
          fg: t.primary,
          bg: t.primarySoft,
          name: 'Chemist Activity',
          desc: 'Coverage & calls',
          open: true,
        ),
        row(
          icon: Icons.description_outlined,
          fg: t.lav,
          bg: t.lavSoft,
          name: 'Bonus & Discount Status',
          desc: 'Pending & approved',
          open: true,
        ),
        const GroupLabel('Customer registration'),
        row(
          icon: Icons.person_outline,
          fg: t.info,
          bg: t.infoSoft,
          name: 'Doctor Registration',
          desc: 'Add & verify',
        ),
        row(
          icon: Icons.inbox_outlined,
          fg: t.warn,
          bg: t.warnSoft,
          name: 'Pending Registrations',
          desc: '3 awaiting review',
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18, color: t.sub),
            const SizedBox(width: 10),
            Opacity(
              opacity: 0.7,
              child: Text(
                'Search reports…',
                style: TextStyle(
                  color: t.sub,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
