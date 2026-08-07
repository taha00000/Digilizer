import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'radial_glow.dart';

/// Reproduces the prototype's `.viewport` treatment:
///
/// ```css
/// background:
///   radial-gradient(120% 70% at 80% -5%,  var(--glow1), transparent 60%),
///   radial-gradient(120% 60% at -10% 8%,  var(--glow2), transparent 55%),
///   var(--canvasgrad);
/// ```
///
/// This ambient wash is what stops the dark themes reading as flat black. It
/// sits behind every screen.
///
/// The fade colour is the glow at zero opacity rather than
/// `Colors.transparent`: transparent is *black* with alpha 0, which would
/// darken the midpoint of the ramp and leave a dirty halo.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return DecoratedBox(
      // --canvasgrad: linear-gradient(180deg, a, b 60%, c)
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: t.canvasGradient,
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: DecoratedBox(
        // radial-gradient(120% 60% at -10% 8%, --glow2, transparent 55%)
        decoration: BoxDecoration(
          gradient: cssRadialGlow(
            color: t.glow2,
            widthPct: 120,
            heightPct: 60,
            atXPct: -10,
            atYPct: 8,
            stopPct: 55,
          ),
        ),
        child: DecoratedBox(
          // radial-gradient(120% 70% at 80% -5%, --glow1, transparent 60%)
          decoration: BoxDecoration(
            gradient: cssRadialGlow(
              color: t.glow1,
              widthPct: 120,
              heightPct: 70,
              atXPct: 80,
              atYPct: -5,
              stopPct: 60,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
