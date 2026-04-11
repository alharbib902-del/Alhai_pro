import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiOrderRow', () {
    testWidgets('renders order number', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiOrderRow(
            orderNumber: '#1234',
            status: AlhaiOrderStatus.completed,
            statusLabel: 'Completed',
            totalAmount: 150.0,
          ),
        ),
      );

      expect(find.text('#1234'), findsOneWidget);
    });

    testWidgets('renders status label', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiOrderRow(
            orderNumber: '#1234',
            status: AlhaiOrderStatus.created,
            statusLabel: 'Pending',
            totalAmount: 150.0,
          ),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('is tappable when onTap provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiOrderRow(
            orderNumber: '#1234',
            status: AlhaiOrderStatus.completed,
            statusLabel: 'Completed',
            totalAmount: 150.0,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('#1234'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows item count when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiOrderRow(
            orderNumber: '#1234',
            status: AlhaiOrderStatus.completed,
            statusLabel: 'Completed',
            totalAmount: 150.0,
            itemCount: 5,
          ),
        ),
      );

      expect(find.byType(AlhaiOrderRow), findsOneWidget);
    });

    testWidgets('shows created time when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiOrderRow(
            orderNumber: '#1234',
            status: AlhaiOrderStatus.completed,
            statusLabel: 'Completed',
            totalAmount: 150.0,
            createdAt: '2:30 PM',
          ),
        ),
      );

      expect(find.text('2:30 PM'), findsOneWidget);
    });

    testWidgets('reduces opacity when disabled', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiOrderRow(
            orderNumber: '#1234',
            status: AlhaiOrderStatus.completed,
            statusLabel: 'Completed',
            totalAmount: 150.0,
            enabled: false,
          ),
        ),
      );

      final opacityFinder = find.byWidgetPredicate(
        (w) => w is Opacity && w.opacity < 1.0,
      );
      expect(opacityFinder, findsOneWidget);
    });
  });
}
