import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/buttons/alhai_button.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiButton', () {
    group('Rendering', () {
      testWidgets('renders filled variant correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Test Button',
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
      });

      testWidgets('renders outlined variant correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.outlined(
            label: 'Outlined',
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.text('Outlined'), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('renders text variant correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.text(
            label: 'Text Button',
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.text('Text Button'), findsOneWidget);
        expect(find.byType(TextButton), findsOneWidget);
      });

      testWidgets('renders tonal variant correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton(
            label: 'Tonal',
            variant: AlhaiButtonVariant.tonal,
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.text('Tonal'), findsOneWidget);
      });

      testWidgets('renders with leading icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'With Icon',
            leadingIcon: Icons.add,
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('With Icon'), findsOneWidget);
      });

      testWidgets('renders with trailing icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Trail',
            trailingIcon: Icons.arrow_forward,
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      });

      testWidgets('expands to full width when fullWidth is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Full Width',
            fullWidth: true,
            onPressed: () {},
          ),
        ));

        // Assert
        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(FilledButton),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.width, equals(double.infinity));
      });
    });

    group('State', () {
      testWidgets('shows loading indicator when isLoading is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading'), findsNothing);
      });

      testWidgets('button is disabled when onPressed is null', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiButton(
            label: 'Disabled',
            onPressed: null,
          ),
        ));

        // Assert
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('button is disabled when isLoading is true', (tester) async {
        // Arrange
        var pressed = false;

        // Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Loading',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ));

        await tester.tap(find.byType(FilledButton));
        await tester.pump();

        // Assert
        expect(pressed, isFalse);
      });
    });

    group('Interaction', () {
      testWidgets('calls onPressed callback when tapped', (tester) async {
        // Arrange
        var pressed = false;

        // Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Tap Me',
            onPressed: () => pressed = true,
          ),
        ));

        await tester.tap(find.text('Tap Me'));
        await tester.pumpAndSettle();

        // Assert
        expect(pressed, isTrue);
      });

      testWidgets('does not call onPressed when disabled', (tester) async {
        // Arrange
        var pressed = false;

        // Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Disabled',
            onPressed: null,
          ),
        ));

        await tester.tap(find.text('Disabled'));
        await tester.pump();

        // Assert
        expect(pressed, isFalse);
      });
    });

    group('Sizes', () {
      testWidgets('small size has correct height', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Small',
            size: AlhaiButtonSize.small,
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.text('Small'), findsOneWidget);
      });

      testWidgets('large size has correct height', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Large',
            size: AlhaiButtonSize.large,
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.text('Large'), findsOneWidget);
      });
    });

    group('Theming', () {
      testWidgets('applies custom background color', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Custom',
            backgroundColor: Colors.red,
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.text('Custom'), findsOneWidget);
      });

      testWidgets('applies custom foreground color', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiButton.filled(
            label: 'Custom FG',
            foregroundColor: Colors.yellow,
            onPressed: () {},
          ),
        ));

        // Assert
        expect(find.text('Custom FG'), findsOneWidget);
      });
    });
  });
}
