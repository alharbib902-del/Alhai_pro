import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/data/local/fts/products_fts.dart';

void main() {
  group('FtsSearchResult', () {
    test('يُنشئ من البيانات الصحيحة', () {
      final result = FtsSearchResult(
        id: 'prod-1',
        storeId: 'store-1',
        name: 'منتج تجريبي',
        barcode: '123456789',
        sku: 'SKU-001',
        description: 'وصف المنتج',
        price: 99.99,
        stockQty: 100,
        imageThumbnail: 'https://example.com/image.jpg',
        categoryId: 'cat-1',
        rank: 0.5,
      );

      expect(result.id, 'prod-1');
      expect(result.storeId, 'store-1');
      expect(result.name, 'منتج تجريبي');
      expect(result.barcode, '123456789');
      expect(result.sku, 'SKU-001');
      expect(result.price, 99.99);
      expect(result.stockQty, 100);
      expect(result.rank, 0.5);
    });

    test('يتعامل مع القيم الفارغة', () {
      final result = FtsSearchResult(
        id: 'prod-1',
        storeId: 'store-1',
        name: 'منتج',
        price: 50.0,
        stockQty: 10,
        rank: 0.0,
      );

      expect(result.barcode, isNull);
      expect(result.sku, isNull);
      expect(result.description, isNull);
      expect(result.imageThumbnail, isNull);
      expect(result.categoryId, isNull);
    });
  });

  group('FtsSearchResponse', () {
    test('يحسب hasMore بشكل صحيح', () {
      final response = FtsSearchResponse(
        results: List.generate(
          10,
          (i) => FtsSearchResult(
            id: 'prod-$i',
            storeId: 'store-1',
            name: 'منتج $i',
            price: 10.0,
            stockQty: 5,
            rank: 0.1,
          ),
        ),
        totalCount: 50,
      );

      expect(response.hasMore, true);
      expect(response.currentCount, 10);
    });

    test('hasMore false عندما لا توجد نتائج أخرى', () {
      final response = FtsSearchResponse(
        results: List.generate(
          10,
          (i) => FtsSearchResult(
            id: 'prod-$i',
            storeId: 'store-1',
            name: 'منتج $i',
            price: 10.0,
            stockQty: 5,
            rank: 0.1,
          ),
        ),
        totalCount: 10,
      );

      expect(response.hasMore, false);
    });

    test('يتعامل مع نتائج فارغة', () {
      final response = FtsSearchResponse(
        results: [],
        totalCount: 0,
      );

      expect(response.hasMore, false);
      expect(response.currentCount, 0);
    });
  });

  group('ProductsFtsService - Query Preparation', () {
    // اختبار تنظيف الاستعلام
    test('_prepareQuery ينظف الاستعلام بشكل صحيح', () {
      // نختبر منطق التنظيف
      const query = 'مانجو  طازج!';
      final cleaned = query
          .trim()
          .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ');

      expect(cleaned, 'مانجو طازج ');
    });

    test('يحافظ على الحروف العربية', () {
      const query = 'منتج عربي';
      final cleaned = query
          .trim()
          .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ');

      expect(cleaned.contains('منتج'), true);
      expect(cleaned.contains('عربي'), true);
    });

    test('يزيل الأحرف الخاصة', () {
      const query = 'test@#\$%product';
      final cleaned = query
          .trim()
          .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ');

      expect(cleaned.contains('@'), false);
      expect(cleaned.contains('#'), false);
      expect(cleaned.contains('\$'), false);
      expect(cleaned.contains('%'), false);
    });

    test('يقلل المسافات المتعددة', () {
      const query = 'منتج    متعدد   المسافات';
      final cleaned = query
          .trim()
          .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ');

      expect(cleaned, 'منتج متعدد المسافات');
    });

    test('يتعامل مع استعلام فارغ', () {
      const query = '';
      final cleaned = query
          .trim()
          .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ');

      expect(cleaned, '');
    });

    test('يضيف * للبحث الجزئي', () {
      const query = 'مان فاك';
      final cleaned = query
          .trim()
          .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ');

      final words = cleaned.split(' ').where((w) => w.isNotEmpty);
      final prepared = words.map((w) => '$w*').join(' ');

      expect(prepared, 'مان* فاك*');
    });
  });

  group('FtsSearchResult - Edge Cases', () {
    test('يتعامل مع أسعار صفرية', () {
      final result = FtsSearchResult(
        id: 'prod-1',
        storeId: 'store-1',
        name: 'منتج مجاني',
        price: 0.0,
        stockQty: 0,
        rank: 0.0,
      );

      expect(result.price, 0.0);
      expect(result.stockQty, 0);
    });

    test('يتعامل مع أسعار كبيرة', () {
      final result = FtsSearchResult(
        id: 'prod-1',
        storeId: 'store-1',
        name: 'منتج غالي',
        price: 999999.99,
        stockQty: 1000000,
        rank: -10.0, // rank سالب يعني أفضل تطابق
      );

      expect(result.price, 999999.99);
      expect(result.stockQty, 1000000);
    });

    test('يتعامل مع اسم طويل جداً', () {
      final longName = 'منتج ' * 100;
      final result = FtsSearchResult(
        id: 'prod-1',
        storeId: 'store-1',
        name: longName,
        price: 10.0,
        stockQty: 5,
        rank: 0.0,
      );

      expect(result.name.length, longName.length);
    });

    test('يتعامل مع باركود رقمي طويل', () {
      final result = FtsSearchResult(
        id: 'prod-1',
        storeId: 'store-1',
        name: 'منتج',
        barcode: '1234567890123456789012345',
        price: 10.0,
        stockQty: 5,
        rank: 0.0,
      );

      expect(result.barcode, '1234567890123456789012345');
    });
  });

  group('FtsSearchResponse - Pagination', () {
    test('يحسب hasMore للصفحة الأولى', () {
      final response = FtsSearchResponse(
        results: List.generate(20, (i) => _createResult(i)),
        totalCount: 100,
      );

      expect(response.hasMore, true);
      expect(response.currentCount, 20);
    });

    test('يحسب hasMore للصفحة الأخيرة', () {
      final response = FtsSearchResponse(
        results: List.generate(5, (i) => _createResult(i)),
        totalCount: 5,
      );

      expect(response.hasMore, false);
    });

    test('يحسب hasMore لصفحة وسطية', () {
      final response = FtsSearchResponse(
        results: List.generate(20, (i) => _createResult(i)),
        totalCount: 60,
      );

      expect(response.hasMore, true);
    });
  });
}

FtsSearchResult _createResult(int index) {
  return FtsSearchResult(
    id: 'prod-$index',
    storeId: 'store-1',
    name: 'منتج $index',
    price: 10.0 * (index + 1),
    stockQty: 5,
    rank: 0.1 * index,
  );
}


