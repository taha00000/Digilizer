import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/reports_datasource.dart';
import '../../data/datasources/reports_mock_datasource.dart';
import '../../data/datasources/reports_remote_datasource.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/entities/report_output.dart';
import '../../domain/repositories/reports_repository.dart';

/// THE SWAP POINT for Reports — see HANDOFF.md §4.
final reportsDataSourceProvider = Provider<ReportsDataSource>((ref) {
  if (AppConfig.useMockData) return ReportsMockDataSource();
  return ReportsRemoteDataSource(ref.watch(dioProvider));
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(ref.watch(reportsDataSourceProvider));
});

/// The two report filters. Free-form strings for now — they become real
/// pickers when the client confirms the member list and date format.
final reportDateProvider = StateProvider<String>((ref) => '17 Jun 2026');
final reportMemberProvider =
    StateProvider<String>((ref) => 'Gohar Zaman · 004324');

/// Null until the user taps "View report", so the output stays hidden the way
/// the prototype does rather than running on screen entry.
class ReportRunner extends StateNotifier<AsyncValue<ReportOutput>?> {
  ReportRunner(this._repo, this._read) : super(null);

  final ReportsRepository _repo;
  final String Function() _read;

  Future<void> run({required String member}) async {
    state = const AsyncValue.loading();
    final res = await _repo.runActivityReport(member: member, date: _read());
    state = res.fold(
      (f) => AsyncValue.error(f.message, StackTrace.current),
      AsyncValue.data,
    );
  }

  void clear() => state = null;
}

final reportRunnerProvider =
    StateNotifierProvider<ReportRunner, AsyncValue<ReportOutput>?>((ref) {
  return ReportRunner(
    ref.watch(reportsRepositoryProvider),
    () => ref.read(reportDateProvider),
  );
});
