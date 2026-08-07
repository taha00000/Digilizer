import '../../domain/entities/dashboard_summary.dart';

/// Data-layer model for the dashboard payload. It extends the domain entity,
/// so the mapping to the domain layer is free while JSON parsing stays out of
/// `domain/` entirely.
///
/// TODO(real-api): the keys below mirror the PROVISIONAL shape taken from the
/// approved prototype, NOT the client's API. When their data structure lands,
/// remap [fromJson] here — no widget, provider or use-case changes.
class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.achievementPct,
    required super.salesLabel,
    required super.targetLabel,
    required super.dayToDatePct,
    required super.dayToDateSpark,
    required super.coveragePct,
    required super.coveredDoctors,
    required super.totalDoctors,
    required super.trendMonthly,
    required super.trendQuarterly,
    required super.salesMix,
    required super.topBrands,
    required super.calls,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      achievementPct: _int(json['achievementPct']),
      salesLabel: json['salesLabel']?.toString() ?? '—',
      targetLabel: json['targetLabel']?.toString() ?? '—',
      dayToDatePct: _int(json['dayToDatePct']),
      dayToDateSpark: _list(json['dayToDateSpark'])
          .map((e) => _double(e))
          .toList(growable: false),
      coveragePct: _int(json['coveragePct']),
      coveredDoctors: _int(json['coveredDoctors']),
      totalDoctors: _int(json['totalDoctors']),
      trendMonthly: _list(json['trendMonthly']).map(_trend).toList(),
      trendQuarterly: _list(json['trendQuarterly']).map(_trend).toList(),
      salesMix: _list(json['salesMix']).map(_slice).toList(),
      topBrands: _list(json['topBrands']).map(_brand).toList(),
      calls: _calls(json['calls']),
    );
  }

  /// Serialised for the offline cache. Mirrors [fromJson] exactly — the same
  /// parser has to read it back, so the two must be changed together when the
  /// real API shape lands.
  Map<String, dynamic> toJson() => {
        'achievementPct': achievementPct,
        'salesLabel': salesLabel,
        'targetLabel': targetLabel,
        'dayToDatePct': dayToDatePct,
        'dayToDateSpark': dayToDateSpark,
        'coveragePct': coveragePct,
        'coveredDoctors': coveredDoctors,
        'totalDoctors': totalDoctors,
        'trendMonthly': trendMonthly.map(_trendJson).toList(),
        'trendQuarterly': trendQuarterly.map(_trendJson).toList(),
        'salesMix': salesMix.map(_sliceJson).toList(),
        'topBrands': topBrands.map(_brandJson).toList(),
        'calls': {
          'plannedDone': calls.plannedDone,
          'plannedTotal': calls.plannedTotal,
          'totalDone': calls.totalDone,
        },
      };

  static Map<String, dynamic> _trendJson(TrendPoint p) => {
        'label': p.label,
        'value': p.value,
      };

  static Map<String, dynamic> _sliceJson(SalesMixSlice s) => {
        'name': s.name,
        'valueM': s.valueM,
        'pct': s.pct,
      };

  static Map<String, dynamic> _brandJson(BrandRow b) => {
        'name': b.name,
        'salesM': b.salesM,
        'achPct': b.achPct,
        'golyPct': b.golyPct,
      };

  // --- defensive primitives: the API shape is unconfirmed, so never let a
  // missing or oddly-typed field crash the dashboard. ---

  static List<dynamic> _list(dynamic v) => v is List ? v : const [];

  static int _int(dynamic v) => switch (v) {
        final int i => i,
        final num n => n.round(),
        final String s => int.tryParse(s) ?? 0,
        _ => 0,
      };

  static double _double(dynamic v) => switch (v) {
        final double d => d,
        final num n => n.toDouble(),
        final String s => double.tryParse(s) ?? 0,
        _ => 0,
      };

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map<String, dynamic> ? v : const {};

  static TrendPoint _trend(dynamic v) {
    final m = _map(v);
    return TrendPoint(m['label']?.toString() ?? '', _double(m['value']));
  }

  static SalesMixSlice _slice(dynamic v) {
    final m = _map(v);
    return SalesMixSlice(
      m['name']?.toString() ?? '',
      _double(m['valueM']),
      _int(m['pct']),
    );
  }

  static BrandRow _brand(dynamic v) {
    final m = _map(v);
    return BrandRow(
      m['name']?.toString() ?? '',
      _double(m['salesM']),
      _int(m['achPct']),
      _int(m['golyPct']),
    );
  }

  static CallsSummary _calls(dynamic v) {
    final m = _map(v);
    return CallsSummary(
      plannedDone: _int(m['plannedDone']),
      plannedTotal: _int(m['plannedTotal']),
      totalDone: _int(m['totalDone']),
    );
  }
}
