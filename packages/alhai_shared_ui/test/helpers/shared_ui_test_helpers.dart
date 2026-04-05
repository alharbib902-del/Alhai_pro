/// Test helpers for alhai_shared_ui package
///
/// Provides mock classes, test widget wrappers, and fallback values.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// Wraps a widget in MaterialApp + ProviderScope for widget testing.
///
/// Supports optional [overrides] for Riverpod providers,
/// [locale] for localization, and [textDirection] for RTL testing.
Widget createTestWidget(
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('ar'),
  TextDirection textDirection = TextDirection.rtl,
  ThemeData? theme,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      theme: theme ?? ThemeData.light(),
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: child,
        ),
      ),
    ),
  );
}

/// Wraps a widget in a minimal MaterialApp for simple widget tests
/// (no ProviderScope needed).
Widget createSimpleTestWidget(
  Widget child, {
  TextDirection textDirection = TextDirection.rtl,
  ThemeData? theme,
}) {
  return MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme ?? ThemeData.light(),
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: child,
      ),
    ),
  );
}
