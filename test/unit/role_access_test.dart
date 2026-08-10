import 'package:flutter_test/flutter_test.dart';

import 'package:eway/core/session/app_session.dart';
import 'package:eway/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:eway/features/auth/data/models/auth_session_model.dart';
import 'package:eway/features/auth/domain/entities/auth_session.dart';

void main() {
  group('AppSession.canViewTeam', () {
    AppSession withRole(UserRole role) => AppSession(
          userId: 'u',
          displayName: 'U',
          company: 'HILAL',
          accountCode: '1',
          role: role,
        );

    test('managers can view team data', () {
      expect(withRole(UserRole.manager).canViewTeam, isTrue);
    });

    test('reps cannot view team data', () {
      expect(withRole(UserRole.rep).canViewTeam, isFalse);
    });
  });

  group('role parsing fails closed', () {
    // A parsing slip must never hand a field rep their colleagues' numbers,
    // so anything not explicitly a manager is treated as a rep.
    test('recognises the manager tiers', () {
      for (final v in ['manager', 'MANAGER', ' mgr ', 'zsm', 'ASM', 'nsm']) {
        expect(
          AuthSessionModel.parseRole(v),
          AuthRole.manager,
          reason: 'expected "$v" to be a manager',
        );
      }
    });

    test('anything unrecognised, null or empty becomes a rep', () {
      for (final v in [null, '', 'rep', 'admin', 'superuser', 42, {}]) {
        expect(
          AuthSessionModel.parseRole(v),
          AuthRole.rep,
          reason: 'expected "$v" to fail closed to rep',
        );
      }
    });

    test('a payload with no role field yields a rep', () {
      final m = AuthSessionModel.fromJson(const {'userId': 'x'});
      expect(m.role, AuthRole.rep);
      expect(m.toEntity().role, AuthRole.rep);
    });

    test('role survives a JSON round-trip', () {
      const original = AuthSessionModel(
        userId: 'u',
        displayName: 'U',
        company: 'HILAL',
        accountCode: '1',
        token: 't',
        role: AuthRole.manager,
      );
      expect(
        AuthSessionModel.fromJson(original.toJson()).role,
        AuthRole.manager,
      );
    });
  });

  group('mock datasource role heuristic', () {
    test('a username containing "rep" signs in as a rep', () async {
      final s = await AuthMockDataSource().login(
        company: 'HILAL',
        username: 'field.rep',
        password: 'x',
      );
      expect(s.role, AuthRole.rep);
      expect(s.displayName, 'Demo Rep');
    });

    test('anything else signs in as a manager', () async {
      final s = await AuthMockDataSource().login(
        company: 'HILAL',
        username: 'demo.support',
        password: 'x',
      );
      expect(s.role, AuthRole.manager);
    });
  });
}
