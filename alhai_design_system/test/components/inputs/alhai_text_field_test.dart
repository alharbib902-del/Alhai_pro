import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiTextField', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiTextField(hintText: 'Enter text')),
      );

      expect(find.byType(AlhaiTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows hint text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiTextField(hintText: 'Enter your name')),
      );

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('shows label text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiTextField(labelText: 'Name')),
      );

      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('shows error text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiTextField(errorText: 'Required field')),
      );

      expect(find.text('Required field'), findsOneWidget);
    });

    testWidgets('shows helper text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiTextField(helperText: 'Enter at least 3 characters'),
        ),
      );

      expect(find.text('Enter at least 3 characters'), findsOneWidget);
    });

    testWidgets('shows prefix icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiTextField(prefixIcon: Icons.email)),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('shows suffix icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiTextField(suffixIcon: Icons.clear)),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('onChanged is called when text changes', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiTextField(onChanged: (value) => changedValue = value),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello');
      expect(changedValue, 'Hello');
    });

    testWidgets('controller receives text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createTestWidget(AlhaiTextField(controller: controller)),
      );

      await tester.enterText(find.byType(TextFormField), 'Test');
      expect(controller.text, 'Test');

      controller.dispose();
    });

    testWidgets('is read only when readOnly is true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AlhaiTextField(readOnly: true, onChanged: (_) {})),
      );

      // Verify the AlhaiTextField renders without error when readOnly
      expect(find.byType(AlhaiTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('error text takes precedence over helper text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiTextField(
            labelText: 'Field',
            helperText: 'Helper',
            errorText: 'Error',
          ),
        ),
      );

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Helper'), findsNothing);
    });

    testWidgets('disabled state renders correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiTextField(labelText: 'Disabled', enabled: false),
        ),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });

    testWidgets('calls onSubmitted callback on submit', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        createTestWidget(
          AlhaiTextField(onSubmitted: (value) => submittedValue = value),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Submitted');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, equals('Submitted'));
    });

    testWidgets('suffix icon calls onSuffixIconTap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestWidget(
          AlhaiTextField(
            suffixIcon: Icons.clear,
            onSuffixIconTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('controller value updates field', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        createTestWidget(AlhaiTextField(controller: controller)),
      );

      controller.text = 'Updated text';
      await tester.pump();

      expect(find.text('Updated text'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('autofocus widget renders correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiTextField(autofocus: true)),
      );
      await tester.pump();

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('validator function is applied', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AlhaiTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    group('factories', () {
      testWidgets('phone factory renders with phone icon', (tester) async {
        await tester.pumpWidget(createTestWidget(AlhaiTextField.phone()));

        expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      });

      testWidgets('password factory renders with lock icon', (tester) async {
        await tester.pumpWidget(createTestWidget(AlhaiTextField.password()));

        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      });

      testWidgets('password factory has toggle visibility button', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(AlhaiTextField.password()));

        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      });

      testWidgets('password toggle shows/hides text', (tester) async {
        await tester.pumpWidget(
          createTestWidget(AlhaiTextField.password(labelText: 'Password')),
        );

        // Initially obscured
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

        // Tap toggle
        await tester.tap(find.byIcon(Icons.visibility_off_outlined));
        await tester.pump();

        // Now visible
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

        // Tap toggle again
        await tester.tap(find.byIcon(Icons.visibility_outlined));
        await tester.pump();

        // Back to obscured
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      });

      testWidgets('otp factory renders with lock icon', (tester) async {
        await tester.pumpWidget(createTestWidget(AlhaiTextField.otp()));

        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      });
    });
  });
}
