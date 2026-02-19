import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:pos_app/data/local/app_database.dart';

// ===========================================
// Sale Items DAO Tests
// ===========================================

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('SaleItemsDao', () {
    const testSaleId = 'sale_001';
    const testProductId = 'prod_001';

    SaleItemsTableCompanion createSaleItem({
      required String id,
      required String saleId,
      required String productId,
      required String productName,
      int qty = 1,
      double unitPrice = 10.0,
      double? costPrice,
      double discount = 0,
      String? notes,
    }) {
      final subtotal = unitPrice * qty;
      final total = subtotal - discount;

      return SaleItemsTableCompanion.insert(
        id: id,
        saleId: saleId,
        productId: productId,
        productName: productName,
        productSku: const Value('SKU001'),
        productBarcode: const Value('1234567890'),
        qty: qty,
        unitPrice: unitPrice,
        costPrice: Value(costPrice),
        subtotal: subtotal,
        discount: Value(discount),
        total: total,
        notes: Value(notes),
      );
    }

    group('insertItem', () {
      test('يُدرج عنصر بيع جديد', () async {
        final item = createSaleItem(
          id: 'item_001',
          saleId: testSaleId,
          productId: testProductId,
          productName: 'حليب طازج',
          qty: 2,
          unitPrice: 15.0,
        );

        final result = await database.saleItemsDao.insertItem(item);
        expect(result, greaterThan(0));
      });
    });

    group('getItemsBySaleId', () {
      test('يُرجع عناصر فاتورة معينة', () async {
        // إضافة عناصر لفواتير مختلفة
        await database.saleItemsDao.insertItem(
          createSaleItem(
            id: 'item_001',
            saleId: testSaleId,
            productId: 'prod_001',
            productName: 'حليب',
          ),
        );

        await database.saleItemsDao.insertItem(
          createSaleItem(
            id: 'item_002',
            saleId: testSaleId,
            productId: 'prod_002',
            productName: 'خبز',
          ),
        );

        await database.saleItemsDao.insertItem(
          createSaleItem(
            id: 'item_003',
            saleId: 'sale_002',
            productId: 'prod_003',
            productName: 'جبن',
          ),
        );

        final items = await database.saleItemsDao.getItemsBySaleId(testSaleId);
        expect(items.length, 2);
        expect(items.every((i) => i.saleId == testSaleId), isTrue);
      });

      test('يُرجع قائمة فارغة إذا لم تُوجد عناصر', () async {
        final items =
            await database.saleItemsDao.getItemsBySaleId('non_existent');
        expect(items, isEmpty);
      });
    });

    group('insertItems', () {
      test('يُدرج عناصر متعددة بشكل دفعي', () async {
        final items = [
          createSaleItem(
            id: 'item_001',
            saleId: testSaleId,
            productId: 'prod_001',
            productName: 'حليب',
            qty: 2,
            unitPrice: 15.0,
          ),
          createSaleItem(
            id: 'item_002',
            saleId: testSaleId,
            productId: 'prod_002',
            productName: 'خبز',
            qty: 3,
            unitPrice: 5.0,
          ),
          createSaleItem(
            id: 'item_003',
            saleId: testSaleId,
            productId: 'prod_003',
            productName: 'جبن',
            qty: 1,
            unitPrice: 25.0,
          ),
        ];

        await database.saleItemsDao.insertItems(items);

        final fetched = await database.saleItemsDao.getItemsBySaleId(testSaleId);
        expect(fetched.length, 3);
      });
    });

    group('deleteItemsBySaleId', () {
      test('يحذف جميع عناصر الفاتورة', () async {
        await database.saleItemsDao.insertItem(
          createSaleItem(
            id: 'item_001',
            saleId: testSaleId,
            productId: 'prod_001',
            productName: 'حليب',
          ),
        );

        await database.saleItemsDao.insertItem(
          createSaleItem(
            id: 'item_002',
            saleId: testSaleId,
            productId: 'prod_002',
            productName: 'خبز',
          ),
        );

        // التحقق من وجود العناصر
        var items = await database.saleItemsDao.getItemsBySaleId(testSaleId);
        expect(items.length, 2);

        // حذف العناصر
        final deleted =
            await database.saleItemsDao.deleteItemsBySaleId(testSaleId);
        expect(deleted, 2);

        // التحقق من الحذف
        items = await database.saleItemsDao.getItemsBySaleId(testSaleId);
        expect(items, isEmpty);
      });

      test('لا يحذف عناصر فواتير أخرى', () async {
        await database.saleItemsDao.insertItem(
          createSaleItem(
            id: 'item_001',
            saleId: testSaleId,
            productId: 'prod_001',
            productName: 'حليب',
          ),
        );

        await database.saleItemsDao.insertItem(
          createSaleItem(
            id: 'item_002',
            saleId: 'sale_002',
            productId: 'prod_002',
            productName: 'خبز',
          ),
        );

        await database.saleItemsDao.deleteItemsBySaleId(testSaleId);

        final otherItems =
            await database.saleItemsDao.getItemsBySaleId('sale_002');
        expect(otherItems.length, 1);
      });
    });

    group('getProductSalesCount', () {
      test('يُرجع إجمالي مبيعات المنتج', () async {
        // بيع 5 وحدات في فاتورة
        await database.saleItemsDao.insertItem(
          createSaleItem(
            id: 'item_001',
            saleId: 'sale_001',
            productId: testProductId,
            productName: 'حليب',
            qty: 5,
          ),
        );

        // بيع 3 وحدات في فاتورة أخرى
        await database.saleItemsDao.insertItem(
          createSaleItem(
            id: 'item_002',
            saleId: 'sale_002',
            productId: testProductId,
            productName: 'حليب',
            qty: 3,
          ),
        );

        // بيع منتج آخر
        await database.saleItemsDao.insertItem(
          createSaleItem(
            id: 'item_003',
            saleId: 'sale_003',
            productId: 'prod_002',
            productName: 'خبز',
            qty: 10,
          ),
        );

        final totalSold =
            await database.saleItemsDao.getProductSalesCount(testProductId);
        expect(totalSold, 8); // 5 + 3
      });

      test('يُرجع 0 إذا لم يُباع المنتج', () async {
        final totalSold =
            await database.saleItemsDao.getProductSalesCount('non_existent');
        expect(totalSold, 0);
      });
    });

    group('data integrity', () {
      test('يحفظ بيانات المنتج وقت البيع', () async {
        await database.saleItemsDao.insertItem(
          SaleItemsTableCompanion.insert(
            id: 'item_001',
            saleId: testSaleId,
            productId: testProductId,
            productName: 'حليب طازج كامل الدسم',
            productSku: const Value('MILK-001'),
            productBarcode: const Value('6281000000001'),
            qty: 2,
            unitPrice: 15.50,
            costPrice: const Value(12.0),
            subtotal: 31.0,
            discount: const Value(1.0),
            total: 30.0,
            notes: const Value('خصم خاص'),
          ),
        );

        final items = await database.saleItemsDao.getItemsBySaleId(testSaleId);
        final item = items.first;

        expect(item.productName, 'حليب طازج كامل الدسم');
        expect(item.productSku, 'MILK-001');
        expect(item.productBarcode, '6281000000001');
        expect(item.qty, 2);
        expect(item.unitPrice, 15.50);
        expect(item.costPrice, 12.0);
        expect(item.subtotal, 31.0);
        expect(item.discount, 1.0);
        expect(item.total, 30.0);
        expect(item.notes, 'خصم خاص');
      });

      test('يحسب المجموع الفرعي والإجمالي بشكل صحيح', () async {
        final item = createSaleItem(
          id: 'item_001',
          saleId: testSaleId,
          productId: testProductId,
          productName: 'منتج اختبار',
          qty: 3,
          unitPrice: 20.0,
          discount: 5.0,
        );

        await database.saleItemsDao.insertItem(item);

        final items = await database.saleItemsDao.getItemsBySaleId(testSaleId);
        final savedItem = items.first;

        expect(savedItem.subtotal, 60.0); // 3 * 20
        expect(savedItem.total, 55.0); // 60 - 5
      });
    });
  });
}
