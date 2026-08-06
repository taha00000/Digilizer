import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The three approved eWay themes.
/// Aurora is the signature gradient scheme; Blue / BlueDark are the company
/// brand-blue schemes. Colour values are lifted directly from the approved
/// interactive prototype (eWay_Interactive_Prototype_FINAL.html).
enum AppThemeId { aurora, blue, blueDark }

extension AppThemeIdX on AppThemeId {
  String get label => switch (this) {
        AppThemeId.aurora => 'Aurora',
        AppThemeId.blue => 'Company Blue',
        AppThemeId.blueDark => 'Blue Dark',
      };
}

/// A small token bundle each theme provides. Widgets read from [AppTokens]
/// (via context extension below) so NOTHING hard-codes a colour — that is what
/// lets the whole app re-skin instantly, exactly like the prototype.
class AppTokens extends ThemeExtension<AppTokens> {
  final Color canvas;
  final Color surface;
  final Color ink;
  final Color sub;
  final Color line;
  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color good;
  final Color warn;
  final Color rose;
  final Color warnSoft;
  final Color roseSoft;
  final List<Color> gradient; // hero / FAB / CTA gradient
  final List<Color> heroGradient;

  /// Categorical palette (--c1..--c4 in the prototype) used by the sales-mix
  /// card and the brand table. Series colours are assigned by index.
  final List<Color> chart;
  final bool isDark;

  const AppTokens({
    required this.canvas,
    required this.surface,
    required this.ink,
    required this.sub,
    required this.line,
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.good,
    required this.warn,
    required this.rose,
    required this.warnSoft,
    required this.roseSoft,
    required this.gradient,
    required this.heroGradient,
    required this.chart,
    required this.isDark,
  });

  /// Colour for series [i], wrapping past the end of the palette and falling
  /// through to [rose] for the 5th slot (matches the prototype's brand table).
  Color series(int i) => i < chart.length ? chart[i] : rose;

  @override
  AppTokens copyWith({
    Color? canvas,
    Color? surface,
    Color? ink,
    Color? sub,
    Color? line,
    Color? primary,
    Color? primaryDark,
    Color? primarySoft,
    Color? good,
    Color? warn,
    Color? rose,
    Color? warnSoft,
    Color? roseSoft,
    List<Color>? gradient,
    List<Color>? heroGradient,
    List<Color>? chart,
    bool? isDark,
  }) {
    return AppTokens(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      sub: sub ?? this.sub,
      line: line ?? this.line,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySoft: primarySoft ?? this.primarySoft,
      good: good ?? this.good,
      warn: warn ?? this.warn,
      rose: rose ?? this.rose,
      warnSoft: warnSoft ?? this.warnSoft,
      roseSoft: roseSoft ?? this.roseSoft,
      gradient: gradient ?? this.gradient,
      heroGradient: heroGradient ?? this.heroGradient,
      chart: chart ?? this.chart,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      sub: Color.lerp(sub, other.sub, t)!,
      line: Color.lerp(line, other.line, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      good: Color.lerp(good, other.good, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      rose: Color.lerp(rose, other.rose, t)!,
      warnSoft: Color.lerp(warnSoft, other.warnSoft, t)!,
      roseSoft: Color.lerp(roseSoft, other.roseSoft, t)!,
      gradient: t < 0.5 ? gradient : other.gradient,
      heroGradient: t < 0.5 ? heroGradient : other.heroGradient,
      chart: t < 0.5 ? chart : other.chart,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

class AppTheme {
  // ---- token sets (from the prototype) ----
  static const _aurora = AppTokens(
    canvas: Color(0xFF0A1024),
    surface: Color(0xFF141D3A),
    ink: Color(0xFFEEF3FF),
    sub: Color(0xFF9FB0D8),
    line: Color(0xFF27325C),
    primary: Color(0xFF22C3F5),
    primaryDark: Color(0xFF3D8BFF),
    primarySoft: Color(0xFF17234A),
    good: Color(0xFF34D399),
    warn: Color(0xFFFFC24D),
    rose: Color(0xFFFF6F8B),
    warnSoft: Color(0xFF3A2F16),
    roseSoft: Color(0xFF3B1B26),
    gradient: [Color(0xFF22C3F5), Color(0xFF3D8BFF), Color(0xFF6A7BFF)],
    heroGradient: [Color(0xFF17234A), Color(0xFF1D2B66), Color(0xFF0F1C52)],
    chart: [
      Color(0xFF22C3F5),
      Color(0xFF5B8CFF),
      Color(0xFFFFC24D),
      Color(0xFFA78BFF),
    ],
    isDark: true,
  );

  static const _blue = AppTokens(
    canvas: Color(0xFFF5FAFD),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF06222E),
    sub: Color(0xFF5A7682),
    line: Color(0xFFE6F1F6),
    primary: Color(0xFF00ACED),
    primaryDark: Color(0xFF0089BD),
    primarySoft: Color(0xFFE1F4FC),
    good: Color(0xFF0E9F6E),
    warn: Color(0xFFF0A500),
    rose: Color(0xFFF4604F),
    warnSoft: Color(0xFFFDF1D8),
    roseSoft: Color(0xFFFDE4E1),
    gradient: [Color(0xFF00ACED), Color(0xFF0089BD), Color(0xFF3DB8FF)],
    heroGradient: [Color(0xFFE1F4FC), Color(0xFFCFEEFB), Color(0xFFE8F6FE)],
    chart: [
      Color(0xFF00ACED),
      Color(0xFF0089BD),
      Color(0xFFF0A500),
      Color(0xFF7A6CF0),
    ],
    isDark: false,
  );

  static const _blueDark = AppTokens(
    canvas: Color(0xFF071A23),
    surface: Color(0xFF0E2D3B),
    ink: Color(0xFFEAFAFF),
    sub: Color(0xFF9DC1D2),
    line: Color(0xFF1D4A5C),
    primary: Color(0xFF22C0F5),
    primaryDark: Color(0xFF00ACED),
    primarySoft: Color(0xFF0F3142),
    good: Color(0xFF34D399),
    warn: Color(0xFFF3B53D),
    rose: Color(0xFFFF7A6E),
    warnSoft: Color(0xFF3A3018),
    roseSoft: Color(0xFF3B1F1B),
    gradient: [Color(0xFF22C0F5), Color(0xFF0E9FD6), Color(0xFF3DB8FF)],
    heroGradient: [Color(0xFF0E3344), Color(0xFF10485E), Color(0xFF0A2E3D)],
    chart: [
      Color(0xFF22C0F5),
      Color(0xFF5B9BFF),
      Color(0xFFF3B53D),
      Color(0xFF7A8CFF),
    ],
    isDark: true,
  );

  static AppTokens tokensFor(AppThemeId id) => switch (id) {
        AppThemeId.aurora => _aurora,
        AppThemeId.blue => _blue,
        AppThemeId.blueDark => _blueDark,
      };

  static ThemeData themeFor(AppThemeId id) {
    final t = tokensFor(id);
    final base = t.isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: t.canvas,
      colorScheme:
          (t.isDark ? const ColorScheme.dark() : const ColorScheme.light())
              .copyWith(primary: t.primary, surface: t.surface),
      textTheme: GoogleFonts.interTextTheme(base.textTheme)
          .apply(bodyColor: t.ink, displayColor: t.ink),
      extensions: [t],
    );
  }
}

/// Convenience: `context.tokens.primary`
extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
