import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:alhai_database/alhai_database.dart';
import 'helpers/database_test_helpers.dart';

void main() {
  group('AppDatabase', () {
    test('forTesting constructor creates database', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      expect(db, isNotNull);
      await db.close();
    });

    test('createTestDatabase helper works', () async {
      final db = createTestDatabase();
      expect(db, isNotNull);
      await db.close();
    });

    test('schema version is 23', () async {
      final db = createTestDatabase();
      expect(db.schemaVersion, 23);
      await db.close();
    });

    test('all DAOs are accessible', () async {
      final db = createTestDatabase();

      // Core DAOs
      expect(db.productsDao, isNotNull);
      expect(db.salesDao, isNotNull);
      expect(db.saleItemsDao, isNotNull);
      expect(db.inventoryDao, isNotNull);
      expect(db.accountsDao, isNotNull);
      expect(db.syncQueueDao, isNotNull);
      expect(db.transactionsDao, isNotNull);
      expect(db.ordersDao, isNotNull);
      expect(db.auditLogDao, isNotNull);
      expect(db.categoriesDao, isNotNull);
      expect(db.loyaltyDao, isNotNull);

      // New DAOs
      expect(db.storesDao, isNotNull);
      expect(db.usersDao, isNotNull);
      expect(db.customersDao, isNotNull);
      expect(db.suppliersDao, isNotNull);
      expect(db.shiftsDao, isNotNull);
      expect(db.returnsDao, isNotNull);
      expect(db.expensesDao, isNotNull);
      expect(db.purchasesDao, isNotNull);
      expect(db.discountsDao, isNotNull);
      expect(db.notificationsDao, isNotNull);

      // WhatsApp DAOs
      expect(db.whatsAppMessagesDao, isNotNull);
      expect(db.whatsAppTemplatesDao, isNotNull);

      // Multi-tenant DAOs
      expect(db.organizationsDao, isNotNull);
      expect(db.orgMembersDao, isNotNull);
      expect(db.posTerminalsDao, isNotNull);

      // Sync DAOs
      expect(db.syncMetadataDao, isNotNull);
      expect(db.stockDeltasDao, isNotNull);

      await db.close();
    });

    test('database can perform basic CRUD operations', () async {
      final db = createTestDatabase();
      await seedTestData(db);

      // Insert a product
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'test-prod',
          storeId: 'test-store',
          name: 'منتج اختبار',
          price: 10.0,
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      // Read it back
      final product = await db.productsDao.getProductById('test-prod');
      expect(product, isNotNull);
      expect(product!.name, 'منتج اختبار');

      // Delete it
      await db.productsDao.deleteProduct('test-prod');
      final deleted = await db.productsDao.getProductById('test-prod');
      expect(deleted, isNull);

      await db.close();
    });

    test('multiple databases are independent', () async {
      final db1 = createTestDatabase();
      final db2 = createTestDatabase();
      await seedTestData(db1);
      await seedTestData(db2);

      await db1.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-db1',
          storeId: 'store-1',
          name: 'منتج قاعدة بيانات 1',
          price: 5.0,
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      // db2 should not have this product
      final inDb2 = await db2.productsDao.getProductById('prod-db1');
      expect(inDb2, isNull);

      await db1.close();
      await db2.close();
    });

    test('FTS service is accessible', () async {
      final db = createTestDatabase();
      expect(db.ftsService, isNotNull);
      await db.close();
    });
  });
}
