import 'package:dio/dio.dart';

import '../../domain/entities/report_output.dart';
import 'reports_datasource.dart';

/// Real-API implementation of [ReportsDataSource].
///
/// Deliberately unimplemented until the client's endpoints land — the class
/// exists so the swap point in `reports_providers.dart` is real. See
/// HANDOFF.md §9.
class ReportsRemoteDataSource implements ReportsDataSource {
  const ReportsRemoteDataSource(this._dio);

  // ignore: unused_field — used once the endpoint below is implemented.
  final Dio _dio;

  // TODO(real-api): confirm this path with the client.
  static const path = '/reports/activity';

  @override
  Future<ReportOutput> runActivityReport({
    required String member,
    required String date,
  }) async {
    throw UnimplementedError(
      'ReportsRemoteDataSource.runActivityReport is not wired yet — the client '
      'API is pending. Run with --dart-define=USE_MOCK=true.',
    );
  }
}
