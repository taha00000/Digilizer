import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/dio_failure_mapper.dart';
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
      return Left(mapDioError(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
