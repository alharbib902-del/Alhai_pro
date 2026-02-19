/// Expenses Providers - مزودات المصروفات
///
/// توفر بيانات المصروفات وتصنيفاتها من قاعدة البيانات
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/local/app_database.dart';
import '../di/injection.dart';
import 'products_providers.dart';

const _uuid = Uuid();

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// مراقبة المصروفات (Stream)
final expensesStreamProvider =
    StreamProvider.autoDispose<List<ExpensesTableData>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return Stream.value([]);
  final db = getIt<AppDatabase>();
  return db.expensesDao.watchExpenses(storeId);
});

/// قائمة المصروفات (Future)
final expensesListProvider =
    FutureProvider.autoDispose<List<ExpensesTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.expensesDao.getAllExpenses(storeId);
});

/// إجمالي مصروفات اليوم
final todayExpensesTotalProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return 0.0;
  final db = getIt<AppDatabase>();
  return db.expensesDao.getTodayExpensesTotal(storeId);
});

/// تصنيفات المصروفات النشطة
final expenseCategoriesProvider =
    FutureProvider.autoDispose<List<ExpenseCategoriesTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.expensesDao.getActiveCategories(storeId);
});

/// جميع تصنيفات المصروفات
final allExpenseCategoriesProvider =
    FutureProvider.autoDispose<List<ExpenseCategoriesTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.expensesDao.getAllCategories(storeId);
});

/// مراقبة التصنيفات (Stream)
final expenseCategoriesStreamProvider =
    StreamProvider.autoDispose<List<ExpenseCategoriesTableData>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return Stream.value([]);
  final db = getIt<AppDatabase>();
  return db.expensesDao.watchCategories(storeId);
});

// ============================================================================
// ACTION HELPERS
// ============================================================================

/// إضافة مصروف جديد
Future<void> addExpense(
  WidgetRef ref, {
  required String categoryId,
  required double amount,
  required String description,
  String paymentMethod = 'cash',
  String? createdBy,
  DateTime? expenseDate,
}) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) return;
  final db = getIt<AppDatabase>();
  await db.expensesDao.insertExpense(ExpensesTableCompanion(
    id: Value(_uuid.v4()),
    storeId: Value(storeId),
    categoryId: Value(categoryId),
    amount: Value(amount),
    description: Value(description),
    paymentMethod: Value(paymentMethod),
    createdBy: Value(createdBy),
    expenseDate: Value(expenseDate ?? DateTime.now()),
    createdAt: Value(DateTime.now()),
  ));
  ref.invalidate(expensesListProvider);
  ref.invalidate(todayExpensesTotalProvider);
}

/// حذف مصروف
Future<void> deleteExpense(WidgetRef ref, String id) async {
  final db = getIt<AppDatabase>();
  await db.expensesDao.deleteExpense(id);
  ref.invalidate(expensesListProvider);
  ref.invalidate(todayExpensesTotalProvider);
}

/// إضافة تصنيف مصروف
Future<void> addExpenseCategory(
  WidgetRef ref, {
  required String name,
  String? nameEn,
  String? icon,
  String? color,
}) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) return;
  final db = getIt<AppDatabase>();
  await db.expensesDao.insertCategory(ExpenseCategoriesTableCompanion(
    id: Value(_uuid.v4()),
    storeId: Value(storeId),
    name: Value(name),
    nameEn: Value(nameEn),
    icon: Value(icon),
    color: Value(color),
    isActive: const Value(true),
    createdAt: Value(DateTime.now()),
  ));
  ref.invalidate(expenseCategoriesProvider);
  ref.invalidate(allExpenseCategoriesProvider);
}

/// حذف تصنيف مصروف
Future<void> deleteExpenseCategory(WidgetRef ref, String id) async {
  final db = getIt<AppDatabase>();
  await db.expensesDao.deleteCategory(id);
  ref.invalidate(expenseCategoriesProvider);
  ref.invalidate(allExpenseCategoriesProvider);
}
