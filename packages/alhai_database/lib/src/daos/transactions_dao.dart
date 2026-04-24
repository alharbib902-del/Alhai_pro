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
  Future<List<TransactionsTableData>> getAccountTransactions(
    String accountId, {
    String? storeId,
  }) {
    return (select(transactionsTable)
          ..where((t) {
            var condition = t.accountId.equals(accountId);
            if (storeId != null) {
              condition = condition & t.storeId.equals(storeId);
            }
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
            if (storeId != null) {
              condition = condition & t.storeId.equals(storeId);
            }
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
            var condition =
                t.accountId.equals(accountId) &
                t.createdAt.isBiggerOrEqualValue(start) &
                t.createdAt.isSmallerOrEqualValue(end);
            if (storeId != null) {
              condition = condition & t.storeId.equals(storeId);
            }
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
  /// [amount], [balanceAfter] are SAR (double); stored as int cents.
  Future<int> recordInvoice({
    required String id,
    required String storeId,
    required String accountId,
    required double amount,
    required double balanceAfter,
    required String saleId,
    String? createdBy,
  }) {
    return insertTransaction(
      TransactionsTableCompanion.insert(
        id: id,
        storeId: storeId,
        accountId: accountId,
        type: 'invoice',
        amount: (amount * 100).round(),
        balanceAfter: (balanceAfter * 100).round(),
        referenceId: Value(saleId),
        referenceType: const Value('sale'),
        createdBy: Value(createdBy),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// تسجيل دفعة من العميل
  /// [amount], [balanceAfter] are SAR (double); stored as int cents.
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
    return insertTransaction(
      TransactionsTableCompanion.insert(
        id: id,
        storeId: storeId,
        accountId: accountId,
        type: 'payment',
        amount: -(amount * 100).round(), // سالب لأنه يخفض الرصيد
        balanceAfter: (balanceAfter * 100).round(),
        paymentMethod: Value(paymentMethod),
        description: Value(description),
        createdBy: Value(createdBy),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// إجمالي المدفوعات لحساب
  /// Internal storage is int cents; public API returns SAR (double).
  Future<double> getTotalPayments(String accountId) async {
    final result = await customSelect(
      '''SELECT COALESCE(SUM(ABS(amount)), 0) as total
         FROM transactions
         WHERE account_id = ? AND type = 'payment' ''',
      variables: [Variable.withString(accountId)],
    ).getSingle();

    final total = result.data['total'];
    if (total == null) return 0.0;
    if (total is int) return total / 100.0;
    return (total as num).toDouble() / 100.0;
  }

  /// مراقبة حركات الحساب
  Stream<List<TransactionsTableData>> watchAccountTransactions(
    String accountId,
  ) {
    return (select(transactionsTable)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(50))
        .watch();
  }
}
