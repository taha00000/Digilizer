import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_session.dart';

/// Contract the presentation layer depends on. Implemented in the data layer.
abstract interface class AuthRepository {
  Future<Either<Failure, AuthSession>> login({
    required String company,
    required String username,
    required String password,
  });

  Future<Either<Failure, AuthSession>> loginWithBiometrics();

  /// Whether this device can show a Face ID / fingerprint prompt. The login
  /// screen hides the biometric affordance when false.
  Future<bool> isBiometricAvailable();

  // Sign-out is deliberately NOT here: it clears state this feature does not
  // own (token store, and later the Drift cache), so it lives app-wide in
  // core/session/session_controller.dart → signOutProvider.
}
