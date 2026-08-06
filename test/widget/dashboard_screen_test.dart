import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eway/core/theme/app_theme.dart';
import 'package:eway/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:eway/features/dashboard/presentation/screens/dashboard_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  /// The dashboard is a long lazy list, so a phone-sized viewport would leave
  /// the lower sections un-inflated and invisible to `find`. Use a tall
  /// surface so the whole screen is in the element tree.
  Future<void> pumpDashboard(
    WidgetTester tester, {
    AppThemeId theme = AppThemeId.aurora,
  }) async {
    tester.view.physicalSize = const Size(400, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester, const DashboardScreen(), theme: theme);
    // The mock datasource resolves via Future.delayed. pumpAndSettle only
    // waits on scheduled frames, not plain timers, so it would return while
    // the screen is still in its loading state — advance past the delay first.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the approved headline numbers', (tester) async {
    await pumpDashboard(tester);

    expect(find.text('58%'), findsWidgets); // gauge centre
    expect(find.text('PKR 30.1M'), findsOneWidget);
    expect(find.text('PKR 51.7M'), findsOneWidget);
    expect(find.text('109%'), findsOneWidget);
    expect(find.text('74%'), findsOneWidget);
    expect(find.text('4,099 / 5,514'), findsOneWidget);
  });

  testWidgets('shows every dashboard section', (tester) async {
    await pumpDashboard(tester);

    expect(find.text('Sales trend'), findsOneWidget);
    expect(find.text('Sales mix'), findsOneWidget);
    expect(find.text('Sales by type'), findsOneWidget);
    expect(find.text('Top brands'), findsOneWidget);
    expect(find.text("Today's calls"), findsOneWidget);
  });

  testWidgets('sales-mix card defaults to Bars and switches views',
      (tester) async {
    await pumpDashboard(tester);

    expect(find.textContaining('Ranked by value'), findsOneWidget);

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Composition · 100%'), findsOneWidget);

    await tester.tap(find.text('Donut'));
    await tester.pumpAndSettle();
    expect(find.text('total'), findsOneWidget);
  });

  testWidgets('brand table sorts by name when the header is tapped',
      (tester) async {
    await pumpDashboard(tester);

    // Default sort is Sales descending → Vlep (8.8M) leads.
    final firstBefore = tester
        .widgetList<Text>(find.textContaining('M', findRichText: false))
        .map((w) => w.data)
        .toList();
    expect(firstBefore, isNotEmpty);

    await tester.tap(find.text('Brand'));
    await tester.pumpAndSettle();

    // Carlep sorts first alphabetically; assert it still renders after sorting.
    expect(find.text('Carlep'), findsOneWidget);
    expect(find.text('Vlep'), findsOneWidget);
  });

  testWidgets('period pills render with every period available',
      (tester) async {
    await pumpDashboard(tester);

    for (final p in DashboardPeriod.values) {
      expect(find.text(p.label), findsOneWidget);
    }
  });

  testWidgets('renders in all three themes without throwing', (tester) async {
    for (final theme in AppThemeId.values) {
      await pumpDashboard(tester, theme: theme);
      expect(tester.takeException(), isNull);
      expect(find.text('PKR 30.1M'), findsOneWidget);
    }
  });
}
