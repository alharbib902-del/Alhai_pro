import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/inputs/alhai_switch.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiSwitch', () {
    group('Rendering', () {
      testWidgets('renders off by default', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiSwitch(
            value: false,
            onChanged: (_) {},
          ),
        ));

        // Assert
        expect(find.byType(Switch), findsOneWidget);
      });

      testWidgets('renders on when value is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiSwitch(
            value: true,
            onChanged: (_) {},
          ),
        ));

        // Assert
        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isTrue);
      });

      testWidgets('renders with label', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiSwitch(
            value: false,
            label: 'Dark Mode',
            onChanged: (_) {},
          ),
        ));

        // Assert
        expect(find.text('Dark Mode'), findsOneWidget);
      });

      testWidgets('renders with subtitle', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiSwitch(
            value: false,
            label: 'Notifications',
            subtitle: 'Receive push notifications',
            onChanged: (_) {},
          ),
        ));

        // Assert
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Receive push notifications'), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('calls onChanged when toggled', (tester) async {
        // Arrange
        bool? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiSwitch(
            value: false,
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.byType(Switch));
        await tester.pump();

        // Assert
        expect(newValue, isTrue);
      });

      testWidgets('can be toggled off', (tester) async {
        // Arrange
        bool? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiSwitch(
            value: true,
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.byType(Switch));
        await tester.pump();

        // Assert
        expect(newValue, isFalse);
      });

      testWidgets('tapping label toggles switch', (tester) async {
        // Arrange
        bool? newValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiSwitch(
            value: false,
            label: 'Tap Label',
            onChanged: (value) => newValue = value,
          ),
        ));

        // Act
        await tester.tap(find.text('Tap Label'));
        await tester.pump();

        // Assert
        expect(newValue, isTrue);
      });
    });

    group('State', () {
      testWidgets('disabled switch does not respond to tap', (tester) async {
        // Arrange
        bool tapped = false;

        await tester.pumpWidget(createTestWidget(
          AlhaiSwitch(
            value: false,
            enabled: false,
            onChanged: (_) => tapped = true,
          ),
        ));

        // Act
        await tester.tap(find.byType(Switch));
        await tester.pump();

        // Assert
        expect(tapped, isFalse);
      });
    });
  });
}
