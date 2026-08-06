import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eway/core/services/biometric_service.dart';
import 'package:eway/features/auth/presentation/screens/login_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('renders the sign-in form with all three fields', (tester) async {
    await pumpApp(tester, const LoginScreen());

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Company'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('hides the Face ID button when the device has no biometrics',
      (tester) async {
    await pumpApp(
      tester,
      const LoginScreen(),
      biometrics: FakeBiometricService(available: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unlock with Face ID'), findsNothing);
  });

  testWidgets('shows the Face ID button when biometrics are available',
      (tester) async {
    await pumpApp(
      tester,
      const LoginScreen(),
      biometrics: FakeBiometricService(
        available: true,
        result: BiometricResult.success,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unlock with Face ID'), findsOneWidget);
  });

  testWidgets('prefills the demo workspace while on placeholder data',
      (tester) async {
    await pumpApp(tester, const LoginScreen());

    final company = tester.widget<TextField>(
      find.ancestor(
        of: find.text('Company'),
        matching: find.byType(TextField),
      ),
    );
    expect(company.controller?.text, 'HILAL');
  });

  testWidgets('rejects an empty password with an inline message',
      (tester) async {
    await pumpApp(tester, const LoginScreen());

    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('Please fill in every field.'), findsOneWidget);
  });

  testWidgets('toggling Remember me flips the checkbox', (tester) async {
    await pumpApp(tester, const LoginScreen());

    expect(find.byIcon(Icons.check_box_rounded), findsOneWidget);
    await tester.tap(find.text('Remember me'));
    await tester.pump();
    expect(find.byIcon(Icons.check_box_outline_blank_rounded), findsOneWidget);
  });
}
