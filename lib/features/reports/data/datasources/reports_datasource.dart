import '../../domain/entities/report_output.dart';

/// Swap point: ReportsMockDataSource (now) vs ReportsRemoteDataSource (later).
abstract interface class ReportsDataSource {
  Future<ReportOutput> runActivityReport({
    required String member,
    required String date,
  });
}
