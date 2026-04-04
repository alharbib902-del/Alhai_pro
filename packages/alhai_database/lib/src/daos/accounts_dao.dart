import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/accounts_table.dart';

part 'accounts_dao.g.dart';

/// DAO للحسابات
@DriftAccessor(tables: [AccountsTable])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.db);

  /// الحصول على جميع الحسابات
  Future<List<AccountsTableData>> getAllAccounts(String storeId) {
    return (select(accountsTable)
          ..where((a) => a.storeId.equals(storeId))
          ..orderBy([(a) => OrderingTerm.asc(a.name)])
          ..limit(500))
        .get();
  }

  /// الحصول على حسابات العملاء (الديون)
  Future<List<AccountsTableData>> getReceivableAccounts(String storeId) {
    return (select(accountsTable)
          ..where(
              (a) => a.storeId.equals(storeId) & a.type.equals('receivable'))
          ..orderBy([(a) => OrderingTerm.asc(a.name)])
          ..limit(500))
        .get();
  }

  /// الحصول على حسابات الموردين
  Future<List<AccountsTableData>> getPayableAccounts(String storeId) {
    return (select(accountsTable)
          ..where((a) => a.storeId.equals(storeId) & a.type.equals('payable'))
          ..orderBy([(a) => OrderingTerm.asc(a.name)])
          ..limit(500))
        .get();
  }

  /// الحصول على حساب بالمعرف
  Future<AccountsTableData?> getAccountById(String id) {
    return (select(accountsTable)..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  /// الحصول على حساب العميل
  Future<AccountsTableData?> getCustomerAccount(
      String customerId, String storeId) {
    return (select(accountsTable)
          ..where((a) =>
              a.customerId.equals(customerId) & a.storeId.equals(storeId)))
        .getSingleOrNull();
  }

  /// إدراج حساب
  Future<int> insertAccount(AccountsTableCompanion account) {
    return into(accountsTable).insert(account);
  }

  /// تحديث حساب
  Future<bool> updateAccount(AccountsTableData account) {
    return update(accountsTable).replace(account);
  }

  /// تحديث الرصيد
  Future<int> updateBalance(String id, double newBalance) {
    return (update(accountsTable)..where((a) => a.id.equals(id)))
        .write(AccountsTableCompanion(
      balance: Value(newBalance),
      lastTransactionAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// إضافة للرصيد - atomic SQL to prevent race conditions
  Future<int> addToBalance(String id, double amount) {
    return customUpdate(
      'UPDATE accounts SET balance = balance + ?, last_transaction_at = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withReal(amount),
        Variable.withDateTime(DateTime.now()),
        Variable.withDateTime(DateTime.now()),
        Variable.withString(id),
      ],
      updates: {accountsTable},
    );
  }

  /// خصم من الرصيد - atomic SQL to prevent race conditions
  Future<int> subtractFromBalance(String id, double amount) {
    return customUpdate(
      'UPDATE accounts SET balance = balance - ?, last_transaction_at = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withReal(amount),
        Variable.withDateTime(DateTime.now()),
        Variable.withDateTime(DateTime.now()),
        Variable.withString(id),
      ],
      updates: {accountsTable},
    );
  }

  /// إجمالي الديون
  Future<double> getTotalReceivable(String storeId) async {
    final result = await customSelect(
      '''SELECT COALESCE(SUM(balance), 0) as total 
         FROM accounts 
         WHERE store_id = ? AND type = 'receivable' AND balance > 0''',
      variables: [Variable.withString(storeId)],
    ).getSingle();

    return result.data['total'] as double? ?? 0.0;
  }

  /// تعيين تاريخ المزامنة
  Future<int> markAsSynced(String id) {
    return (update(accountsTable)..where((a) => a.id.equals(id)))
        .write(AccountsTableCompanion(syncedAt: Value(DateTime.now())));
  }

  /// مراقبة الحسابات
  Stream<List<AccountsTableData>> watchReceivableAccounts(String storeId) {
    return (select(accountsTable)
          ..where((a) =>
              a.storeId.equals(storeId) &
              a.type.equals('receivable') &
              a.balance.isBiggerThanValue(0))
          ..orderBy([(a) => OrderingTerm.desc(a.balance)]))
        .watch();
  }

  // ============================================================================
  // Pagination Methods - M61: تحسينات الأداء للقوائم الطويلة
  // ============================================================================

  /// الحصول على حسابات مع Pagination
  /// [offset] - عدد العناصر للتخطي
  /// [limit] - الحد الأقصى للنتائج (افتراضي 50)
  Future<List<AccountsTableData>> getAccountsPaginated(
    String storeId, {
    int offset = 0,
    int limit = 50,
    String? type,
  }) {
    var query = select(accountsTable)
      ..where((a) {
        var condition = a.storeId.equals(storeId);
        if (type != null) {
          condition = condition & a.type.equals(type);
        }
        return condition;
      })
      ..orderBy([(a) => OrderingTerm.asc(a.name)])
      ..limit(limit, offset: offset);

    return query.get();
  }

  /// عدد الحسابات الكلي (للـ pagination)
  Future<int> getAccountsCount(String storeId, {String? type}) async {
    final countExpression = accountsTable.id.count();

    var query = selectOnly(accountsTable)
      ..addColumns([countExpression])
      ..where(accountsTable.storeId.equals(storeId));

    if (type != null) {
      query.where(accountsTable.type.equals(type));
    }

    final result = await query.getSingle();
    return result.read(countExpression) ?? 0;
  }
}
