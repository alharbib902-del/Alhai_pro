import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/feedback/alhai_badge.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiBadge', () {
    group('Dot Badge', () {
      testWidgets('renders dot badge', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiBadge.dot(
            child: const Icon(Icons.notifications),
          ),
        ));

        // Assert
        expect(find.byType(AlhaiBadge), findsOneWidget);
        expect(find.byIcon(Icons.notifications), findsOneWidget);
      });

      testWidgets('hides dot when show is false', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiBadge.dot(
            show: false,
            child: const Icon(Icons.notifications),
          ),
        ));

        // Assert - should only find the icon, badge hidden
        expect(find.byIcon(Icons.notifications), findsOneWidget);
      });
    });

    group('Count Badge', () {
      testWidgets('renders count badge with number', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiBadge.count(
            count: 5,
            child: const Icon(Icons.shopping_cart),
          ),
        ));

        // Assert
        expect(find.text('5'), findsOneWidget);
        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      });

      testWidgets('shows max+ when count exceeds maxCount', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiBadge.count(
            count: 150,
            maxCount: 99,
            child: const Icon(Icons.mail),
          ),
        ));

        // Assert
        expect(find.text('99+'), findsOneWidget);
      });

      testWidgets('hides when count is 0', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiBadge.count(
            count: 0,
            child: const Icon(Icons.notifications),
          ),
        ));

        // Assert - count text should not appear
        expect(find.text('0'), findsNothing);
      });
    });

    group('Sizes', () {
      testWidgets('renders small size badge', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiBadge.count(
            count: 3,
            size: AlhaiBadgeSize.small,
            child: const Icon(Icons.inbox),
          ),
        ));

        // Assert
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('renders large size badge', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiBadge.count(
            count: 10,
            size: AlhaiBadgeSize.large,
            child: const Icon(Icons.inbox),
          ),
        ));

        // Assert
        expect(find.text('10'), findsOneWidget);
      });
    });

    group('Custom Colors', () {
      testWidgets('applies custom background color', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiBadge.count(
            count: 7,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.inbox),
          ),
        ));

        // Assert
        expect(find.text('7'), findsOneWidget);
      });

      testWidgets('applies custom text color', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiBadge.count(
            count: 9,
            textColor: Colors.yellow,
            child: const Icon(Icons.inbox),
          ),
        ));

        // Assert
        expect(find.text('9'), findsOneWidget);
      });
    });

    group('Standalone Badge', () {
      testWidgets('renders without child', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiBadge(
            count: 3,
          ),
        ));

        // Assert
        expect(find.text('3'), findsOneWidget);
      });
    });
  });
}
