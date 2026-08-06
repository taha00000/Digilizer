import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/token_store.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource, this._biometrics, this._tokens);

  final AuthDataSource _dataSource;
  final BiometricService _biometrics;
  final TokenStore _tokens;

  @override
  Future<Either<Failure, AuthSession>> login({
    required String company,
    required String username,
    required String password,
  }) async {
    if (company.isEmpty || username.isEmpty || password.isEmpty) {
      return const Left(AuthFailure('Please fill in every field.'));
    }

    try {
      final model = await _dataSource.login(
        company: company,
        username: username,
        password: password,
      );
      await _tokens.write(model.token);
      return Right(model.toEntity());
    } catch (_) {
      return const Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, AuthSession>> loginWithBiometrics() async {
    final result = await _biometrics.authenticate(
      reason: 'Unlock eWay to view your dashboard',
    );

    if (result == BiometricResult.failed) {
      return const Left(AuthFailure('Biometric sign-in failed.'));
    }

    // While we run on placeholder data we still want this flow usable on
    // simulators and desktop, so an unavailable sensor still yields the mock
    // session. Against the real API it is a hard stop — the user signs in
    // with a password instead.
    if (result == BiometricResult.unavailable && !AppConfig.useMockData) {
      return const Left(BiometricUnavailableFailure());
    }

    try {
      final model = await _dataSource.loginWithBiometrics();
      await _tokens.write(model.token);
      return Right(model.toEntity());
    } catch (_) {
      return const Left(AuthFailure('Biometric sign-in failed.'));
    }
  }

  @override
  Future<bool> isBiometricAvailable() => _biometrics.isAvailable;
}
