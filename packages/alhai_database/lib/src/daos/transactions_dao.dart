import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/transactions_table.dart';

part 'transactions_dao.g.dart';

/// DAO لحركات الحسابات
@DriftAccessor(tables: [TransactionsTable])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  /// الحصول على حركات الحساب (مع فلتر المتجر)
  Future<List<TransactionsTableData>> getAccountTransactions(String accountId,
      {String? storeId}) {
    return (select(transactionsTable)
          ..where((t) {
            var condition = t.accountId.equals(accountId);
            if (storeId != null)
              condition = condition & t.storeId.equals(storeId);
            return condition;
          })
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(200))
        .get();
  }

  /// الحصول على حركات حساب مع فلترة النوع
  Future<List<TransactionsTableData>> getAccountTransactionsByType(
    String accountId,
    String type, {
    String? storeId,
  }) {
    return (select(transactionsTable)
          ..where((t) {
            var condition = t.accountId.equals(accountId) & t.type.equals(type);
            if (storeId != null)
              condition = condition & t.storeId.equals(storeId);
            return condition;
          })
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(200))
        .get();
  }

  /// الحصول على حركات فترة زمنية
  Future<List<TransactionsTableData>> getTransactionsInRange(
    String accountId,
    DateTime start,
    DateTime end, {
    String? storeId,
  }) {
    return (select(transactionsTable)
          ..where((t) {
            var condition = t.accountId.equals(accountId) &
                t.createdAt.isBiggerOrEqualValue(start) &
                t.createdAt.isSmallerOrEqualValue(end);
            if (storeId != null)
              condition = condition & t.storeId.equals(storeId);
            return condition;
          })
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(500))
        .get();
  }

  /// إضافة حركة
  Future<int> insertTransaction(TransactionsTableCompanion transaction) {
    return into(transactionsTable).insert(transaction);
  }

  /// تسجيل فاتورة (دين على العميل)
  Future<int> recordInvoice({
    required String id,
    required String storeId,
    required String accountId,
    required double amount,
    required double balanceAfter,
    required String saleId,
    String? createdBy,
  }) {
    return insertTransaction(TransactionsTableCompanion.insert(
      id: id,
      storeId: storeId,
      accountId: accountId,
      type: 'invoice',
      amount: amount,
      balanceAfter: balanceAfter,
      referenceId: Value(saleId),
      referenceType: const Value('sale'),
      createdBy: Value(createdBy),
      createdAt: DateTime.now(),
    ));
  }

  /// تسجيل دفعة من العميل
  Future<int> recordPayment({
    required String id,
    required String storeId,
    required String accountId,
    required double amount,
    required double balanceAfter,
    required String paymentMethod,
    String? description,
    String? createdBy,
  }) {
    return insertTransaction(TransactionsTableCompanion.insert(
      id: id,
      storeId: storeId,
      accountId: accountId,
      type: 'payment',
      amount: -amount, // سالب لأنه يخفض الرصيد
      balanceAfter: balanceAfter,
      paymentMethod: Value(paymentMethod),
      description: Value(description),
      createdBy: Value(createdBy),
      createdAt: DateTime.now(),
    ));
  }

  /// تسجيل فائدة شهرية
  Future<int> recordInterest({
    required String id,
    required String storeId,
    required String accountId,
    required double amount,
    required double balanceAfter,
    required String periodKey, // YYYY-MM
    String? createdBy,
  }) {
    return insertTransaction(TransactionsTableCompanion.insert(
      id: id,
      storeId: storeId,
      accountId: accountId,
      type: 'interest',
      amount: amount,
      balanceAfter: balanceAfter,
      periodKey: Value(periodKey),
      createdBy: Value(createdBy),
      createdAt: DateTime.now(),
    ));
  }

  /// التحقق من وجود فائدة لفترة معينة
  Future<bool> hasInterestForPeriod(String accountId, String periodKey) async {
    final result = await (select(transactionsTable)
          ..where((t) =>
              t.accountId.equals(accountId) &
              t.type.equals('interest') &
              t.periodKey.equals(periodKey)))
        .get();
    return result.isNotEmpty;
  }

  /// إجمالي المدفوعات لحساب
  Future<double> getTotalPayments(String accountId) async {
    final result = await customSelect(
      '''SELECT COALESCE(SUM(ABS(amount)), 0) as total 
         FROM transactions 
         WHERE account_id = ? AND type = 'payment' ''',
      variables: [Variable.withString(accountId)],
    ).getSingle();

    return result.data['total'] as double? ?? 0.0;
  }

  /// مراقبة حركات الحساب
  Stream<List<TransactionsTableData>> watchAccountTransactions(
      String accountId) {
    return (select(transactionsTable)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(50))
        .watch();
  }
}
