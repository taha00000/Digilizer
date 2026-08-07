import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/database/response_cache.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/calls_datasource.dart';
import '../../data/datasources/calls_mock_datasource.dart';
import '../../data/datasources/calls_remote_datasource.dart';
import '../../data/repositories/calls_repository_impl.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/calls_repository.dart';

/// THE SWAP POINT for Call Reporting — see HANDOFF.md §4.
final callsDataSourceProvider = Provider<CallsDataSource>((ref) {
  if (AppConfig.useMockData) return CallsMockDataSource();
  return CallsRemoteDataSource(ref.watch(dioProvider));
});

final callsRepositoryProvider = Provider<CallsRepository>((ref) {
  return CallsRepositoryImpl(
    ref.watch(callsDataSourceProvider),
    ref.watch(responseCacheProvider),
  );
});

/// Which customer type the pill row is filtered to.
enum CallAudience { doctors, chemists, institutions }

extension CallAudienceX on CallAudience {
  String get label => switch (this) {
        CallAudience.doctors => 'Doctors',
        CallAudience.chemists => 'Chemists',
        CallAudience.institutions => 'Institutions',
      };
}

/// TODO(real-api): send this as a query parameter once the client defines how
/// visits are scoped by customer type.
final callAudienceProvider =
    StateProvider<CallAudience>((ref) => CallAudience.doctors);

final callsTodayProvider = FutureProvider<CallsSnapshot>((ref) async {
  final res = await ref.watch(callsRepositoryProvider).getToday();
  return res.fold((f) => throw Exception(f.message), (s) => s);
});
