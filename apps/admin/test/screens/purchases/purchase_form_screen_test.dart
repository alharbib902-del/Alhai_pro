import 'package:admin/screens/purchases/purchase_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockSuppliersDao mockSuppliersDao;

  setUpAll(() {
    registerAdminFallbackValues();
  });

  setUp(() {
    mockSuppliersDao = MockSuppliersDao();
    mockDb = setupMockDatabase(suppliersDao: mockSuppliersDao);
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('PurchaseFormScreen', () {
    testWidgets('renders the form screen', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(
        () => mockSuppliersDao.getActiveSuppliers(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PurchaseFormScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows supplier dropdown when loaded', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final suppliers = [createTestSupplier(id: 'sup-1', name: 'مورد تجريبي')];
      when(
        () => mockSuppliersDao.getActiveSuppliers(any()),
      ).thenAnswer((_) async => suppliers);

      await tester.pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(DropdownButtonFormField<String>), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows empty products message initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(
        () => mockSuppliersDao.getActiveSuppliers(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows payment status segment buttons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(
        () => mockSuppliersDao.getActiveSuppliers(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SegmentedButton<String>), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('save button is disabled when no items', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(
        () => mockSuppliersDao.getActiveSuppliers(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      final saveButton = find.byIcon(Icons.save);
      expect(saveButton, findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows add product button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(
        () => mockSuppliersDao.getActiveSuppliers(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.add), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
