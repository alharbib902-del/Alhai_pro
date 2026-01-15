import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/inputs/alhai_search_field.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiSearchField', () {
    group('Rendering', () {
      testWidgets('renders with default hint text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiSearchField(),
        ));

        // Assert
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('بحث...'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('renders with custom hint text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiSearchField(
            hintText: 'Search products',
          ),
        ));

        // Assert
        expect(find.text('Search products'), findsOneWidget);
      });

      testWidgets('shows loading indicator when isLoading', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiSearchField(
            isLoading: true,
          ),
        ));
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('calls onChanged when text changes', (tester) async {
        // Arrange
        String? changedValue;

        // Act
        await tester.pumpWidget(createTestWidget(
          AlhaiSearchField(
            onChanged: (value) => changedValue = value,
          ),
        ));

        await tester.enterText(find.byType(TextField), 'test query');
        await tester.pump();

        // Assert
        expect(changedValue, equals('test query'));
      });

      testWidgets('shows clear button when has text', (tester) async {
        // Arrange
        final controller = TextEditingController(text: 'some text');

        // Act
        await tester.pumpWidget(createTestWidget(
          AlhaiSearchField(
            controller: controller,
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('hides clear button when empty', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiSearchField(),
        ));

        // Assert
        expect(find.byIcon(Icons.close), findsNothing);
      });

      testWidgets('clears text when clear button tapped', (tester) async {
        // Arrange
        final controller = TextEditingController(text: 'test');
        var cleared = false;

        await tester.pumpWidget(createTestWidget(
          AlhaiSearchField(
            controller: controller,
            onClear: () => cleared = true,
          ),
        ));

        // Act
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();

        // Assert
        expect(controller.text, isEmpty);
        expect(cleared, isTrue);
      });

      testWidgets('calls onSubmitted when submitted', (tester) async {
        // Arrange
        String? submittedValue;

        await tester.pumpWidget(createTestWidget(
          AlhaiSearchField(
            onSubmitted: (value) => submittedValue = value,
          ),
        ));

        // Act
        await tester.enterText(find.byType(TextField), 'search query');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        // Assert
        expect(submittedValue, equals('search query'));
      });
    });

    group('State', () {
      testWidgets('disabled state prevents input', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiSearchField(
            enabled: false,
          ),
        ));

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enabled, isFalse);
      });
    });
  });
}
