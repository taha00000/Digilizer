import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';

/// Profile bottom sheet, opened by tapping the dashboard avatar. Carries the
/// in-app theme switcher (Aurora / Company Blue / Blue Dark) — the selection
/// persists via [ThemeController] and re-skins the app live.
///
/// Sign-out is passed in as [onSignOut] so this stays free of any feature
/// import (see HANDOFF.md §5.7).
class ProfileSheet extends ConsumerWidget {
  const ProfileSheet({
    super.key,
    required this.displayName,
    required this.subtitle,
    required this.initials,
    this.onSignOut,
  });

  final String displayName;
  final String subtitle;
  final String initials;
  final VoidCallback? onSignOut;

  static Future<void> show(
    BuildContext context, {
    required String displayName,
    required String subtitle,
    required String initials,
    VoidCallback? onSignOut,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ProfileSheet(
        displayName: displayName,
        subtitle: subtitle,
        initials: initials,
        onSignOut: onSignOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final current = ref.watch(themeControllerProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: t.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: t.primarySoft,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: t.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: t.sub, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'APPEARANCE',
              style: TextStyle(
                color: t.sub,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            for (final id in AppThemeId.values)
              _ThemeRow(
                id: id,
                selected: id == current,
                onTap: () =>
                    ref.read(themeControllerProvider.notifier).setTheme(id),
              ),
            const SizedBox(height: 18),
            Divider(color: t.line, height: 1),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.logout_rounded, color: t.rose, size: 21),
              title: Text(
                'Sign out',
                style: TextStyle(
                  color: t.rose,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: onSignOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.id,
    required this.selected,
    required this.onTap,
  });

  final AppThemeId id;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final preview = AppTheme.tokensFor(id);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? t.primarySoft : t.canvas,
          border: Border.all(color: selected ? t.primary : t.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: preview.gradient,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                id.label,
                style: TextStyle(
                  color: t.ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: t.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
