import 'package:flutter_test/flutter_test.dart';

import 'package:eway/core/session/app_session.dart';

AppSession session(String name) => AppSession(
      userId: 'u1',
      displayName: name,
      company: 'HILAL',
      accountCode: '999903',
    );

void main() {
  group('AppSession.initials', () {
    test('uses first and last name', () {
      expect(session('Demo Support').initials, 'DS');
    });

    test('falls back to a single letter for one-word names', () {
      expect(session('Demo').initials, 'D');
    });

    test('skips middle names', () {
      expect(session('Ali Raza Khan').initials, 'AK');
    });

    test('tolerates extra whitespace', () {
      expect(session('  Demo   Support  ').initials, 'DS');
    });

    test('does not crash on an empty name', () {
      expect(session('').initials, '?');
    });
  });

  test('descriptor matches the prototype header', () {
    expect(
      session('Demo Support').descriptor,
      'Demo Support · HILAL · ACC 999903',
    );
  });
}
