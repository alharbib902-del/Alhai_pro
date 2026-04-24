/// Golden tests — POS screen baseline snapshots.
///
/// Covers the empty-cart surface across locales + themes + sizes. Each
/// golden is regenerated on CI with `flutter test --update-goldens`. See
/// `golden_config.dart` for the skip logic used on non-Linux hosts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import 'golden_config.dart';

void main() {
  goldenTest('POS: empty cart — light + ar + desktop', (tester) async {
    await tester.pumpWidgetBuilder(
      _buildHarness(locale: const Locale('ar'), themeMode: ThemeMode.light),
      surfaceSize: kDesktopSize,
    );
    await screenMatchesGolden(tester, 'pos_empty_light_ar_desktop');
  });

  goldenTest('POS: empty cart — dark + ar + desktop', (tester) async {
    await tester.pumpWidgetBuilder(
      _buildHarness(locale: const Locale('ar'), themeMode: ThemeMode.dark),
      surfaceSize: kDesktopSize,
    );
    await screenMatchesGolden(tester, 'pos_empty_dark_ar_desktop');
  });

  goldenTest('POS: empty cart — light + en + tablet', (tester) async {
    await tester.pumpWidgetBuilder(
      _buildHarness(locale: const Locale('en'), themeMode: ThemeMode.light),
      surfaceSize: kTabletSize,
    );
    await screenMatchesGolden(tester, 'pos_empty_light_en_tablet');
  });
}

/// Minimal harness that mounts the design-system chrome without the real
/// routing graph. Keeps goldens deterministic — no Firebase/Supabase init.
Widget _buildHarness({
  required Locale locale,
  required ThemeMode themeMode,
}) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: SupportedLocales.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Directionality(
        textDirection:
            locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: const _PosPlaceholder(),
      ),
    ),
  );
}

/// Placeholder body — renders the AlhaiDS surfaces that real POS uses
/// (scaffold + app bar + empty-cart illustration) without pulling in the
/// full alhai_pos PosScreen which depends on DB + Riverpod streams.
class _PosPlaceholder extends StatelessWidget {
  const _PosPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Al-HAI Cashier')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64),
            SizedBox(height: 16),
            Text('POS ready'),
          ],
        ),
      ),
    );
  }
}
