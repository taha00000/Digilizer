import 'auth_datasource.dart';
import '../models/auth_session_model.dart';

/// Placeholder auth. Accepts any non-empty credentials and returns the demo
/// session shown in the prototype (HILAL · ACC 999903 · Demo Support).
/// Replace with AuthRemoteDataSource when the API is ready.
class AuthMockDataSource implements AuthDataSource {
  @override
  Future<AuthSessionModel> login({
    required String company,
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (company.isEmpty || username.isEmpty || password.isEmpty) {
      throw Exception('Missing credentials');
    }
    return const AuthSessionModel(
      userId: 'demo-1',
      displayName: 'Demo Support',
      company: 'HILAL',
      accountCode: '999903',
      token: 'mock-jwt-token',
    );
  }

  @override
  Future<AuthSessionModel> loginWithBiometrics() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const AuthSessionModel(
      userId: 'demo-1',
      displayName: 'Demo Support',
      company: 'HILAL',
      accountCode: '999903',
      token: 'mock-jwt-token',
    );
  }
}
