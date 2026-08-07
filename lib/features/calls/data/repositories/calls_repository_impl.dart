import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/database/response_cache.dart';
import '../../../../core/error/dio_failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/calls_repository.dart';
import '../datasources/calls_datasource.dart';
import '../models/calls_snapshot_model.dart';

/// Offline-first, same policy as the dashboard: write through on success, fall
/// back to cache only on a network failure.
class CallsRepositoryImpl implements CallsRepository {
  const CallsRepositoryImpl(this._ds, this._cache);

  final CallsDataSource _ds;
  final ResponseCache _cache;

  @override
  Future<Either<Failure, CallsSnapshot>> getToday() async {
    try {
      final fresh = await _ds.getToday();
      await _cache.write(CacheKeys.callsToday, fresh.toJson());
      return Right(fresh);
    } on DioException catch (e) {
      final failure = mapDioError(e);
      if (failure is! NetworkFailure) return Left(failure);

      final cached = await _cache.read(CacheKeys.callsToday);
      if (cached == null) return Left(failure);
      return Right(CallsSnapshotModel.fromJson(cached.json));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
