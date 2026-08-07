import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

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
        // glow 2 — at -10% 8%, extent 55%
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-1.2, -0.84),
            radius: 1.2,
            colors: [t.glow2, t.glow2.withValues(alpha: 0)],
            stops: const [0.0, 0.55],
          ),
        ),
        child: DecoratedBox(
          // glow 1 — at 80% -5%, extent 60%
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.6, -1.1),
              radius: 1.2,
              colors: [t.glow1, t.glow1.withValues(alpha: 0)],
              stops: const [0.0, 0.6],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
