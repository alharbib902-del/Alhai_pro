// NOTE: RPC-invocation coverage is deferred to live smoke testing.
// A Dart mock would require either reshaping the shared FakeSupabaseClient
// or adding a wrapper provider layer; both were out of scope for U2.
// The dirty-state tracking (tests below) is the main UX risk.
// RPC contract is verified at the DB layer (v48 V48-A/B/C1, committed separately).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:super_admin/data/models/sa_analytics_model.dart';
import 'package:super_admin/providers/sa_providers.dart';
import 'package:super_admin/screens/settings/sa_platform_settings_screen.dart';

void main() {
  const baseSettings = SAPlatformSettings(
    zatcaEnabled: true,
    zatcaEnvironment: 'production',
    vatRate: 15.0,
    defaultLanguage: 'ar',
    defaultCurrency: 'SAR',
    trialPeriodDays: 14,
    moyasarEnabled: true,
    hyperpayEnabled: false,
    tabbyEnabled: true,
    tamaraEnabled: false,
  );

  Widget buildTestWidget({SAPlatformSettings settings = baseSettings}) {
    return ProviderScope(
      overrides: [
        saPlatformSettingsProvider.overrideWith((_) async => settings),
      ],
      child: MaterialApp(
        title: 'Test',
        theme: AlhaiTheme.dark,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SAPlatformSettingsScreen(),
      ),
    );
  }

  group('SAPlatformSettingsScreen save flow', () {
    testWidgets('Save button disabled when no local changes', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
      expect(saveButton, findsOneWidget);

      final button = tester.widget<FilledButton>(saveButton);
      expect(
        button.onPressed,
        isNull,
        reason: 'Save should be disabled while form matches loaded settings',
      );

      final discard = find.widgetWithText(TextButton, 'Discard');
      expect(discard, findsOneWidget);
      expect(
        tester.widget<TextButton>(discard).onPressed,
        isNull,
        reason: 'Discard should also be disabled when nothing changed',
      );
    });

    testWidgets('Toggling a switch enables Save and Discard', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Toggle Moyasar (was enabled in baseline, flip to off).
      final moyasarTile = find.widgetWithText(SwitchListTile, 'Moyasar');
      expect(moyasarTile, findsOneWidget);
      await tester.tap(moyasarTile);
      await tester.pump();

      final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
      expect(
        tester.widget<FilledButton>(saveButton).onPressed,
        isNotNull,
        reason: 'Save should enable once any field differs from original',
      );

      final discard = find.widgetWithText(TextButton, 'Discard');
      expect(
        tester.widget<TextButton>(discard).onPressed,
        isNotNull,
        reason: 'Discard should enable alongside Save',
      );
    });
  });
}
