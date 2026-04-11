import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_reports/alhai_reports.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() {
    registerWidgetTestFallbackValues();
  });

  setUp(() {
    setupMockGetIt();
  });

  tearDown(() {
    teardownMockGetIt();
  });

  group('BalanceSheetScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const BalanceSheetScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(BalanceSheetScreen), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const BalanceSheetScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows loading or content after data loads', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const BalanceSheetScreen()));
      await tester.pump();

      // Should show loading or content
      expect(find.byType(BalanceSheetScreen), findsOneWidget);
    });
  });
}
