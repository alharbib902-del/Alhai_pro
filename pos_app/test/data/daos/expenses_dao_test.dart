/// اختبارات DAO المصروفات
///
/// اختبارات تكامل تستخدم قاعدة بيانات SQLite في الذاكرة
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_app/data/local/app_database.dart';

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

Future<void> _insertTestExpense(
  AppDatabase db, {
  required String id,
  required String storeId,
  double amount = 100.0,
  String? description,
  String? categoryId,
  DateTime? expenseDate,
}) async {
  await db.expensesDao.insertExpense(ExpensesTableCompanion.insert(
    id: id,
    storeId: storeId,
    amount: amount,
    description: Value(description),
    categoryId: Value(categoryId),
    expenseDate: expenseDate ?? DateTime.now(),
    createdAt: DateTime.now(),
  ));
}

Future<void> _insertTestCategory(
  AppDatabase db, {
  required String id,
  required String storeId,
  String name = 'فئة اختبار',
  bool isActive = true,
}) async {
  await db.expensesDao.insertCategory(ExpenseCategoriesTableCompanion.insert(
    id: id,
    storeId: storeId,
    name: name,
    isActive: Value(isActive),
    createdAt: DateTime.now(),
  ));
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('ExpensesDao', () {
    group('insertExpense', () {
      test('inserts a new expense', () async {
        // Act
        final result = await db.expensesDao.insertExpense(
          ExpensesTableCompanion.insert(
            id: 'exp-1',
            storeId: 'store-1',
            amount: 150.0,
            expenseDate: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getAllExpenses', () {
      test('returns all expenses for the store', () async {
        // Arrange
        await _insertTestExpense(db, id: 'exp-1', storeId: 'store-1', amount: 50.0);
        await _insertTestExpense(db, id: 'exp-2', storeId: 'store-1', amount: 75.0);
        await _insertTestExpense(db, id: 'exp-3', storeId: 'store-2', amount: 100.0);

        // Act
        final expenses = await db.expensesDao.getAllExpenses('store-1');

        // Assert
        expect(expenses.length, 2);
      });

      test('does not return expenses from other stores', () async {
        // Arrange
        await _insertTestExpense(db, id: 'exp-1', storeId: 'store-2', amount: 200.0);

        // Act
        final expenses = await db.expensesDao.getAllExpenses('store-1');

        // Assert
        expect(expenses.length, 0);
      });
    });

    group('getExpensesByDateRange', () {
      test('returns expenses within date range', () async {
        // Arrange
        final jan1 = DateTime(2025, 1, 1);
        final jan15 = DateTime(2025, 1, 15);
        final feb1 = DateTime(2025, 2, 1);
        final mar1 = DateTime(2025, 3, 1);

        await _insertTestExpense(db, id: 'exp-1', storeId: 'store-1', expenseDate: jan1);
        await _insertTestExpense(db, id: 'exp-2', storeId: 'store-1', expenseDate: jan15);
        await _insertTestExpense(db, id: 'exp-3', storeId: 'store-1', expenseDate: feb1);
        await _insertTestExpense(db, id: 'exp-4', storeId: 'store-1', expenseDate: mar1);

        // Act - get January expenses
        final expenses = await db.expensesDao.getExpensesByDateRange(
          'store-1',
          jan1,
          DateTime(2025, 2, 1),
        );

        // Assert
        expect(expenses.length, 2);
      });

      test('returns empty list when no expenses in range', () async {
        // Arrange
        await _insertTestExpense(
          db,
          id: 'exp-1',
          storeId: 'store-1',
          expenseDate: DateTime(2025, 6, 1),
        );

        // Act
        final expenses = await db.expensesDao.getExpensesByDateRange(
          'store-1',
          DateTime(2025, 1, 1),
          DateTime(2025, 2, 1),
        );

        // Assert
        expect(expenses.length, 0);
      });
    });

    group('updateExpense', () {
      test('updates expense data', () async {
        // Arrange
        await _insertTestExpense(db, id: 'exp-1', storeId: 'store-1', amount: 100.0, description: 'وصف قديم');
        final expenses = await db.expensesDao.getAllExpenses('store-1');
        final expense = expenses.first;

        // Act
        final updated = expense.copyWith(amount: 200.0, description: const Value('وصف جديد'));
        final result = await db.expensesDao.updateExpense(updated);

        // Assert
        expect(result, true);
        final fetched = await db.expensesDao.getAllExpenses('store-1');
        expect(fetched.first.amount, 200.0);
      });
    });

    group('deleteExpense', () {
      test('deletes the expense', () async {
        // Arrange
        await _insertTestExpense(db, id: 'exp-1', storeId: 'store-1');

        // Act
        final deleted = await db.expensesDao.deleteExpense('exp-1');
        final expenses = await db.expensesDao.getAllExpenses('store-1');

        // Assert
        expect(deleted, 1);
        expect(expenses.length, 0);
      });

      test('returns 0 when expense does not exist', () async {
        // Act
        final deleted = await db.expensesDao.deleteExpense('non-existent');

        // Assert
        expect(deleted, 0);
      });
    });

    group('insertCategory', () {
      test('inserts a new expense category', () async {
        // Act
        final result = await db.expensesDao.insertCategory(
          ExpenseCategoriesTableCompanion.insert(
            id: 'cat-1',
            storeId: 'store-1',
            name: 'إيجار',
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getAllCategories', () {
      test('returns all categories for the store', () async {
        // Arrange
        await _insertTestCategory(db, id: 'cat-1', storeId: 'store-1', name: 'إيجار');
        await _insertTestCategory(db, id: 'cat-2', storeId: 'store-1', name: 'رواتب');
        await _insertTestCategory(db, id: 'cat-3', storeId: 'store-2', name: 'كهرباء');

        // Act
        final categories = await db.expensesDao.getAllCategories('store-1');

        // Assert
        expect(categories.length, 2);
      });

      test('orders categories by name', () async {
        // Arrange
        await _insertTestCategory(db, id: 'cat-1', storeId: 'store-1', name: 'رواتب');
        await _insertTestCategory(db, id: 'cat-2', storeId: 'store-1', name: 'إيجار');

        // Act
        final categories = await db.expensesDao.getAllCategories('store-1');

        // Assert
        expect(categories.first.name, 'إيجار');
        expect(categories.last.name, 'رواتب');
      });
    });

    group('getActiveCategories', () {
      test('returns only active categories', () async {
        // Arrange
        await _insertTestCategory(db, id: 'cat-1', storeId: 'store-1', isActive: true, name: 'إيجار');
        await _insertTestCategory(db, id: 'cat-2', storeId: 'store-1', isActive: false, name: 'متنوع');
        await _insertTestCategory(db, id: 'cat-3', storeId: 'store-1', isActive: true, name: 'رواتب');

        // Act
        final categories = await db.expensesDao.getActiveCategories('store-1');

        // Assert
        expect(categories.length, 2);
      });
    });
  });
}
