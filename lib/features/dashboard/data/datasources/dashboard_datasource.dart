import '../models/dashboard_summary_model.dart';

/// Swap point: DashboardMockDataSource (now) vs DashboardRemoteDataSource
/// (later, real API). The repository depends on this abstraction, so switching
/// implementations touches no UI.
abstract interface class DashboardDataSource {
  Future<DashboardSummaryModel> getSummary();
}
