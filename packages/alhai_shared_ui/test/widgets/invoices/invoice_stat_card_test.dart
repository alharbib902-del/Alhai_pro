import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AppColors;
import 'package:alhai_shared_ui/src/widgets/invoices/invoice_stat_card.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('InvoiceStatData', () {
    test('stores properties correctly', () {
      final data = InvoiceStatData(
        title: 'Total Invoices',
        value: '150',
        icon: Icons.receipt,
        iconBgColor: Colors.blue.shade50,
        iconColor: Colors.blue,
        gradientColor: Colors.blue,
        subtitle: 'This month',
        changeValue: '+12%',
        isPositive: true,
      );
      expect(data.title, 'Total Invoices');
      expect(data.value, '150');
      expect(data.subtitle, 'This month');
      expect(data.changeValue, '+12%');
      expect(data.isPositive, isTrue);
    });
  });

  group('InvoiceStatCard', () {
    testWidgets('renders title and value', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          InvoiceStatCard(
            data: InvoiceStatData(
              title: 'Total Revenue',
              value: '50,000',
              icon: Icons.attach_money,
              iconBgColor: Colors.green.shade50,
              iconColor: Colors.green,
              gradientColor: Colors.green,
            ),
          ),
        ),
      );
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('50,000'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          InvoiceStatCard(
            data: InvoiceStatData(
              title: 'Invoices',
              value: '30',
              icon: Icons.receipt_long,
              iconBgColor: Colors.blue.shade50,
              iconColor: Colors.blue,
              gradientColor: Colors.blue,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('renders change indicator when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          InvoiceStatCard(
            data: InvoiceStatData(
              title: 'Revenue',
              value: '10,000',
              icon: Icons.attach_money,
              iconBgColor: Colors.green.shade50,
              iconColor: Colors.green,
              gradientColor: Colors.green,
              changeValue: '+15%',
              isPositive: true,
            ),
          ),
        ),
      );
      expect(find.text('+15%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('renders negative change', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          InvoiceStatCard(
            data: InvoiceStatData(
              title: 'Refunds',
              value: '5,000',
              icon: Icons.money_off,
              iconBgColor: Colors.red.shade50,
              iconColor: Colors.red,
              gradientColor: Colors.red,
              changeValue: '-8%',
              isPositive: false,
            ),
          ),
        ),
      );
      expect(find.text('-8%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('renders progress bar when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          InvoiceStatCard(
            data: InvoiceStatData(
              title: 'Target',
              value: '75%',
              icon: Icons.flag,
              iconBgColor: Colors.orange.shade50,
              iconColor: Colors.orange,
              gradientColor: Colors.orange,
              progressValue: 0.75,
              subtitle: '75% of target',
            ),
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      var actionTapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          InvoiceStatCard(
            data: InvoiceStatData(
              title: 'Overdue',
              value: '3',
              icon: Icons.warning,
              iconBgColor: Colors.red.shade50,
              iconColor: AppColors.error,
              gradientColor: AppColors.error,
              actionText: 'View All',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );
      expect(find.text('View All'), findsOneWidget);
      await tester.tap(find.text('View All'));
      expect(actionTapped, isTrue);
    });

    testWidgets('renders compact mode', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          InvoiceStatCard(
            compact: true,
            data: InvoiceStatData(
              title: 'Compact',
              value: '42',
              icon: Icons.info,
              iconBgColor: Colors.blue.shade50,
              iconColor: Colors.blue,
              gradientColor: Colors.blue,
            ),
          ),
        ),
      );
      expect(find.text('Compact'), findsOneWidget);
    });
  });
}
