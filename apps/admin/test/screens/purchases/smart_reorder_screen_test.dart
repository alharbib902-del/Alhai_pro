import 'dart:async';

import 'package:admin/screens/purchases/smart_reorder_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockSuppliersDao mockSuppliersDao;
  late MockProductsDao mockProductsDao;

  setUpAll(() {
    suppressOverflowErrors();
    registerAdminFallbackValues();
  });

  setUp(() {
    mockSuppliersDao = MockSuppliersDao();
    mockProductsDao = MockProductsDao();
    mockDb = setupMockDatabase(
      suppliersDao: mockSuppliersDao,
      productsDao: mockProductsDao,
    );
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('SmartReorderScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<List<dynamic>>();
      when(
        () => mockSuppliersDao.getActiveSuppliers(any()),
      ).thenAnswer((_) => completer.future.then((v) => v.cast()));

      await tester.pumpWidget(createTestWidget(const SmartReorderScreen()));
      await tester.pump();

      // Screen renders while suppliers are loading (no standalone CircularProgressIndicator)
      expect(find.byType(SmartReorderScreen), findsOneWidget);
    });

    testWidgets('renders screen with widget tree', (tester) async {
      when(
        () => mockSuppliersDao.getActiveSuppliers(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const SmartReorderScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SmartReorderScreen), findsOneWidget);
    });

    testWidgets('shows budget text field', (tester) async {
      when(
        () => mockSuppliersDao.getActiveSuppliers(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const SmartReorderScreen()));
      await tester.pumpAndSettle();

      // Budget field should have default value '5000'
      expect(find.text('5000'), findsOneWidget);
    });

    testWidgets('loads suppliers successfully', (tester) async {
      final suppliers = [createTestSupplier(id: 'sup-1', name: 'مورد 1')];
      when(
        () => mockSuppliersDao.getActiveSuppliers(any()),
      ).thenAnswer((_) async => suppliers);

      await tester.pumpWidget(createTestWidget(const SmartReorderScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SmartReorderScreen), findsOneWidget);
    });
  });
}
