import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummary {
  const GetDashboardSummary(this._repo);
  final DashboardRepository _repo;
  Future<Either<Failure, DashboardSummary>> call() => _repo.getSummary();
}
