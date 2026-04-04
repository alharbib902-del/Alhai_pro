import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  ReturnsTableCompanion _makeReturn({
    String id = 'ret-1',
    String returnNumber = 'RET-001',
    String saleId = 'sale-1',
    String storeId = 'store-1',
    double totalRefund = 50.0,
    String status = 'completed',
    DateTime? createdAt,
  }) {
    return ReturnsTableCompanion.insert(
      id: id,
      returnNumber: returnNumber,
      saleId: saleId,
      storeId: storeId,
      totalRefund: totalRefund,
      status: Value(status),
      reason: const Value('المنتج تالف'),
      createdAt: createdAt ?? DateTime(2025, 6, 15),
    );
  }

  group('ReturnsDao', () {
    test('insertReturn and getReturnById', () async {
      await db.returnsDao.insertReturn(_makeReturn());

      final ret = await db.returnsDao.getReturnById('ret-1');
      expect(ret, isNotNull);
      expect(ret!.returnNumber, 'RET-001');
      expect(ret.totalRefund, 50.0);
      expect(ret.reason, 'المنتج تالف');
    });

    test('getReturnById returns null for non-existent', () async {
      final ret = await db.returnsDao.getReturnById('non-existent');
      expect(ret, isNull);
    });

    test('getAllReturns returns all for store', () async {
      await db.returnsDao.insertReturn(_makeReturn());
      await db.returnsDao.insertReturn(_makeReturn(
        id: 'ret-2',
        returnNumber: 'RET-002',
        saleId: 'sale-2',
      ));

      final returns = await db.returnsDao.getAllReturns('store-1');
      expect(returns, hasLength(2));
    });

    test('getReturnsBySaleId finds returns for a sale', () async {
      await db.returnsDao.insertReturn(_makeReturn());
      await db.returnsDao.insertReturn(_makeReturn(
        id: 'ret-other',
        returnNumber: 'RET-OTHER',
        saleId: 'sale-other',
      ));

      final returns =
          await db.returnsDao.getReturnsBySaleId('sale-1', 'store-1');
      expect(returns, hasLength(1));
      expect(returns.first.id, 'ret-1');
    });

    test('getReturnsByDateRange filters by date', () async {
      await db.returnsDao.insertReturn(_makeReturn(
        id: 'ret-jun',
        createdAt: DateTime(2025, 6, 15),
      ));
      await db.returnsDao.insertReturn(_makeReturn(
        id: 'ret-jul',
        returnNumber: 'RET-JUL',
        saleId: 'sale-2',
        createdAt: DateTime(2025, 7, 15),
      ));

      final results = await db.returnsDao.getReturnsByDateRange(
        'store-1',
        DateTime(2025, 6, 1),
        DateTime(2025, 6, 30),
      );
      expect(results, hasLength(1));
      expect(results.first.id, 'ret-jun');
    });

    test('markAsSynced sets syncedAt', () async {
      await db.returnsDao.insertReturn(_makeReturn());

      await db.returnsDao.markAsSynced('ret-1');

      final ret = await db.returnsDao.getReturnById('ret-1');
      expect(ret!.syncedAt, isNotNull);
    });

    // Return Items
    test('insertReturnItems and getReturnItems', () async {
      await db.returnsDao.insertReturn(_makeReturn());
      await db.returnsDao.insertReturnItems([
        ReturnItemsTableCompanion.insert(
          id: 'ri-1',
          returnId: 'ret-1',
          productId: 'prod-1',
          productName: 'حليب طازج',
          qty: 2,
          unitPrice: 5.5,
          refundAmount: 11.0,
        ),
        ReturnItemsTableCompanion.insert(
          id: 'ri-2',
          returnId: 'ret-1',
          productId: 'prod-2',
          productName: 'عصير',
          qty: 1,
          unitPrice: 3.0,
          refundAmount: 3.0,
        ),
      ]);

      final items = await db.returnsDao.getReturnItems('ret-1');
      expect(items, hasLength(2));
    });
  });
}
