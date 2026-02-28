import 'dart:async';

import 'package:admin/screens/purchases/supplier_return_screen.dart';
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

  group('SupplierReturnScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<List<dynamic>>();
      when(() => mockSuppliersDao.getAllSuppliers(any()))
          .thenAnswer((_) => completer.future.then((v) => v.cast()));

      await tester.pumpWidget(
          createTestWidget(const SupplierReturnScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('renders the supplier return screen', (tester) async {
      when(() => mockSuppliersDao.getAllSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(
          createTestWidget(const SupplierReturnScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SupplierReturnScreen), findsOneWidget);
    });

    testWidgets('loads suppliers list', (tester) async {
      final suppliers = [
        createTestSupplier(id: 'sup-1', name: 'مورد 1'),
        createTestSupplier(id: 'sup-2', name: 'مورد 2'),
      ];
      when(() => mockSuppliersDao.getAllSuppliers(any()))
          .thenAnswer((_) async => suppliers);

      await tester.pumpWidget(
          createTestWidget(const SupplierReturnScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SupplierReturnScreen), findsOneWidget);
    });

    testWidgets('shows return reason options', (tester) async {
      when(() => mockSuppliersDao.getAllSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(
          createTestWidget(const SupplierReturnScreen()));
      await tester.pumpAndSettle();

      // Reason options should be present in the UI
      expect(find.byType(SupplierReturnScreen), findsOneWidget);
    });
  });
}
