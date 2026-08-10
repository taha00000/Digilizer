import 'package:flutter_test/flutter_test.dart';

import 'package:eway/core/error/failures.dart';
import 'package:eway/core/services/biometric_service.dart';
import 'package:eway/core/services/token_store.dart';
import 'package:eway/features/auth/data/datasources/auth_datasource.dart';
import 'package:eway/features/auth/domain/entities/auth_session.dart';
import 'package:eway/features/auth/data/models/auth_session_model.dart';
import 'package:eway/features/auth/data/repositories/auth_repository_impl.dart';

const _model = AuthSessionModel(
  userId: 'demo-1',
  displayName: 'Demo Support',
  company: 'HILAL',
  accountCode: '999903',
  token: 'mock-jwt-token',
  role: AuthRole.manager,
);

class _FakeDataSource implements AuthDataSource {
  _FakeDataSource({this.throws = false});
  final bool throws;
  int loginCalls = 0;
  int biometricCalls = 0;

  @override
  Future<AuthSessionModel> login({
    required String company,
    required String username,
    required String password,
  }) async {
    loginCalls++;
    if (throws) throw Exception('boom');
    return _model;
  }

  @override
  Future<AuthSessionModel> loginWithBiometrics() async {
    biometricCalls++;
    if (throws) throw Exception('boom');
    return _model;
  }
}

class _FakeBiometrics implements BiometricService {
  _FakeBiometrics(this.result, {this.available = true});
  final BiometricResult result;
  final bool available;

  @override
  Future<bool> get isAvailable async => available;

  @override
  Future<BiometricResult> authenticate({required String reason}) async =>
      result;
}

void main() {
  late InMemoryTokenStore tokens;

  setUp(() => tokens = InMemoryTokenStore());

  AuthRepositoryImpl build({
    _FakeDataSource? ds,
    BiometricResult biometric = BiometricResult.success,
  }) {
    return AuthRepositoryImpl(
      ds ?? _FakeDataSource(),
      _FakeBiometrics(biometric),
      tokens,
    );
  }

  group('login', () {
    test('returns the session and stores the token on success', () async {
      final repo = build();
      final res = await repo.login(
        company: 'HILAL',
        username: 'demo.support',
        password: 'demo1234',
      );

      expect(res.isRight(), isTrue);
      res.fold(
        (_) => fail('expected a session'),
        (s) => expect(s.displayName, 'Demo Support'),
      );
      expect(await tokens.read(), 'mock-jwt-token');
    });

    test('rejects empty fields without hitting the datasource', () async {
      final ds = _FakeDataSource();
      final repo = build(ds: ds);

      final res = await repo.login(
        company: 'HILAL',
        username: '',
        password: 'demo1234',
      );

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f.message, 'Please fill in every field.'),
        (_) => fail('expected a failure'),
      );
      expect(ds.loginCalls, 0);
      expect(await tokens.read(), isNull);
    });

    test('maps a datasource exception to AuthFailure', () async {
      final repo = build(ds: _FakeDataSource(throws: true));
      final res = await repo.login(
        company: 'HILAL',
        username: 'demo.support',
        password: 'wrong',
      );

      expect(res.isLeft(), isTrue);
      res.fold((f) => expect(f, isA<AuthFailure>()), (_) => fail('expected'));
      expect(await tokens.read(), isNull);
    });
  });

  group('loginWithBiometrics', () {
    test('signs in when the prompt succeeds', () async {
      final repo = build(biometric: BiometricResult.success);
      final res = await repo.loginWithBiometrics();

      expect(res.isRight(), isTrue);
      expect(await tokens.read(), 'mock-jwt-token');
    });

    test('fails without calling the datasource when the user cancels',
        () async {
      final ds = _FakeDataSource();
      final repo = build(ds: ds, biometric: BiometricResult.failed);

      final res = await repo.loginWithBiometrics();

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f.message, 'Biometric sign-in failed.'),
        (_) => fail('expected a failure'),
      );
      expect(ds.biometricCalls, 0);
    });

    // Tests run with USE_MOCK defaulting to true, so an unavailable sensor
    // still yields the placeholder session — that is what keeps the flow
    // usable on simulators and desktop. Against the real API this branch
    // returns BiometricUnavailableFailure instead.
    test('falls back to the mock session when biometrics are unavailable',
        () async {
      final repo = build(biometric: BiometricResult.unavailable);
      final res = await repo.loginWithBiometrics();

      expect(res.isRight(), isTrue);
    });
  });

  test('isBiometricAvailable delegates to the service', () async {
    final repo = AuthRepositoryImpl(
      _FakeDataSource(),
      _FakeBiometrics(BiometricResult.unavailable, available: false),
      tokens,
    );
    expect(await repo.isBiometricAvailable(), isFalse);
  });
}
