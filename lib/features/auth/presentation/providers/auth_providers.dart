import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/token_store.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/session/session_controller.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/auth_mock_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

/// THE SWAP POINT for auth. Flip [AppConfig.useMockData] (or pass
/// `--dart-define=USE_MOCK=false`) and the whole feature talks to the real API
/// instead — no widget or controller changes. See HANDOFF.md §4.
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  if (AppConfig.useMockData) return AuthMockDataSource();
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authDataSourceProvider),
    ref.watch(biometricServiceProvider),
    ref.watch(tokenStoreProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

/// Drives whether the login screen shows the Face ID affordance at all.
final biometricAvailableProvider = FutureProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).isBiometricAvailable();
});

// --- login state ---
sealed class AuthState {
  const AuthState();
}

class AuthIdle extends AuthState {
  const AuthIdle();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess(this.session);
  final AuthSession session;
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._login, this._repo, this._session)
      : super(const AuthIdle());

  final LoginUseCase _login;
  final AuthRepository _repo;
  final SessionController _session;

  Future<void> login({
    required String company,
    required String username,
    required String password,
  }) async {
    if (state is AuthLoading) return;
    state = const AuthLoading();

    final res = await _login(
      company: company,
      username: username,
      password: password,
    );
    _apply(res.fold<AuthState>((f) => AuthError(f.message), AuthSuccess.new));
  }

  Future<void> biometric() async {
    if (state is AuthLoading) return;
    state = const AuthLoading();

    final res = await _repo.loginWithBiometrics();
    _apply(res.fold<AuthState>((f) => AuthError(f.message), AuthSuccess.new));
  }

  /// Clears any lingering success/error so a returning user lands on a fresh
  /// login form. Called when the app-wide session is dropped.
  void reset() => state = const AuthIdle();

  /// Publishing the session is what actually navigates the app: the router
  /// watches it and redirects /login → /dashboard.
  void _apply(AuthState next) {
    state = next;
    if (next is AuthSuccess) {
      _session.signIn(
        AppSession(
          userId: next.session.userId,
          displayName: next.session.displayName,
          company: next.session.company,
          accountCode: next.session.accountCode,
        ),
      );
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final controller = AuthController(
    ref.watch(loginUseCaseProvider),
    ref.watch(authRepositoryProvider),
    ref.watch(sessionControllerProvider.notifier),
  );

  // Signing out anywhere in the app resets this form back to idle.
  ref.listen<AppSession?>(sessionControllerProvider, (_, next) {
    if (next == null) controller.reset();
  });

  return controller;
});
