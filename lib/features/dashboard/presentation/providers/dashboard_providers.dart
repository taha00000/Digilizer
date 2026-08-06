import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/dashboard_datasource.dart';
import '../../data/datasources/dashboard_mock_datasource.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_summary.dart';

/// THE SWAP POINT for the dashboard — see HANDOFF.md §4.
final dashboardDataSourceProvider = Provider<DashboardDataSource>((ref) {
  if (AppConfig.useMockData) return DashboardMockDataSource();
  return DashboardRemoteDataSource(ref.watch(dioProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardDataSourceProvider));
});

final getDashboardSummaryProvider = Provider<GetDashboardSummary>((ref) {
  return GetDashboardSummary(ref.watch(dashboardRepositoryProvider));
});

/// The period selected by the filter pills.
///
/// TODO(real-api): pass this to the summary request once the client confirms
/// how they scope the numbers.
enum DashboardPeriod { thisMonth, day, ytd, vsLastYear }

extension DashboardPeriodX on DashboardPeriod {
  String get label => switch (this) {
        DashboardPeriod.thisMonth => 'This month',
        DashboardPeriod.day => 'Day',
        DashboardPeriod.ytd => 'YTD',
        DashboardPeriod.vsLastYear => 'vs LY',
      };
}

final dashboardPeriodProvider =
    StateProvider<DashboardPeriod>((ref) => DashboardPeriod.thisMonth);

/// AsyncValue gives the UI loading / data / error in one object.
///
/// Throwing the failure's message keeps the error path readable in the widget
/// layer; the typed [Failure] is still available from the repository if a
/// screen ever needs to branch on it.
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final res = await ref.watch(getDashboardSummaryProvider)();
  return res.fold((f) => throw Exception(f.message), (s) => s);
});
