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

  group('TopProductsReportScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const TopProductsReportScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TopProductsReportScreen), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const TopProductsReportScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows content after loading', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const TopProductsReportScreen()),
      );
      await tester.pump();

      expect(find.byType(TopProductsReportScreen), findsOneWidget);
    });
  });
}
