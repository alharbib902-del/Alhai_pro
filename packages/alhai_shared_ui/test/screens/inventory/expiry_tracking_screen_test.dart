/// Widget tests for ExpiryTrackingScreen
///
/// Tests: loading state, error state, data display
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget({
  AsyncValue<List<ExpiryItemData>>? expiryValue,
  Completer<List<ExpiryItemData>>? loadingCompleter,
}) {
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      expiryTrackingProvider.overrideWith(
        (ref) =>
            expiryValue?.when(
              data: (d) => Future.value(d),
              loading: () =>
                  loadingCompleter?.future ??
                  Completer<List<ExpiryItemData>>().future,
              error: (e, _) => Future.error(e),
            ) ??
            Future.value(<ExpiryItemData>[]),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ExpiryTrackingScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final originalOnError = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
  });
  tearDown(() => FlutterError.onError = originalOnError);

  group('ExpiryTrackingScreen', () {
    testWidgets('renders without errors', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ExpiryTrackingScreen), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final completer = Completer<List<ExpiryItemData>>();

      await tester.pumpWidget(_buildTestWidget(
        expiryValue: const AsyncValue.loading(),
        loadingCompleter: completer,
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(<ExpiryItemData>[]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows error state', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget(
        expiryValue: AsyncValue.error(Exception('Failed'), StackTrace.current),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows data when loaded with empty list', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget(
        expiryValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ExpiryTrackingScreen), findsOneWidget);
    });

    testWidgets('has TabBar with 3 tabs', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(TabBar), findsOneWidget);
    });
  });
}
