import '../../domain/entities/team.dart';

/// Swap point: TeamMockDataSource (now) vs TeamRemoteDataSource (later).
abstract interface class TeamDataSource {
  Future<TeamSnapshot> getTeam();
  Future<RepDetail> getRep(String code);
}
