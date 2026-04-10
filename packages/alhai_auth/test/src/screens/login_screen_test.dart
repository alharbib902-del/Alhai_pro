import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  group('LoginScreen', () {
    Widget buildTestableWidget() {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: const LoginScreen(),
        ),
      );
    }

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // Use pump() instead of pumpAndSettle() because LoginScreen has
      // ongoing async operations (SharedPreferences, timers) that
      // prevent settling.
      await tester.pump();

      // Should render without errors - the screen uses providers
      // but at minimum should build the widget tree
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('contains phone input area', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Phone input should be present on login screen
      expect(find.byType(PhoneInputField), findsOneWidget);
    });

    testWidgets('starts on phone step', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // OTP field should not be visible initially
      expect(find.byType(OtpInputField), findsNothing);
    });
  });

  group('LoginStep', () {
    test('has phone and otp values', () {
      expect(LoginStep.values, hasLength(2));
      expect(LoginStep.values, contains(LoginStep.phone));
      expect(LoginStep.values, contains(LoginStep.otp));
    });
  });
}
