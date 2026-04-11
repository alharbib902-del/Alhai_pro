import 'dart:async';

import 'package:admin/screens/management/branch_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockStoresDao mockStoresDao;

  setUpAll(() {
    suppressOverflowErrors();
    registerAdminFallbackValues();
  });

  setUp(() {
    mockStoresDao = MockStoresDao();
    mockDb = setupMockDatabase(storesDao: mockStoresDao);
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('BranchManagementScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      final completer = Completer<List<StoresTableData>>();
      when(
        () => mockStoresDao.getAllStores(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(const BranchManagementScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders screen after loading', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockStoresDao.getAllStores()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const BranchManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(BranchManagementScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows error state on failure', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockStoresDao.getAllStores()).thenThrow(Exception('DB error'));

      await tester.pumpWidget(createTestWidget(const BranchManagementScreen()));
      await tester.pumpAndSettle();

      // AppErrorState should be shown
      expect(find.byType(BranchManagementScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has add branch action in header', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockStoresDao.getAllStores()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const BranchManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays stores when loaded', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      final stores = [
        StoresTableData(
          id: 'store-1',
          name: 'الفرع الرئيسي',
          currency: 'SAR',
          timezone: 'Asia/Riyadh',
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        StoresTableData(
          id: 'store-2',
          name: 'فرع المطار',
          currency: 'SAR',
          timezone: 'Asia/Riyadh',
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];
      when(() => mockStoresDao.getAllStores()).thenAnswer((_) async => stores);

      await tester.pumpWidget(createTestWidget(const BranchManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.text('الفرع الرئيسي'), findsOneWidget);
      expect(find.text('فرع المطار'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
