import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/visit.dart';

abstract interface class CallsRepository {
  Future<Either<Failure, CallsSnapshot>> getToday();
}
