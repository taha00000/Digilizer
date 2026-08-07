import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eway/features/calls/presentation/screens/calls_screen.dart';
import 'package:eway/features/modules/presentation/screens/modules_screen.dart';
import 'package:eway/features/reports/presentation/screens/report_output_screen.dart';
import 'package:eway/features/reports/presentation/screens/reports_screen.dart';
import 'package:eway/features/team/presentation/screens/rep_detail_screen.dart';
import 'package:eway/features/team/presentation/screens/team_screen.dart';

import '../helpers/test_harness.dart';

/// Renders every screen added beyond login + dashboard, on a tall surface so
/// the lazy list inflates the whole page.
///
/// These assert on the data actually reaching the widget tree, which is what
/// proves each feature's mock datasource → repository → provider chain is
/// wired, not just that the screen compiles.
void main() {
  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(400, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester, screen, session: demoSession);
    // Mock datasources resolve via Future.delayed; pumpAndSettle waits on
    // frames, not plain timers, so advance past them first.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
  }

  testWidgets('Modules lists both tool groups', (tester) async {
    await pump(tester, const ModulesScreen());

    expect(find.text('My Team · ZSM (10)'), findsOneWidget);
    expect(find.text('DAILY WORK'), findsOneWidget);
    expect(find.text('ANALYSIS & APPROVALS'), findsOneWidget);
    expect(find.text('Call Reporting'), findsOneWidget);
    expect(find.text('Field Force HR'), findsOneWidget);
  });

  testWidgets('Call Reporting shows today\'s visits and rate', (tester) async {
    await pump(tester, const CallsScreen());

    expect(find.text('8'), findsOneWidget); // planned
    expect(find.text('6'), findsOneWidget); // done
    expect(find.text('75% rate'), findsOneWidget);
    expect(find.text('Dr. Anwar Sheikh'), findsOneWidget);
    expect(find.text('Missed'), findsOneWidget);
  });

  testWidgets('My Team shows the zone header and every rep', (tester) async {
    await pump(tester, const TeamScreen());

    // The zone figure is a Text.rich (value + coloured %), which find.text
    // cannot match — it has no `data`.
    expect(
      find.textContaining('58.24', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Gohar Zaman'), findsOneWidget);
    expect(find.text('Imran Zafar'), findsOneWidget);
    expect(find.text('75% ACH'), findsOneWidget);
  });

  testWidgets('My Team re-sorts reps by name', (tester) async {
    const names = [
      'Gohar Zaman',
      'Raheel Zafar',
      'Zia Muhammad',
      'Imran Zafar',
    ];
    List<String> order() => tester
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data)
        .whereType<String>()
        .where(names.contains)
        .toList();

    await pump(tester, const TeamScreen());

    // Default sort is achievement descending: 75, 59, 51, 49.
    expect(order(), [
      'Gohar Zaman',
      'Raheel Zafar',
      'Zia Muhammad',
      'Imran Zafar',
    ]);

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    expect(order().first, 'Gohar Zaman'); // alphabetical by first name
    expect(order().last, 'Zia Muhammad');
  });

  testWidgets('Rep detail expands a product row', (tester) async {
    await pump(tester, const RepDetailScreen(code: '004324'));

    expect(find.text('Vlep'), findsOneWidget);
    // SectionLink appends the chevron, so match on the label alone.
    expect(find.textContaining('4 brands'), findsOneWidget);

    // The leading brand opens by default, so its detail is already visible.
    expect(find.text('Growth over last year'), findsOneWidget);

    await tester.tap(find.text('Cubriva'));
    await tester.pumpAndSettle();
    expect(find.text('Growth over last year'), findsNWidgets(2));
  });

  testWidgets('Reports lists every group', (tester) async {
    await pump(tester, const ReportsScreen());

    expect(find.text('CALL REPORTS'), findsOneWidget);
    expect(find.text('CHEMIST & BONUS'), findsOneWidget);
    expect(find.text('CUSTOMER REGISTRATION'), findsOneWidget);
    expect(find.text('Activity Details'), findsOneWidget);
  });

  testWidgets('Report output stays hidden until the report is run',
      (tester) async {
    await pump(tester, const ReportOutputScreen());

    expect(find.text('View report'), findsOneWidget);
    expect(find.text('Visit summary'), findsNothing);

    await tester.tap(find.text('View report'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Visit summary'), findsOneWidget);
    expect(find.text('Dr. Anwar'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget); // completion
  });
}
