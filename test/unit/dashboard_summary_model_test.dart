import 'package:flutter_test/flutter_test.dart';

import 'package:eway/features/dashboard/data/models/dashboard_summary_model.dart';

void main() {
  group('DashboardSummaryModel.fromJson', () {
    test('parses a well-formed payload', () {
      final m = DashboardSummaryModel.fromJson({
        'achievementPct': 58,
        'salesLabel': 'PKR 30.1M',
        'targetLabel': 'PKR 51.7M',
        'dayToDatePct': 109,
        'dayToDateSpark': [0.4, 0.55],
        'coveragePct': 74,
        'coveredDoctors': 4099,
        'totalDoctors': 5514,
        'trendMonthly': [
          {'label': 'Jan', 'value': 42},
        ],
        'trendQuarterly': [
          {'label': 'Q1', 'value': 140},
        ],
        'salesMix': [
          {'name': 'Retail', 'valueM': 16.0, 'pct': 67},
        ],
        'topBrands': [
          {'name': 'Vlep', 'salesM': 8.8, 'achPct': 63, 'golyPct': 58},
        ],
        'calls': {
          'plannedDone': 205,
          'plannedTotal': 1242,
          'totalDone': 285,
        },
      });

      expect(m.achievementPct, 58);
      expect(m.salesLabel, 'PKR 30.1M');
      expect(m.trendMonthly.single.label, 'Jan');
      expect(m.trendMonthly.single.value, 42);
      expect(m.salesMix.single.valueM, 16.0);
      expect(m.topBrands.single.name, 'Vlep');
      expect(m.calls.totalDone, 285);
    });

    // The client's structure is still unconfirmed, so parsing must never be
    // the thing that crashes the dashboard.
    test('survives a completely empty payload', () {
      final m = DashboardSummaryModel.fromJson(const {});

      expect(m.achievementPct, 0);
      expect(m.salesLabel, '—');
      expect(m.trendMonthly, isEmpty);
      expect(m.salesMix, isEmpty);
      expect(m.topBrands, isEmpty);
      expect(m.calls.totalDone, 0);
    });

    test('coerces numbers delivered as strings', () {
      final m = DashboardSummaryModel.fromJson({
        'achievementPct': '58',
        'coveredDoctors': 4099.0,
        'salesMix': [
          {'name': 'Retail', 'valueM': '16.0', 'pct': '67'},
        ],
      });

      expect(m.achievementPct, 58);
      expect(m.coveredDoctors, 4099);
      expect(m.salesMix.single.valueM, 16.0);
      expect(m.salesMix.single.pct, 67);
    });

    test('ignores a wrong-typed list instead of throwing', () {
      final m = DashboardSummaryModel.fromJson({'trendMonthly': 'nope'});
      expect(m.trendMonthly, isEmpty);
    });
  });

  group('CallsSummary', () {
    test('derives unplanned visits and plan completion', () {
      final m = DashboardSummaryModel.fromJson({
        'calls': {
          'plannedDone': 205,
          'plannedTotal': 1242,
          'totalDone': 285,
        },
      });

      expect(m.calls.unplanned, 80);
      expect(m.calls.planCompletionPct, 17); // 205/1242 = 16.5% → 17
    });

    test('does not divide by zero', () {
      final m = DashboardSummaryModel.fromJson(const {});
      expect(m.calls.planCompletionPct, 0);
    });
  });
}
