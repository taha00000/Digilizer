import 'dashboard_datasource.dart';
import '../models/dashboard_summary_model.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Placeholder dashboard data. Numbers mirror the approved prototype exactly,
/// so the built app matches what the client already signed off.
///
/// TODO(real-api): replaced by DashboardRemoteDataSource once the client's
/// data structure arrives — see dashboard_providers.dart for the swap point.
class DashboardMockDataSource implements DashboardDataSource {
  @override
  Future<DashboardSummaryModel> getSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const DashboardSummaryModel(
      achievementPct: 58,
      salesLabel: 'PKR 30.1M',
      targetLabel: 'PKR 51.7M',
      dayToDatePct: 109,
      dayToDateSpark: [0.40, 0.55, 0.48, 0.70, 1.0],
      coveragePct: 74,
      coveredDoctors: 4099,
      totalDoctors: 5514,
      trendMonthly: [
        TrendPoint('Jan', 42),
        TrendPoint('Feb', 48),
        TrendPoint('Mar', 45),
        TrendPoint('Apr', 58),
        TrendPoint('May', 62),
        TrendPoint('Jun', 71),
      ],
      trendQuarterly: [
        TrendPoint('Q1', 140),
        TrendPoint('Q2', 165),
        TrendPoint('Q3', 158),
        TrendPoint('Q4', 182),
      ],
      salesMix: [
        SalesMixSlice('Retail', 16.0, 67),
        SalesMixSlice('Institution', 4.5, 19),
        SalesMixSlice('Doctor', 2.2, 9),
        SalesMixSlice('Wholesale', 1.4, 5),
      ],
      topBrands: [
        BrandRow('Vlep', 8.8, 63, 58),
        BrandRow('Cubriva', 8.3, 64, 101),
        BrandRow('Carlep', 4.9, 64, 179),
        BrandRow('Seipil', 2.3, 62, 55),
        BrandRow('Prixteen', 2.0, 58, 40),
      ],
      calls: CallsSummary(
        plannedDone: 205,
        plannedTotal: 1242,
        totalDone: 285,
      ),
    );
  }
}
