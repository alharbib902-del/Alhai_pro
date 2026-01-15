import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/inputs/alhai_quantity_control.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiQuantityControl', () {
    group('Rendering', () {
      testWidgets('renders with quantity value', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiQuantityControl(
            quantity: 5,
            onChanged: (_) {},
          ),
        ));

        // Assert
        expect(find.text('5'), findsOneWidget);
        expect(find.byIcon(Icons.remove), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('renders compact size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiQuantityControl(
            quantity: 1,
            onChanged: (_) {},
            size: AlhaiQuantityControlSize.compact,
          ),
        ));

        // Assert
        expect(find.text('1'), findsOneWidget);
      });
    });

    group('Increment/Decrement', () {
      testWidgets('increments value when plus tapped', (tester) async {
        // Arrange
        int? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiQuantityControl(
            quantity: 3,
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // Assert
        expect(newValue, equals(4));
      });

      testWidgets('decrements value when minus tapped', (tester) async {
        // Arrange
        int? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiQuantityControl(
            quantity: 3,
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        // Assert
        expect(newValue, equals(2));
      });

      testWidgets('respects min value', (tester) async {
        // Arrange
        int? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiQuantityControl(
            quantity: 1,
            min: 1,
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        // Assert - should not call onChanged if already at min
        expect(newValue, isNull);
      });

      testWidgets('respects max value', (tester) async {
        // Arrange
        int? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiQuantityControl(
            quantity: 10,
            max: 10,
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // Assert - should not call onChanged if already at max
        expect(newValue, isNull);
      });

      testWidgets('uses custom step value', (tester) async {
        // Arrange
        int? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiQuantityControl(
            quantity: 5,
            step: 5,
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // Assert
        expect(newValue, equals(10));
      });
    });

    group('Disabled State', () {
      testWidgets('disabled control does not respond to taps', (tester) async {
        // Arrange
        var tapped = false;

        await tester.pumpWidget(createTestWidget(
          AlhaiQuantityControl(
            quantity: 5,
            enabled: false,
            onChanged: (_) => tapped = true,
          ),
        ));

        // Act
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // Assert
        expect(tapped, isFalse);
      });
    });

    group('Custom Icons', () {
      testWidgets('renders custom decrement icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiQuantityControl(
            quantity: 5,
            onChanged: (_) {},
            decrementIcon: Icons.remove_circle,
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.remove_circle), findsOneWidget);
      });

      testWidgets('renders custom increment icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiQuantityControl(
            quantity: 5,
            onChanged: (_) {},
            incrementIcon: Icons.add_circle,
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.add_circle), findsOneWidget);
      });
    });
  });
}
