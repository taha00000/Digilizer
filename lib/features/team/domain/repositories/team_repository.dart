import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/team.dart';

abstract interface class TeamRepository {
  Future<Either<Failure, TeamSnapshot>> getTeam();

  /// [code] is the rep's account code, e.g. `004324`.
  Future<Either<Failure, RepDetail>> getRep(String code);
}
