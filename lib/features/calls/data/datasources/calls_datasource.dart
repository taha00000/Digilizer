import '../models/calls_snapshot_model.dart';

/// Swap point: CallsMockDataSource (now) vs CallsRemoteDataSource (later).
abstract interface class CallsDataSource {
  Future<CallsSnapshotModel> getToday();
}
