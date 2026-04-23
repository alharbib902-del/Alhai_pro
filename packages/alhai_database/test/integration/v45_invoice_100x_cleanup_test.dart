/// Tests the v45 migration UPDATE logic in isolation.
///
/// v45 corrects the 100× amount corruption on local `invoices` rows that
/// was written by the pre-9b154327 invoice_service.createFromSale code.
/// The detection rule is `invoice.total = linked_sale.total * 100`, which
/// is idempotent and safe on clean databases.
library;

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

  group('v45 — Bug A local cleanup', () {
    // Re-run the same UPDATE the migration applies. In production it's
    // executed once by the Drift migrator; here we exercise the SQL
    // logic against fixtures that simulate a pre-fix cashier DB.
    Future<void> runV45Update() async {
      await db.customStatement('''
        UPDATE invoices
        SET
          subtotal = subtotal / 100,
          discount = discount / 100,
          tax_amount = tax_amount / 100,
          total = total / 100,
          amount_paid = amount_paid / 100,
          amount_due = amount_due / 100
        WHERE sale_id IS NOT NULL
          AND invoice_type IN ('simplified_tax', 'standard_tax')
          AND EXISTS (
            SELECT 1 FROM sales s
            WHERE s.id = invoices.sale_id
              AND invoices.total = s.total * 100
          );
      ''');
    }

    test(
      'divides money columns by 100 on a confirmed 100× pattern row',
      () async {
        final now = DateTime(2026, 4, 23, 12, 0);

        // Arrange: a sale stored correctly as 11,550 cents (115.50 SAR),
        // and an invoice corrupted by the pre-fix bug to 1,155,000 cents
        // (displayed as 11,550 SAR).
        await db.salesDao.insertSale(
          SalesTableCompanion.insert(
            id: 'sale-x1',
            receiptNo: 'POS-X1',
            storeId: 'store-1',
            cashierId: 'cashier-1',
            subtotal: 10000,
            total: 11550,
            tax: const Value(1500),
            paymentMethod: 'cash',
            createdAt: now,
          ),
        );
        await db.invoicesDao.upsertInvoice(
          InvoicesTableCompanion.insert(
            id: 'inv-x1',
            storeId: 'store-1',
            invoiceNumber: 'INV-2026-00001',
            invoiceType: const Value('simplified_tax'),
            subtotal: const Value(1000000),
            discount: const Value(0),
            taxAmount: const Value(150000),
            total: const Value(1155000),
            amountPaid: const Value(1155000),
            amountDue: const Value(0),
            saleId: const Value('sale-x1'),
            createdAt: now,
          ),
        );

        // Act.
        await runV45Update();

        // Assert: byte-exact match to source sale.
        final fixed = await db.invoicesDao.getById('inv-x1');
        expect(fixed, isNotNull);
        expect(fixed!.subtotal, 10000);
        expect(fixed.taxAmount, 1500);
        expect(fixed.total, 11550);
        expect(fixed.amountPaid, 11550);
        expect(fixed.amountDue, 0);
      },
    );

    test('is a no-op on a clean invoice (total already matches sale)', () async {
      final now = DateTime(2026, 4, 23, 12, 0);

      // Invoice totals already in cents and equal to sale.total.
      await db.salesDao.insertSale(
        SalesTableCompanion.insert(
          id: 'sale-y1',
          receiptNo: 'POS-Y1',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          subtotal: 4000,
          total: 4600,
          tax: const Value(600),
          paymentMethod: 'cash',
          createdAt: now,
        ),
      );
      await db.invoicesDao.upsertInvoice(
        InvoicesTableCompanion.insert(
          id: 'inv-y1',
          storeId: 'store-1',
          invoiceNumber: 'INV-2026-00002',
          invoiceType: const Value('simplified_tax'),
          subtotal: const Value(4000),
          taxAmount: const Value(600),
          total: const Value(4600),
          amountPaid: const Value(4600),
          saleId: const Value('sale-y1'),
          createdAt: now,
        ),
      );

      await runV45Update();

      final afterRow = await db.invoicesDao.getById('inv-y1');
      expect(afterRow, isNotNull);
      // Untouched.
      expect(afterRow!.subtotal, 4000);
      expect(afterRow.taxAmount, 600);
      expect(afterRow.total, 4600);
      expect(afterRow.amountPaid, 4600);
    });

    test(
      'leaves credit_note invoices alone (different code path, not corrupted)',
      () async {
        final now = DateTime(2026, 4, 23, 12, 0);

        // A credit note has no sale_id linkage; pre-fix code did not
        // corrupt this path. Row values are already in cents.
        await db.invoicesDao.upsertInvoice(
          InvoicesTableCompanion.insert(
            id: 'inv-cn-1',
            storeId: 'store-1',
            invoiceNumber: 'CN-2026-00001',
            invoiceType: const Value('credit_note'),
            subtotal: const Value(10000),
            taxAmount: const Value(1500),
            total: const Value(11500),
            amountPaid: const Value(11500),
            createdAt: now,
          ),
        );

        await runV45Update();

        final cn = await db.invoicesDao.getById('inv-cn-1');
        expect(cn, isNotNull);
        expect(cn!.total, 11500);
        expect(cn.subtotal, 10000);
      },
    );

    test(
      'leaves an invoice whose total does NOT match `sale.total × 100` alone',
      () async {
        final now = DateTime(2026, 4, 23, 12, 0);

        // Fabricated edge case: invoice total doesn't match the 100×
        // pattern against its linked sale. Could be a partial payment
        // that drifted, a later manual correction, or a fresh invoice
        // created by already-fixed code. Safe to leave alone.
        await db.salesDao.insertSale(
          SalesTableCompanion.insert(
            id: 'sale-z1',
            receiptNo: 'POS-Z1',
            storeId: 'store-1',
            cashierId: 'cashier-1',
            subtotal: 4000,
            total: 4600,
            tax: const Value(600),
            paymentMethod: 'cash',
            createdAt: now,
          ),
        );
        // 7000 != 4600 × 100 (= 460000); not the 100× pattern.
        await db.invoicesDao.upsertInvoice(
          InvoicesTableCompanion.insert(
            id: 'inv-z1',
            storeId: 'store-1',
            invoiceNumber: 'INV-2026-00003',
            invoiceType: const Value('simplified_tax'),
            subtotal: const Value(6000),
            taxAmount: const Value(1000),
            total: const Value(7000),
            amountPaid: const Value(7000),
            saleId: const Value('sale-z1'),
            createdAt: now,
          ),
        );

        await runV45Update();

        final z = await db.invoicesDao.getById('inv-z1');
        expect(z, isNotNull);
        expect(z!.total, 7000);
        expect(z.subtotal, 6000);
        expect(z.taxAmount, 1000);
      },
    );
  });
}
