import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_reports/alhai_reports.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  late MockSalesDao mockSalesDao;

  setUpAll(() {
    registerWidgetTestFallbackValues();
  });

  setUp(() {
    final mocks = setupMockGetIt();
    mockSalesDao = mocks.salesDao;
  });

  tearDown(() {
    teardownMockGetIt();
  });

  group('DailySalesReportScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const DailySalesReportScreen()),
      );
      // Initial pump shows loading, then data loads
      await tester.pumpAndSettle();

      // Screen should render with Scaffold
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      // Make the DAO call delay so we can see the loading state
      when(() => mockSalesDao.getSalesByDate(any(), any()))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return <SalesTableData>[];
      });

      await tester.pumpWidget(
        buildTestableWidget(const DailySalesReportScreen()),
      );
      // After first frame, should be in loading state
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no transactions', (tester) async {
      // Default mock already returns empty list
      await tester.pumpWidget(
        buildTestableWidget(const DailySalesReportScreen()),
      );
      await tester.pumpAndSettle();

      // The screen shows an empty state icon when totalTransactions == 0
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
    });

    testWidgets('shows date selector card', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const DailySalesReportScreen()),
      );
      await tester.pumpAndSettle();

      // Date selector card with calendar icon should be present
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('has navigation arrows for date', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const DailySalesReportScreen()),
      );
      await tester.pumpAndSettle();

      // Previous day arrow
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      // Next day arrow
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('has export and print buttons in app bar', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const DailySalesReportScreen()),
      );
      await tester.pumpAndSettle();

      // Refresh button
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      // Share button
      expect(find.byIcon(Icons.share), findsOneWidget);
      // CSV export button
      expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
      // Print button
      expect(find.byIcon(Icons.print), findsOneWidget);
    });

    testWidgets('navigating to previous date reloads data', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const DailySalesReportScreen()),
      );
      await tester.pumpAndSettle();

      // Tap the left arrow to go to previous day
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // getSalesByDate should have been called multiple times (initial + after nav)
      verify(() => mockSalesDao.getSalesByDate(any(), any()))
          .called(greaterThanOrEqualTo(2));
    });
  });
}
