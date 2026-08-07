import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/database/response_cache.dart';
import '../../../../core/error/dio_failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_datasource.dart';
import '../models/dashboard_summary_model.dart';

/// Offline-first: every successful fetch is written through to the cache, and
/// a network failure falls back to the last good copy rather than showing an
/// error. A rep in a basement still sees this morning's numbers.
///
/// Only *network* failures fall back. A 500 or a parse error means the data we
/// would serve is untrustworthy, so those surface — silently showing stale
/// numbers after a server error would be worse than an honest error state.
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._ds, this._cache);

  final DashboardDataSource _ds;
  final ResponseCache _cache;

  @override
  Future<Either<Failure, DashboardSummary>> getSummary() async {
    try {
      final fresh = await _ds.getSummary();
      await _cache.write(CacheKeys.dashboardSummary, fresh.toJson());
      return Right(fresh);
    } on DioException catch (e) {
      final failure = mapDioError(e);
      if (failure is! NetworkFailure) return Left(failure);

      final cached = await _cache.read(CacheKeys.dashboardSummary);
      if (cached == null) return Left(failure);
      return Right(DashboardSummaryModel.fromJson(cached.json));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
