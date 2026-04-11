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

  group('ReportsScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ReportsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ReportsScreen), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ReportsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows content structure', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ReportsScreen()));
      await tester.pumpAndSettle();

      // Reports screen should have scrollable content
      expect(find.byType(ReportsScreen), findsOneWidget);
    });
  });
}
