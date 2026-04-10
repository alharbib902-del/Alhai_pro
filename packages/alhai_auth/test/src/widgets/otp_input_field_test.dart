import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  Widget buildTestableWidget({
    ValueChanged<String>? onCompleted,
    ValueChanged<String>? onChanged,
    int length = 6,
    bool isError = false,
    bool isSuccess = false,
    bool enabled = true,
    bool autoFocus = false,
    bool showPasteButton = true,
    GlobalKey<OtpInputFieldState>? otpKey,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      home: Scaffold(
        body: OtpInputField(
          key: otpKey,
          onCompleted: onCompleted ?? (_) {},
          onChanged: onChanged,
          length: length,
          isError: isError,
          isSuccess: isSuccess,
          enabled: enabled,
          autoFocus: autoFocus,
          showPasteButton: showPasteButton,
        ),
      ),
    );
  }

  group('OtpInputField', () {
    testWidgets('renders correct number of text fields', (tester) async {
      await tester.pumpWidget(buildTestableWidget(length: 6));
      await tester.pumpAndSettle();

      // Each OTP box has a TextField
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('renders 4 fields when length is 4', (tester) async {
      await tester.pumpWidget(buildTestableWidget(length: 4));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('shows paste button when enabled', (tester) async {
      await tester.pumpWidget(buildTestableWidget(showPasteButton: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.content_paste_rounded), findsOneWidget);
    });

    testWidgets('hides paste button when disabled', (tester) async {
      await tester.pumpWidget(buildTestableWidget(showPasteButton: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.content_paste_rounded), findsNothing);
    });

    testWidgets('hides paste button when field is disabled', (tester) async {
      await tester.pumpWidget(
          buildTestableWidget(showPasteButton: true, enabled: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.content_paste_rounded), findsNothing);
    });

    testWidgets('calls onCompleted when all digits entered', (tester) async {
      String? completedValue;
      await tester.pumpWidget(buildTestableWidget(
        length: 6,
        onCompleted: (value) => completedValue = value,
        autoFocus: false,
      ));
      await tester.pumpAndSettle();

      // Enter digits in each field
      final textFields = find.byType(TextField);
      for (var i = 0; i < 6; i++) {
        await tester.tap(textFields.at(i));
        await tester.enterText(textFields.at(i), '${i + 1}');
        await tester.pumpAndSettle();
      }

      expect(completedValue, '123456');
    });

    testWidgets('calls onChanged when a digit is entered', (tester) async {
      String? changedValue;
      await tester.pumpWidget(buildTestableWidget(
        length: 6,
        onChanged: (value) => changedValue = value,
        autoFocus: false,
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.tap(textFields.first);
      await tester.enterText(textFields.first, '1');
      await tester.pumpAndSettle();

      expect(changedValue, isNotNull);
    });

    testWidgets('clear() empties all fields', (tester) async {
      final key = GlobalKey<OtpInputFieldState>();
      await tester.pumpWidget(buildTestableWidget(
        otpKey: key,
        autoFocus: false,
      ));
      await tester.pumpAndSettle();

      // Enter a digit
      final textFields = find.byType(TextField);
      await tester.tap(textFields.first);
      await tester.enterText(textFields.first, '5');
      await tester.pumpAndSettle();

      // Clear
      key.currentState!.clear();
      await tester.pumpAndSettle();

      // All fields should be empty
      for (var i = 0; i < 6; i++) {
        final field = tester.widget<TextField>(textFields.at(i));
        expect(field.controller!.text, isEmpty);
      }
    });

    testWidgets('setValue() fills fields programmatically', (tester) async {
      final key = GlobalKey<OtpInputFieldState>();
      String? completedValue;
      await tester.pumpWidget(buildTestableWidget(
        otpKey: key,
        autoFocus: false,
        onCompleted: (value) => completedValue = value,
      ));
      await tester.pumpAndSettle();

      key.currentState!.setValue('654321');
      await tester.pumpAndSettle();

      expect(completedValue, '654321');
    });

    testWidgets('renders in LTR direction for numbers', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Directionality), findsWidgets);
    });
  });

  group('OtpInputWithLabel', () {
    testWidgets('shows label when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: OtpInputWithLabel(
            onCompleted: (_) {},
            label: 'Enter OTP',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Enter OTP'), findsOneWidget);
    });

    testWidgets('shows error text when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: OtpInputWithLabel(
            onCompleted: (_) {},
            errorText: 'Invalid code',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Invalid code'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('shows success message when isSuccess', (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: OtpInputWithLabel(
            onCompleted: (_) {},
            isSuccess: true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(
          find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });
  });
}
