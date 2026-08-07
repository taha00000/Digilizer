import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/report_output.dart';

abstract interface class ReportsRepository {
  /// Runs the Activity Details report for [member] on [date].
  Future<Either<Failure, ReportOutput>> runActivityReport({
    required String member,
    required String date,
  });
}
