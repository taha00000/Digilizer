import 'package:flutter_test/flutter_test.dart';

import 'package:eway/core/database/response_cache.dart';
import 'package:eway/features/dashboard/data/datasources/dashboard_mock_datasource.dart';
import 'package:eway/features/dashboard/data/repositories/dashboard_repository_impl.dart';

/// Failure mapping and the cache fallback are covered in
/// `offline_cache_test.dart`, which exercises them against a real Drift
/// database. This file just pins the happy path.
void main() {
  test('returns the summary from the datasource', () async {
    final repo = DashboardRepositoryImpl(
      DashboardMockDataSource(),
      const NoopResponseCache(),
    );
    final res = await repo.getSummary();

    expect(res.isRight(), isTrue);
    res.fold(
      (_) => fail('expected a summary'),
      (s) {
        expect(s.achievementPct, 58);
        expect(s.topBrands.first.name, 'Vlep');
        expect(s.salesMix.length, 4);
        expect(s.trendMonthly.length, 6);
        expect(s.calls.unplanned, 80);
      },
    );
  });
}
