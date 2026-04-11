library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:admin/screens/settings/business/store_settings_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockStoresDao storesDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    storesDao = MockStoresDao();
    db = setupMockDatabase(storesDao: storesDao);
    setupTestGetIt(mockDb: db);

    when(() => storesDao.getStoreById(any())).thenAnswer(
      (_) async => StoresTableData(
        id: 'test-store-1',
        name: 'Test Store',
        currency: 'SAR',
        timezone: 'Asia/Riyadh',
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  });

  tearDown(() => tearDownTestGetIt());

  group('StoreSettingsScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StoreSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(StoreSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows store icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StoreSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.store_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows form fields after loading', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StoreSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows save button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StoreSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows VAT switch', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StoreSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
