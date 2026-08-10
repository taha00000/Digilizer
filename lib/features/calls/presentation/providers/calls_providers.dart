import 'package:flutter/material.dart';
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

final _fetchedTodayProvider = FutureProvider<CallsSnapshot>((ref) async {
  final res = await ref.watch(callsRepositoryProvider).getToday();
  return res.fold((f) => throw Exception(f.message), (s) => s);
});

/// Visits logged on-device this session, held separately from the fetched
/// snapshot so a refresh does not discard them.
///
/// TODO(real-api): replace with a POST to the visit endpoint followed by an
/// invalidate. Until then this is optimistic-only and does not survive a
/// restart — which is honest, since there is nowhere to send it.
final pendingVisitsProvider = StateProvider<List<Visit>>((ref) => const []);

/// The fetched day merged with anything logged since.
final callsTodayProvider = FutureProvider<CallsSnapshot>((ref) async {
  final fetched = await ref.watch(_fetchedTodayProvider.future);
  final pending = ref.watch(pendingVisitsProvider);
  if (pending.isEmpty) return fetched;

  return CallsSnapshot(
    planned: fetched.planned,
    // Unplanned visits count as done but do not inflate the plan.
    done: fetched.done + pending.length,
    visits: [...fetched.visits, ...pending],
  );
});

/// Logs an unplanned visit against [doctorName].
void logVisit(WidgetRef ref, {required String doctorName, String? specialty}) {
  final now = TimeOfDay.fromDateTime(DateTime.now());
  final stamp = '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}';

  ref.read(pendingVisitsProvider.notifier).update(
        (list) => [
          ...list,
          Visit(
            time: stamp,
            name: doctorName,
            specialty: specialty ?? 'Unspecified',
            type: VisitType.unplanned,
            status: VisitStatus.logged,
          ),
        ],
      );
}
