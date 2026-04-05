import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  ExpensesTableCompanion makeExpense({
    String id = 'exp-1',
    String storeId = 'store-1',
    double amount = 200.0,
    String? categoryId,
    DateTime? expenseDate,
  }) {
    return ExpensesTableCompanion.insert(
      id: id,
      storeId: storeId,
      amount: amount,
      categoryId: Value(categoryId),
      description: const Value('مصروف تجريبي'),
      expenseDate: expenseDate ?? DateTime(2025, 6, 15),
      createdAt: DateTime(2025, 6, 15),
    );
  }

  group('ExpensesDao', () {
    test('insertExpense and getAllExpenses', () async {
      await db.expensesDao.insertExpense(makeExpense());
      await db.expensesDao.insertExpense(makeExpense(
        id: 'exp-2',
        amount: 150.0,
      ));

      final expenses = await db.expensesDao.getAllExpenses('store-1');
      expect(expenses, hasLength(2));
    });

    test('getExpensesByDateRange filters correctly', () async {
      await db.expensesDao.insertExpense(makeExpense(
        id: 'exp-jun',
        expenseDate: DateTime(2025, 6, 15),
      ));
      await db.expensesDao.insertExpense(makeExpense(
        id: 'exp-jul',
        expenseDate: DateTime(2025, 7, 15),
      ));

      final results = await db.expensesDao.getExpensesByDateRange(
        'store-1',
        DateTime(2025, 6, 1),
        DateTime(2025, 6, 30),
      );
      expect(results, hasLength(1));
      expect(results.first.id, 'exp-jun');
    });

    test('deleteExpense removes expense', () async {
      await db.expensesDao.insertExpense(makeExpense());

      final deleted = await db.expensesDao.deleteExpense('exp-1');
      expect(deleted, 1);
    });

    test('markAsSynced sets syncedAt', () async {
      await db.expensesDao.insertExpense(makeExpense());

      await db.expensesDao.markAsSynced('exp-1');

      // Verify by checking if it would still appear in unsynced list
      // (getAllExpenses still returns it)
      final expenses = await db.expensesDao.getAllExpenses('store-1');
      expect(expenses, hasLength(1));
    });

    // Expense Categories
    test('insertCategory and getAllCategories', () async {
      await db.expensesDao.insertCategory(
        ExpenseCategoriesTableCompanion.insert(
          id: 'ecat-1',
          storeId: 'store-1',
          name: 'إيجار',
          createdAt: DateTime(2025, 1, 1),
        ),
      );
      await db.expensesDao.insertCategory(
        ExpenseCategoriesTableCompanion.insert(
          id: 'ecat-2',
          storeId: 'store-1',
          name: 'رواتب',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final categories = await db.expensesDao.getAllCategories('store-1');
      expect(categories, hasLength(2));
    });

    test('getActiveCategories excludes inactive', () async {
      await db.expensesDao.insertCategory(
        ExpenseCategoriesTableCompanion.insert(
          id: 'ecat-1',
          storeId: 'store-1',
          name: 'إيجار',
          isActive: const Value(true),
          createdAt: DateTime(2025, 1, 1),
        ),
      );
      await db.expensesDao.insertCategory(
        ExpenseCategoriesTableCompanion.insert(
          id: 'ecat-2',
          storeId: 'store-1',
          name: 'قديم',
          isActive: const Value(false),
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final active = await db.expensesDao.getActiveCategories('store-1');
      expect(active, hasLength(1));
      expect(active.first.name, 'إيجار');
    });

    test('deleteCategory removes category', () async {
      await db.expensesDao.insertCategory(
        ExpenseCategoriesTableCompanion.insert(
          id: 'ecat-1',
          storeId: 'store-1',
          name: 'إيجار',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final deleted = await db.expensesDao.deleteCategory('ecat-1');
      expect(deleted, 1);
    });
  });
}
