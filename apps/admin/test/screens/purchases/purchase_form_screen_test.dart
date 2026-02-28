import 'package:admin/screens/purchases/purchase_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockSuppliersDao mockSuppliersDao;

  setUpAll(() {
    suppressOverflowErrors();
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
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PurchaseFormScreen), findsOneWidget);
    });

    testWidgets('shows supplier dropdown when loaded', (tester) async {
      final suppliers = [
        createTestSupplier(id: 'sup-1', name: 'مورد تجريبي'),
      ];
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => suppliers);

      await tester
          .pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
    });

    testWidgets('shows empty products message initially', (tester) async {
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('shows payment status segment buttons', (tester) async {
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<String>), findsOneWidget);
    });

    testWidgets('save button is disabled when no items', (tester) async {
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pumpAndSettle();

      final saveButton = find.byIcon(Icons.save);
      expect(saveButton, findsOneWidget);
    });

    testWidgets('shows add product button', (tester) async {
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsWidgets);
    });
  });
}
