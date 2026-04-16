import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/dashboard/stat_card.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('DashboardStatCard', () {
    testWidgets('renders title and value', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const DashboardStatCard(
            title: 'Today Sales',
            value: '1,500',
            icon: Icons.attach_money,
          ),
        ),
      );
      expect(find.text('Today Sales'), findsOneWidget);
      expect(find.text('1,500'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });

    testWidgets('renders value suffix', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const DashboardStatCard(
            title: 'Revenue',
            value: '5,000',
            valueSuffix: 'SAR',
            icon: Icons.attach_money,
          ),
        ),
      );
      expect(find.text('SAR'), findsOneWidget);
    });

    testWidgets('shows increase change indicator', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const DashboardStatCard(
            title: 'Orders',
            value: '25',
            icon: Icons.shopping_cart,
            change: 10.0,
            changeType: ChangeType.increase,
          ),
        ),
      );
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    });

    testWidgets('shows decrease change indicator', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const DashboardStatCard(
            title: 'Profit',
            value: '800',
            icon: Icons.trending_down,
            change: -5.0,
            changeType: ChangeType.decrease,
          ),
        ),
      );
      expect(find.byIcon(Icons.trending_down_rounded), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          DashboardStatCard(
            title: 'Tap Me',
            value: '0',
            icon: Icons.touch_app,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('renders without change indicator', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const DashboardStatCard(
            title: 'Simple',
            value: '100',
            icon: Icons.info,
          ),
        ),
      );
      expect(find.text('Simple'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      // No trending icon
      expect(find.byIcon(Icons.trending_up_rounded), findsNothing);
      expect(find.byIcon(Icons.trending_down_rounded), findsNothing);
    });
  });

  group('ChangeType', () {
    test('has correct values', () {
      expect(ChangeType.values.length, 3);
      expect(ChangeType.values, contains(ChangeType.increase));
      expect(ChangeType.values, contains(ChangeType.decrease));
      expect(ChangeType.values, contains(ChangeType.neutral));
    });
  });
}
