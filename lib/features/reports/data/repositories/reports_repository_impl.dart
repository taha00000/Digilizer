import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/dio_failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/report_output.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._ds);
  final ReportsDataSource _ds;

  @override
  Future<Either<Failure, ReportOutput>> runActivityReport({
    required String member,
    required String date,
  }) async {
    try {
      return Right(
        await _ds.runActivityReport(member: member, date: date),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
