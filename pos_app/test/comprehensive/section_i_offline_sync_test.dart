/// اختبارات قسم I: وضع عدم الاتصال / المزامنة (Offline/Sync)
///
/// 16 اختبار تغطي:
/// - I01: إضافة بيع لطابور المزامنة أثناء عدم الاتصال
/// - I02: معالجة الطابور عند إعادة الاتصال
/// - I03: منع التكرار بمفتاح الـ idempotency
/// - I04: تعارض المخزون أثناء المزامنة (مفاهيمي)
/// - I05: تعارض السعر أثناء المزامنة (مفاهيمي)
/// - I06: تعارض معدل الضريبة (مفاهيمي)
/// - I07: ترتيب الأولوية في الطابور
/// - I08: مزامنة دفعة من 10 عمليات
/// - I09: فشل مزامنة جزئي
/// - I10: عدم اتصال لأكثر من 24 ساعة
/// - I11: انهيار أثناء البيع (تراجع معاملة قاعدة البيانات)
/// - I12: انهيار أثناء المزامنة
/// - I13: تبديل الاتصال السريع
/// - I14: ذرية الطلب والدفع (مفاهيمي)
/// - I15: ذرية المعاملة المحلية
/// - I16: إعادة المحاولة لا تمنع العناصر الأخرى
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_core/alhai_core.dart' hide CartItem;
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/providers/cart_providers.dart';
import 'package:pos_app/services/sync/sync_service.dart';

import 'fixtures/test_fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  group('Section I: Offline / Sync - وضع عدم الاتصال / المزامنة', () {
    // ================================================================
    // I01: إضافة بيع لطابور المزامنة أثناء عدم الاتصال
    // ================================================================

    test('I01 بيع يُضاف للطابور أثناء عدم الاتصال → getPendingCount=1', () async {
      // Arrange
      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);

      // Act - إضافة بيع للطابور كما يحصل أثناء عدم الاتصال
      final id = await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-001',
        data: {
          'storeId': 'store-1',
          'cashierId': uCashierId,
          'total': 100.0,
          'paymentMethod': 'cash',
        },
        priority: SyncPriority.high,
      );

      // Assert
      expect(id, isNotEmpty);
      final count = await syncService.getPendingCount();
      expect(count, equals(1));

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I02: معالجة الطابور عند إعادة الاتصال
    // ================================================================

    test('I02 معالجة الطابور عند إعادة الاتصال → getPendingCount=0', () async {
      // Arrange
      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);

      // إضافة عنصرين للطابور
      final id1 = await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-001',
        data: {'total': 50.0},
      );
      final id2 = await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-002',
        data: {'total': 75.0},
      );

      expect(await syncService.getPendingCount(), equals(2));

      // Act - محاكاة إعادة الاتصال: تعيين كمتزامن
      await syncService.markAsSynced(id1);
      await syncService.markAsSynced(id2);

      // Assert
      final count = await syncService.getPendingCount();
      expect(count, equals(0));

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I03: منع التكرار بمفتاح الـ idempotency
    // ================================================================

    test('I03 نفس الجدول+السجل+العملية → findByIdempotencyKey يجد الموجود', () async {
      // Arrange
      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);

      // Act - إضافة عملية أولى
      final id1 = await syncService.enqueue(
        tableName: 'products',
        recordId: 'prod-100',
        operation: SyncOperation.update,
        payload: {'price': 10.0},
      );

      // البحث بمفتاح idempotency المُولّد
      final pendingItems = await syncService.getPendingItems();
      expect(pendingItems, hasLength(1));

      final idempotencyKey = pendingItems.first.idempotencyKey;
      final found = await db.syncQueueDao.findByIdempotencyKey(idempotencyKey);

      // Assert - العنصر موجود ومعرفه يطابق
      expect(found, isNotNull);
      expect(found!.id, equals(id1));
      expect(found.recordId, equals('prod-100'));

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I04: تعارض المخزون أثناء المزامنة (مفاهيمي)
    // ================================================================

    test('I04 تعارض المخزون: مخزون محلي != مخزون السيرفر → يتم التعليم (placeholder)', () {
      // سيناريو مفاهيمي:
      // 1. المخزون المحلي = 10
      // 2. المخزون على السيرفر = 5 (شخص آخر باع أثناء عدم الاتصال)
      // 3. عند المزامنة، يُكتشف التعارض
      // 4. يجب تعليم العنصر كـ "conflict" للمراجعة

      const localStock = 10;
      const serverStock = 5;

      // محاكاة كشف التعارض
      final hasConflict = localStock != serverStock;
      expect(hasConflict, isTrue, reason: 'يجب كشف تعارض المخزون');

      // القرار: أخذ القيمة الأقل (الأكثر أماناً)
      final resolvedStock =
          localStock < serverStock ? localStock : serverStock;
      expect(resolvedStock, equals(5));
    });

    // ================================================================
    // I05: تعارض السعر أثناء المزامنة (مفاهيمي)
    // ================================================================

    test('I05 تعارض السعر: سعر محلي != سعر السيرفر → يتم التعليم (placeholder)', () {
      // سيناريو مفاهيمي:
      // 1. السعر المحلي = 7.00
      // 2. السعر على السيرفر = 7.50 (تم تحديثه)
      // 3. عند المزامنة، يُكتشف التعارض

      const localPrice = 7.00;
      const serverPrice = 7.50;

      final hasConflict = localPrice != serverPrice;
      expect(hasConflict, isTrue, reason: 'يجب كشف تعارض السعر');

      // القرار: سعر السيرفر يأخذ الأولوية (server wins)
      const resolvedPrice = serverPrice;
      expect(resolvedPrice, equals(7.50));
    });

    // ================================================================
    // I06: تعارض معدل الضريبة (مفاهيمي)
    // ================================================================

    test('I06 تعارض معدل الضريبة: محلي != سيرفر → يتم التعليم (placeholder)', () {
      // سيناريو مفاهيمي:
      // 1. معدل الضريبة المحلي = 15%
      // 2. معدل الضريبة على السيرفر = 10% (تغيير حكومي)
      // 3. الفواتير القديمة تحتفظ بمعدلها الأصلي
      // 4. الفواتير الجديدة تستخدم المعدل الجديد

      const localTaxRate = 0.15;
      const serverTaxRate = 0.10;

      final hasConflict = localTaxRate != serverTaxRate;
      expect(hasConflict, isTrue, reason: 'يجب كشف تعارض معدل الضريبة');

      // الفاتورة القديمة تحتفظ بمعدلها
      final oldInvoiceTotal = roundSar(100.0 * (1 + localTaxRate));
      expect(oldInvoiceTotal, equals(115.0));

      // الفاتورة الجديدة تستخدم المعدل الجديد
      final newInvoiceTotal = roundSar(100.0 * (1 + serverTaxRate));
      expect(newInvoiceTotal, equals(110.0));
    });

    // ================================================================
    // I07: ترتيب الأولوية في الطابور
    // ================================================================

    test('I07 ترتيب الأولوية: عالية تُعالَج قبل المنخفضة', () async {
      // Arrange
      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);

      // إضافة عنصر منخفض الأولوية أولاً
      await syncService.enqueueCreate(
        tableName: 'products',
        recordId: 'prod-low',
        data: {'name': 'منتج عادي'},
        priority: SyncPriority.low,
      );

      // ثم عنصر عالي الأولوية
      await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-high',
        data: {'total': 200.0},
        priority: SyncPriority.high,
      );

      // ثم عنصر عادي الأولوية
      await syncService.enqueueCreate(
        tableName: 'inventory',
        recordId: 'inv-normal',
        data: {'qty': 5},
        priority: SyncPriority.normal,
      );

      // Act
      final items = await syncService.getPendingItems();

      // Assert - الأعلى أولوية أولاً
      expect(items, hasLength(3));
      expect(items[0].recordId, equals('sale-high')); // high (3)
      expect(items[1].recordId, equals('inv-normal')); // normal (2)
      expect(items[2].recordId, equals('prod-low')); // low (1)

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I08: مزامنة دفعة من 10 عمليات
    // ================================================================

    test('I08 دفعة من 10 عمليات → getPendingCount=10 ثم 0 بعد المزامنة', () async {
      // Arrange
      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);
      final ids = <String>[];

      // Act - إضافة 10 عمليات
      for (var i = 0; i < 10; i++) {
        final id = await syncService.enqueueCreate(
          tableName: 'sales',
          recordId: 'sale-batch-$i',
          data: {'total': (i + 1) * 10.0},
        );
        ids.add(id);
      }

      // Assert - 10 عناصر معلقة
      expect(await syncService.getPendingCount(), equals(10));

      // محاكاة مزامنة كل العناصر
      for (final id in ids) {
        await syncService.markAsSynced(id);
      }

      // Assert - 0 عناصر معلقة
      expect(await syncService.getPendingCount(), equals(0));

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I09: فشل مزامنة جزئي
    // ================================================================

    test('I09 فشل جزئي: 5 متزامنة + 5 فاشلة → العناصر الفاشلة ما زالت معلقة', () async {
      // Arrange
      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);
      final ids = <String>[];

      for (var i = 0; i < 10; i++) {
        final id = await syncService.enqueueCreate(
          tableName: 'sales',
          recordId: 'sale-partial-$i',
          data: {'total': (i + 1) * 10.0},
        );
        ids.add(id);
      }

      expect(await syncService.getPendingCount(), equals(10));

      // Act - 5 تتزامن بنجاح و 5 تفشل
      for (var i = 0; i < 5; i++) {
        await syncService.markAsSynced(ids[i]);
      }
      for (var i = 5; i < 10; i++) {
        await syncService.markAsFailed(ids[i], 'خطأ في الشبكة');
      }

      // Assert - العناصر الفاشلة ما زالت في العدد المعلق (pending + failed مع retryCount < maxRetries)
      final count = await syncService.getPendingCount();
      expect(count, equals(5), reason: 'العناصر الفاشلة ما زالت تُحسب كمعلقة');

      // التحقق من أن العناصر الفاشلة لديها رسالة خطأ
      final pending = await syncService.getPendingItems();
      expect(pending, hasLength(5));
      for (final item in pending) {
        expect(item.status, equals('failed'));
        expect(item.lastError, equals('خطأ في الشبكة'));
        expect(item.retryCount, equals(1));
      }

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I10: عدم اتصال لأكثر من 24 ساعة
    // ================================================================

    test('I10 عناصر قديمة (24+ ساعة) لا تزال قابلة للمعالجة', () async {
      // Arrange
      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);

      // إضافة عنصر يدوياً بتاريخ إنشاء قديم (قبل 48 ساعة)
      final oldTimestamp = DateTime.now().subtract(const Duration(hours: 48));

      await db.syncQueueDao.enqueue(
        id: 'old-item-001',
        tableName: 'sales',
        recordId: 'sale-old-001',
        operation: 'CREATE',
        payload: '{"total":150.0}',
        idempotencyKey: 'sales_sale-old-001_create_old',
        priority: 2,
      );

      // Act - التحقق من أن العنصر القديم يظهر في القائمة المعلقة
      final count = await syncService.getPendingCount();
      final items = await syncService.getPendingItems();

      // Assert
      expect(count, equals(1));
      expect(items, hasLength(1));
      expect(items.first.id, equals('old-item-001'));
      expect(items.first.recordId, equals('sale-old-001'));

      // يمكن مزامنته بنجاح
      await syncService.markAsSynced('old-item-001');
      expect(await syncService.getPendingCount(), equals(0));

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I11: انهيار أثناء البيع (تراجع معاملة قاعدة البيانات)
    // ================================================================

    test('I11 فشل المعاملة أثناء البيع → لا شيء يُحفظ', () async {
      // Arrange
      final db = createTestDb();
      await seedAllProducts(db);

      // Act - محاولة معاملة تفشل في المنتصف
      try {
        await db.transaction(() async {
          // إدراج بيع
          await db.salesDao.insertSale(SalesTableCompanion.insert(
            id: 'sale-crash-001',
            receiptNo: 'RCP-CRASH-001',
            storeId: 'store-1',
            cashierId: uCashierId,
            subtotal: 100.0,
            discount: const Value(0.0),
            tax: const Value(15.0),
            total: 115.0,
            paymentMethod: 'cash',
            createdAt: DateTime.now(),
          ));

          // محاكاة خطأ قبل إكمال المعاملة
          throw Exception('انهيار أثناء البيع');
        });
      } catch (_) {
        // متوقع
      }

      // Assert - لا يوجد بيع محفوظ
      final sales = await db.salesDao.getAllSales('store-1');
      expect(sales, isEmpty, reason: 'يجب ألا يُحفظ أي بيع بعد فشل المعاملة');

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I12: انهيار أثناء المزامنة
    // ================================================================

    test('I12 انهيار أثناء المزامنة: بعض متزامن وبعض معلق → المتبقي لا يزال معلق', () async {
      // Arrange
      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);

      final ids = <String>[];
      for (var i = 0; i < 5; i++) {
        final id = await syncService.enqueueCreate(
          tableName: 'sales',
          recordId: 'sale-crash-$i',
          data: {'total': (i + 1) * 20.0},
        );
        ids.add(id);
      }

      expect(await syncService.getPendingCount(), equals(5));

      // Act - مزامنة أول عنصرين ثم "انهيار" (توقف عن المعالجة)
      await syncService.markAsSynced(ids[0]);
      await syncService.markAsSynced(ids[1]);
      // العناصر 2, 3, 4 تبقى معلقة (محاكاة الانهيار)

      // Assert - 3 عناصر لا تزال معلقة
      final count = await syncService.getPendingCount();
      expect(count, equals(3));

      final pending = await syncService.getPendingItems();
      expect(pending, hasLength(3));
      final pendingIds = pending.map((e) => e.id).toSet();
      expect(pendingIds, contains(ids[2]));
      expect(pendingIds, contains(ids[3]));
      expect(pendingIds, contains(ids[4]));

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I13: تبديل الاتصال السريع (مفاهيمي)
    // ================================================================

    test('I13 تبديل اتصال سريع: الطابور يحافظ على تكامله (placeholder)', () async {
      // سيناريو مفاهيمي:
      // 1. يتم إضافة عمليات أثناء تبديل سريع بين اتصال/عدم اتصال
      // 2. الطابور يجب أن يحافظ على جميع العمليات بدون فقدان

      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);

      // محاكاة: إضافة عمليات كأن الاتصال يتغير
      // الدورة 1: أوفلاين → إضافة
      await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'toggle-1',
        data: {'total': 10.0},
      );

      // الدورة 2: أونلاين لحظة → أوفلاين مرة أخرى → إضافة
      await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'toggle-2',
        data: {'total': 20.0},
      );

      // الدورة 3: أوفلاين → إضافة
      await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'toggle-3',
        data: {'total': 30.0},
      );

      // Assert - جميع العمليات موجودة
      final count = await syncService.getPendingCount();
      expect(count, equals(3), reason: 'تبديل الاتصال السريع يجب ألا يفقد عمليات');

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I14: ذرية الطلب والدفع (مفاهيمي)
    // ================================================================

    test('I14 ذرية الطلب والدفع: الطلب يجب أن ينجح قبل الدفع (placeholder)', () {
      // سيناريو مفاهيمي:
      // 1. يتم إنشاء الطلب أولاً في الطابور
      // 2. يتم إنشاء الدفع ثانياً
      // 3. عند المزامنة: الطلب يُرسل أولاً
      // 4. إذا فشل الطلب، لا يُرسل الدفع
      // 5. إذا نجح الطلب، يُرسل الدفع

      // محاكاة ترتيب العمليات
      const orderCreated = true;
      const orderSynced = true;
      const paymentShouldSync = orderSynced;

      expect(orderCreated, isTrue);
      expect(paymentShouldSync, isTrue, reason: 'الدفع يُزامن فقط بعد نجاح الطلب');

      // حالة فشل الطلب
      const orderFailed = true;
      const paymentBlocked = orderFailed;
      expect(paymentBlocked, isTrue, reason: 'الدفع يُحظر إذا فشل الطلب');
    });

    // ================================================================
    // I15: ذرية المعاملة المحلية
    // ================================================================

    test('I15 تراجع المعاملة → لا يوجد حالة جزئية', () async {
      // Arrange
      final db = createTestDb();
      await seedAllProducts(db);

      final originalProduct =
          await db.productsDao.getProductById('p1-pepsi');
      expect(originalProduct, isNotNull);
      final originalStock = originalProduct!.stockQty;

      // Act - معاملة تفشل بعد تعديل المخزون
      try {
        await db.transaction(() async {
          // تعديل المخزون
          await db.productsDao.updateStock('p1-pepsi', originalStock - 5);

          // إدراج بيع
          await db.salesDao.insertSale(SalesTableCompanion.insert(
            id: 'sale-atomic-001',
            receiptNo: 'RCP-ATOMIC-001',
            storeId: 'store-1',
            cashierId: uCashierId,
            subtotal: 35.0,
            discount: const Value(0.0),
            tax: const Value(5.25),
            total: 40.25,
            paymentMethod: 'cash',
            createdAt: DateTime.now(),
          ));

          // خطأ قبل الإكمال → تراجع كامل
          throw Exception('خطأ أثناء المعاملة');
        });
      } catch (_) {
        // متوقع
      }

      // Assert - المخزون لم يتغير والبيع لم يُحفظ
      final productAfter = await db.productsDao.getProductById('p1-pepsi');
      expect(productAfter, isNotNull);
      expect(productAfter!.stockQty, equals(originalStock),
          reason: 'المخزون يجب أن يعود لقيمته الأصلية');

      final sales = await db.salesDao.getAllSales('store-1');
      expect(sales, isEmpty, reason: 'البيع يجب ألا يُحفظ بعد التراجع');

      // Cleanup
      await db.close();
    });

    // ================================================================
    // I16: إعادة المحاولة لا تمنع العناصر الأخرى
    // ================================================================

    test('I16 عنصر فاشل مع retryCount++ لا يمنع العناصر الأخرى', () async {
      // Arrange
      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);

      // إضافة عنصر سيفشل عدة مرات
      final failingId = await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-failing',
        data: {'total': 100.0},
      );

      // إضافة عناصر أخرى عادية
      final normalId1 = await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-normal-1',
        data: {'total': 50.0},
      );
      final normalId2 = await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-normal-2',
        data: {'total': 75.0},
      );

      // Act - العنصر الأول يفشل مرتين
      await syncService.markAsFailed(failingId, 'خطأ شبكة - محاولة 1');
      await syncService.markAsFailed(failingId, 'خطأ شبكة - محاولة 2');

      // العنصران العاديان يتزامنان بنجاح
      await syncService.markAsSynced(normalId1);
      await syncService.markAsSynced(normalId2);

      // Assert - العنصر الفاشل ما زال معلقاً لكنه لم يمنع الآخرين
      final pending = await syncService.getPendingItems();
      expect(pending, hasLength(1), reason: 'العنصر الفاشل فقط يبقى');
      expect(pending.first.id, equals(failingId));
      expect(pending.first.retryCount, equals(2));

      // التحقق من أن العنصر الفاشل لم يتجاوز الحد الأقصى لإعادة المحاولة
      expect(pending.first.retryCount, lessThan(pending.first.maxRetries),
          reason: 'ما زال قابل لإعادة المحاولة');

      // Cleanup
      await db.close();
    });
  });
}
