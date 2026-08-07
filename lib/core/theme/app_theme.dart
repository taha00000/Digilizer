import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The three approved eWay themes.
///
/// Every value below is lifted verbatim from the CSS custom properties in
/// `docs/eWay_Interactive_Prototype_FINAL.html` (the `.theme-aurora`,
/// `.theme-blue` and `.theme-bluedark` blocks). Token names mirror the CSS
/// names so the two can be diffed by eye.
enum AppThemeId { aurora, blue, blueDark }

extension AppThemeIdX on AppThemeId {
  String get label => switch (this) {
        AppThemeId.aurora => 'Aurora',
        AppThemeId.blue => 'Company Blue',
        AppThemeId.blueDark => 'Blue Dark',
      };
}

/// Theme tokens, read through `context.tokens`. NOTHING hard-codes a colour —
/// that is what lets the whole app re-skin instantly, exactly like the
/// prototype's theme switcher.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  // --- surfaces & type ---
  final Color canvas; // --canvas
  final Color surface; // --surface
  final Color ink; // --aink
  final Color sub; // --asub
  final Color line; // --aline

  // --- brand ---
  final Color primary; // --pri
  final Color primaryDark; // --pri-d
  final Color primarySoft; // --pri-soft
  final Color primarySoft2; // --pri-soft2
  final Color eyebrow; // --eyebrow

  // --- semantic ---
  final Color info; // --info
  final Color infoSoft; // --info-soft
  final Color warn; // --warn
  final Color warnSoft; // --warn-soft
  final Color warnText; // --warn-tx
  final Color rose; // --rose
  final Color roseSoft; // --rose-soft
  final Color roseText; // --rose-tx

  // --- gradient stops (--g1/--g2/--g3) ---
  final List<Color> gradient;

  /// Categorical palette (--c1..--c4). 5th series falls through to [rose].
  final List<Color> chart;

  // --- ambient treatment ---
  /// `.viewport` layers two radial glows over `--canvasgrad`.
  final Color glow1; // --glow1
  final Color glow2; // --glow2
  final List<Color> canvasGradient; // --canvasgrad stops

  /// `.hero` — its own gradient, border and drop shadow.
  final List<Color> heroGradient; // --herobg stops
  final Color heroBorder; // --heroborder

  /// `.login` — per-theme; Aurora's is deep navy, NOT the brand gradient.
  final Color loginGlow1; // --loginglow1
  final Color loginGlow2; // --loginglow2
  final List<Color> loginGradient; // --logingrad stops

  /// Translucent tab-bar fill (`--tabbg`) and the brand glow used for the
  /// FAB/CTA drop shadows (`--shadow`).
  final Color tabBar;
  final Color shadow;

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
    required this.primarySoft2,
    required this.eyebrow,
    required this.info,
    required this.infoSoft,
    required this.warn,
    required this.warnSoft,
    required this.warnText,
    required this.rose,
    required this.roseSoft,
    required this.roseText,
    required this.gradient,
    required this.chart,
    required this.glow1,
    required this.glow2,
    required this.canvasGradient,
    required this.heroGradient,
    required this.heroBorder,
    required this.loginGlow1,
    required this.loginGlow2,
    required this.loginGradient,
    required this.tabBar,
    required this.shadow,
    required this.isDark,
  });

  /// Colour for series [i]; the prototype's 5th brand row uses `--rose`.
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
    Color? primarySoft2,
    Color? eyebrow,
    Color? info,
    Color? infoSoft,
    Color? warn,
    Color? warnSoft,
    Color? warnText,
    Color? rose,
    Color? roseSoft,
    Color? roseText,
    List<Color>? gradient,
    List<Color>? chart,
    Color? glow1,
    Color? glow2,
    List<Color>? canvasGradient,
    List<Color>? heroGradient,
    Color? heroBorder,
    Color? loginGlow1,
    Color? loginGlow2,
    List<Color>? loginGradient,
    Color? tabBar,
    Color? shadow,
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
      primarySoft2: primarySoft2 ?? this.primarySoft2,
      eyebrow: eyebrow ?? this.eyebrow,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      warn: warn ?? this.warn,
      warnSoft: warnSoft ?? this.warnSoft,
      warnText: warnText ?? this.warnText,
      rose: rose ?? this.rose,
      roseSoft: roseSoft ?? this.roseSoft,
      roseText: roseText ?? this.roseText,
      gradient: gradient ?? this.gradient,
      chart: chart ?? this.chart,
      glow1: glow1 ?? this.glow1,
      glow2: glow2 ?? this.glow2,
      canvasGradient: canvasGradient ?? this.canvasGradient,
      heroGradient: heroGradient ?? this.heroGradient,
      heroBorder: heroBorder ?? this.heroBorder,
      loginGlow1: loginGlow1 ?? this.loginGlow1,
      loginGlow2: loginGlow2 ?? this.loginGlow2,
      loginGradient: loginGradient ?? this.loginGradient,
      tabBar: tabBar ?? this.tabBar,
      shadow: shadow ?? this.shadow,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      canvas: c(canvas, other.canvas),
      surface: c(surface, other.surface),
      ink: c(ink, other.ink),
      sub: c(sub, other.sub),
      line: c(line, other.line),
      primary: c(primary, other.primary),
      primaryDark: c(primaryDark, other.primaryDark),
      primarySoft: c(primarySoft, other.primarySoft),
      primarySoft2: c(primarySoft2, other.primarySoft2),
      eyebrow: c(eyebrow, other.eyebrow),
      info: c(info, other.info),
      infoSoft: c(infoSoft, other.infoSoft),
      warn: c(warn, other.warn),
      warnSoft: c(warnSoft, other.warnSoft),
      warnText: c(warnText, other.warnText),
      rose: c(rose, other.rose),
      roseSoft: c(roseSoft, other.roseSoft),
      roseText: c(roseText, other.roseText),
      // Multi-stop lists snap at the midpoint rather than blending, which
      // keeps gradients coherent during a theme change.
      gradient: t < 0.5 ? gradient : other.gradient,
      chart: t < 0.5 ? chart : other.chart,
      glow1: c(glow1, other.glow1),
      glow2: c(glow2, other.glow2),
      canvasGradient: t < 0.5 ? canvasGradient : other.canvasGradient,
      heroGradient: t < 0.5 ? heroGradient : other.heroGradient,
      heroBorder: c(heroBorder, other.heroBorder),
      loginGlow1: c(loginGlow1, other.loginGlow1),
      loginGlow2: c(loginGlow2, other.loginGlow2),
      loginGradient: t < 0.5 ? loginGradient : other.loginGradient,
      tabBar: c(tabBar, other.tabBar),
      shadow: c(shadow, other.shadow),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

class AppTheme {
  static const _aurora = AppTokens(
    canvas: Color(0xFF0A1024),
    surface: Color(0xFF141D3A),
    ink: Color(0xFFEEF3FF),
    sub: Color(0xFF9FB0D8),
    line: Color(0xFF27325C),
    primary: Color(0xFF22C3F5),
    primaryDark: Color(0xFF3D8BFF),
    primarySoft: Color(0xFF17234A),
    primarySoft2: Color(0xFF1D2B58),
    eyebrow: Color(0xFF8FD9FF),
    info: Color(0xFF7C8CFF),
    infoSoft: Color(0xFF1A2348),
    warn: Color(0xFFFFC24D),
    warnSoft: Color(0xFF352B16),
    warnText: Color(0xFFFFC24D),
    rose: Color(0xFFFF6F8B),
    roseSoft: Color(0xFF351A28),
    roseText: Color(0xFFFF9DB0),
    gradient: [Color(0xFF22C3F5), Color(0xFF3D8BFF), Color(0xFF6A7BFF)],
    chart: [
      Color(0xFF22C3F5),
      Color(0xFF5B8CFF),
      Color(0xFFFFC24D),
      Color(0xFFA78BFF),
    ],
    glow1: Color(0x2922C3F5), // rgba(34,195,245,.16)
    glow2: Color(0x297C8CFF), // rgba(124,140,255,.16)
    canvasGradient: [
      Color(0xFF0A1024),
      Color(0xFF0B1230),
      Color(0xFF0A1024),
    ],
    heroGradient: [
      Color(0xFF17234A),
      Color(0xFF1D2B66),
      Color(0xFF0F1C52),
    ],
    heroBorder: Color(0xFF2C3A78),
    loginGlow1: Color(0x8022C3F5), // rgba(34,195,245,.5)
    loginGlow2: Color(0x737C8CFF), // rgba(124,140,255,.45)
    loginGradient: [
      Color(0xFF0C1330),
      Color(0xFF141D52),
      Color(0xFF0A1024),
    ],
    tabBar: Color(0xEB0A1024), // rgba(10,16,36,.92)
    shadow: Color(0x5722C3F5), // rgba(34,195,245,.34)
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
    primarySoft2: Color(0xFFC8EBF9),
    eyebrow: Color(0xFF0089BD),
    info: Color(0xFF5B6BFF),
    infoSoft: Color(0xFFEAECFF),
    warn: Color(0xFFF0A500),
    warnSoft: Color(0xFFFDF3DA),
    warnText: Color(0xFFA87800),
    rose: Color(0xFFF4604F),
    roseSoft: Color(0xFFFDECEA),
    roseText: Color(0xFFC43D2E),
    gradient: [Color(0xFF00ACED), Color(0xFF0089BD), Color(0xFF3DB8FF)],
    chart: [
      Color(0xFF00ACED),
      Color(0xFF0089BD),
      Color(0xFFF0A500),
      Color(0xFF7A6CF0),
    ],
    glow1: Color(0x1A00ACED), // rgba(0,172,237,.10)
    glow2: Color(0x120089BD), // rgba(0,137,189,.07)
    canvasGradient: [
      Color(0xFFF5FAFD),
      Color(0xFFEEF8FD),
      Color(0xFFF5FAFD),
    ],
    heroGradient: [
      Color(0xFFE1F4FC),
      Color(0xFFCFEEFB),
      Color(0xFFE8F6FE),
    ],
    heroBorder: Color(0xFFBFE6F7),
    loginGlow1: Color(0x59FFFFFF), // rgba(255,255,255,.35)
    loginGlow2: Color(0x4000ACED), // rgba(0,172,237,.25)
    loginGradient: [
      Color(0xFF0089BD),
      Color(0xFF00ACED),
      Color(0xFF22B8F0),
    ],
    tabBar: Color(0xF0FFFFFF), // rgba(255,255,255,.94)
    shadow: Color(0x4700ACED), // rgba(0,172,237,.28)
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
    primarySoft2: Color(0xFF143D50),
    eyebrow: Color(0xFF7FDCFF),
    info: Color(0xFF5B9BFF),
    infoSoft: Color(0xFF13294A),
    warn: Color(0xFFF3B53D),
    warnSoft: Color(0xFF352B16),
    warnText: Color(0xFFF3B53D),
    rose: Color(0xFFFF7A6E),
    roseSoft: Color(0xFF341C1A),
    roseText: Color(0xFFFF9D92),
    gradient: [Color(0xFF22C0F5), Color(0xFF0E9FD6), Color(0xFF3DB8FF)],
    chart: [
      Color(0xFF22C0F5),
      Color(0xFF5B9BFF),
      Color(0xFFF3B53D),
      Color(0xFF7A8CFF),
    ],
    glow1: Color(0x2422C0F5), // rgba(34,192,245,.14)
    glow2: Color(0x1F0B8CC8), // rgba(11,140,200,.12)
    canvasGradient: [
      Color(0xFF071A23),
      Color(0xFF08222E),
      Color(0xFF071A23),
    ],
    heroGradient: [
      Color(0xFF0E3344),
      Color(0xFF10485E),
      Color(0xFF0A2E3D),
    ],
    heroBorder: Color(0xFF1C5C70),
    loginGlow1: Color(0x7322C0F5), // rgba(34,192,245,.45)
    loginGlow2: Color(0x660B8CC8), // rgba(11,140,200,.4)
    loginGradient: [
      Color(0xFF06222E),
      Color(0xFF0C4054),
      Color(0xFF071A23),
    ],
    tabBar: Color(0xEB071A23), // rgba(7,26,35,.92)
    shadow: Color(0x6600ACED), // rgba(0,172,237,.4)
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
