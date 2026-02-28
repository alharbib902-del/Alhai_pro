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

  // ============================================================================
  // Pagination Methods - M61: تحسينات الأداء للقوائم الطويلة
  // ============================================================================

  /// الحصول على عملاء مع Pagination
  Future<List<CustomersTableData>> getCustomersPaginated(
    String storeId, {
    int offset = 0,
    int limit = 50,
    bool activeOnly = true,
  }) {
    return (select(customersTable)
      ..where((c) {
        var condition = c.storeId.equals(storeId);
        if (activeOnly) {
          condition = condition & c.isActive.equals(true) & c.deletedAt.isNull();
        }
        return condition;
      })
      ..orderBy([(c) => OrderingTerm.asc(c.name)])
      ..limit(limit, offset: offset))
      .get();
  }

  /// عدد العملاء الكلي (للـ pagination)
  Future<int> getCustomersCount(String storeId, {bool activeOnly = true}) async {
    final countExpression = customersTable.id.count();

    var query = selectOnly(customersTable)
      ..addColumns([countExpression])
      ..where(customersTable.storeId.equals(storeId));

    if (activeOnly) {
      query.where(customersTable.isActive.equals(true));
    }

    final result = await query.getSingle();
    return result.read(countExpression) ?? 0;
  }

  Future<List<CustomersTableData>> getActiveCustomers(String storeId) {
    return (select(customersTable)..where((c) => c.storeId.equals(storeId) & c.isActive.equals(true) & c.deletedAt.isNull())..orderBy([(c) => OrderingTerm.asc(c.name)])).get();
  }

  Future<CustomersTableData?> getCustomerById(String id) => (select(customersTable)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<List<CustomersTableData>> searchCustomers(String query, String storeId) {
    return (select(customersTable)..where((c) => c.storeId.equals(storeId) & c.deletedAt.isNull() & (c.name.contains(query) | c.phone.contains(query)))..limit(20)).get();
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
    return (select(customersTable)..where((c) => c.storeId.equals(storeId) & c.deletedAt.isNull())..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();
  }

  // Addresses
  Future<List<CustomerAddressesTableData>> getCustomerAddresses(String customerId) {
    return (select(customerAddressesTable)..where((a) => a.customerId.equals(customerId))..orderBy([(a) => OrderingTerm.desc(a.isDefault)])).get();
  }

  Future<int> insertAddress(CustomerAddressesTableCompanion address) => into(customerAddressesTable).insert(address);
  Future<int> deleteAddress(String id) => (delete(customerAddressesTable)..where((a) => a.id.equals(id))).go();

  // ============================================================================
  // H03: JOIN queries - استعلامات مع ربط الجداول
  // ============================================================================

  /// عميل مع عناوينه في استعلام واحد
  Future<CustomerWithAddresses?> getCustomerWithAddresses(String id) async {
    final customer = await getCustomerById(id);
    if (customer == null) return null;

    final addresses = await getCustomerAddresses(id);
    return CustomerWithAddresses(customer: customer, addresses: addresses);
  }

  /// عميل مع إحصائيات المشتريات
  Future<CustomerWithStats?> getCustomerWithStats(String customerId) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) return null;

    final result = await customSelect(
      '''SELECT
           COUNT(*) as total_purchases,
           COALESCE(SUM(total), 0) as total_spent,
           MAX(created_at) as last_purchase_date
         FROM sales
         WHERE customer_id = ? AND status = 'completed' ''',
      variables: [Variable.withString(customerId)],
    ).getSingle();

    return CustomerWithStats(
      customer: customer,
      totalPurchases: result.data['total_purchases'] as int? ?? 0,
      totalSpent: _toDouble(result.data['total_spent']),
      lastPurchaseDate: result.data['last_purchase_date'] != null
          ? DateTime.tryParse(result.data['last_purchase_date'].toString())
          : null,
    );
  }

  /// أفضل العملاء حسب إجمالي المشتريات
  Future<List<CustomerWithStats>> getTopCustomers(
    String storeId, {
    int limit = 10,
  }) async {
    final result = await customSelect(
      '''SELECT c.*,
              COUNT(s.id) as total_purchases,
              COALESCE(SUM(s.total), 0) as total_spent,
              MAX(s.created_at) as last_purchase_date
         FROM customers c
         INNER JOIN sales s ON c.id = s.customer_id AND s.status = 'completed'
         WHERE c.store_id = ? AND c.deleted_at IS NULL
         GROUP BY c.id
         ORDER BY total_spent DESC
         LIMIT ?''',
      variables: [Variable.withString(storeId), Variable.withInt(limit)],
    ).get();

    return result.map((row) => CustomerWithStats(
      customer: customersTable.map(row.data),
      totalPurchases: row.data['total_purchases'] as int? ?? 0,
      totalSpent: _toDouble(row.data['total_spent']),
      lastPurchaseDate: row.data['last_purchase_date'] != null
          ? DateTime.tryParse(row.data['last_purchase_date'].toString())
          : null,
    )).toList();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    return value as double;
  }
}

/// عميل مع عناوينه
class CustomerWithAddresses {
  final CustomersTableData customer;
  final List<CustomerAddressesTableData> addresses;

  const CustomerWithAddresses({required this.customer, required this.addresses});
}

/// عميل مع إحصائيات المشتريات
class CustomerWithStats {
  final CustomersTableData customer;
  final int totalPurchases;
  final double totalSpent;
  final DateTime? lastPurchaseDate;

  const CustomerWithStats({
    required this.customer,
    required this.totalPurchases,
    required this.totalSpent,
    this.lastPurchaseDate,
  });
}
