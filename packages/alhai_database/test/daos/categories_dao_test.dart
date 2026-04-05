import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
  });

  tearDown(() async {
    await db.close();
  });

  CategoriesTableCompanion makeCategory({
    String id = 'cat-1',
    String storeId = 'store-1',
    String name = 'مشروبات',
    String? parentId,
    int sortOrder = 0,
    bool isActive = true,
  }) {
    return CategoriesTableCompanion.insert(
      id: id,
      storeId: storeId,
      name: name,
      parentId: Value(parentId),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('CategoriesDao', () {
    test('insertCategory and getCategoryById', () async {
      await db.categoriesDao.insertCategory(makeCategory());

      final category = await db.categoriesDao.getCategoryById('cat-1');
      expect(category, isNotNull);
      expect(category!.name, 'مشروبات');
      expect(category.storeId, 'store-1');
    });

    test('getCategoryById returns null for non-existent', () async {
      final category = await db.categoriesDao.getCategoryById('non-existent');
      expect(category, isNull);
    });

    test('getAllCategories returns active categories sorted', () async {
      await db.categoriesDao.insertCategory(makeCategory(
        id: 'cat-1',
        name: 'حلويات',
        sortOrder: 2,
      ));
      await db.categoriesDao.insertCategory(makeCategory(
        id: 'cat-2',
        name: 'مشروبات',
        sortOrder: 1,
      ));
      await db.categoriesDao.insertCategory(makeCategory(
        id: 'cat-3',
        name: 'معلبات',
        sortOrder: 3,
        isActive: false,
      ));

      final categories = await db.categoriesDao.getAllCategories('store-1');
      expect(categories, hasLength(2)); // excludes inactive
      expect(categories.first.name, 'مشروبات'); // sortOrder 1
    });

    test('getRootCategories returns only top-level', () async {
      await db.categoriesDao.insertCategory(makeCategory(
        id: 'cat-1',
        name: 'مشروبات',
      ));
      await db.categoriesDao.insertCategory(makeCategory(
        id: 'cat-2',
        name: 'عصائر',
        parentId: 'cat-1',
      ));

      final roots = await db.categoriesDao.getRootCategories('store-1');
      expect(roots, hasLength(1));
      expect(roots.first.name, 'مشروبات');
    });

    test('getSubCategories returns children', () async {
      await db.categoriesDao.insertCategory(makeCategory(
        id: 'cat-parent',
        name: 'مشروبات',
      ));
      await db.categoriesDao.insertCategory(makeCategory(
        id: 'cat-child-1',
        name: 'عصائر',
        parentId: 'cat-parent',
        sortOrder: 1,
      ));
      await db.categoriesDao.insertCategory(makeCategory(
        id: 'cat-child-2',
        name: 'مشروبات غازية',
        parentId: 'cat-parent',
        sortOrder: 2,
      ));

      final children =
          await db.categoriesDao.getSubCategories('cat-parent', 'store-1');
      expect(children, hasLength(2));
      expect(children.first.name, 'عصائر');
    });

    test('updateCategory modifies data', () async {
      await db.categoriesDao.insertCategory(makeCategory());
      final category = await db.categoriesDao.getCategoryById('cat-1');
      final updated = category!.copyWith(name: 'مشروبات باردة');

      await db.categoriesDao.updateCategory(updated);

      final fetched = await db.categoriesDao.getCategoryById('cat-1');
      expect(fetched!.name, 'مشروبات باردة');
    });

    test('deleteCategory removes category', () async {
      await db.categoriesDao.insertCategory(makeCategory());

      final deleted = await db.categoriesDao.deleteCategory('cat-1');
      expect(deleted, 1);

      final category = await db.categoriesDao.getCategoryById('cat-1');
      expect(category, isNull);
    });

    test('deleteAllCategories removes all for store', () async {
      await db.categoriesDao.insertCategory(makeCategory(id: 'cat-1'));
      await db.categoriesDao
          .insertCategory(makeCategory(id: 'cat-2', name: 'حلويات'));
      await db.categoriesDao.insertCategory(makeCategory(
        id: 'cat-other',
        name: 'أخرى',
        storeId: 'store-2',
      ));

      await db.categoriesDao.deleteAllCategories('store-1');

      final store1 = await db.categoriesDao.getAllCategories('store-1');
      expect(store1, isEmpty);

      // store-2 should be unaffected
      final store2 = await db.categoriesDao.getAllCategories('store-2');
      expect(store2, hasLength(1));
    });

    test('upsertCategory inserts or updates', () async {
      await db.categoriesDao.upsertCategory(makeCategory(name: 'أصلي'));

      var cat = await db.categoriesDao.getCategoryById('cat-1');
      expect(cat!.name, 'أصلي');

      await db.categoriesDao.upsertCategory(makeCategory(name: 'محدّث'));
      cat = await db.categoriesDao.getCategoryById('cat-1');
      expect(cat!.name, 'محدّث');
    });

    test('getCategoriesCount returns correct count', () async {
      await db.categoriesDao.insertCategory(makeCategory(id: 'cat-1'));
      await db.categoriesDao
          .insertCategory(makeCategory(id: 'cat-2', name: 'حلويات'));

      final count = await db.categoriesDao.getCategoriesCount('store-1');
      expect(count, 2);
    });

    test('insertCategories batch inserts', () async {
      await db.categoriesDao.insertCategories([
        makeCategory(id: 'cat-1', name: 'مشروبات'),
        makeCategory(id: 'cat-2', name: 'حلويات'),
        makeCategory(id: 'cat-3', name: 'معلبات'),
      ]);

      final count = await db.categoriesDao.getCategoriesCount('store-1');
      expect(count, 3);
    });
  });
}
