import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/inputs/alhai_text_field.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiTextField', () {
    group('Rendering', () {
      testWidgets('renders with label text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiTextField(
            labelText: 'Username',
            hintText: 'Enter username',
          ),
        ));

        // Assert
        expect(find.text('Username'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('renders with hint text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiTextField(
            hintText: 'Enter text here',
          ),
        ));

        // Assert
        expect(find.text('Enter text here'), findsOneWidget);
      });

      testWidgets('renders with prefix icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiTextField(
            prefixIcon: Icons.person,
            hintText: 'Name',
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('renders with suffix icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiTextField(
            suffixIcon: Icons.clear,
            hintText: 'Search',
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('phone factory renders correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiTextField.phone(
            labelText: 'Phone',
          ),
        ));

        // Assert
        expect(find.text('Phone'), findsOneWidget);
        expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      });

      testWidgets('password factory renders with toggle', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiTextField.password(
            labelText: 'Password',
          ),
        ));

        // Assert
        expect(find.text('Password'), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      });

      testWidgets('OTP factory renders correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiTextField.otp(
            labelText: 'OTP',
          ),
        ));

        // Assert
        expect(find.text('OTP'), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      });
    });

    group('State', () {
      testWidgets('shows error text when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiTextField(
            labelText: 'Email',
            errorText: 'Invalid email address',
          ),
        ));

        // Assert
        expect(find.text('Invalid email address'), findsOneWidget);
      });

      testWidgets('shows helper text when no error', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiTextField(
            labelText: 'Email',
            helperText: 'Enter your email',
          ),
        ));

        // Assert
        expect(find.text('Enter your email'), findsOneWidget);
      });

      testWidgets('error text takes precedence over helper text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiTextField(
            labelText: 'Field',
            helperText: 'Helper',
            errorText: 'Error',
          ),
        ));

        // Assert
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Helper'), findsNothing);
      });

      testWidgets('disabled state renders correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiTextField(
            labelText: 'Disabled',
            enabled: false,
          ),
        ));

        // Assert
        final field = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(field.enabled, isFalse);
      });

      testWidgets('read only state works correctly', (tester) async {
        // Arrange
        final controller = TextEditingController(text: 'Read only value');

        // Act
        await tester.pumpWidget(createTestWidget(
          AlhaiTextField(
            controller: controller,
            readOnly: true,
          ),
        ));

        // Assert
        expect(find.text('Read only value'), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('calls onChanged callback when text changes', (tester) async {
        // Arrange
        String? changedValue;

        // Act
        await tester.pumpWidget(createTestWidget(
          AlhaiTextField(
            onChanged: (value) => changedValue = value,
          ),
        ));

        await tester.enterText(find.byType(TextFormField), 'Hello');
        await tester.pump();

        // Assert
        expect(changedValue, equals('Hello'));
      });

      testWidgets('calls onSubmitted callback on submit', (tester) async {
        // Arrange
        String? submittedValue;

        // Act
        await tester.pumpWidget(createTestWidget(
          AlhaiTextField(
            onSubmitted: (value) => submittedValue = value,
          ),
        ));

        await tester.enterText(find.byType(TextFormField), 'Submitted');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Assert
        expect(submittedValue, equals('Submitted'));
      });

      testWidgets('password toggle shows/hides text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiTextField.password(
            labelText: 'Password',
          ),
        ));

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

      testWidgets('suffix icon calls onSuffixIconTap', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(createTestWidget(
          AlhaiTextField(
            suffixIcon: Icons.clear,
            onSuffixIconTap: () => tapped = true,
          ),
        ));

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('controller value updates field', (tester) async {
        // Arrange
        final controller = TextEditingController();

        // Act
        await tester.pumpWidget(createTestWidget(
          AlhaiTextField(
            controller: controller,
          ),
        ));

        controller.text = 'Updated text';
        await tester.pump();

        // Assert
        expect(find.text('Updated text'), findsOneWidget);
      });
    });

    group('Focus', () {
      testWidgets('autofocus widget renders correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiTextField(
            autofocus: true,
          ),
        ));
        await tester.pump();

        // Assert - just verify it renders without error
        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Validation', () {
      testWidgets('validator function is applied', (tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();

        // Act
        await tester.pumpWidget(MaterialApp(
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
        ));

        // Trigger validation
        formKey.currentState!.validate();
        await tester.pump();

        // Assert
        expect(find.text('Required'), findsOneWidget);
      });
    });
  });
}
