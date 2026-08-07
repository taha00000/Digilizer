import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eway/core/services/biometric_service.dart';
import 'package:eway/features/auth/presentation/screens/login_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('renders the sign-in form with all three fields', (tester) async {
    await pumpApp(tester, const LoginScreen());

    expect(find.text('Sign in'), findsWidgets);
    // `.linput .ll` is uppercased in CSS; we bake that into the label.
    expect(find.text('COMPANY'), findsOneWidget);
    expect(find.text('USERNAME'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
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

    // find.text also matches EditableText, so this asserts on field values.
    expect(find.text('HILAL'), findsOneWidget);
    expect(find.text('demo.support'), findsOneWidget);
  });

  testWidgets('rejects a blanked-out field with an inline message',
      (tester) async {
    await pumpApp(tester, const LoginScreen());

    // Clear the username (index 1: company, username, password).
    await tester.enterText(find.byType(TextField).at(1), '');
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

  testWidgets('password is obscured until the reveal toggle is tapped',
      (tester) async {
    await pumpApp(tester, const LoginScreen());

    TextField passwordField() =>
        tester.widget<TextField>(find.byType(TextField).at(2));

    expect(passwordField().obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(passwordField().obscureText, isFalse);
  });
}
