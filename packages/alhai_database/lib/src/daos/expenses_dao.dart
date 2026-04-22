import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/expenses_table.dart';

part 'expenses_dao.g.dart';

/// DAO for expenses
@DriftAccessor(tables: [ExpensesTable, ExpenseCategoriesTable])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.db);

  Future<List<ExpensesTableData>> getAllExpenses(String storeId) {
    return (select(expensesTable)
          ..where((e) => e.storeId.equals(storeId) & e.deletedAt.isNull())
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
          ..limit(500))
        .get();
  }

  Future<List<ExpensesTableData>> getExpensesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(expensesTable)
          ..where(
            (e) =>
                e.storeId.equals(storeId) &
                e.deletedAt.isNull() &
                e.expenseDate.isBiggerOrEqualValue(startDate) &
                e.expenseDate.isSmallerThanValue(endDate),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.expenseDate)])
          ..limit(1000))
        .get();
  }

  /// Returns today's total expenses in SAR (double).
  /// Internal storage is int cents; divides by 100 inside DAO.
  Future<double> getTodayExpensesTotal(String storeId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final result = await customSelect(
      'SELECT COALESCE(SUM(amount), 0) as total FROM expenses '
      'WHERE store_id = ? AND expense_date >= ? AND expense_date < ? '
      'AND deleted_at IS NULL',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
    ).getSingle();
    final total = result.data['total'];
    if (total == null) return 0.0;
    if (total is int) return total / 100.0;
    return (total as num).toDouble() / 100.0;
  }

  Future<int> insertExpense(ExpensesTableCompanion expense) =>
      into(expensesTable).insert(expense);
  Future<bool> updateExpense(ExpensesTableData expense) =>
      update(expensesTable).replace(expense);
  Future<int> deleteExpense(String id) =>
      (delete(expensesTable)..where((e) => e.id.equals(id))).go();

  Future<int> markAsSynced(String id) {
    return (update(expensesTable)..where((e) => e.id.equals(id))).write(
      ExpensesTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  Stream<List<ExpensesTableData>> watchExpenses(String storeId) {
    return (select(expensesTable)
          ..where((e) => e.storeId.equals(storeId) & e.deletedAt.isNull())
          ..orderBy([(e) => OrderingTerm.desc(e.expenseDate)]))
        .watch();
  }

  // Expense categories
  Future<List<ExpenseCategoriesTableData>> getAllCategories(String storeId) {
    return (select(expenseCategoriesTable)
          ..where((c) => c.storeId.equals(storeId))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  Future<List<ExpenseCategoriesTableData>> getActiveCategories(String storeId) {
    return (select(expenseCategoriesTable)
          ..where((c) => c.storeId.equals(storeId) & c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  Future<int> insertCategory(ExpenseCategoriesTableCompanion category) =>
      into(expenseCategoriesTable).insert(category);
  Future<bool> updateCategory(ExpenseCategoriesTableData category) =>
      update(expenseCategoriesTable).replace(category);
  Future<int> deleteCategory(String id) =>
      (delete(expenseCategoriesTable)..where((c) => c.id.equals(id))).go();

  Stream<List<ExpenseCategoriesTableData>> watchCategories(String storeId) {
    return (select(expenseCategoriesTable)
          ..where((c) => c.storeId.equals(storeId))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }
}
