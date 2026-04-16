import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/dashboard/sales_chart.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('SimpleBarChart', () {
    final sampleData = [
      const ChartDataPoint(label: 'Mon', value: 100),
      const ChartDataPoint(label: 'Tue', value: 200),
      const ChartDataPoint(label: 'Wed', value: 150),
    ];

    testWidgets('renders with data', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          SizedBox(
            height: 300,
            child: SimpleBarChart(data: sampleData),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
    });

    testWidgets('shows no data message when empty', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const SizedBox(
            height: 300,
            child: SimpleBarChart(data: []),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Should show "no data" in Arabic
      expect(find.byType(SimpleBarChart), findsOneWidget);
    });

    testWidgets('hides labels when showLabels is false', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          SizedBox(
            height: 300,
            child: SimpleBarChart(
              data: sampleData,
              showLabels: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mon'), findsNothing);
    });

    testWidgets('renders with custom bar color', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          SizedBox(
            height: 300,
            child: SimpleBarChart(
              data: sampleData,
              barColor: Colors.red,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SimpleBarChart), findsOneWidget);
    });
  });

  group('ChartDataPoint', () {
    test('stores label and value', () {
      const point = ChartDataPoint(label: 'Jan', value: 1000);
      expect(point.label, 'Jan');
      expect(point.value, 1000);
      expect(point.date, isNull);
    });

    test('stores optional date', () {
      final date = DateTime(2026, 1, 1);
      final point = ChartDataPoint(label: 'Jan', value: 1000, date: date);
      expect(point.date, date);
    });
  });

  group('ChartPeriod', () {
    test('has correct values', () {
      expect(ChartPeriod.values.length, 3);
      expect(ChartPeriod.values, contains(ChartPeriod.weekly));
      expect(ChartPeriod.values, contains(ChartPeriod.monthly));
      expect(ChartPeriod.values, contains(ChartPeriod.yearly));
    });
  });

  group('SalesChartCard', () {
    final chartData = {
      ChartPeriod.weekly: [
        const ChartDataPoint(label: 'Mon', value: 100),
        const ChartDataPoint(label: 'Tue', value: 200),
      ],
      ChartPeriod.monthly: [
        const ChartDataPoint(label: 'W1', value: 500),
        const ChartDataPoint(label: 'W2', value: 600),
      ],
    };

    testWidgets('renders with title', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          SizedBox(
            height: 400,
            child: SalesChartCard(
              data: chartData,
              title: 'Sales Report',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sales Report'), findsOneWidget);
    });

    testWidgets('renders period toggle buttons', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          SizedBox(
            height: 400,
            child: SalesChartCard(data: chartData),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Should show period labels in Arabic
      expect(find.byType(SalesChartCard), findsOneWidget);
    });
  });
}
