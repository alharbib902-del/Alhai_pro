library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/settings/store/store_info_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  late MockStoresDao storesDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    storesDao = MockStoresDao();

    // StoreInfoScreen uses _db.storesDao.getStoreById(storeId).
    // Default: return null (no store found), screen shows empty fields.
    when(() => storesDao.getStoreById(any())).thenAnswer((_) async => null);

    final db = setupMockDatabase(storesDao: storesDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('StoreInfoScreen', () {
    testWidgets('renders with no store data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StoreInfoScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(StoreInfoScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<StoresTableData?>();
      when(
        () => storesDao.getStoreById(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(const StoreInfoScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(null);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const StoreInfoScreen(), theme: ThemeData.dark()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StoreInfoScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StoreInfoScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(StoreInfoScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on tablet viewport', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StoreInfoScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(StoreInfoScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // --- New behaviour: English labels replaced with Arabic -----------------

    testWidgets('shows Arabic "read-only" badge', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StoreInfoScreen()));
      await tester.pumpAndSettle();

      // Was "Read Only", now "للقراءة فقط".
      expect(find.text('للقراءة فقط'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows Arabic "Store Details" section header', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StoreInfoScreen()));
      await tester.pumpAndSettle();

      // Was "Store Details", now "بيانات المتجر".
      expect(find.text('بيانات المتجر'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
