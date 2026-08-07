import 'dart:ui';

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
        AppTab.home => Icons.home_outlined,
        AppTab.modules => Icons.grid_view_outlined,
        AppTab.team => Icons.people_outline,
        AppTab.reports => Icons.description_outlined,
      };
}

/// `.tabbar` — translucent, blurred, with the FAB floating proud of the top
/// edge.
///
/// ```css
/// .tabbar{background:var(--tabbg);backdrop-filter:blur(12px);
///         border-top:1px solid var(--aline);padding:9px 8px 13px}
/// .tab{flex:1;font-size:10px;font-weight:700;color:var(--asub);opacity:.7}
/// .tab.on{color:var(--pri);opacity:1}
/// .fabtab{flex:none;width:54px}
/// .fab{top:-20px;width:50px;height:50px;border-radius:16px;
///      background:linear-gradient(140deg,--g1,--g2 60%,--g3);
///      box-shadow:0 8px 22px var(--shadow)}
/// ```
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

  /// Bar height excluding the safe-area inset; used to pad scroll views.
  static const double height = 74;

  /// How far the FAB rises above the bar.
  static const double _fabOverhang = 20;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1.4),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 280),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 9, 8, 13),
                  decoration: BoxDecoration(
                    color: t.tabBar,
                    border: Border(top: BorderSide(color: t.line)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        _tab(context, AppTab.home),
                        _tab(context, AppTab.modules),
                        // .fabtab — a fixed 54px gap the FAB floats over.
                        const SizedBox(width: 54),
                        _tab(context, AppTab.team),
                        _tab(context, AppTab.reports),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -_fabOverhang,
              child: _fab(context),
            ),
          ],
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
        child: Opacity(
          opacity: on ? 1 : 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 23, color: on ? t.primary : t.sub),
              const SizedBox(height: 3),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: on ? t.primary : t.sub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onFabPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // linear-gradient(140deg, g1, g2 60%, g3)
            begin: const Alignment(-0.9, -1),
            end: const Alignment(0.9, 1),
            colors: t.gradient,
            stops: const [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: t.shadow,
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
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
      next = true; // at the top -> always show
    } else if (y > _lastOffset + 6 && y > 40) {
      next = false; // scrolling down -> hide
    } else if (y < _lastOffset - 6) {
      next = true; // scrolling up -> show
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
