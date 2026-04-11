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

  group('VatReportScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const VatReportScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(VatReportScreen), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const VatReportScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows content after loading', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const VatReportScreen()));
      await tester.pump();

      expect(find.byType(VatReportScreen), findsOneWidget);
    });
  });
}
