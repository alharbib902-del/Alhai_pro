import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  Widget buildTestableWidget({
    TextEditingController? controller,
    CountryData initialCountry = CountryData.saudiArabia,
    ValueChanged<String>? onChanged,
    ValueChanged<CountryData>? onCountryChanged,
    VoidCallback? onSubmitted,
    String? errorText,
    bool enabled = true,
    bool autofocus = false,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: PhoneInputField(
            controller: controller,
            initialCountry: initialCountry,
            onChanged: onChanged,
            onCountryChanged: onCountryChanged,
            onSubmitted: onSubmitted,
            errorText: errorText,
            enabled: enabled,
            autofocus: autofocus,
          ),
        ),
      ),
    );
  }

  group('PhoneInputField', () {
    testWidgets('renders with default Saudi Arabia country', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PhoneInputField), findsOneWidget);
      expect(find.text('+966'), findsOneWidget);
    });

    testWidgets('renders with UAE country', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(initialCountry: CountryData.uae),
      );
      await tester.pumpAndSettle();

      expect(find.text('+971'), findsOneWidget);
    });

    testWidgets('shows phone text field', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows error text when provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(errorText: 'Invalid phone number'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid phone number'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('does not show error icon when no error', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
    });

    testWidgets('shows country picker arrow', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        buildTestableWidget(onChanged: (value) => changedValue = value),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, '0512345678');
      await tester.pumpAndSettle();

      expect(changedValue, isNotNull);
    });

    testWidgets('uses external controller when provided', (tester) async {
      final controller = TextEditingController(text: '0501234567');
      await tester.pumpWidget(buildTestableWidget(controller: controller));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, contains('050'));

      controller.dispose();
    });

    testWidgets('disables input when enabled is false', (tester) async {
      await tester.pumpWidget(buildTestableWidget(enabled: false));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('opens country picker on tap', (tester) async {
      // Use a taller surface to avoid bottom sheet overflow
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap on the country code area
      await tester.tap(find.text('+966'));
      await tester.pumpAndSettle();

      // Bottom sheet with country list should appear
      // Country picker shows dial codes inside subtitle text like
      // "United Arab Emirates (+971)", so search for substring.
      expect(find.textContaining('+971'), findsWidgets);
    });
  });

  group('CountryData', () {
    test('saudiArabia has correct data', () {
      expect(CountryData.saudiArabia.code, 'SA');
      expect(CountryData.saudiArabia.dialCode, '+966');
      expect(CountryData.saudiArabia.name, 'Saudi Arabia');
    });

    test('uae has correct data', () {
      expect(CountryData.uae.code, 'AE');
      expect(CountryData.uae.dialCode, '+971');
    });

    test('kuwait has correct data', () {
      expect(CountryData.kuwait.code, 'KW');
      expect(CountryData.kuwait.dialCode, '+965');
    });

    test('bahrain has correct data', () {
      expect(CountryData.bahrain.code, 'BH');
      expect(CountryData.bahrain.dialCode, '+973');
    });

    test('qatar has correct data', () {
      expect(CountryData.qatar.code, 'QA');
      expect(CountryData.qatar.dialCode, '+974');
    });

    test('oman has correct data', () {
      expect(CountryData.oman.code, 'OM');
      expect(CountryData.oman.dialCode, '+968');
    });

    test('gulfCountries contains all 6 countries', () {
      expect(CountryData.gulfCountries, hasLength(6));
    });
  });

  group('WhatsAppOtpButton', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WhatsAppOtpButton(onPressed: () {})),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows loading spinner when isLoading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhatsAppOtpButton(onPressed: () {}, isLoading: true),
          ),
        ),
      );
      // Use pump() instead of pumpAndSettle() because
      // CircularProgressIndicator animates indefinitely.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhatsAppOtpButton(onPressed: () => pressed = true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('disables when enabled is false', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhatsAppOtpButton(
              onPressed: () => pressed = true,
              enabled: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isFalse);
    });
  });
}
