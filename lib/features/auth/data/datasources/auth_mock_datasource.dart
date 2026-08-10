import 'auth_datasource.dart';
import '../models/auth_session_model.dart';
import '../../domain/entities/auth_session.dart';

/// Placeholder auth. Accepts any non-empty credentials and returns the demo
/// session shown in the prototype (HILAL · ACC 999903 · Demo Support).
/// Replace with AuthRemoteDataSource when the API is ready.
class AuthMockDataSource implements AuthDataSource {
  /// Lets the role gating be exercised before the API exists: sign in as
  /// anything containing "rep" to get the field-rep view, anything else to get
  /// the manager view.
  ///
  /// TODO(real-api): the server decides the role; delete this heuristic.
  static AuthRole roleForUsername(String username) {
    return username.toLowerCase().contains('rep')
        ? AuthRole.rep
        : AuthRole.manager;
  }

  AuthSessionModel _session(AuthRole role) => AuthSessionModel(
        userId: 'demo-1',
        displayName: role == AuthRole.rep ? 'Demo Rep' : 'Demo Support',
        company: 'HILAL',
        accountCode: '999903',
        token: 'mock-jwt-token',
        role: role,
      );

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
    return _session(roleForUsername(username));
  }

  @override
  Future<AuthSessionModel> loginWithBiometrics() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // Biometric unlock resumes the last session, which in the mock is the
    // manager. The real implementation reads the role off the stored token.
    return _session(AuthRole.manager);
  }
}
