/// Everything the dashboard needs, as pure domain entities.
/// No Flutter, no packages — this layer must stay vendor-free.
class DashboardSummary {
  const DashboardSummary({
    required this.achievementPct,
    required this.salesLabel,
    required this.targetLabel,
    required this.dayToDatePct,
    required this.dayToDateSpark,
    required this.coveragePct,
    required this.coveredDoctors,
    required this.totalDoctors,
    required this.trendMonthly,
    required this.trendQuarterly,
    required this.salesMix,
    required this.topBrands,
    required this.calls,
  });

  final int achievementPct; // 58
  final String salesLabel; // "PKR 30.1M"
  final String targetLabel; // "PKR 51.7M"
  final int dayToDatePct; // 109

  /// Five-point mini bar sparkline on the "Day to date" KPI card, as fractions
  /// of the card height (0..1). Last value is the highlighted current period.
  final List<double> dayToDateSpark;

  final int coveragePct; // 74
  final int coveredDoctors; // 4099
  final int totalDoctors; // 5514

  final List<TrendPoint> trendMonthly; // 6M view
  final List<TrendPoint> trendQuarterly; // 4Q view
  final List<SalesMixSlice> salesMix;
  final List<BrandRow> topBrands;
  final CallsSummary calls;
}

class TrendPoint {
  const TrendPoint(this.label, this.value);
  final String label; // "Jan"
  final double value; // 42
}

class SalesMixSlice {
  const SalesMixSlice(this.name, this.valueM, this.pct);
  final String name; // "Retail"
  final double valueM; // 16.0
  final int pct; // 67
}

class BrandRow {
  const BrandRow(this.name, this.salesM, this.achPct, this.golyPct);
  final String name; // "Vlep"
  final double salesM; // 8.8
  final int achPct; // 63
  final int golyPct; // 58
}

/// The "Today's calls" pair of KPI cards at the foot of the dashboard.
class CallsSummary {
  const CallsSummary({
    required this.plannedDone,
    required this.plannedTotal,
    required this.totalDone,
  });

  final int plannedDone; // 205
  final int plannedTotal; // 1242
  final int totalDone; // 285

  /// Visits logged beyond the plan — the prototype's "▲ +80 unplanned".
  int get unplanned => totalDone - plannedDone;

  /// Share of the day's plan completed, as a whole percent.
  int get planCompletionPct =>
      plannedTotal == 0 ? 0 : ((plannedDone / plannedTotal) * 100).round();
}
