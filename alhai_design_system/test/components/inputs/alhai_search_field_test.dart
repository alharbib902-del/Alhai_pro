import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiSearchField', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlhaiSearchField()));

      expect(find.byType(AlhaiSearchField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows search icon', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlhaiSearchField()));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows custom hint text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiSearchField(hintText: 'Search products...'),
        ),
      );

      expect(find.text('Search products...'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiSearchField(onChanged: (value) => changedValue = value),
        ),
      );

      await tester.enterText(find.byType(TextField), 'apple');
      expect(changedValue, 'apple');
    });

    testWidgets('shows clear button when text is present', (tester) async {
      final controller = TextEditingController(text: 'search term');
      await tester.pumpWidget(
        createTestWidget(AlhaiSearchField(controller: controller)),
      );

      // Clear button should show when there is text
      expect(find.byIcon(Icons.close), findsOneWidget);

      controller.dispose();
    });

    testWidgets('clear button clears text', (tester) async {
      final controller = TextEditingController(text: 'search term');
      String? changedValue;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiSearchField(
            controller: controller,
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(changedValue, '');

      controller.dispose();
    });

    testWidgets('does not show clear button when empty', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlhaiSearchField()));

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiSearchField(isLoading: true)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('uses external controller', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createTestWidget(AlhaiSearchField(controller: controller)),
      );

      await tester.enterText(find.byType(TextField), 'test query');
      expect(controller.text, 'test query');

      controller.dispose();
    });

    testWidgets('calls onClear when clear button tapped', (tester) async {
      final controller = TextEditingController(text: 'test');
      var cleared = false;

      await tester.pumpWidget(
        createTestWidget(
          AlhaiSearchField(
            controller: controller,
            onClear: () => cleared = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(cleared, isTrue);

      controller.dispose();
    });

    testWidgets('calls onSubmitted when submitted', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        createTestWidget(
          AlhaiSearchField(onSubmitted: (value) => submittedValue = value),
        ),
      );

      await tester.enterText(find.byType(TextField), 'search query');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedValue, equals('search query'));
    });

    testWidgets('disabled state prevents input', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiSearchField(enabled: false)),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });
}
