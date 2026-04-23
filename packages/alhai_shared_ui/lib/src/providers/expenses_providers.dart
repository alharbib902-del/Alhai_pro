/// Expenses Providers - مزودات المصروفات
///
/// توفر بيانات المصروفات وتصنيفاتها من قاعدة البيانات
library;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:alhai_auth/alhai_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'sync_providers.dart';

const _uuid = Uuid();

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// مراقبة المصروفات (Stream)
final expensesStreamProvider =
    StreamProvider.autoDispose<List<ExpensesTableData>>((ref) {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return Stream.value([]);
      final db = GetIt.I<AppDatabase>();
      return db.expensesDao.watchExpenses(storeId);
    });

/// قائمة المصروفات (Future)
final expensesListProvider =
    FutureProvider.autoDispose<List<ExpensesTableData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.expensesDao.getAllExpenses(storeId);
    });

/// إجمالي مصروفات اليوم
final todayExpensesTotalProvider = FutureProvider.autoDispose<double>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return 0.0;
  final db = GetIt.I<AppDatabase>();
  return db.expensesDao.getTodayExpensesTotal(storeId);
});

/// تصنيفات المصروفات النشطة
final expenseCategoriesProvider =
    FutureProvider.autoDispose<List<ExpenseCategoriesTableData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.expensesDao.getActiveCategories(storeId);
    });

/// جميع تصنيفات المصروفات
final allExpenseCategoriesProvider =
    FutureProvider.autoDispose<List<ExpenseCategoriesTableData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.expensesDao.getAllCategories(storeId);
    });

/// مراقبة التصنيفات (Stream)
final expenseCategoriesStreamProvider =
    StreamProvider.autoDispose<List<ExpenseCategoriesTableData>>((ref) {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return Stream.value([]);
      final db = GetIt.I<AppDatabase>();
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
  final db = GetIt.I<AppDatabase>();
  final id = _uuid.v4();
  final now = DateTime.now();
  final date = expenseDate ?? now;
  await db.expensesDao.insertExpense(
    ExpensesTableCompanion(
      id: Value(id),
      storeId: Value(storeId),
      categoryId: Value(categoryId),
      // C-4 Session 4: expenses.amount is int cents.
      amount: Value((amount * 100).round()),
      description: Value(description),
      paymentMethod: Value(paymentMethod),
      createdBy: Value(createdBy),
      expenseDate: Value(date),
      createdAt: Value(now),
    ),
  );

  // إضافة للطابور المزامنة
  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueCreate(
      tableName: 'expenses',
      recordId: id,
      data: {
        'id': id,
        'store_id': storeId,
        'category_id': categoryId,
        // C-4 §4h (Session 52): expenses.amount is int cents on both
        // Drift and Supabase after migration v78. The wire payload must
        // match — do NOT send SAR doubles here or the server will store
        // fractional cents as a float-to-int coerce value.
        'amount': (amount * 100).round(),
        'description': description,
        'payment_method': paymentMethod,
        'created_by': createdBy,
        'expense_date': date.toIso8601String(),
        'created_at': now.toIso8601String(),
      },
    );
  } catch (e) {
    // المزامنة اختيارية - لا تمنع العملية المحلية
    if (kDebugMode) debugPrint('Expense sync enqueue failed: $e');
  }

  ref.invalidate(expensesListProvider);
  ref.invalidate(todayExpensesTotalProvider);
}

/// حذف مصروف
Future<void> deleteExpense(WidgetRef ref, String id) async {
  final db = GetIt.I<AppDatabase>();
  await db.expensesDao.deleteExpense(id);

  // إضافة للطابور المزامنة
  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueDelete(tableName: 'expenses', recordId: id);
  } catch (e) {
    // المزامنة اختيارية - لا تمنع العملية المحلية
    if (kDebugMode) debugPrint('Expense delete sync enqueue failed: $e');
  }

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
  final db = GetIt.I<AppDatabase>();
  await db.expensesDao.insertCategory(
    ExpenseCategoriesTableCompanion(
      id: Value(_uuid.v4()),
      storeId: Value(storeId),
      name: Value(name),
      nameEn: Value(nameEn),
      icon: Value(icon),
      color: Value(color),
      isActive: const Value(true),
      createdAt: Value(DateTime.now()),
    ),
  );
  ref.invalidate(expenseCategoriesProvider);
  ref.invalidate(allExpenseCategoriesProvider);
}

/// حذف تصنيف مصروف
Future<void> deleteExpenseCategory(WidgetRef ref, String id) async {
  final db = GetIt.I<AppDatabase>();
  await db.expensesDao.deleteCategory(id);
  ref.invalidate(expenseCategoriesProvider);
  ref.invalidate(allExpenseCategoriesProvider);
}
