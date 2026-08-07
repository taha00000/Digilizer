import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Single responsibility: perform a username/password login.
class LoginUseCase {
  const LoginUseCase(this._repo);
  final AuthRepository _repo;

  Future<Either<Failure, AuthSession>> call({
    required String company,
    required String username,
    required String password,
  }) {
    return _repo.login(
      company: company,
      username: username,
      password: password,
    );
  }
}
