import 'package:dio/dio.dart';

import '../../domain/entities/team.dart';
import 'team_datasource.dart';

/// Real-API implementation of [TeamDataSource].
///
/// Deliberately unimplemented until the client's endpoints land — the class
/// exists so the swap point in `team_providers.dart` is real. See HANDOFF.md §9.
///
/// When wiring this up, add a `TeamSnapshotModel` / `RepDetailModel` pair
/// alongside the other features' models rather than parsing here.
class TeamRemoteDataSource implements TeamDataSource {
  const TeamRemoteDataSource(this._dio);

  // ignore: unused_field — used once the endpoints below are implemented.
  final Dio _dio;

  // TODO(real-api): confirm these paths with the client.
  static const teamPath = '/team';
  static const repPath = '/team/rep';

  @override
  Future<TeamSnapshot> getTeam() async {
    throw UnimplementedError(
      'TeamRemoteDataSource.getTeam is not wired yet — the client API is '
      'pending. Run with --dart-define=USE_MOCK=true.',
    );
  }

  @override
  Future<RepDetail> getRep(String code) async {
    throw UnimplementedError(
      'TeamRemoteDataSource.getRep is not wired yet — the client API is '
      'pending. Run with --dart-define=USE_MOCK=true.',
    );
  }
}
