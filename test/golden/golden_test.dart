import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eway/core/theme/app_theme.dart';
import 'package:eway/features/auth/presentation/screens/login_screen.dart';
import 'package:eway/features/dashboard/presentation/screens/dashboard_screen.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_harness.dart';

/// Golden tests across all three approved themes.
///
/// Regenerate after an intentional UI change:
///   flutter test --update-goldens
void main() {
  setUpAll(loadTestFonts);

  /// Phone-sized surface (iPhone-class logical width).
  Future<void> setSurface(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  for (final theme in AppThemeId.values) {
    testWidgets('login - ${theme.name}', (tester) async {
      await setSurface(tester, const Size(393, 852));
      await pumpApp(tester, const LoginScreen(), theme: theme);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LoginScreen),
        matchesGoldenFile('images/login_${theme.name}.png'),
      );
    });

    testWidgets('dashboard - ${theme.name}', (tester) async {
      await setSurface(tester, const Size(393, 852));
      await pumpApp(
        tester,
        const DashboardScreen(),
        theme: theme,
        session: demoSession,
      );
      // Advance past the mock datasource's Future.delayed - pumpAndSettle
      // waits on scheduled frames, not plain timers.
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DashboardScreen),
        matchesGoldenFile('images/dashboard_${theme.name}.png'),
      );
    });
  }

  testWidgets('dashboard - full scroll extent - aurora', (tester) async {
    await setSurface(tester, const Size(393, 2400));
    await pumpApp(
      tester,
      const DashboardScreen(),
      theme: AppThemeId.aurora,
      session: demoSession,
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(DashboardScreen),
      matchesGoldenFile('images/dashboard_full_aurora.png'),
    );
  });
}
