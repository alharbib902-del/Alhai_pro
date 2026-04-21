import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DatabaseBackupService backupService;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
    backupService = DatabaseBackupService(db);
  });

  tearDown(() async {
    backupService.dispose();
    await db.close();
  });

  group('SQL Injection Prevention in Backup Import', () {
    test('valid backup with known columns imports successfully', () async {
      // Insert a product first so the export has data
      // C-4 Stage B: SAR × 100 = cents
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-1',
          storeId: 'store-1',
          name: 'Test Product',
          price: 1000,
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      // Export → import round-trip should succeed (INSERT OR REPLACE)
      final exported = await backupService.exportToJson();
      final counts = await backupService.importFromJson(exported);

      // At least the products table should have imported rows
      expect(counts['products'], greaterThanOrEqualTo(1));
    });

    test('backup with unknown column name throws ArgumentError', () async {
      final maliciousBackup = jsonEncode({
        '_meta': {'schemaVersion': db.schemaVersion},
        'products': [
          {
            'id': 'prod-bad',
            'store_id': 'store-1',
            'name': 'Normal Product',
            'price': 5.0,
            'nonexistent_column': 'should be rejected',
          },
        ],
      });

      expect(
        () => backupService.importFromJson(maliciousBackup),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('invalid column names'),
          ),
        ),
      );
    });

    test('backup with SQL injection column name throws ArgumentError '
        'and tables remain intact', () async {
      // Seed a sale so we can verify it survives the attack
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-safe',
          storeId: 'store-1',
          name: 'Safe Product',
          price: 1000,
          createdAt: DateTime(2025, 1, 1),
        ),
      );
      await db.salesDao.insertSale(
        SalesTableCompanion.insert(
          id: 'sale-safe',
          storeId: 'store-1',
          receiptNo: 'REC-SAFE',
          cashierId: 'cashier-1',
          subtotal: 100.0,
          total: 100.0,
          paymentMethod: 'cash',
          status: const Value('completed'),
          createdAt: DateTime(2025, 6, 15),
        ),
      );

      // Craft a malicious backup that attempts SQL injection via column name
      final maliciousBackup = jsonEncode({
        '_meta': {'schemaVersion': db.schemaVersion},
        'products': [
          {'id': '1', "name) VALUES ('x'); DROP TABLE sales; --": 'payload'},
        ],
      });

      // The import must throw ArgumentError
      expect(
        () => backupService.importFromJson(maliciousBackup),
        throwsA(isA<ArgumentError>()),
      );

      // Verify the sales table still exists and data is intact
      final sale = await db.salesDao.getSaleById('sale-safe');
      expect(sale, isNotNull, reason: 'sales table must survive injection');
      expect(sale!.receiptNo, 'REC-SAFE');
    });
  });
}
