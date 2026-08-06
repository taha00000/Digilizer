import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The five app-level destinations. Only [home] is wired this phase; the rest
/// are built in later phases (see HANDOFF.md §1).
enum AppTab { home, modules, team, reports }

extension AppTabX on AppTab {
  String get label => switch (this) {
        AppTab.home => 'Home',
        AppTab.modules => 'Modules',
        AppTab.team => 'Team',
        AppTab.reports => 'Reports',
      };

  IconData get icon => switch (this) {
        AppTab.home => Icons.home_rounded,
        AppTab.modules => Icons.grid_view_rounded,
        AppTab.team => Icons.people_alt_rounded,
        AppTab.reports => Icons.description_rounded,
      };
}

/// Bottom navigation with the centre FAB, matching the prototype. Slides out of
/// view on scroll-down and back in on scroll-up — drive [visible] from a
/// [ScrollController] (see `HideOnScroll`).
class BottomTabBar extends StatelessWidget {
  const BottomTabBar({
    super.key,
    required this.current,
    required this.visible,
    this.onTabSelected,
    this.onFabPressed,
  });

  final AppTab current;
  final bool visible;
  final ValueChanged<AppTab>? onTabSelected;
  final VoidCallback? onFabPressed;

  static const double height = 74;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1.2),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 280),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 9, 8, 13),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(top: BorderSide(color: t.line)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                _tab(context, AppTab.home),
                _tab(context, AppTab.modules),
                Expanded(child: _fab(context)),
                _tab(context, AppTab.team),
                _tab(context, AppTab.reports),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, AppTab tab) {
    final t = context.tokens;
    final on = tab == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected?.call(tab),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 21, color: on ? t.primary : t.sub),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: on ? t.primary : t.sub,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onFabPressed,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: t.gradient,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

/// Tracks a [ScrollController] and reports whether a hide-on-scroll chrome
/// element should currently be visible: hidden while scrolling down past a
/// threshold, shown again on any upward scroll or at the top of the list.
class HideOnScroll extends ChangeNotifier {
  HideOnScroll(this._controller) {
    _controller.addListener(_onScroll);
  }

  final ScrollController _controller;
  bool _visible = true;
  double _lastOffset = 0;

  bool get visible => _visible;

  void _onScroll() {
    final y = _controller.offset;
    var next = _visible;

    if (y <= 4) {
      next = true; // at the top → always show
    } else if (y > _lastOffset + 6 && y > 40) {
      next = false; // scrolling down → hide
    } else if (y < _lastOffset - 6) {
      next = true; // scrolling up → show
    }

    _lastOffset = y;
    if (next != _visible) {
      _visible = next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    super.dispose();
  }
}
