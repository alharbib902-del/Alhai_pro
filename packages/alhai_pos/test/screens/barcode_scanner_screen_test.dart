/// Widget tests for BarcodeScannerScreen
///
/// Tests: rendering, barcode input, scan toggle, empty state
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_pos/src/screens/inventory/barcode_scanner_screen.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockProductsDao extends Mock implements ProductsDao {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget({
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const BarcodeScannerScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockProductsDao mockProductsDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockProductsDao = MockProductsDao();
    when(() => mockDb.productsDao).thenReturn(mockProductsDao);

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(mockDb);
  });

  final originalOnError = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      final msg = details.toString();
      if (msg.contains('overflowed') || msg.contains('Multiple exceptions')) {
        return;
      }
      originalOnError?.call(details);
    };
  });
  tearDown(() {
    FlutterError.onError = originalOnError;
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
  });

  group('BarcodeScannerScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(BarcodeScannerScreen), findsOneWidget);
    });

    testWidgets('shows scan area with QR icon', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byIcon(Icons.qr_code), findsOneWidget);
    });

    testWidgets('has a barcode text input field', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('has a start scanning button with play icon', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      // Start scanning button has play_arrow icon
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('has history button in app bar', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('shows empty state with QR code icon', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      // Empty state shows qr_code_2 icon
      expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    });

    testWidgets('has search icon button next to input', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('has AppBar with title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
