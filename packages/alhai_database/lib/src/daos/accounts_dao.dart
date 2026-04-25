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
          ..where((a) => a.storeId.equals(storeId) & a.deletedAt.isNull())
          ..orderBy([(a) => OrderingTerm.asc(a.name)])
          ..limit(500))
        .get();
  }

  /// الحصول على حسابات العملاء (الديون)
  ///
  /// Wave 8 (P0-33): [limit] and [offset] are now params (previously a
  /// hardcoded `limit(500)` with no escape hatch). For total receivables
  /// use [getTotalReceivable] (SQL aggregate, no truncation hazard).
  /// Paginated lists should pair this with [getAccountsCount] and a
  /// `SilentLimitBadge` when `result.length == limit`.
  Future<List<AccountsTableData>> getReceivableAccounts(
    String storeId, {
    int limit = 500,
    int offset = 0,
  }) {
    return (select(accountsTable)
          ..where(
            (a) =>
                a.storeId.equals(storeId) &
                a.type.equals('receivable') &
                a.deletedAt.isNull(),
          )
          ..orderBy([(a) => OrderingTerm.asc(a.name)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// الحصول على حسابات الموردين
  Future<List<AccountsTableData>> getPayableAccounts(String storeId) {
    return (select(accountsTable)
          ..where((a) =>
              a.storeId.equals(storeId) &
              a.type.equals('payable') &
              a.deletedAt.isNull())
          ..orderBy([(a) => OrderingTerm.asc(a.name)])
          ..limit(500))
        .get();
  }

  /// الحصول على حساب بالمعرف
  Future<AccountsTableData?> getAccountById(String id) {
    return (select(accountsTable)
          ..where((a) => a.id.equals(id) & a.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// مراقبة حساب بالمعرف (Stream — يتحدث تلقائياً على كل كتابة).
  ///
  /// استخدم هذا في شاشات الـ ledger / customer detail ليتحدث الرصيد الحالي
  /// فوراً بعد كل حركة بدون `invalidate` يدوي.
  Stream<AccountsTableData?> watchAccountById(String id) {
    return (select(accountsTable)
          ..where((a) => a.id.equals(id) & a.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  /// الحصول على حساب العميل
  Future<AccountsTableData?> getCustomerAccount(
    String customerId,
    String storeId,
  ) {
    return (select(accountsTable)..where(
          (a) =>
              a.customerId.equals(customerId) &
              a.storeId.equals(storeId) &
              a.deletedAt.isNull(),
        ))
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
  /// [newBalance] is SAR (double); stored as int cents internally.
  Future<int> updateBalance(String id, double newBalance) {
    return (update(accountsTable)..where((a) => a.id.equals(id))).write(
      AccountsTableCompanion(
        balance: Value((newBalance * 100).round()),
        lastTransactionAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// إضافة للرصيد - atomic SQL to prevent race conditions
  /// [amount] is SAR (double); converted to int cents for storage.
  Future<int> addToBalance(String id, double amount) {
    return customUpdate(
      'UPDATE accounts SET balance = balance + ?, last_transaction_at = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withInt((amount * 100).round()),
        Variable.withDateTime(DateTime.now()),
        Variable.withDateTime(DateTime.now()),
        Variable.withString(id),
      ],
      updates: {accountsTable},
    );
  }

  /// خصم من الرصيد - atomic SQL to prevent race conditions
  /// [amount] is SAR (double); converted to int cents for storage.
  Future<int> subtractFromBalance(String id, double amount) {
    return customUpdate(
      'UPDATE accounts SET balance = balance - ?, last_transaction_at = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withInt((amount * 100).round()),
        Variable.withDateTime(DateTime.now()),
        Variable.withDateTime(DateTime.now()),
        Variable.withString(id),
      ],
      updates: {accountsTable},
    );
  }

  /// إجمالي الديون
  /// Internal storage is int cents; public API returns SAR (double).
  Future<double> getTotalReceivable(String storeId) async {
    final result = await customSelect(
      '''SELECT COALESCE(SUM(balance), 0) as total
         FROM accounts
         WHERE store_id = ? AND type = 'receivable' AND balance > 0
           AND deleted_at IS NULL''',
      variables: [Variable.withString(storeId)],
    ).getSingle();

    final total = result.data['total'];
    if (total == null) return 0.0;
    if (total is int) return total / 100.0;
    return (total as num).toDouble() / 100.0;
  }

  /// تعيين تاريخ المزامنة
  Future<int> markAsSynced(String id) {
    return (update(accountsTable)..where((a) => a.id.equals(id))).write(
      AccountsTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  /// مراقبة الحسابات
  Stream<List<AccountsTableData>> watchReceivableAccounts(String storeId) {
    return (select(accountsTable)
          ..where(
            (a) =>
                a.storeId.equals(storeId) &
                a.type.equals('receivable') &
                a.balance.isBiggerThanValue(0) &
                a.deletedAt.isNull(),
          )
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
        var condition = a.storeId.equals(storeId) & a.deletedAt.isNull();
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
      ..where(accountsTable.storeId.equals(storeId) &
          accountsTable.deletedAt.isNull());

    if (type != null) {
      query.where(accountsTable.type.equals(type));
    }

    final result = await query.getSingle();
    return result.read(countExpression) ?? 0;
  }
}
