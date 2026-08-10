import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_controller.dart';
import '../../core/theme/app_theme.dart';
import 'app_background.dart';
import 'app_top_bar.dart';
import 'bottom_tab_bar.dart';
import 'profile_sheet.dart';

/// The common chrome every in-app screen sits inside: ambient background,
/// app bar, a scrolling body, and the hide-on-scroll tab bar with its FAB.
///
/// Screens supply [slivers]-free plain children; this owns the scroll
/// controller so the tab bar can react to it.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.tab,
    required this.children,
    this.subtitle,
    this.onBack,
    this.showAvatar = true,
    this.onRefresh,
  });

  final String title;
  final String? subtitle;

  /// Which bottom tab highlights. Sub-screens map to their parent tab, the
  /// way TABMAP does in the prototype.
  final AppTab tab;
  final List<Widget> children;
  final VoidCallback? onBack;
  final bool showAvatar;
  final Future<void> Function()? onRefresh;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scroll = ScrollController();
  late final HideOnScroll _hideOnScroll = HideOnScroll(_scroll);

  @override
  void dispose() {
    _hideOnScroll.dispose();
    _scroll.dispose();
    super.dispose();
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

  void _goTab(AppTab tab) {
    if (tab == widget.tab) return;
    final path = switch (tab) {
      AppTab.home => '/dashboard',
      AppTab.modules => '/modules',
      AppTab.team => '/team',
      AppTab.reports => '/reports',
    };
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final session = ref.watch(currentSessionProvider);

    final body = ListView(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      // .body{padding:4px 18px 96px}
      padding: const EdgeInsets.fromLTRB(18, 4, 18, BottomTabBar.height + 32),
      children: widget.children,
    );

    return Scaffold(
      backgroundColor: t.canvas,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  AppTopBar(
                    title: widget.title,
                    subtitle: widget.subtitle,
                    onBack: widget.onBack,
                    avatarInitials: widget.showAvatar && widget.onBack == null
                        ? (session?.initials ?? '?')
                        : null,
                    onAvatarTap: _openProfile,
                  ),
                  Expanded(
                    child: widget.onRefresh == null
                        ? body
                        : RefreshIndicator(
                            onRefresh: widget.onRefresh!,
                            color: t.primary,
                            backgroundColor: t.surface,
                            child: body,
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
                    current: widget.tab,
                    visible: _hideOnScroll.visible,
                    showTeam: session?.canViewTeam ?? false,
                    onTabSelected: _goTab,
                    onFabPressed: () => context.go('/calls'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
