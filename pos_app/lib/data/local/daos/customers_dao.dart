import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/customers_table.dart';

part 'customers_dao.g.dart';

/// DAO for customers
@DriftAccessor(tables: [CustomersTable, CustomerAddressesTable])
class CustomersDao extends DatabaseAccessor<AppDatabase> with _$CustomersDaoMixin {
  CustomersDao(super.db);

  Future<List<CustomersTableData>> getAllCustomers(String storeId) {
    return (select(customersTable)..where((c) => c.storeId.equals(storeId))..orderBy([(c) => OrderingTerm.asc(c.name)])).get();
  }

  Future<List<CustomersTableData>> getActiveCustomers(String storeId) {
    return (select(customersTable)..where((c) => c.storeId.equals(storeId) & c.isActive.equals(true))..orderBy([(c) => OrderingTerm.asc(c.name)])).get();
  }

  Future<CustomersTableData?> getCustomerById(String id) => (select(customersTable)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<List<CustomersTableData>> searchCustomers(String query, String storeId) {
    return (select(customersTable)..where((c) => c.storeId.equals(storeId) & (c.name.contains(query) | c.phone.contains(query)))..limit(20)).get();
  }

  Future<CustomersTableData?> getCustomerByPhone(String phone, String storeId) {
    return (select(customersTable)..where((c) => c.storeId.equals(storeId) & c.phone.equals(phone))).getSingleOrNull();
  }

  Future<int> insertCustomer(CustomersTableCompanion customer) => into(customersTable).insert(customer);
  Future<bool> updateCustomer(CustomersTableData customer) => update(customersTable).replace(customer);
  Future<int> deleteCustomer(String id) => (delete(customersTable)..where((c) => c.id.equals(id))).go();

  Future<int> markAsSynced(String id) {
    return (update(customersTable)..where((c) => c.id.equals(id))).write(CustomersTableCompanion(syncedAt: Value(DateTime.now())));
  }

  Stream<List<CustomersTableData>> watchCustomers(String storeId) {
    return (select(customersTable)..where((c) => c.storeId.equals(storeId))..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();
  }

  // Addresses
  Future<List<CustomerAddressesTableData>> getCustomerAddresses(String customerId) {
    return (select(customerAddressesTable)..where((a) => a.customerId.equals(customerId))..orderBy([(a) => OrderingTerm.desc(a.isDefault)])).get();
  }

  Future<int> insertAddress(CustomerAddressesTableCompanion address) => into(customerAddressesTable).insert(address);
  Future<int> deleteAddress(String id) => (delete(customerAddressesTable)..where((a) => a.id.equals(id))).go();
}
