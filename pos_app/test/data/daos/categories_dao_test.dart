import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:pos_app/data/local/app_database.dart';

// ===========================================
// Categories DAO Tests
// ===========================================

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('CategoriesDao', () {
    const testStoreId = 'store_123';
    const testCategoryId = 'cat_001';

    CategoriesTableCompanion createCategory({
      required String id,
      required String name,
      String? nameEn,
      String? parentId,
      bool isActive = true,
      int sortOrder = 0,
    }) {
      return CategoriesTableCompanion.insert(
        id: id,
        storeId: testStoreId,
        name: name,
        nameEn: Value(nameEn),
        parentId: Value(parentId),
        isActive: Value(isActive),
        sortOrder: Value(sortOrder),
        createdAt: DateTime.now(),
      );
    }

    group('insertCategory', () {
      test('يُضيف تصنيف جديد بنجاح', () async {
        final category = createCategory(
          id: testCategoryId,
          name: 'ألبان',
          nameEn: 'Dairy',
          sortOrder: 1,
        );

        final result = await database.categoriesDao.insertCategory(category);
        expect(result, greaterThan(0));

        final fetched =
            await database.categoriesDao.getCategoryById(testCategoryId);
        expect(fetched, isNotNull);
        expect(fetched!.name, 'ألبان');
        expect(fetched.nameEn, 'Dairy');
      });
    });

    group('getCategoryById', () {
      test('يجد التصنيف بالمعرف', () async {
        final category = createCategory(
          id: testCategoryId,
          name: 'خضروات',
          nameEn: 'Vegetables',
        );
        await database.categoriesDao.insertCategory(category);

        final result =
            await database.categoriesDao.getCategoryById(testCategoryId);
        expect(result, isNotNull);
        expect(result!.name, 'خضروات');
      });

      test('يُرجع null إذا لم يُوجد التصنيف', () async {
        final result =
            await database.categoriesDao.getCategoryById('non_existent');
        expect(result, isNull);
      });
    });

    group('getAllCategories', () {
      test('يُرجع جميع التصنيفات النشطة للمتجر', () async {
        await database.categoriesDao.insertCategory(
          createCategory(id: 'cat_001', name: 'ألبان', sortOrder: 1),
        );
        await database.categoriesDao.insertCategory(
          createCategory(id: 'cat_002', name: 'خضروات', sortOrder: 2),
        );
        await database.categoriesDao.insertCategory(
          createCategory(
              id: 'cat_003', name: 'فواكه', isActive: false, sortOrder: 3),
        );

        final result =
            await database.categoriesDao.getAllCategories(testStoreId);
        expect(result.length, 2);
        expect(result[0].name, 'ألبان');
        expect(result[1].name, 'خضروات');
      });

      test('يُرتب التصنيفات حسب sortOrder', () async {
        await database.categoriesDao.insertCategory(
          createCategory(id: 'cat_001', name: 'زيوت', sortOrder: 3),
        );
        await database.categoriesDao.insertCategory(
          createCategory(id: 'cat_002', name: 'ألبان', sortOrder: 1),
        );

        final result =
            await database.categoriesDao.getAllCategories(testStoreId);
        expect(result[0].sortOrder, 1);
        expect(result[1].sortOrder, 3);
      });
    });

    group('getRootCategories', () {
      test('يُرجع التصنيفات الرئيسية فقط', () async {
        await database.categoriesDao.insertCategory(
          createCategory(id: 'cat_parent', name: 'أغذية'),
        );
        await database.categoriesDao.insertCategory(
          createCategory(
              id: 'cat_child', name: 'ألبان', parentId: 'cat_parent'),
        );

        final result =
            await database.categoriesDao.getRootCategories(testStoreId);
        expect(result.length, 1);
        expect(result[0].name, 'أغذية');
      });
    });

    group('getSubCategories', () {
      test('يُرجع التصنيفات الفرعية', () async {
        await database.categoriesDao.insertCategory(
          createCategory(id: 'cat_parent', name: 'أغذية'),
        );
        await database.categoriesDao.insertCategory(
          createCategory(
              id: 'cat_child1', name: 'ألبان', parentId: 'cat_parent', sortOrder: 1),
        );
        await database.categoriesDao.insertCategory(
          createCategory(
              id: 'cat_child2', name: 'خضروات', parentId: 'cat_parent', sortOrder: 2),
        );

        final result = await database.categoriesDao
            .getSubCategories('cat_parent', testStoreId);
        expect(result.length, 2);
        expect(result[0].name, 'ألبان');
        expect(result[1].name, 'خضروات');
      });
    });

    group('updateCategory', () {
      test('يُحدّث بيانات التصنيف', () async {
        final category = createCategory(id: testCategoryId, name: 'ألبان');
        await database.categoriesDao.insertCategory(category);

        final fetched =
            await database.categoriesDao.getCategoryById(testCategoryId);
        final updated = fetched!.copyWith(name: 'منتجات الألبان');

        await database.categoriesDao.updateCategory(updated);

        final result =
            await database.categoriesDao.getCategoryById(testCategoryId);
        expect(result!.name, 'منتجات الألبان');
      });
    });

    group('deleteCategory', () {
      test('يحذف التصنيف', () async {
        final category = createCategory(id: testCategoryId, name: 'للحذف');
        await database.categoriesDao.insertCategory(category);

        await database.categoriesDao.deleteCategory(testCategoryId);

        final result =
            await database.categoriesDao.getCategoryById(testCategoryId);
        expect(result, isNull);
      });
    });

    group('deleteAllCategories', () {
      test('يحذف جميع تصنيفات المتجر', () async {
        await database.categoriesDao.insertCategory(
          createCategory(id: 'cat_001', name: 'ألبان'),
        );
        await database.categoriesDao.insertCategory(
          createCategory(id: 'cat_002', name: 'خضروات'),
        );

        await database.categoriesDao.deleteAllCategories(testStoreId);

        final result =
            await database.categoriesDao.getAllCategories(testStoreId);
        expect(result, isEmpty);
      });
    });

    group('getCategoriesCount', () {
      test('يُرجع عدد التصنيفات للمتجر', () async {
        await database.categoriesDao.insertCategory(
          createCategory(id: 'cat_001', name: 'ألبان'),
        );
        await database.categoriesDao.insertCategory(
          createCategory(id: 'cat_002', name: 'خضروات'),
        );

        final count =
            await database.categoriesDao.getCategoriesCount(testStoreId);
        expect(count, 2);
      });
    });

    group('upsertCategory', () {
      test('يُضيف تصنيف جديد إذا لم يكن موجوداً', () async {
        final category = createCategory(id: testCategoryId, name: 'جديد');

        await database.categoriesDao.upsertCategory(category);

        final result =
            await database.categoriesDao.getCategoryById(testCategoryId);
        expect(result, isNotNull);
        expect(result!.name, 'جديد');
      });

      test('يُحدّث التصنيف إذا كان موجوداً', () async {
        await database.categoriesDao.insertCategory(
          createCategory(id: testCategoryId, name: 'قديم'),
        );

        await database.categoriesDao.upsertCategory(
          createCategory(id: testCategoryId, name: 'محدّث'),
        );

        final result =
            await database.categoriesDao.getCategoryById(testCategoryId);
        expect(result!.name, 'محدّث');
      });
    });

    group('insertCategories', () {
      test('يُضيف تصنيفات متعددة', () async {
        final categories = <CategoriesTableCompanion>[
          createCategory(id: 'cat_001', name: 'ألبان'),
          createCategory(id: 'cat_002', name: 'خضروات'),
          createCategory(id: 'cat_003', name: 'فواكه'),
        ];

        await database.categoriesDao.insertCategories(categories);

        final result =
            await database.categoriesDao.getAllCategories(testStoreId);
        expect(result.length, 3);
      });
    });
  });
}
