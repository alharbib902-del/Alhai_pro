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

  StockTransfersTableCompanion makeTransfer({
    String id = 'xfer-1',
    String transferNumber = 'TRF-001',
    String fromStoreId = 'store-1',
    String toStoreId = 'store-2',
    String status = 'pending',
    String approvalStatus = 'pending',
    String items = '[]',
    String? createdBy,
    DateTime? createdAt,
  }) {
    return StockTransfersTableCompanion.insert(
      id: id,
      transferNumber: transferNumber,
      fromStoreId: fromStoreId,
      toStoreId: toStoreId,
      status: Value(status),
      approvalStatus: Value(approvalStatus),
      items: items,
      createdBy: Value(createdBy),
      createdAt: createdAt ?? DateTime(2026, 1, 15, 10, 0),
    );
  }

  group('StockTransfersDao', () {
    group('getById', () {
      test('returns transfer when exists', () async {
        await db.stockTransfersDao.upsertTransfer(makeTransfer());

        final transfer = await db.stockTransfersDao.getById('xfer-1');
        expect(transfer, isNotNull);
        expect(transfer!.transferNumber, 'TRF-001');
        expect(transfer.status, 'pending');
      });

      test('returns null for non-existent', () async {
        final transfer = await db.stockTransfersDao.getById('non-existent');
        expect(transfer, isNull);
      });
    });

    group('getByStore', () {
      test('returns transfers where store is sender or receiver', () async {
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-1',
            transferNumber: 'TRF-001',
            fromStoreId: 'store-1',
            toStoreId: 'store-2',
          ),
        );
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-2',
            transferNumber: 'TRF-002',
            fromStoreId: 'store-2',
            toStoreId: 'store-1',
          ),
        );
        // store-1 is involved in both
        final transfers = await db.stockTransfersDao.getByStore('store-1');
        expect(transfers, hasLength(2));
      });

      test('excludes transfers for other stores', () async {
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(fromStoreId: 'store-1', toStoreId: 'store-2'),
        );

        final transfers = await db.stockTransfersDao.getByStore('test-store');
        expect(transfers, isEmpty);
      });

      test('orders by createdAt desc', () async {
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-old',
            transferNumber: 'TRF-001',
            createdAt: DateTime(2026, 1, 1),
          ),
        );
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-new',
            transferNumber: 'TRF-002',
            createdAt: DateTime(2026, 1, 20),
          ),
        );

        final transfers = await db.stockTransfersDao.getByStore('store-1');
        expect(transfers.first.id, 'xfer-new');
      });
    });

    group('getOutgoing', () {
      test('returns only transfers FROM the store', () async {
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-out',
            transferNumber: 'TRF-001',
            fromStoreId: 'store-1',
            toStoreId: 'store-2',
          ),
        );
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-in',
            transferNumber: 'TRF-002',
            fromStoreId: 'store-2',
            toStoreId: 'store-1',
          ),
        );

        final outgoing = await db.stockTransfersDao.getOutgoing('store-1');
        expect(outgoing, hasLength(1));
        expect(outgoing.first.id, 'xfer-out');
      });
    });

    group('getIncoming', () {
      test('returns only transfers TO the store', () async {
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-out',
            transferNumber: 'TRF-001',
            fromStoreId: 'store-1',
            toStoreId: 'store-2',
          ),
        );
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-in',
            transferNumber: 'TRF-002',
            fromStoreId: 'store-2',
            toStoreId: 'store-1',
          ),
        );

        final incoming = await db.stockTransfersDao.getIncoming('store-1');
        expect(incoming, hasLength(1));
        expect(incoming.first.id, 'xfer-in');
      });
    });

    group('getPendingIncoming', () {
      test('returns pending incoming transfers', () async {
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-1',
            transferNumber: 'TRF-001',
            fromStoreId: 'store-2',
            toStoreId: 'store-1',
            approvalStatus: 'pending',
          ),
        );
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-2',
            transferNumber: 'TRF-002',
            fromStoreId: 'store-2',
            toStoreId: 'store-1',
            approvalStatus: 'approved',
          ),
        );

        final pending = await db.stockTransfersDao.getPendingIncoming(
          'store-1',
        );
        expect(pending, hasLength(1));
        expect(pending.first.id, 'xfer-1');
      });
    });

    group('updateApprovalStatus', () {
      test('sets approval status and approved by', () async {
        await db.stockTransfersDao.upsertTransfer(makeTransfer());

        await db.stockTransfersDao.updateApprovalStatus(
          'xfer-1',
          approvalStatus: 'approved',
          approvedBy: 'user-1',
        );

        final transfer = await db.stockTransfersDao.getById('xfer-1');
        expect(transfer!.approvalStatus, 'approved');
        expect(transfer.approvedBy, 'user-1');
        expect(transfer.approvedAt, isNotNull);
      });

      test('does not set approvedAt for non-approved status', () async {
        await db.stockTransfersDao.upsertTransfer(makeTransfer());

        await db.stockTransfersDao.updateApprovalStatus(
          'xfer-1',
          approvalStatus: 'cancelled',
        );

        final transfer = await db.stockTransfersDao.getById('xfer-1');
        expect(transfer!.approvalStatus, 'cancelled');
        expect(transfer.approvedAt, isNull);
      });
    });

    group('markInTransit', () {
      test('sets status and approvalStatus to in_transit', () async {
        await db.stockTransfersDao.upsertTransfer(makeTransfer());

        await db.stockTransfersDao.markInTransit('xfer-1');

        final transfer = await db.stockTransfersDao.getById('xfer-1');
        expect(transfer!.status, 'in_transit');
        expect(transfer.approvalStatus, 'in_transit');
      });
    });

    group('markReceived', () {
      test('completes transfer with receiver info', () async {
        await db.stockTransfersDao.upsertTransfer(makeTransfer());

        await db.stockTransfersDao.markReceived('xfer-1', 'user-2');

        final transfer = await db.stockTransfersDao.getById('xfer-1');
        expect(transfer!.status, 'completed');
        expect(transfer.approvalStatus, 'received');
        expect(transfer.receivedBy, 'user-2');
        expect(transfer.receivedAt, isNotNull);
        expect(transfer.completedAt, isNotNull);
      });
    });

    group('cancelTransfer', () {
      test('sets status and approvalStatus to cancelled', () async {
        await db.stockTransfersDao.upsertTransfer(makeTransfer());

        await db.stockTransfersDao.cancelTransfer('xfer-1');

        final transfer = await db.stockTransfersDao.getById('xfer-1');
        expect(transfer!.status, 'cancelled');
        expect(transfer.approvalStatus, 'cancelled');
      });
    });

    group('markAsSynced', () {
      test('sets syncedAt timestamp', () async {
        await db.stockTransfersDao.upsertTransfer(makeTransfer());

        await db.stockTransfersDao.markAsSynced('xfer-1');

        final transfer = await db.stockTransfersDao.getById('xfer-1');
        expect(transfer!.syncedAt, isNotNull);
      });
    });

    group('getUnsynced', () {
      test('returns transfers without syncedAt', () async {
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(id: 'xfer-1', transferNumber: 'TRF-001'),
        );
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(id: 'xfer-2', transferNumber: 'TRF-002'),
        );
        await db.stockTransfersDao.markAsSynced('xfer-1');

        final unsynced = await db.stockTransfersDao.getUnsynced();
        expect(unsynced, hasLength(1));
        expect(unsynced.first.id, 'xfer-2');
      });

      test('orders by createdAt asc', () async {
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-new',
            transferNumber: 'TRF-001',
            createdAt: DateTime(2026, 1, 20),
          ),
        );
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-old',
            transferNumber: 'TRF-002',
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        final unsynced = await db.stockTransfersDao.getUnsynced();
        expect(unsynced.first.id, 'xfer-old');
      });
    });

    group('watchByStore', () {
      test('emits initial list', () async {
        await db.stockTransfersDao.upsertTransfer(makeTransfer());

        final transfers = await db.stockTransfersDao
            .watchByStore('store-1')
            .first;
        expect(transfers, hasLength(1));
      });
    });

    group('watchPendingIncomingCount', () {
      test('emits count of pending incoming transfers', () async {
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-1',
            transferNumber: 'TRF-001',
            fromStoreId: 'store-2',
            toStoreId: 'store-1',
            approvalStatus: 'pending',
          ),
        );
        await db.stockTransfersDao.upsertTransfer(
          makeTransfer(
            id: 'xfer-2',
            transferNumber: 'TRF-002',
            fromStoreId: 'store-2',
            toStoreId: 'store-1',
            approvalStatus: 'approved',
          ),
        );

        final count = await db.stockTransfersDao
            .watchPendingIncomingCount('store-1')
            .first;
        expect(count, 1);
      });
    });
  });
}
