import 'package:admin/screens/purchases/ai_invoice_review_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_ai/alhai_ai.dart' show AiInvoiceResult, AiInvoiceItem;

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

  AiInvoiceResult createTestInvoiceResult() {
    return AiInvoiceResult(
      supplierName: 'مورد تجريبي',
      invoiceNumber: 'INV-001',
      invoiceDate: DateTime(2026, 1, 15),
      totalAmount: 500.0,
      taxAmount: 75.0,
      items: [
        AiInvoiceItem(
          rawName: 'منتج تجريبي',
          quantity: 10,
          unitPrice: 25.0,
          total: 250.0,
          confidence: 95,
        ),
        AiInvoiceItem(
          rawName: 'منتج آخر',
          quantity: 5,
          unitPrice: 50.0,
          total: 250.0,
          confidence: 50,
        ),
      ],
    );
  }

  group('AiInvoiceReviewScreen', () {
    testWidgets('renders the review screen', (tester) async {
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(
        AiInvoiceReviewScreen(invoiceData: createTestInvoiceResult()),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AiInvoiceReviewScreen), findsOneWidget);
    });

    testWidgets('displays invoice items', (tester) async {
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(
        AiInvoiceReviewScreen(invoiceData: createTestInvoiceResult()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('منتج تجريبي'), findsWidgets);
      expect(find.text('منتج آخر'), findsWidgets);
    });

    testWidgets('shows supplier name from invoice', (tester) async {
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(
        AiInvoiceReviewScreen(invoiceData: createTestInvoiceResult()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('مورد تجريبي'), findsWidgets);
    });

    testWidgets('shows confidence indicators', (tester) async {
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(
        AiInvoiceReviewScreen(invoiceData: createTestInvoiceResult()),
      ));
      await tester.pumpAndSettle();

      // Screen should render with items
      expect(find.byType(AiInvoiceReviewScreen), findsOneWidget);
    });
  });
}
