import '../models/auth_session_model.dart';

/// Abstraction over "where auth data comes from". Two implementations:
///  - AuthMockDataSource (now, placeholder)
///  - AuthRemoteDataSource (later, real API) — create when endpoints arrive.
/// The repository depends on THIS, so swapping data sources touches no UI.
abstract interface class AuthDataSource {
  Future<AuthSessionModel> login({
    required String company,
    required String username,
    required String password,
  });

  Future<AuthSessionModel> loginWithBiometrics();
}
