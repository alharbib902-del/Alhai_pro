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

  SuppliersTableCompanion _makeSupplier({
    String id = 'sup-1',
    String storeId = 'store-1',
    String name = 'شركة الأغذية المتحدة',
    String? phone = '0112345678',
    bool isActive = true,
    double balance = 0.0,
  }) {
    return SuppliersTableCompanion.insert(
      id: id,
      storeId: storeId,
      name: name,
      phone: Value(phone),
      isActive: Value(isActive),
      balance: Value(balance),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('SuppliersDao', () {
    test('insertSupplier and getSupplierById', () async {
      await db.suppliersDao.insertSupplier(_makeSupplier());

      final supplier = await db.suppliersDao.getSupplierById('sup-1');
      expect(supplier, isNotNull);
      expect(supplier!.name, 'شركة الأغذية المتحدة');
    });

    test('getAllSuppliers returns all for store', () async {
      await db.suppliersDao.insertSupplier(_makeSupplier());
      await db.suppliersDao.insertSupplier(_makeSupplier(
        id: 'sup-2',
        name: 'مؤسسة التوزيع',
      ));

      final suppliers = await db.suppliersDao.getAllSuppliers('store-1');
      expect(suppliers, hasLength(2));
    });

    test('getActiveSuppliers excludes inactive', () async {
      await db.suppliersDao.insertSupplier(_makeSupplier());
      await db.suppliersDao.insertSupplier(_makeSupplier(
        id: 'sup-2',
        name: 'مورد قديم',
        isActive: false,
      ));

      final active = await db.suppliersDao.getActiveSuppliers('store-1');
      expect(active, hasLength(1));
    });

    test('searchSuppliers finds by name', () async {
      await db.suppliersDao.insertSupplier(_makeSupplier());

      final results = await db.suppliersDao.searchSuppliers('أغذية', 'store-1');
      expect(results, hasLength(1));
    });

    test('searchSuppliers finds by phone', () async {
      await db.suppliersDao.insertSupplier(_makeSupplier());

      final results =
          await db.suppliersDao.searchSuppliers('011234', 'store-1');
      expect(results, hasLength(1));
    });

    test('updateBalance changes supplier balance', () async {
      await db.suppliersDao.insertSupplier(_makeSupplier(balance: 0.0));

      await db.suppliersDao.updateBalance('sup-1', 5000.0);

      final supplier = await db.suppliersDao.getSupplierById('sup-1');
      expect(supplier!.balance, 5000.0);
    });

    test('deleteSupplier removes supplier', () async {
      await db.suppliersDao.insertSupplier(_makeSupplier());

      final deleted = await db.suppliersDao.deleteSupplier('sup-1');
      expect(deleted, 1);

      final supplier = await db.suppliersDao.getSupplierById('sup-1');
      expect(supplier, isNull);
    });

    test('markAsSynced sets syncedAt', () async {
      await db.suppliersDao.insertSupplier(_makeSupplier());

      await db.suppliersDao.markAsSynced('sup-1');

      final supplier = await db.suppliersDao.getSupplierById('sup-1');
      expect(supplier!.syncedAt, isNotNull);
    });
  });
}
