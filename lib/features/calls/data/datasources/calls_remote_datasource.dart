import 'package:dio/dio.dart';

import '../models/calls_snapshot_model.dart';
import 'calls_datasource.dart';

/// Real-API implementation of [CallsDataSource].
///
/// Deliberately unimplemented until the client's endpoints land — the class
/// exists so the swap point in `calls_providers.dart` is real. See
/// HANDOFF.md §9.
class CallsRemoteDataSource implements CallsDataSource {
  const CallsRemoteDataSource(this._dio);

  final Dio _dio;

  // TODO(real-api): confirm this path with the client.
  static const _path = '/calls/today';

  @override
  Future<CallsSnapshotModel> getToday() async {
    throw UnimplementedError(
      'CallsRemoteDataSource.getToday is not wired yet — the client API is '
      'pending. Run with --dart-define=USE_MOCK=true.',
    );

    // ignore: dead_code
    final res = await _dio.get<Map<String, dynamic>>(_path);
    return CallsSnapshotModel.fromJson(res.data ?? const {});
  }
}
