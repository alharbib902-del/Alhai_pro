import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
  });

  tearDown(() async {
    await db.close();
  });

  InvoicesTableCompanion makeInvoice({
    String id = 'inv-1',
    String storeId = 'store-1',
    String invoiceNumber = 'INV-2026-00001',
    String invoiceType = 'simplified_tax',
    String status = 'issued',
    double subtotal = 100.0,
    double taxAmount = 15.0,
    double total = 115.0,
    double amountPaid = 0.0,
    double amountDue = 115.0,
    String? saleId,
    String? customerId,
    String? customerName,
    String paymentMethod = 'cash',
    DateTime? createdAt,
    DateTime? dueAt,
  }) {
    return InvoicesTableCompanion.insert(
      id: id,
      storeId: storeId,
      invoiceNumber: invoiceNumber,
      invoiceType: Value(invoiceType),
      status: Value(status),
      // C-4 Session 2: fixture inputs are SAR doubles for readability;
      // convert to int cents at the Drift boundary.
      subtotal: Value((subtotal * 100).round()),
      taxAmount: Value((taxAmount * 100).round()),
      total: Value((total * 100).round()),
      amountPaid: Value((amountPaid * 100).round()),
      amountDue: Value((amountDue * 100).round()),
      saleId: Value(saleId),
      customerId: Value(customerId),
      customerName: Value(customerName),
      paymentMethod: Value(paymentMethod),
      createdAt: createdAt ?? DateTime(2026, 1, 15, 10, 0),
      dueAt: Value(dueAt),
    );
  }

  group('InvoicesDao', () {
    group('getById', () {
      test('returns invoice when exists', () async {
        await db.invoicesDao.upsertInvoice(makeInvoice());

        final invoice = await db.invoicesDao.getById('inv-1');
        expect(invoice, isNotNull);
        expect(invoice!.invoiceNumber, 'INV-2026-00001');
        // C-4 Session 2: invoices.total is int cents.
        expect(invoice.total, 11500);
      });

      test('returns null for non-existent', () async {
        final invoice = await db.invoicesDao.getById('non-existent');
        expect(invoice, isNull);
      });
    });

    group('getByNumber', () {
      test('finds invoice by number and store', () async {
        await db.invoicesDao.upsertInvoice(makeInvoice());

        final invoice = await db.invoicesDao.getByNumber(
          'store-1',
          'INV-2026-00001',
        );
        expect(invoice, isNotNull);
        expect(invoice!.id, 'inv-1');
      });

      test('returns null for wrong store', () async {
        await db.invoicesDao.upsertInvoice(makeInvoice());

        final invoice = await db.invoicesDao.getByNumber(
          'store-2',
          'INV-2026-00001',
        );
        expect(invoice, isNull);
      });
    });

    group('getByStore', () {
      test('returns invoices ordered by date desc', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-1',
            invoiceNumber: 'INV-001',
            createdAt: DateTime(2026, 1, 10),
          ),
        );
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-2',
            invoiceNumber: 'INV-002',
            createdAt: DateTime(2026, 1, 20),
          ),
        );

        final invoices = await db.invoicesDao.getByStore('store-1');
        expect(invoices, hasLength(2));
        expect(invoices.first.id, 'inv-2');
      });

      test('respects limit and offset', () async {
        for (var i = 0; i < 5; i++) {
          await db.invoicesDao.upsertInvoice(
            makeInvoice(
              id: 'inv-$i',
              invoiceNumber: 'INV-$i',
              createdAt: DateTime(2026, 1, i + 1),
            ),
          );
        }

        final page = await db.invoicesDao.getByStore(
          'store-1',
          limit: 2,
          offset: 0,
        );
        expect(page, hasLength(2));
      });
    });

    group('getByType', () {
      test('filters by invoice type', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-1',
            invoiceNumber: 'INV-001',
            invoiceType: 'simplified_tax',
          ),
        );
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-2',
            invoiceNumber: 'CN-001',
            invoiceType: 'credit_note',
          ),
        );

        final creditNotes = await db.invoicesDao.getByType(
          'store-1',
          'credit_note',
        );
        expect(creditNotes, hasLength(1));
        expect(creditNotes.first.id, 'inv-2');
      });
    });

    group('getByStatus', () {
      test('filters by status', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(id: 'inv-1', invoiceNumber: 'INV-001', status: 'issued'),
        );
        await db.invoicesDao.upsertInvoice(
          makeInvoice(id: 'inv-2', invoiceNumber: 'INV-002', status: 'paid'),
        );

        final issued = await db.invoicesDao.getByStatus('store-1', 'issued');
        expect(issued, hasLength(1));
        expect(issued.first.id, 'inv-1');
      });
    });

    group('getBySaleId', () {
      test('finds invoice linked to sale', () async {
        await db.invoicesDao.upsertInvoice(makeInvoice(saleId: 'sale-1'));

        final invoice = await db.invoicesDao.getBySaleId('sale-1');
        expect(invoice, isNotNull);
        expect(invoice!.id, 'inv-1');
      });

      test('returns null when no invoice linked', () async {
        final invoice = await db.invoicesDao.getBySaleId('sale-999');
        expect(invoice, isNull);
      });
    });

    group('getByCustomer', () {
      test('returns invoices for a customer', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-1',
            invoiceNumber: 'INV-001',
            customerId: 'cust-1',
          ),
        );
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-2',
            invoiceNumber: 'INV-002',
            customerId: 'cust-2',
          ),
        );

        final invoices = await db.invoicesDao.getByCustomer(
          'store-1',
          'cust-1',
        );
        expect(invoices, hasLength(1));
        expect(invoices.first.id, 'inv-1');
      });
    });

    group('getUnpaid', () {
      test('returns invoices with amount due > 0', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-paid',
            invoiceNumber: 'INV-001',
            amountDue: 0.0,
            status: 'paid',
          ),
        );
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-unpaid',
            invoiceNumber: 'INV-002',
            amountDue: 50.0,
            status: 'issued',
          ),
        );
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-cancelled',
            invoiceNumber: 'INV-003',
            amountDue: 100.0,
            status: 'cancelled',
          ),
        );

        final unpaid = await db.invoicesDao.getUnpaid('store-1');
        expect(unpaid, hasLength(1));
        expect(unpaid.first.id, 'inv-unpaid');
      });
    });

    group('updateStatus', () {
      test('changes invoice status', () async {
        await db.invoicesDao.upsertInvoice(makeInvoice());

        await db.invoicesDao.updateStatus('inv-1', 'paid');

        final invoice = await db.invoicesDao.getById('inv-1');
        expect(invoice!.status, 'paid');
      });
    });

    group('updatePdfUrl', () {
      test('sets PDF URL', () async {
        await db.invoicesDao.upsertInvoice(makeInvoice());

        await db.invoicesDao.updatePdfUrl('inv-1', 'https://example.com/f.pdf');

        final invoice = await db.invoicesDao.getById('inv-1');
        expect(invoice!.pdfUrl, 'https://example.com/f.pdf');
      });
    });

    group('recordPayment', () {
      test('records partial payment', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(total: 100.0, amountPaid: 0.0, amountDue: 100.0),
        );

        await db.invoicesDao.recordPayment('inv-1', 60.0);

        final invoice = await db.invoicesDao.getById('inv-1');
        // C-4 Session 2: amountPaid/amountDue are int cents.
        expect(invoice!.amountPaid, 6000);
        expect(invoice.amountDue, 4000);
        expect(invoice.status, 'partially_paid');
      });

      test('records full payment and marks as paid', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(total: 100.0, amountPaid: 0.0, amountDue: 100.0),
        );

        await db.invoicesDao.recordPayment('inv-1', 100.0);

        final invoice = await db.invoicesDao.getById('inv-1');
        expect(invoice!.amountPaid, 10000);
        expect(invoice.amountDue, 0);
        expect(invoice.status, 'paid');
        expect(invoice.paidAt, isNotNull);
      });

      test('returns 0 for non-existent invoice', () async {
        final result = await db.invoicesDao.recordPayment('non-existent', 50.0);
        expect(result, 0);
      });
    });

    group('markAsSynced', () {
      test('sets syncedAt timestamp', () async {
        await db.invoicesDao.upsertInvoice(makeInvoice());

        await db.invoicesDao.markAsSynced('inv-1');

        final invoice = await db.invoicesDao.getById('inv-1');
        expect(invoice!.syncedAt, isNotNull);
      });
    });

    group('getLastSequence', () {
      test('returns 0 when no invoices exist', () async {
        final seq = await db.invoicesDao.getLastSequence(
          'store-1',
          'INV',
          2026,
        );
        expect(seq, 0);
      });

      test('extracts sequence number from invoice number', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(id: 'inv-1', invoiceNumber: 'INV-2026-00005'),
        );

        final seq = await db.invoicesDao.getLastSequence(
          'store-1',
          'INV',
          2026,
        );
        expect(seq, 5);
      });
    });

    group('watchByStore', () {
      test('emits initial list', () async {
        await db.invoicesDao.upsertInvoice(makeInvoice());

        final invoices = await db.invoicesDao.watchByStore('store-1').first;
        expect(invoices, hasLength(1));
      });
    });

    group('watchUnpaidCount', () {
      test('emits count of unpaid invoices', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-1',
            invoiceNumber: 'INV-001',
            amountDue: 50.0,
            status: 'issued',
          ),
        );
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-2',
            invoiceNumber: 'INV-002',
            amountDue: 0.0,
            status: 'paid',
          ),
        );

        final count = await db.invoicesDao.watchUnpaidCount('store-1').first;
        expect(count, 1);
      });
    });

    group('getZatcaSentCount (M7)', () {
      test('returns 0 when no invoices exist', () async {
        final count = await db.invoicesDao.getZatcaSentCount(
          storeId: 'store-1',
        );
        expect(count, 0);
      });

      test(
        'counts only invoices with zatca_hash that are NOT in the '
        'queue or dead-letter',
        () async {
          // 3 invoices with zatca_hash:
          //   inv-sent       — signed and no queue row → counted as Sent
          //   inv-pending    — signed but in pending queue → NOT counted
          //   inv-dead       — signed but in dead-letter → NOT counted
          // 1 invoice WITHOUT zatca_hash → NOT counted (never went to ZATCA)
          await db.invoicesDao.upsertInvoice(
            makeInvoice(
              id: 'inv-sent',
              invoiceNumber: 'INV-S',
            ).copyWith(zatcaHash: const Value('hash-sent')),
          );
          await db.invoicesDao.upsertInvoice(
            makeInvoice(
              id: 'inv-pending',
              invoiceNumber: 'INV-P',
            ).copyWith(zatcaHash: const Value('hash-pending')),
          );
          await db.invoicesDao.upsertInvoice(
            makeInvoice(
              id: 'inv-dead',
              invoiceNumber: 'INV-D',
            ).copyWith(zatcaHash: const Value('hash-dead')),
          );
          await db.invoicesDao.upsertInvoice(
            makeInvoice(
              id: 'inv-no-zatca',
              invoiceNumber: 'INV-N',
            ),
          );

          // Put INV-P in the pending queue and INV-D in dead-letter.
          await db.zatcaOfflineQueueDao.upsert(
            invoiceNumber: 'INV-P',
            uuid: 'uuid-p',
            storeId: 'store-1',
            signedXmlBase64: 'xml',
            invoiceHash: 'hash-pending',
            isStandard: false,
          );
          await db
              .into(db.zatcaDeadLetterTable)
              .insert(
                ZatcaDeadLetterTableCompanion.insert(
                  invoiceNumber: 'INV-D',
                  uuid: 'uuid-d',
                  storeId: 'store-1',
                  signedXmlBase64: 'xml',
                  invoiceHash: 'hash-dead',
                  isStandard: false,
                  retryCount: 10,
                  queuedAt: DateTime(2026, 1, 1),
                  deadLetteredAt: DateTime(2026, 1, 2),
                ),
              );

          final count = await db.invoicesDao.getZatcaSentCount(
            storeId: 'store-1',
          );
          expect(count, 1);
        },
      );

      test('respects storeId filter', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-a',
            invoiceNumber: 'INV-A',
          ).copyWith(zatcaHash: const Value('hash-a')),
        );
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-b',
            storeId: 'store-2',
            invoiceNumber: 'INV-B',
          ).copyWith(zatcaHash: const Value('hash-b')),
        );

        final count1 = await db.invoicesDao.getZatcaSentCount(
          storeId: 'store-1',
        );
        final count2 = await db.invoicesDao.getZatcaSentCount(
          storeId: 'store-2',
        );
        expect(count1, 1);
        expect(count2, 1);
      });

      test('returns global count when storeId is null', () async {
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-a',
            invoiceNumber: 'INV-A',
          ).copyWith(zatcaHash: const Value('hash-a')),
        );
        await db.invoicesDao.upsertInvoice(
          makeInvoice(
            id: 'inv-b',
            storeId: 'store-2',
            invoiceNumber: 'INV-B',
          ).copyWith(zatcaHash: const Value('hash-b')),
        );

        final count = await db.invoicesDao.getZatcaSentCount();
        expect(count, 2);
      });
    });
  });
}
