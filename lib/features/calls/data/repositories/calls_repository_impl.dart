import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/dio_failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/calls_repository.dart';
import '../datasources/calls_datasource.dart';

class CallsRepositoryImpl implements CallsRepository {
  const CallsRepositoryImpl(this._ds);
  final CallsDataSource _ds;

  @override
  Future<Either<Failure, CallsSnapshot>> getToday() async {
    try {
      return Right(await _ds.getToday());
    } on DioException catch (e) {
      return Left(mapDioError(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
