/// Test helpers for Admin Lite app
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'mock_database.dart';
import 'mock_providers.dart';

/// Creates a test widget wrapped in MaterialApp + ProviderScope + RTL
Widget createTestWidget(
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('ar'),
  TextDirection textDirection = TextDirection.rtl,
  ThemeData? theme,
  GoRouter? router,
}) {
  return ProviderScope(
    overrides: [...defaultProviderOverrides(), ...overrides],
    child: router != null
        ? MaterialApp.router(
            locale: locale,
            theme: theme ?? ThemeData.light(),
            routerConfig: router,
          )
        : MaterialApp(
            locale: locale,
            theme: theme ?? ThemeData.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Directionality(
              textDirection: textDirection,
              child: Scaffold(body: child),
            ),
          ),
  );
}

/// Setup GetIt with mock database before each test
void setupTestGetIt({MockAppDatabase? mockDb}) {
  final getIt = GetIt.instance;
  if (getIt.isRegistered<AppDatabase>()) {
    getIt.unregister<AppDatabase>();
  }
  getIt.registerSingleton<AppDatabase>(mockDb ?? MockAppDatabase());
}

/// Cleanup GetIt after each test
void tearDownTestGetIt() {
  final getIt = GetIt.instance;
  getIt.reset();
}

/// Suppress overflow errors during widget tests
void suppressOverflowErrors() {
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final isOverflow = details.toString().contains('overflowed');
    if (!isOverflow) {
      oldOnError?.call(details);
    }
  };
}
