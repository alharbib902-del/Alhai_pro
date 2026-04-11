/// Test helpers for Admin app
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'mock_database.dart';
import 'mock_providers.dart';

// Re-export sibling helpers so tests only need one import
export 'mock_database.dart';
export 'mock_providers.dart';
export 'test_factories.dart';

// ============================================================================
// WIDGET TEST WRAPPER
// ============================================================================

/// Creates a test widget wrapped in [ProviderScope] + [MaterialApp].
///
/// Defaults to Arabic locale, RTL text direction, and light theme.
/// When [router] is provided, [MaterialApp.router] is used instead and
/// the [child] parameter is ignored (GoRouter controls the widget tree).
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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

// ============================================================================
// GETIT SETUP / TEARDOWN
// ============================================================================

/// Register a [MockAppDatabase] (or the provided [mockDb]) in GetIt.
///
/// Call this in setUp() before each test that pumps a screen using
/// `GetIt.I<AppDatabase>()`.
void setupTestGetIt({MockAppDatabase? mockDb}) {
  final getIt = GetIt.instance;
  if (getIt.isRegistered<AppDatabase>()) {
    getIt.unregister<AppDatabase>();
  }
  getIt.registerSingleton<AppDatabase>(mockDb ?? MockAppDatabase());
  if (!getIt.isRegistered<SupabaseClient>()) {
    getIt.registerSingleton<SupabaseClient>(MockSupabaseClient());
  }
}

/// Reset GetIt to a clean state.
///
/// Call this in tearDown() after each test.
void tearDownTestGetIt() {
  final getIt = GetIt.instance;
  getIt.reset();
}

// ============================================================================
// ERROR SUPPRESSION
// ============================================================================

/// Suppress [FlutterError] overflow messages during widget tests.
///
/// Useful when testing screens that may overflow in the constrained
/// test viewport. Call once in setUpAll().
void suppressOverflowErrors() {
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final isOverflow = details.toString().contains('overflowed');
    if (!isOverflow) {
      oldOnError?.call(details);
    }
  };
}
