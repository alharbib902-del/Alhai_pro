import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiStatCard', () {
    testWidgets('renders title and value', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiStatCard(title: 'Total Sales', value: '1,234'),
        ),
      );

      expect(find.text('Total Sales'), findsOneWidget);
      expect(find.text('1,234'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiStatCard(
            title: 'Revenue',
            value: '50K',
            subtitle: 'This month',
          ),
        ),
      );

      expect(find.text('This month'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiStatCard(
            title: 'Orders',
            value: '42',
            icon: Icons.shopping_cart,
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('is tappable when onTap provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiStatCard(
            title: 'Stat',
            value: '100',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('100'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows loading skeleton when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiStatCard(title: 'Loading', value: '---', isLoading: true),
        ),
      );

      // When loading, the value text should not be shown
      expect(find.text('---'), findsNothing);
    });

    testWidgets('renders trend widget when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiStatCard(
            title: 'Sales',
            value: '500',
            trend: Text('+12%'),
          ),
        ),
      );

      expect(find.text('+12%'), findsOneWidget);
    });

    testWidgets('renders with custom icon color', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiStatCard(
            title: 'Revenue',
            value: '1000',
            icon: Icons.attach_money,
            iconColor: Colors.green,
          ),
        ),
      );

      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });
  });
}
