import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_pos/src/services/invoice_service.dart';

import '../helpers/pos_test_helpers.dart';

// ── Mocks ──────────────────────────────────────────────────

class MockInvoicesDao extends Mock implements InvoicesDao {}

class MockImageUploadService extends Mock implements ImageUploadService {}

class FakeInvoicesTableCompanion extends Fake
    implements InvoicesTableCompanion {}

class TestMockAppDatabase extends MockAppDatabase {
  @override
  Future<T> transaction<T>(
    Future<T> Function() action, {
    bool requireNew = false,
  }) async {
    return await action();
  }
}

void main() {
  late InvoiceService invoiceService;
  late TestMockAppDatabase mockDb;
  late MockInvoicesDao mockInvoicesDao;
  late MockImageUploadService mockUploadService;

  // Test data
  final testSale = createTestSalesTableData();
  final testItems = [
    createTestSaleItemsTableData(
      id: 'item-1',
      productId: 'prod-1',
      productName: 'Product A',
      unitPrice: 20.0,
      qty: 2.0,
      subtotal: 40.0,
      total: 40.0,
    ),
  ];

  final testInvoiceData = InvoicesTableData(
    id: 'invoice-1',
    storeId: 'store-1',
    invoiceNumber: 'INV-2026-00001',
    invoiceType: 'simplified_tax',
    status: 'paid',
    subtotal: (40.0 * 100).round(),
    discount: (0.0 * 100).round(),
    taxRate: 15.0,
    taxAmount: (6.0 * 100).round(),
    total: (46.0 * 100).round(),
    amountPaid: (46.0 * 100).round(),
    amountDue: (0.0 * 100).round(),
    currency: 'SAR',
    createdAt: DateTime(2026, 1, 1, 10, 30),
  );

  setUpAll(() {
    registerPosFallbackValues();
    registerFallbackValue(FakeInvoicesTableCompanion());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockInvoicesDao = MockInvoicesDao();
    mockUploadService = MockImageUploadService();

    mockDb = TestMockAppDatabase();
    when(() => mockDb.invoicesDao).thenReturn(mockInvoicesDao);

    invoiceService = InvoiceService(
      db: mockDb,
      uploadService: mockUploadService,
    );
  });

  group('InvoiceService', () {
    // ── createFromSale ──────────────────────────────────

    group('createFromSale', () {
      setUp(() {
        when(
          () => mockInvoicesDao.getLastSequence(any(), any(), any()),
        ).thenAnswer((_) async => 0);
        when(
          () => mockInvoicesDao.upsertInvoice(any()),
        ).thenAnswer((_) async => 1);
        when(
          () => mockInvoicesDao.getById(any()),
        ).thenAnswer((_) async => testInvoiceData);
        when(
          () => mockInvoicesDao.updatePdfUrl(any(), any()),
        ).thenAnswer((_) async => 1);
        when(
          () => mockUploadService.archiveInvoicePdf(
            storeId: any(named: 'storeId'),
            invoiceNumber: any(named: 'invoiceNumber'),
            pdfBytes: any(named: 'pdfBytes'),
          ),
        ).thenAnswer((_) async => 'https://storage/pdf/inv-001.pdf');
      });

      test('creates simplified tax invoice from sale', () async {
        final result = await invoiceService.createFromSale(
          sale: testSale,
          items: testItems,
        );

        expect(result, isNotNull);
        verify(() => mockInvoicesDao.upsertInvoice(any())).called(1);
      });

      test('generates correct sequential invoice number format', () async {
        when(
          () => mockInvoicesDao.getLastSequence('store-1', 'INV', any()),
        ).thenAnswer((_) async => 42);

        InvoicesTableCompanion? capturedCompanion;
        when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
          capturedCompanion =
              inv.positionalArguments[0] as InvoicesTableCompanion;
          return Future.value(1);
        });

        await invoiceService.createFromSale(sale: testSale, items: testItems);

        expect(capturedCompanion, isNotNull);
        final invoiceNumber = capturedCompanion!.invoiceNumber.value;
        expect(invoiceNumber, 'INV-2026-00043');
      });

      test('returns null on database error', () async {
        when(
          () => mockInvoicesDao.getLastSequence(any(), any(), any()),
        ).thenThrow(Exception('Database error'));

        final result = await invoiceService.createFromSale(
          sale: testSale,
          items: testItems,
        );

        expect(result, isNull);
      });

      test('sets paid status for paid sales', () async {
        final paidSale = createTestSalesTableData(isPaid: true);

        InvoicesTableCompanion? capturedCompanion;
        when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
          capturedCompanion =
              inv.positionalArguments[0] as InvoicesTableCompanion;
          return Future.value(1);
        });

        await invoiceService.createFromSale(sale: paidSale, items: testItems);

        expect(capturedCompanion, isNotNull);
        expect(capturedCompanion!.status.value, 'paid');
      });

      test('sets issued status for unpaid sales', () async {
        final unpaidSale = createTestSalesTableData(isPaid: false);

        InvoicesTableCompanion? capturedCompanion;
        when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
          capturedCompanion =
              inv.positionalArguments[0] as InvoicesTableCompanion;
          return Future.value(1);
        });

        await invoiceService.createFromSale(sale: unpaidSale, items: testItems);

        expect(capturedCompanion, isNotNull);
        expect(capturedCompanion!.status.value, 'issued');
      });

      // C-4 Session 2 regression: createFromSale used to read sale.* (already
      // int cents after the C-4 Session 3 sales migration) and then multiply by
      // 100 again — 100x corruption on every POS-generated invoice, and a
      // ZATCA compliance break since stored totals were wrong. Locks the
      // byte-exact cents round trip here.
      test(
        'passes sale cents through byte-exact to invoice companion '
        '(sale=46.00 SAR, paid, amountReceived=null)',
        () async {
          final sale = createTestSalesTableData(
            subtotal: 40.0,
            discount: 0.0,
            tax: 6.0,
            total: 46.0,
            isPaid: true,
          );

          InvoicesTableCompanion? capturedCompanion;
          when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
            capturedCompanion =
                inv.positionalArguments[0] as InvoicesTableCompanion;
            return Future.value(1);
          });

          await invoiceService.createFromSale(sale: sale, items: testItems);

          expect(capturedCompanion, isNotNull);
          // Sale is stored in cents by the factory (40.0 SAR -> 4000 cents).
          expect(capturedCompanion!.subtotal.value, 4000);
          expect(capturedCompanion!.discount.value, 0);
          expect(capturedCompanion!.taxAmount.value, 600);
          expect(capturedCompanion!.total.value, 4600);
          // Paid sale: amountPaid == total; amountDue == 0.
          expect(capturedCompanion!.amountPaid.value, 4600);
          expect(capturedCompanion!.amountDue.value, 0);
        },
      );

      test(
        'partial payment round-trips cents (sale=100.00, paid 60.00)',
        () async {
          final sale = createTestSalesTableData(
            subtotal: 87.0,
            discount: 0.0,
            tax: 13.0,
            total: 100.0,
            isPaid: false,
            amountReceived: 60.0,
          );

          InvoicesTableCompanion? capturedCompanion;
          when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
            capturedCompanion =
                inv.positionalArguments[0] as InvoicesTableCompanion;
            return Future.value(1);
          });

          await invoiceService.createFromSale(sale: sale, items: testItems);

          expect(capturedCompanion, isNotNull);
          expect(capturedCompanion!.subtotal.value, 8700);
          expect(capturedCompanion!.taxAmount.value, 1300);
          expect(capturedCompanion!.total.value, 10000);
          // Unpaid: amountPaid reflects amountReceived; amountDue is the gap.
          expect(capturedCompanion!.amountPaid.value, 6000);
          expect(capturedCompanion!.amountDue.value, 4000);
        },
      );

      test(
        'unpaid with null amountReceived stores amountPaid=0 and amountDue=total',
        () async {
          final sale = createTestSalesTableData(
            subtotal: 50.0,
            total: 50.0,
            tax: 0.0,
            isPaid: false,
            amountReceived: null,
          );

          InvoicesTableCompanion? capturedCompanion;
          when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
            capturedCompanion =
                inv.positionalArguments[0] as InvoicesTableCompanion;
            return Future.value(1);
          });

          await invoiceService.createFromSale(sale: sale, items: testItems);

          expect(capturedCompanion, isNotNull);
          expect(capturedCompanion!.total.value, 5000);
          expect(capturedCompanion!.amountPaid.value, 0);
          expect(capturedCompanion!.amountDue.value, 5000);
        },
      );
    });

    // ── createCreditNote ────────────────────────────────

    group('createCreditNote', () {
      setUp(() {
        when(
          () => mockInvoicesDao.getLastSequence(any(), any(), any()),
        ).thenAnswer((_) async => 0);
        when(
          () => mockInvoicesDao.upsertInvoice(any()),
        ).thenAnswer((_) async => 1);
        when(
          () => mockInvoicesDao.getById(any()),
        ).thenAnswer((_) async => testInvoiceData);
      });

      test('creates a credit note with correct type', () async {
        InvoicesTableCompanion? capturedCompanion;
        when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
          capturedCompanion =
              inv.positionalArguments[0] as InvoicesTableCompanion;
          return Future.value(1);
        });

        final result = await invoiceService.createCreditNote(
          storeId: 'store-1',
          refInvoiceId: 'original-inv-1',
          reason: 'Customer return',
          amount: 100.0,
          taxAmount: 15.0,
        );

        expect(result, isNotNull);
        expect(capturedCompanion, isNotNull);
        expect(capturedCompanion!.invoiceType.value, 'credit_note');
        expect(capturedCompanion!.refInvoiceId.value, 'original-inv-1');
        expect(capturedCompanion!.refReason.value, 'Customer return');
      });

      test('generates CN- prefixed invoice number', () async {
        when(
          () => mockInvoicesDao.getLastSequence('store-1', 'CN', any()),
        ).thenAnswer((_) async => 5);

        InvoicesTableCompanion? capturedCompanion;
        when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
          capturedCompanion =
              inv.positionalArguments[0] as InvoicesTableCompanion;
          return Future.value(1);
        });

        await invoiceService.createCreditNote(
          storeId: 'store-1',
          refInvoiceId: 'inv-1',
          reason: 'Return',
          amount: 50.0,
          taxAmount: 7.50,
        );

        expect(capturedCompanion, isNotNull);
        final invoiceNumber = capturedCompanion!.invoiceNumber.value;
        expect(invoiceNumber, startsWith('CN-'));
        expect(invoiceNumber, 'CN-2026-00006');
      });

      test('calculates total as amount plus tax', () async {
        InvoicesTableCompanion? capturedCompanion;
        when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
          capturedCompanion =
              inv.positionalArguments[0] as InvoicesTableCompanion;
          return Future.value(1);
        });

        await invoiceService.createCreditNote(
          storeId: 'store-1',
          refInvoiceId: 'inv-1',
          reason: 'Partial return',
          amount: 200.0,
          taxAmount: 30.0,
        );

        // C-4 Session 2: invoices.total/amountPaid are int cents (230 SAR = 23000).
        expect(capturedCompanion!.total.value, 23000);
        expect(capturedCompanion!.amountPaid.value, 23000);
      });

      test('returns null on error', () async {
        when(
          () => mockInvoicesDao.getLastSequence(any(), any(), any()),
        ).thenThrow(Exception('DB error'));

        final result = await invoiceService.createCreditNote(
          storeId: 'store-1',
          refInvoiceId: 'inv-1',
          reason: 'Error test',
          amount: 10.0,
          taxAmount: 1.5,
        );

        expect(result, isNull);
      });
    });

    // ── createDebitNote ─────────────────────────────────

    group('createDebitNote', () {
      setUp(() {
        when(
          () => mockInvoicesDao.getLastSequence(any(), any(), any()),
        ).thenAnswer((_) async => 0);
        when(
          () => mockInvoicesDao.upsertInvoice(any()),
        ).thenAnswer((_) async => 1);
        when(
          () => mockInvoicesDao.getById(any()),
        ).thenAnswer((_) async => testInvoiceData);
      });

      test('creates a debit note with correct type', () async {
        InvoicesTableCompanion? capturedCompanion;
        when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
          capturedCompanion =
              inv.positionalArguments[0] as InvoicesTableCompanion;
          return Future.value(1);
        });

        final result = await invoiceService.createDebitNote(
          storeId: 'store-1',
          refInvoiceId: 'original-inv-1',
          reason: 'Price adjustment',
          amount: 50.0,
          taxAmount: 7.50,
        );

        expect(result, isNotNull);
        expect(capturedCompanion!.invoiceType.value, 'debit_note');
        expect(capturedCompanion!.refInvoiceId.value, 'original-inv-1');
      });

      test('generates DN- prefixed invoice number', () async {
        when(
          () => mockInvoicesDao.getLastSequence('store-1', 'DN', any()),
        ).thenAnswer((_) async => 10);

        InvoicesTableCompanion? capturedCompanion;
        when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
          capturedCompanion =
              inv.positionalArguments[0] as InvoicesTableCompanion;
          return Future.value(1);
        });

        await invoiceService.createDebitNote(
          storeId: 'store-1',
          refInvoiceId: 'inv-1',
          reason: 'Adjustment',
          amount: 25.0,
          taxAmount: 3.75,
        );

        final invoiceNumber = capturedCompanion!.invoiceNumber.value;
        expect(invoiceNumber, 'DN-2026-00011');
      });

      test('sets amount due instead of paid for debit notes', () async {
        InvoicesTableCompanion? capturedCompanion;
        when(() => mockInvoicesDao.upsertInvoice(any())).thenAnswer((inv) {
          capturedCompanion =
              inv.positionalArguments[0] as InvoicesTableCompanion;
          return Future.value(1);
        });

        await invoiceService.createDebitNote(
          storeId: 'store-1',
          refInvoiceId: 'inv-1',
          reason: 'Additional charge',
          amount: 100.0,
          taxAmount: 15.0,
        );

        // C-4 Session 2: invoices.total/amountDue are int cents (115 SAR = 11500).
        expect(capturedCompanion!.total.value, 11500);
        expect(capturedCompanion!.amountDue.value, 11500);
      });

      test('returns null on error', () async {
        when(
          () => mockInvoicesDao.getLastSequence(any(), any(), any()),
        ).thenThrow(Exception('Connection lost'));

        final result = await invoiceService.createDebitNote(
          storeId: 'store-1',
          refInvoiceId: 'inv-1',
          reason: 'Test',
          amount: 10.0,
          taxAmount: 1.5,
        );

        expect(result, isNull);
      });
    });

    // ── InvoiceType enum ────────────────────────────────

    group('InvoiceType', () {
      test('has correct values and prefixes', () {
        expect(InvoiceType.simplifiedTax.value, 'simplified_tax');
        expect(InvoiceType.simplifiedTax.prefix, 'INV');

        expect(InvoiceType.standardTax.value, 'standard_tax');
        expect(InvoiceType.standardTax.prefix, 'TAX');

        expect(InvoiceType.creditNote.value, 'credit_note');
        expect(InvoiceType.creditNote.prefix, 'CN');

        expect(InvoiceType.debitNote.value, 'debit_note');
        expect(InvoiceType.debitNote.prefix, 'DN');
      });
    });
  });
}
