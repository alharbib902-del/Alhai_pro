import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/inputs/alhai_checkbox.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiCheckbox', () {
    group('Rendering', () {
      testWidgets('renders unchecked by default', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiCheckbox(
            value: false,
            onChanged: (_) {},
          ),
        ));

        // Assert
        expect(find.byType(Checkbox), findsOneWidget);
      });

      testWidgets('renders checked when value is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiCheckbox(
            value: true,
            onChanged: (_) {},
          ),
        ));

        // Assert
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);
      });

      testWidgets('renders with label', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiCheckbox(
            value: false,
            label: 'Accept Terms',
            onChanged: (_) {},
          ),
        ));

        // Assert
        expect(find.text('Accept Terms'), findsOneWidget);
      });

      testWidgets('renders with subtitle', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiCheckbox(
            value: false,
            label: 'Newsletter',
            subtitle: 'Receive updates',
            onChanged: (_) {},
          ),
        ));

        // Assert
        expect(find.text('Newsletter'), findsOneWidget);
        expect(find.text('Receive updates'), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('calls onChanged when tapped', (tester) async {
        // Arrange
        bool? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiCheckbox(
            value: false,
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Assert
        expect(newValue, isTrue);
      });

      testWidgets('can be toggled off', (tester) async {
        // Arrange
        bool? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiCheckbox(
            value: true,
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Assert
        expect(newValue, isFalse);
      });

      testWidgets('tapping label toggles checkbox', (tester) async {
        // Arrange
        bool? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiCheckbox(
            value: false,
            label: 'Tap Me',
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.text('Tap Me'));
        await tester.pump();

        // Assert
        expect(newValue, isTrue);
      });
    });

    group('State', () {
      testWidgets('disabled checkbox does not respond to tap', (tester) async {
        // Arrange
        bool tapped = false;

        await tester.pumpWidget(createTestWidget(
          AlhaiCheckbox(
            value: false,
            enabled: false,
            onChanged: (_) => tapped = true,
          ),
        ));

        // Act
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Assert
        expect(tapped, isFalse);
      });
    });

    group('Tristate', () {
      testWidgets('supports tristate mode', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiCheckbox(
            value: null,
            tristate: true,
            onChanged: (_) {},
          ),
        ));

        // Assert
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.tristate, isTrue);
        expect(checkbox.value, isNull);
      });
    });
  });
}
