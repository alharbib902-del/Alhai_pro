library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/settings/settings_screen.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockStoresDao storesDao;
  late MockSyncQueueDao syncQueueDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    storesDao = MockStoresDao();
    syncQueueDao = MockSyncQueueDao();
    db = setupMockDatabase(storesDao: storesDao, syncQueueDao: syncQueueDao);
    setupTestGetIt(mockDb: db);

    when(() => storesDao.getStoreById(any())).thenAnswer((_) async => null);
    when(() => syncQueueDao.getPendingCount()).thenAnswer((_) async => 0);
  });

  tearDown(() => tearDownTestGetIt());

  group('SettingsScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows settings icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows grid of setting cards', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Make getStoreById hang using Completer
      final completer = Completer<StoresTableData?>();
      when(() => storesDao.getStoreById(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows ZATCA card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('ZATCA'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows WhatsApp card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('WhatsApp'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
