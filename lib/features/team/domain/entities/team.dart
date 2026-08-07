/// How a rep's achievement is graded, driving the chip and bar colour.
/// The prototype hard-codes a colour per row; this names the intent instead.
enum AchievementTone { good, watch, behind }

class TeamMember {
  const TeamMember({
    required this.initials,
    required this.name,
    required this.role,
    required this.code,
    required this.achPct,
    required this.sales,
    required this.target,
    required this.goLM,
    required this.goLY,
    required this.tone,
  });

  final String initials; // "GZ"
  final String name; // "Gohar Zaman"
  final String role; // "Assoc. Director"
  final String code; // "004324"
  final int achPct; // 75
  final String sales; // "6.5M"
  final String target; // "8.7M"
  final String goLM; // "15"
  final String goLY; // "109"
  final AchievementTone tone;
}

/// The zone header on the Team screen.
class ZoneSummary {
  const ZoneSummary({
    required this.achievementPct,
    required this.sales,
    required this.target,
    required this.goLY,
  });

  final double achievementPct; // 58.24
  final String sales; // "30.1M"
  final String target; // "51.7M"
  final String goLY; // "+59.9%"
}

class TeamSnapshot {
  const TeamSnapshot({required this.zone, required this.members});

  final ZoneSummary zone;
  final List<TeamMember> members;
}

/// One expandable product row on the rep detail screen.
class ProductSale {
  const ProductSale({
    required this.brand,
    required this.form,
    required this.achPct,
    required this.target,
    required this.sales,
    required this.goLM,
    required this.goLY,
    required this.targetUnits,
    required this.salesUnits,
  });

  final String brand; // "Vlep"
  final String form; // "Tablets 500mg"
  final int achPct; // 77
  final String target; // "3.7M"
  final String sales; // "2.9M"
  final int goLM; // 25
  final int goLY; // 68
  final String targetUnits; // "2,172"
  final String salesUnits; // "1,686"

  /// Avatar letter, derived rather than stored.
  String get initial => brand.isEmpty ? '?' : brand[0].toUpperCase();
}

/// Rep · Product Sale payload.
class RepDetail {
  const RepDetail({
    required this.name,
    required this.code,
    required this.role,
    required this.achPct,
    required this.sales,
    required this.target,
    required this.goLY,
    required this.products,
  });

  final String name;
  final String code;
  final String role;
  final int achPct;
  final String sales;
  final String target;
  final String goLY;
  final List<ProductSale> products;
}
