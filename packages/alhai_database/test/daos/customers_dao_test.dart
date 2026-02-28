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

  CustomersTableCompanion _makeCustomer({
    String id = 'cust-1',
    String storeId = 'store-1',
    String name = 'أحمد محمد',
    String? phone = '0501234567',
    bool isActive = true,
  }) {
    return CustomersTableCompanion.insert(
      id: id,
      storeId: storeId,
      name: name,
      phone: Value(phone),
      isActive: Value(isActive),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('CustomersDao', () {
    test('insertCustomer and getCustomerById', () async {
      await db.customersDao.insertCustomer(_makeCustomer());

      final customer = await db.customersDao.getCustomerById('cust-1');
      expect(customer, isNotNull);
      expect(customer!.name, 'أحمد محمد');
      expect(customer.phone, '0501234567');
    });

    test('getCustomerById returns null for non-existent', () async {
      final customer = await db.customersDao.getCustomerById('non-existent');
      expect(customer, isNull);
    });

    test('getAllCustomers returns all for store', () async {
      await db.customersDao.insertCustomer(_makeCustomer());
      await db.customersDao.insertCustomer(_makeCustomer(
        id: 'cust-2',
        name: 'فاطمة علي',
        phone: '0509876543',
      ));

      final customers = await db.customersDao.getAllCustomers('store-1');
      expect(customers, hasLength(2));
    });

    test('getActiveCustomers excludes inactive', () async {
      await db.customersDao.insertCustomer(_makeCustomer());
      await db.customersDao.insertCustomer(_makeCustomer(
        id: 'cust-2',
        name: 'خالد سعيد',
        isActive: false,
      ));

      final active = await db.customersDao.getActiveCustomers('store-1');
      expect(active, hasLength(1));
      expect(active.first.name, 'أحمد محمد');
    });

    test('searchCustomers finds by name', () async {
      await db.customersDao.insertCustomer(_makeCustomer());
      await db.customersDao.insertCustomer(_makeCustomer(
        id: 'cust-2',
        name: 'سارة أحمد',
        phone: '0507777777',
      ));

      final results =
          await db.customersDao.searchCustomers('أحمد', 'store-1');
      expect(results, hasLength(2));
    });

    test('searchCustomers finds by phone', () async {
      await db.customersDao.insertCustomer(_makeCustomer());

      final results =
          await db.customersDao.searchCustomers('0501234567', 'store-1');
      expect(results, hasLength(1));
    });

    test('getCustomerByPhone returns correct customer', () async {
      await db.customersDao.insertCustomer(_makeCustomer());

      final customer =
          await db.customersDao.getCustomerByPhone('0501234567', 'store-1');
      expect(customer, isNotNull);
      expect(customer!.id, 'cust-1');
    });

    test('updateCustomer modifies data', () async {
      await db.customersDao.insertCustomer(_makeCustomer());
      final customer = await db.customersDao.getCustomerById('cust-1');
      final updated = customer!.copyWith(name: 'أحمد محمد الشهري');

      await db.customersDao.updateCustomer(updated);

      final fetched = await db.customersDao.getCustomerById('cust-1');
      expect(fetched!.name, 'أحمد محمد الشهري');
    });

    test('deleteCustomer removes customer', () async {
      await db.customersDao.insertCustomer(_makeCustomer());

      final deleted = await db.customersDao.deleteCustomer('cust-1');
      expect(deleted, 1);

      final customer = await db.customersDao.getCustomerById('cust-1');
      expect(customer, isNull);
    });

    test('markAsSynced sets syncedAt', () async {
      await db.customersDao.insertCustomer(_makeCustomer());

      await db.customersDao.markAsSynced('cust-1');

      final customer = await db.customersDao.getCustomerById('cust-1');
      expect(customer!.syncedAt, isNotNull);
    });

    // Customer Addresses
    test('insertAddress and getCustomerAddresses', () async {
      await db.customersDao.insertCustomer(_makeCustomer());
      await db.customersDao.insertAddress(
        CustomerAddressesTableCompanion.insert(
          id: 'addr-1',
          customerId: 'cust-1',
          address: 'شارع الملك فهد، الرياض',
          isDefault: const Value(true),
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final addresses =
          await db.customersDao.getCustomerAddresses('cust-1');
      expect(addresses, hasLength(1));
      expect(addresses.first.address, 'شارع الملك فهد، الرياض');
      expect(addresses.first.isDefault, true);
    });

    test('deleteAddress removes address', () async {
      await db.customersDao.insertCustomer(_makeCustomer());
      await db.customersDao.insertAddress(
        CustomerAddressesTableCompanion.insert(
          id: 'addr-1',
          customerId: 'cust-1',
          address: 'عنوان تجريبي',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      await db.customersDao.deleteAddress('addr-1');

      final addresses =
          await db.customersDao.getCustomerAddresses('cust-1');
      expect(addresses, isEmpty);
    });
  });
}
