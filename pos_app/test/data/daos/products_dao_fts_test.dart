import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // انتظار إنشاء قاعدة البيانات
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() async {
    await db.close();
  });

  group('ProductsDao FTS Integration', () {
    test('ftsService متاح من ProductsDao', () {
      expect(db.productsDao.ftsService, isNotNull);
    });

    test('ftsService متاح من AppDatabase', () {
      expect(db.ftsService, isNotNull);
    });

    test('initializeFts يعمل بشكل صحيح', () async {
      // لا يجب أن يرمي خطأ
      await expectLater(
        db.initializeFts(),
        completes,
      );
    });

    test('rebuildFtsIndex يعمل بشكل صحيح', () async {
      // تهيئة أولاً
      await db.initializeFts();

      // لا يجب أن يرمي خطأ
      await expectLater(
        db.rebuildFtsIndex(),
        completes,
      );
    });

    test('searchWithFts يعيد قائمة فارغة للاستعلام الفارغ', () async {
      await db.initializeFts();

      final results = await db.productsDao.searchWithFts('', 'store-1');
      expect(results, isEmpty);
    });

    test('getSearchSuggestions يعيد قائمة فارغة للاستعلام الفارغ', () async {
      await db.initializeFts();

      final suggestions =
          await db.productsDao.getSearchSuggestions('', 'store-1');
      expect(suggestions, isEmpty);
    });
  });

  group('ProductsDao searchProducts', () {
    test('searchProducts يعيد قائمة فارغة عندما لا توجد منتجات', () async {
      final results = await db.productsDao.searchProducts('test', 'store-1');
      expect(results, isEmpty);
    });
  });
}
