import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/layout/alhai_card.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiCard', () {
    group('Rendering', () {
      testWidgets('renders child content', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiCard(
            child: Text('Card Content'),
          ),
        ));

        // Assert
        expect(find.text('Card Content'), findsOneWidget);
      });

      testWidgets('renders elevated variant', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiCard.elevated(
            elevation: 4,
            child: const Text('Elevated'),
          ),
        ));

        // Assert
        expect(find.text('Elevated'), findsOneWidget);
      });

      testWidgets('renders filled variant', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiCard.filled(
            child: const Text('Filled'),
          ),
        ));

        // Assert
        expect(find.text('Filled'), findsOneWidget);
      });

      testWidgets('applies border when showBorder is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiCard(
            showBorder: true,
            child: Text('Bordered'),
          ),
        ));

        // Assert
        expect(find.text('Bordered'), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('calls onTap when tapped', (tester) async {
        // Arrange
        var tapped = false;

        await tester.pumpWidget(createTestWidget(
          AlhaiCard(
            onTap: () => tapped = true,
            child: const Text('Tappable'),
          ),
        ));

        // Act
        await tester.tap(find.text('Tappable'));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('calls onLongPress when long pressed', (tester) async {
        // Arrange
        var longPressed = false;

        await tester.pumpWidget(createTestWidget(
          AlhaiCard(
            onLongPress: () => longPressed = true,
            child: const Text('Long Press'),
          ),
        ));

        // Act
        await tester.longPress(find.text('Long Press'));
        await tester.pump();

        // Assert
        expect(longPressed, isTrue);
      });
    });

    group('Styling', () {
      testWidgets('applies custom background color', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiCard(
            backgroundColor: Colors.blue,
            child: Text('Blue Card'),
          ),
        ));

        // Assert
        expect(find.text('Blue Card'), findsOneWidget);
      });

      testWidgets('applies custom border radius', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiCard(
            borderRadius: 24,
            child: Text('Rounded'),
          ),
        ));

        // Assert
        expect(find.text('Rounded'), findsOneWidget);
      });
    });
  });
}
