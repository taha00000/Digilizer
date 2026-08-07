import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._ds);
  final DashboardDataSource _ds;

  @override
  Future<Either<Failure, DashboardSummary>> getSummary() async {
    try {
      // The model extends the entity, so this is already a DashboardSummary.
      return Right(await _ds.getSummary());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  /// TODO(real-api): once Drift is wired, fall back to the cached summary here
  /// instead of surfacing a NetworkFailure (report §5, offline-first).
  Failure _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        const NetworkFailure(),
      DioExceptionType.badResponse => e.response?.statusCode == 401
          ? const AuthFailure()
          : const ServerFailure(),
      _ => const ServerFailure(),
    };
  }
}
