import 'package:dio/dio.dart';

import '../models/auth_session_model.dart';
import 'auth_datasource.dart';

/// Real-API implementation of [AuthDataSource].
///
/// Deliberately unimplemented: the client's endpoints and data structure are
/// still pending. The class exists now so the swap point in
/// `auth_providers.dart` is real and the wiring can be reviewed — see
/// HANDOFF.md §9 for the checklist when the API lands.
///
/// To finish it:
///  1. Put the real paths in [_loginPath] / [_biometricPath].
///  2. Delete the `UnimplementedError` throws below.
///  3. Remap [AuthSessionModel.fromJson] to the client's field names.
class AuthRemoteDataSource implements AuthDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  // TODO(real-api): confirm these paths with the client.
  static const _loginPath = '/auth/login';
  static const _biometricPath = '/auth/biometric';

  @override
  Future<AuthSessionModel> login({
    required String company,
    required String username,
    required String password,
  }) async {
    throw UnimplementedError(
      'AuthRemoteDataSource.login is not wired yet — the client API is '
      'pending. Run with --dart-define=USE_MOCK=true.',
    );

    // ignore: dead_code
    final res = await _dio.post<Map<String, dynamic>>(
      _loginPath,
      data: {
        'company': company,
        'username': username,
        'password': password,
      },
    );
    return AuthSessionModel.fromJson(res.data ?? const {});
  }

  @override
  Future<AuthSessionModel> loginWithBiometrics() async {
    throw UnimplementedError(
      'AuthRemoteDataSource.loginWithBiometrics is not wired yet — the client '
      'API is pending. Run with --dart-define=USE_MOCK=true.',
    );

    // ignore: dead_code
    final res = await _dio.post<Map<String, dynamic>>(_biometricPath);
    return AuthSessionModel.fromJson(res.data ?? const {});
  }
}
