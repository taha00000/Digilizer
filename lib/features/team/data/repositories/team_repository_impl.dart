import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/dio_failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_datasource.dart';

class TeamRepositoryImpl implements TeamRepository {
  const TeamRepositoryImpl(this._ds);
  final TeamDataSource _ds;

  @override
  Future<Either<Failure, TeamSnapshot>> getTeam() =>
      _guard(() => _ds.getTeam());

  @override
  Future<Either<Failure, RepDetail>> getRep(String code) =>
      _guard(() => _ds.getRep(code));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on DioException catch (e) {
      return Left(mapDioError(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
