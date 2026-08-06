import 'package:dio/dio.dart';

import '../models/dashboard_summary_model.dart';
import 'dashboard_datasource.dart';

/// Real-API implementation of [DashboardDataSource].
///
/// Deliberately unimplemented: the client's endpoints and data structure are
/// still pending. The class exists now so the swap point in
/// `dashboard_providers.dart` is real — see HANDOFF.md §9.
///
/// To finish it:
///  1. Put the real path in [_summaryPath] (plus the period query parameter
///     once the filter pills drive the request).
///  2. Delete the `UnimplementedError` throw below.
///  3. Remap [DashboardSummaryModel.fromJson] to the client's field names.
class DashboardRemoteDataSource implements DashboardDataSource {
  const DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  // TODO(real-api): confirm this path with the client.
  static const _summaryPath = '/dashboard/summary';

  @override
  Future<DashboardSummaryModel> getSummary() async {
    throw UnimplementedError(
      'DashboardRemoteDataSource.getSummary is not wired yet — the client API '
      'is pending. Run with --dart-define=USE_MOCK=true.',
    );

    // ignore: dead_code
    final res = await _dio.get<Map<String, dynamic>>(_summaryPath);
    return DashboardSummaryModel.fromJson(res.data ?? const {});
  }
}
