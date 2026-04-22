import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
    // purchase_items reference products via FK
    // C-4 Stage B: SAR × 100 = cents
    final now = DateTime(2025, 1, 1);
    for (var i = 1; i <= 2; i++) {
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-$i',
          storeId: 'store-1',
          name: 'P$i',
          price: 1000,
          createdAt: now,
        ),
      );
    }
  });

  tearDown(() async {
    await db.close();
  });

  PurchasesTableCompanion makePurchase({
    String id = 'pur-1',
    String storeId = 'store-1',
    String purchaseNumber = 'PO-001',
    String status = 'draft',
    double total = 5000.0,
  }) {
    return PurchasesTableCompanion.insert(
      id: id,
      storeId: storeId,
      purchaseNumber: purchaseNumber,
      status: Value(status),
      total: Value((total * 100).round()),
      supplierName: const Value('مورد تجريبي'),
      createdAt: DateTime(2025, 6, 15),
    );
  }

  group('PurchasesDao', () {
    test('insertPurchase and getPurchaseById', () async {
      await db.purchasesDao.insertPurchase(makePurchase());

      final purchase = await db.purchasesDao.getPurchaseById('pur-1');
      expect(purchase, isNotNull);
      expect(purchase!.purchaseNumber, 'PO-001');
      expect(purchase.status, 'draft');
      expect(purchase.total, 500000); // 5000.00 in cents
    });

    test('getAllPurchases returns all for store', () async {
      await db.purchasesDao.insertPurchase(makePurchase());
      await db.purchasesDao.insertPurchase(
        makePurchase(id: 'pur-2', purchaseNumber: 'PO-002'),
      );

      final purchases = await db.purchasesDao.getAllPurchases('store-1');
      expect(purchases, hasLength(2));
    });

    test('getPurchasesByStatus filters correctly', () async {
      await db.purchasesDao.insertPurchase(
        makePurchase(id: 'pur-1', status: 'draft'),
      );
      await db.purchasesDao.insertPurchase(
        makePurchase(id: 'pur-2', purchaseNumber: 'PO-002', status: 'received'),
      );

      final drafts = await db.purchasesDao.getPurchasesByStatus(
        'store-1',
        'draft',
      );
      expect(drafts, hasLength(1));
      expect(drafts.first.id, 'pur-1');
    });

    test('updateStatus changes purchase status', () async {
      await db.purchasesDao.insertPurchase(makePurchase());

      await db.purchasesDao.updateStatus('pur-1', 'confirmed');

      final purchase = await db.purchasesDao.getPurchaseById('pur-1');
      expect(purchase!.status, 'confirmed');
    });

    test('receivePurchase sets status and receivedAt', () async {
      await db.purchasesDao.insertPurchase(makePurchase());

      await db.purchasesDao.receivePurchase('pur-1');

      final purchase = await db.purchasesDao.getPurchaseById('pur-1');
      expect(purchase!.status, 'received');
      expect(purchase.receivedAt, isNotNull);
    });

    test('deletePurchase removes purchase', () async {
      await db.purchasesDao.insertPurchase(makePurchase());

      final deleted = await db.purchasesDao.deletePurchase('pur-1');
      expect(deleted, 1);
    });

    test('markAsSynced sets syncedAt', () async {
      await db.purchasesDao.insertPurchase(makePurchase());

      await db.purchasesDao.markAsSynced('pur-1');

      final purchase = await db.purchasesDao.getPurchaseById('pur-1');
      expect(purchase!.syncedAt, isNotNull);
    });

    // Purchase Items
    test('insertPurchaseItems and getPurchaseItems', () async {
      await db.purchasesDao.insertPurchase(makePurchase());
      await db.purchasesDao.insertPurchaseItems([
        PurchaseItemsTableCompanion.insert(
          id: 'pi-1',
          purchaseId: 'pur-1',
          productId: 'prod-1',
          productName: 'حليب طازج',
          qty: 100,
          unitCost: 400, // 4.00 in cents
          total: 40000, // 400.00 in cents
        ),
        PurchaseItemsTableCompanion.insert(
          id: 'pi-2',
          purchaseId: 'pur-1',
          productId: 'prod-2',
          productName: 'عصير',
          qty: 50,
          unitCost: 200, // 2.00 in cents
          total: 10000, // 100.00 in cents
        ),
      ]);

      final items = await db.purchasesDao.getPurchaseItems('pur-1');
      expect(items, hasLength(2));
    });

    test('deletePurchaseItems removes items for purchase', () async {
      await db.purchasesDao.insertPurchase(makePurchase());
      await db.purchasesDao.insertPurchaseItems([
        PurchaseItemsTableCompanion.insert(
          id: 'pi-1',
          purchaseId: 'pur-1',
          productId: 'prod-1',
          productName: 'حليب',
          qty: 10,
          unitCost: 400, // 4.00 in cents
          total: 4000, // 40.00 in cents
        ),
      ]);

      final deleted = await db.purchasesDao.deletePurchaseItems('pur-1');
      expect(deleted, 1);

      final items = await db.purchasesDao.getPurchaseItems('pur-1');
      expect(items, isEmpty);
    });
  });
}
