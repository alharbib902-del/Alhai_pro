import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/app_input.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('AppTextField', () {
    testWidgets('should display label', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppTextField(label: 'Username'),
      ));
      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('should display hint text', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppTextField(hint: 'Enter value'),
      ));
      expect(find.text('Enter value'), findsOneWidget);
    });

    testWidgets('should display required asterisk', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppTextField(label: 'Name', required: true),
      ));
      expect(find.text(' *'), findsOneWidget);
    });

    testWidgets('should not display asterisk when not required',
        (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppTextField(label: 'Name', required: false),
      ));
      expect(find.text(' *'), findsNothing);
    });

    testWidgets('should call onChanged when text changes', (tester) async {
      String? changedValue;
      await tester.pumpWidget(createSimpleTestWidget(
        AppTextField(
          onChanged: (value) => changedValue = value,
        ),
      ));
      await tester.enterText(find.byType(TextFormField), 'Hello');
      expect(changedValue, 'Hello');
    });

    testWidgets('should use provided controller', (tester) async {
      final controller = TextEditingController(text: 'Initial');
      await tester.pumpWidget(createSimpleTestWidget(
        AppTextField(controller: controller),
      ));
      expect(find.text('Initial'), findsOneWidget);
    });

    testWidgets('should show prefix icon', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppTextField(prefixIcon: Icons.search),
      ));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppTextField(obscureText: true),
      ));
      // Should show visibility toggle button
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap to toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should show error text', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppTextField(errorText: 'Invalid input'),
      ));
      expect(find.text('Invalid input'), findsOneWidget);
    });

    testWidgets('should show helper text', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppTextField(helperText: 'Enter your name'),
      ));
      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('should be disabled when enabled is false', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppTextField(enabled: false),
      ));
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('search factory should show search icon', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppTextField.search(),
      ));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('number factory should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppTextField.number(label: 'Amount'),
      ));
      expect(find.text('Amount'), findsOneWidget);
    });

    testWidgets('phone factory should show phone icon', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppTextField.phone(),
      ));
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });
  });

  group('AppSearchField', () {
    testWidgets('should display search icon', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppSearchField(),
      ));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should call onChanged when text changes', (tester) async {
      String? changedValue;
      await tester.pumpWidget(createSimpleTestWidget(
        AppSearchField(
          onChanged: (value) => changedValue = value,
        ),
      ));
      await tester.enterText(find.byType(TextField), 'search query');
      expect(changedValue, 'search query');
    });

    testWidgets('should show clear button when text is present',
        (tester) async {
      final controller = TextEditingController(text: 'query');
      await tester.pumpWidget(createSimpleTestWidget(
        AppSearchField(controller: controller),
      ));
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should clear text when clear button tapped', (tester) async {
      final controller = TextEditingController(text: 'query');
      var cleared = false;
      await tester.pumpWidget(createSimpleTestWidget(
        AppSearchField(
          controller: controller,
          onClear: () => cleared = true,
        ),
      ));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(controller.text, '');
      expect(cleared, isTrue);
    });
  });

  group('AppQuantityField', () {
    testWidgets('should display current value', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppQuantityField(
          value: 5,
          onChanged: (_) {},
        ),
      ));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should increment value', (tester) async {
      int currentValue = 5;
      await tester.pumpWidget(createSimpleTestWidget(
        AppQuantityField(
          value: currentValue,
          onChanged: (v) => currentValue = v,
        ),
      ));
      await tester.tap(find.byIcon(Icons.add));
      expect(currentValue, 6);
    });

    testWidgets('should decrement value', (tester) async {
      int currentValue = 5;
      await tester.pumpWidget(createSimpleTestWidget(
        AppQuantityField(
          value: currentValue,
          onChanged: (v) => currentValue = v,
        ),
      ));
      await tester.tap(find.byIcon(Icons.remove));
      expect(currentValue, 4);
    });

    testWidgets('should not decrement below min', (tester) async {
      int currentValue = 0;
      await tester.pumpWidget(createSimpleTestWidget(
        AppQuantityField(
          value: currentValue,
          min: 0,
          onChanged: (v) => currentValue = v,
        ),
      ));
      await tester.tap(find.byIcon(Icons.remove));
      expect(currentValue, 0);
    });

    testWidgets('should not increment above max', (tester) async {
      int currentValue = 10;
      await tester.pumpWidget(createSimpleTestWidget(
        AppQuantityField(
          value: currentValue,
          max: 10,
          onChanged: (v) => currentValue = v,
        ),
      ));
      await tester.tap(find.byIcon(Icons.add));
      expect(currentValue, 10);
    });

    testWidgets('should use custom step', (tester) async {
      int currentValue = 5;
      await tester.pumpWidget(createSimpleTestWidget(
        AppQuantityField(
          value: currentValue,
          step: 5,
          onChanged: (v) => currentValue = v,
        ),
      ));
      await tester.tap(find.byIcon(Icons.add));
      expect(currentValue, 10);
    });

    testWidgets('should not respond when disabled', (tester) async {
      int currentValue = 5;
      await tester.pumpWidget(createSimpleTestWidget(
        AppQuantityField(
          value: currentValue,
          enabled: false,
          onChanged: (v) => currentValue = v,
        ),
      ));
      await tester.tap(find.byIcon(Icons.add));
      expect(currentValue, 5);
    });
  });
}
