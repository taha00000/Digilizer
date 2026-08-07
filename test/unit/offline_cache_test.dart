import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eway/core/database/app_database.dart';
import 'package:eway/core/database/response_cache.dart';
import 'package:eway/core/error/failures.dart';
import 'package:eway/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:eway/features/dashboard/data/datasources/dashboard_mock_datasource.dart';
import 'package:eway/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:eway/features/dashboard/data/repositories/dashboard_repository_impl.dart';

/// Fails every call with the given Dio error, so the repository has to fall
/// back to whatever is cached.
class _OfflineDataSource implements DashboardDataSource {
  _OfflineDataSource(this.type, {this.status});
  final DioExceptionType type;
  final int? status;

  @override
  Future<DashboardSummaryModel> getSummary() async {
    throw DioException(
      requestOptions: RequestOptions(path: '/dashboard/summary'),
      type: type,
      response: status == null
          ? null
          : Response<dynamic>(
              requestOptions: RequestOptions(path: '/dashboard/summary'),
              statusCode: status,
            ),
    );
  }
}

void main() {
  late AppDatabase db;
  late ResponseCache cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cache = DriftResponseCache(db);
  });

  tearDown(() => db.close());

  group('ResponseCache', () {
    test('round-trips a payload', () async {
      await cache.write('k', {'a': 1, 'b': 'two'});
      final got = await cache.read('k');

      expect(got, isNotNull);
      expect(got!.json['a'], 1);
      expect(got.json['b'], 'two');
      expect(got.age.inSeconds, lessThan(5));
    });

    test('misses on an unknown key', () async {
      expect(await cache.read('nope'), isNull);
    });

    test('overwrites an existing key rather than duplicating', () async {
      await cache.write('k', {'v': 1});
      await cache.write('k', {'v': 2});
      expect((await cache.read('k'))!.json['v'], 2);
    });

    test('clear() empties the cache', () async {
      await cache.write('k', {'v': 1});
      await cache.clear();
      expect(await cache.read('k'), isNull);
    });
  });

  group('offline read path', () {
    test('writes through on a successful fetch', () async {
      final repo = DashboardRepositoryImpl(DashboardMockDataSource(), cache);
      await repo.getSummary();

      final cached = await cache.read(CacheKeys.dashboardSummary);
      expect(cached, isNotNull);
      expect(cached!.json['achievementPct'], 58);
    });

    test('serves the cached copy when the network is down', () async {
      // Warm the cache from a good fetch...
      await DashboardRepositoryImpl(DashboardMockDataSource(), cache)
          .getSummary();

      // ...then go offline.
      final offline = DashboardRepositoryImpl(
        _OfflineDataSource(DioExceptionType.connectionError),
        cache,
      );
      final res = await offline.getSummary();

      expect(res.isRight(), isTrue);
      res.fold(
        (_) => fail('expected the cached summary'),
        (s) {
          expect(s.achievementPct, 58);
          expect(s.topBrands.first.name, 'Vlep');
          expect(s.salesMix.length, 4);
          expect(s.calls.totalDone, 285);
        },
      );
    });

    test('fails when offline with a cold cache', () async {
      final repo = DashboardRepositoryImpl(
        _OfflineDataSource(DioExceptionType.connectionError),
        cache,
      );
      final res = await repo.getSummary();

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected'),
      );
    });

    // A server error means the data we would serve is untrustworthy, so it
    // must surface rather than silently showing yesterday's numbers.
    test('does NOT fall back to cache on a 500', () async {
      await DashboardRepositoryImpl(DashboardMockDataSource(), cache)
          .getSummary();

      final repo = DashboardRepositoryImpl(
        _OfflineDataSource(DioExceptionType.badResponse, status: 500),
        cache,
      );
      final res = await repo.getSummary();

      expect(res.isLeft(), isTrue);
      res.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('expected'));
    });

    test('does NOT fall back to cache on a 401', () async {
      await DashboardRepositoryImpl(DashboardMockDataSource(), cache)
          .getSummary();

      final repo = DashboardRepositoryImpl(
        _OfflineDataSource(DioExceptionType.badResponse, status: 401),
        cache,
      );
      final res = await repo.getSummary();

      res.fold((f) => expect(f, isA<AuthFailure>()), (_) => fail('expected'));
    });
  });

  test('cached payload survives a full model round-trip', () async {
    final original = await DashboardMockDataSource().getSummary();
    await cache.write(CacheKeys.dashboardSummary, original.toJson());

    final restored = DashboardSummaryModel.fromJson(
      (await cache.read(CacheKeys.dashboardSummary))!.json,
    );

    expect(restored.achievementPct, original.achievementPct);
    expect(restored.salesLabel, original.salesLabel);
    expect(restored.dayToDateSpark, original.dayToDateSpark);
    expect(restored.trendMonthly.length, original.trendMonthly.length);
    expect(restored.trendMonthly.last.label, 'Jun');
    expect(restored.trendQuarterly.last.value, 182);
    expect(restored.topBrands.last.golyPct, 40);
    expect(restored.calls.unplanned, original.calls.unplanned);
  });
}
