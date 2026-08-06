/// Domain-level failures. The data layer converts exceptions (Dio errors,
/// database errors) into these typed failures so the UI can show a human
/// message instead of a raw error. Returned via Either<Failure, T>.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Invalid credentials.']);
}

/// Raised when the device cannot do biometrics (no hardware, nothing enrolled,
/// or an unsupported platform) — distinct from the user failing the prompt, so
/// the UI can hide the Face ID affordance rather than show an error.
class BiometricUnavailableFailure extends Failure {
  const BiometricUnavailableFailure([
    super.message = 'Biometric sign-in is not available on this device.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read local data.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error.']);
}
