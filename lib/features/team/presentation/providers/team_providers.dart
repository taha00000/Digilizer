import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/team_datasource.dart';
import '../../data/datasources/team_mock_datasource.dart';
import '../../data/datasources/team_remote_datasource.dart';
import '../../data/repositories/team_repository_impl.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository.dart';

/// THE SWAP POINT for My Team — see HANDOFF.md §4.
final teamDataSourceProvider = Provider<TeamDataSource>((ref) {
  if (AppConfig.useMockData) return TeamMockDataSource();
  return TeamRemoteDataSource(ref.watch(dioProvider));
});

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepositoryImpl(ref.watch(teamDataSourceProvider));
});

/// How the rep list is ordered.
enum TeamSort { achievement, name }

final teamSortProvider = StateProvider<TeamSort>((ref) => TeamSort.achievement);

final teamProvider = FutureProvider<TeamSnapshot>((ref) async {
  final res = await ref.watch(teamRepositoryProvider).getTeam();
  return res.fold((f) => throw Exception(f.message), (s) => s);
});

/// Members ordered by the current [teamSortProvider] selection.
final sortedMembersProvider = Provider<List<TeamMember>>((ref) {
  final snapshot = ref.watch(teamProvider).valueOrNull;
  if (snapshot == null) return const [];

  final list = [...snapshot.members];
  switch (ref.watch(teamSortProvider)) {
    case TeamSort.achievement:
      list.sort((a, b) => b.achPct.compareTo(a.achPct));
    case TeamSort.name:
      list.sort((a, b) => a.name.compareTo(b.name));
  }
  return list;
});

final repDetailProvider =
    FutureProvider.family<RepDetail, String>((ref, code) async {
  final res = await ref.watch(teamRepositoryProvider).getRep(code);
  return res.fold((f) => throw Exception(f.message), (s) => s);
});
