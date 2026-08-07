import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Builds a Flutter [RadialGradient] that behaves like a CSS
/// `radial-gradient(<w>% <h>% at <x>% <y>%, color, transparent <stop>%)`.
///
/// Two mismatches make a naive translation look wrong, and both are visible as
/// a hard arc across the backdrop:
///
/// 1. **CSS gradients are ellipses.** `130% 80%` means the ramp reaches its end
///    at 1.3x the box width horizontally but only 0.8x its height vertically.
///    Flutter's [RadialGradient] is a circle whose radius is a fraction of the
///    shorter side, so the falloff lands in the wrong place on both axes.
///    [_EllipseGradientTransform] scales the gradient space to compensate.
///
/// 2. **`transparent` is black with zero alpha.** Interpolating a bright colour
///    towards it dims the midpoint and leaves a dirty ring, so we fade to the
///    same colour at zero alpha instead.
///
/// A pair of eased intermediate stops replaces the single linear ramp, since a
/// straight alpha ramp terminating at the stop reads as a visible edge on a
/// large, low-contrast wash.
RadialGradient cssRadialGlow({
  required Color color,
  required double widthPct,
  required double heightPct,
  required double atXPct,
  required double atYPct,
  required double stopPct,
}) {
  // CSS position % -> Flutter Alignment (-1..1).
  final center = Alignment(atXPct / 50 - 1, atYPct / 50 - 1);

  // Drive the circle off the wider axis, then squash the other one.
  final radius = math.max(widthPct, heightPct) / 100;
  final scaleX = (widthPct / 100) / radius;
  final scaleY = (heightPct / 100) / radius;

  final end = stopPct / 100;
  return RadialGradient(
    center: center,
    radius: radius,
    transform: _EllipseGradientTransform(center, scaleX, scaleY),
    colors: [
      color,
      color.withValues(alpha: color.a * 0.55),
      color.withValues(alpha: color.a * 0.16),
      color.withValues(alpha: 0),
    ],
    stops: [0.0, end * 0.45, end * 0.75, end],
  );
}

/// Scales gradient space about [center] so a circular gradient paints as the
/// ellipse CSS would have drawn.
@immutable
class _EllipseGradientTransform extends GradientTransform {
  const _EllipseGradientTransform(this.center, this.scaleX, this.scaleY);

  final Alignment center;
  final double scaleX;
  final double scaleY;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final focal = center.withinRect(bounds);
    return Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..scaleByDouble(scaleX, scaleY, 1, 1)
      ..translateByDouble(-focal.dx, -focal.dy, 0, 1);
  }

  @override
  bool operator ==(Object other) =>
      other is _EllipseGradientTransform &&
      other.center == center &&
      other.scaleX == scaleX &&
      other.scaleY == scaleY;

  @override
  int get hashCode => Object.hash(center, scaleX, scaleY);
}
