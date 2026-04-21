import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('ZatcaOfflineQueueDao', () {
    group('upsert', () {
      test('inserts a new invoice in queue with retry=0', () async {
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-001',
          uuid: 'uuid-1',
          storeId: 'store-1',
          signedXmlBase64: 'xml-base64-data',
          invoiceHash: 'hash-1',
          isStandard: false,
        );

        final row = await db.zatcaOfflineQueueDao.getByInvoiceNumber('INV-001');
        expect(row, isNotNull);
        expect(row!.retryCount, 0);
        expect(row.signedXmlBase64, 'xml-base64-data');
        expect(row.isStandard, isFalse);
      });

      test('updates signed XML on existing invoice without resetting retry',
          () async {
        // Insert first
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-001',
          uuid: 'uuid-1',
          storeId: 'store-1',
          signedXmlBase64: 'original-xml',
          invoiceHash: 'hash-1',
          isStandard: false,
        );

        // Record one retry so count is non-zero
        await db.zatcaOfflineQueueDao.recordRetry(
          invoiceNumber: 'INV-001',
          lastError: 'network',
        );

        // Re-upsert with new XML (re-sign scenario)
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-001',
          uuid: 'uuid-1',
          storeId: 'store-1',
          signedXmlBase64: 're-signed-xml',
          invoiceHash: 'hash-2',
          isStandard: true,
        );

        final row = await db.zatcaOfflineQueueDao.getByInvoiceNumber('INV-001');
        expect(row!.signedXmlBase64, 're-signed-xml');
        expect(row.invoiceHash, 'hash-2');
        expect(row.isStandard, isTrue);
        expect(row.retryCount, 1, reason: 'retry count must be preserved');
      });
    });

    group('recordRetry', () {
      test('increments retry count and sets lastRetryAt (below max)',
          () async {
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-001',
          uuid: 'uuid-1',
          storeId: 'store-1',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          isStandard: false,
        );

        await db.zatcaOfflineQueueDao.recordRetry(
          invoiceNumber: 'INV-001',
          lastError: 'timeout',
        );

        final row = await db.zatcaOfflineQueueDao.getByInvoiceNumber('INV-001');
        expect(row, isNotNull, reason: 'row should stay in queue below max');
        expect(row!.retryCount, 1);
        expect(row.lastError, 'timeout');
        expect(row.lastRetryAt, isNotNull);

        // Not in dead_letter yet
        final dead = await db.zatcaOfflineQueueDao
            .getDeadLetterByInvoiceNumber('INV-001');
        expect(dead, isNull);
      });

      test('atomic row-move to dead_letter when retry count hits maxRetries',
          () async {
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-001',
          uuid: 'uuid-1',
          storeId: 'store-1',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          isStandard: false,
        );

        // Trigger 10 retries (maxRetries = 10)
        for (var i = 0; i < ZatcaOfflineQueueDao.maxRetries; i++) {
          await db.zatcaOfflineQueueDao.recordRetry(
            invoiceNumber: 'INV-001',
            lastError: 'attempt $i',
          );
        }

        // Row should be GONE from active queue
        final queueRow =
            await db.zatcaOfflineQueueDao.getByInvoiceNumber('INV-001');
        expect(queueRow, isNull,
            reason: 'row must be removed from queue after moveToDeadLetter');

        // Row should be IN dead_letter with full audit trail
        final deadRow = await db.zatcaOfflineQueueDao
            .getDeadLetterByInvoiceNumber('INV-001');
        expect(deadRow, isNotNull);
        expect(deadRow!.retryCount, ZatcaOfflineQueueDao.maxRetries);
        expect(deadRow.deadLetterReason, 'max_retries');
        expect(deadRow.deadLetteredAt, isNotNull);
        expect(deadRow.signedXmlBase64, 'xml',
            reason: 'XML preserved for review/manual retry');
      });

      test('is a no-op when invoice does not exist', () async {
        await db.zatcaOfflineQueueDao.recordRetry(
          invoiceNumber: 'NONEXISTENT',
          lastError: 'x',
        );
        // No exception is success
      });
    });

    group('getPending / getDeadLetter', () {
      test('getPending returns only active queue rows', () async {
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-A',
          uuid: 'uuid-a',
          storeId: 'store-1',
          signedXmlBase64: 'xml-a',
          invoiceHash: 'hash-a',
          isStandard: false,
        );
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-B',
          uuid: 'uuid-b',
          storeId: 'store-1',
          signedXmlBase64: 'xml-b',
          invoiceHash: 'hash-b',
          isStandard: false,
        );

        // Move B to dead_letter
        for (var i = 0; i < ZatcaOfflineQueueDao.maxRetries; i++) {
          await db.zatcaOfflineQueueDao.recordRetry(invoiceNumber: 'INV-B');
        }

        final pending = await db.zatcaOfflineQueueDao.getPending();
        expect(pending.length, 1);
        expect(pending.first.invoiceNumber, 'INV-A');

        final dead = await db.zatcaOfflineQueueDao.getDeadLetter();
        expect(dead.length, 1);
        expect(dead.first.invoiceNumber, 'INV-B');
      });

      test('getPendingCount + getDeadLetterCount separate correctly', () async {
        expect(await db.zatcaOfflineQueueDao.getPendingCount(), 0);
        expect(await db.zatcaOfflineQueueDao.getDeadLetterCount(), 0);

        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-1',
          uuid: 'u1',
          storeId: 's1',
          signedXmlBase64: 'x',
          invoiceHash: 'h',
          isStandard: false,
        );

        expect(await db.zatcaOfflineQueueDao.getPendingCount(), 1);
        expect(await db.zatcaOfflineQueueDao.getDeadLetterCount(), 0);

        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-2',
          uuid: 'u2',
          storeId: 's1',
          signedXmlBase64: 'x',
          invoiceHash: 'h',
          isStandard: false,
        );

        expect(await db.zatcaOfflineQueueDao.getPendingCount(), 2);

        // Move INV-2 to dead_letter
        for (var i = 0; i < ZatcaOfflineQueueDao.maxRetries; i++) {
          await db.zatcaOfflineQueueDao.recordRetry(invoiceNumber: 'INV-2');
        }

        expect(await db.zatcaOfflineQueueDao.getPendingCount(), 1);
        expect(await db.zatcaOfflineQueueDao.getDeadLetterCount(), 1);
      });

      test('getPending filters by storeId when provided', () async {
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-S1',
          uuid: 'u',
          storeId: 'store-1',
          signedXmlBase64: 'x',
          invoiceHash: 'h',
          isStandard: false,
        );
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-S2',
          uuid: 'u',
          storeId: 'store-2',
          signedXmlBase64: 'x',
          invoiceHash: 'h',
          isStandard: false,
        );

        final s1 = await db.zatcaOfflineQueueDao.getPending(storeId: 'store-1');
        expect(s1.length, 1);
        expect(s1.first.invoiceNumber, 'INV-S1');
      });

      test('getDeadLetter filters by storeId when provided', () async {
        // Create + move both to dead_letter
        for (final inv in ['INV-A', 'INV-B']) {
          await db.zatcaOfflineQueueDao.upsert(
            invoiceNumber: inv,
            uuid: 'u',
            storeId: inv == 'INV-A' ? 'store-1' : 'store-2',
            signedXmlBase64: 'x',
            invoiceHash: 'h',
            isStandard: false,
          );
          for (var i = 0; i < ZatcaOfflineQueueDao.maxRetries; i++) {
            await db.zatcaOfflineQueueDao.recordRetry(invoiceNumber: inv);
          }
        }

        final s1 =
            await db.zatcaOfflineQueueDao.getDeadLetter(storeId: 'store-1');
        expect(s1.length, 1);
        expect(s1.first.invoiceNumber, 'INV-A');
      });
    });

    group('remove (active queue)', () {
      test('deletes the invoice row from queue', () async {
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-001',
          uuid: 'u',
          storeId: 's',
          signedXmlBase64: 'x',
          invoiceHash: 'h',
          isStandard: false,
        );

        final removed = await db.zatcaOfflineQueueDao.remove('INV-001');
        expect(removed, 1);

        final row = await db.zatcaOfflineQueueDao.getByInvoiceNumber('INV-001');
        expect(row, isNull);
      });
    });

    group('removeDeadLetter + purgeDeadLetter', () {
      test('purgeDeadLetter deletes only dead_letter rows', () async {
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-PENDING',
          uuid: 'u',
          storeId: 's',
          signedXmlBase64: 'x',
          invoiceHash: 'h',
          isStandard: false,
        );
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-DEAD',
          uuid: 'u',
          storeId: 's',
          signedXmlBase64: 'x',
          invoiceHash: 'h',
          isStandard: false,
        );
        for (var i = 0; i < ZatcaOfflineQueueDao.maxRetries; i++) {
          await db.zatcaOfflineQueueDao.recordRetry(invoiceNumber: 'INV-DEAD');
        }

        final purged = await db.zatcaOfflineQueueDao.purgeDeadLetter();
        expect(purged, 1);

        // Active queue row untouched
        expect(
          await db.zatcaOfflineQueueDao.getByInvoiceNumber('INV-PENDING'),
          isNotNull,
        );
        // Dead_letter row gone
        expect(
          await db.zatcaOfflineQueueDao
              .getDeadLetterByInvoiceNumber('INV-DEAD'),
          isNull,
        );
      });

      test('removeDeadLetter removes single dead_letter row', () async {
        await db.zatcaOfflineQueueDao.upsert(
          invoiceNumber: 'INV-DEAD',
          uuid: 'u',
          storeId: 's',
          signedXmlBase64: 'x',
          invoiceHash: 'h',
          isStandard: false,
        );
        for (var i = 0; i < ZatcaOfflineQueueDao.maxRetries; i++) {
          await db.zatcaOfflineQueueDao.recordRetry(invoiceNumber: 'INV-DEAD');
        }

        final removed =
            await db.zatcaOfflineQueueDao.removeDeadLetter('INV-DEAD');
        expect(removed, 1);
        expect(
          await db.zatcaOfflineQueueDao
              .getDeadLetterByInvoiceNumber('INV-DEAD'),
          isNull,
        );
      });
    });
  });
}
