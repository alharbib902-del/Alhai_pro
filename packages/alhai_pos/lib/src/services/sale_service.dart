import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/errors/app_exceptions.dart';
import 'package:alhai_database/alhai_database.dart';
import '../providers/cart_providers.dart';
import 'package:alhai_sync/alhai_sync.dart';

/// خدمة المبيعات
/// تدير إنشاء المبيعات وخصم المخزون مع دعم offline
class SaleService {
  final AppDatabase _db;
  final SyncService _syncService;
  static const _uuid = Uuid();
  
  SaleService({
    required AppDatabase db,
    required SyncService syncService,
  }) : _db = db,
       _syncService = syncService;
  
  /// إنشاء بيع جديد
  Future<String> createSale({
    required String storeId,
    required String cashierId,
    required List<PosCartItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required String paymentMethod,
    String? customerId,
    String? customerName,
    String? notes,
  }) async {
    final saleId = _uuid.v4();
    final receiptNo = await _generateReceiptNo(storeId);
    final now = DateTime.now();
    
    return _db.transaction(() async {
      // 1. إنشاء البيع
      await _db.salesDao.insertSale(SalesTableCompanion.insert(
        id: saleId,
        storeId: storeId,
        receiptNo: receiptNo,
        cashierId: cashierId,
        customerId: Value(customerId),
        customerName: Value(customerName),
        subtotal: subtotal,
        discount: Value(discount),
        tax: Value(tax),
        total: total,
        paymentMethod: paymentMethod,
        channel: const Value('POS'),
        status: const Value('completed'),
        isPaid: const Value(true),
        createdAt: now,
      ));
      
      // 2. التحقق من توفر المخزون قبل الخصم (قراءة حية من قاعدة البيانات)
      final freshProducts = <String, ProductsTableData>{};
      for (final item in items) {
        final product = await _db.productsDao.getProductById(item.product.id);
        if (product == null) {
          throw SaleException(
            message: 'Product not found in DB: ${item.product.id}',
            userMessage: 'المنتج "${item.product.name}" غير موجود في قاعدة البيانات',
            code: 'PRODUCT_NOT_FOUND',
          );
        }
        freshProducts[item.product.id] = product;

        // تخطي المنتجات التي لا تتبع المخزون
        if (!product.trackInventory) continue;

        if (product.stockQty < item.quantity) {
          throw SaleException.insufficientStock(
            product.name,
            product.stockQty,
            item.quantity,
          );
        }
      }

      // 3. إضافة عناصر البيع وخصم المخزون
      for (final item in items) {
        final freshProduct = freshProducts[item.product.id]!;
        final itemId = _uuid.v4();
        await _db.saleItemsDao.insertItem(SaleItemsTableCompanion.insert(
          id: itemId,
          saleId: saleId,
          productId: item.product.id,
          productName: item.product.name,
          unitPrice: item.effectivePrice,
          qty: item.quantity.toDouble(),
          subtotal: item.effectivePrice * item.quantity,
          discount: const Value(0),
          total: item.total,
        ));

        // خصم المخزون
        final movementId = _uuid.v4();
        await _db.inventoryDao.recordSaleMovement(
          id: movementId,
          productId: item.product.id,
          storeId: storeId,
          qty: item.quantity.toDouble(),
          previousQty: freshProduct.stockQty.toDouble(),
          saleId: saleId,
        );

        // تحديث كمية المنتج
        await _db.productsDao.updateStock(
          item.product.id,
          freshProduct.stockQty - item.quantity,
        );
      }
      
      // 4. إضافة للمزامنة
      await _syncService.enqueueCreate(
        tableName: 'sales',
        recordId: saleId,
        data: {
          'id': saleId,
          'storeId': storeId,
          'receiptNo': receiptNo,
          'cashierId': cashierId,
          'customerId': customerId,
          'customerName': customerName,
          'subtotal': subtotal,
          'discount': discount,
          'tax': tax,
          'total': total,
          'paymentMethod': paymentMethod,
          'items': items.map((i) => {
            'productId': i.product.id,
            'name': i.product.name,
            'unitPrice': i.effectivePrice,
            'qty': i.quantity,
            'lineTotal': i.total,
          }).toList(),
          'createdAt': now.toIso8601String(),
        },
        priority: SyncPriority.high,
      );
      
      return saleId;
    });
  }
  
  /// إلغاء بيع
  Future<void> voidSale(String saleId, {String? reason}) async {
    await _db.transaction(() async {
      final sale = await _db.salesDao.getSaleById(saleId);
      if (sale == null) throw SaleException.notFound(saleId);

      // التحقق من أن البيع ليس ملغياً مسبقاً
      if (sale.status == 'voided') {
        throw SaleException.alreadyVoided(saleId);
      }

      final items = await _db.saleItemsDao.getItemsBySaleId(saleId);

      // قراءة الكميات الحالية قبل الإلغاء (للسجل)
      final stockSnapshots = <String, double>{};
      for (final item in items) {
        final product = await _db.productsDao.getProductById(item.productId);
        if (product != null) {
          stockSnapshots[item.productId] = product.stockQty.toDouble();
        }
      }

      // إلغاء البيع (يستعيد المخزون تلقائياً)
      await _db.salesDao.voidSale(saleId);

      // تسجيل حركة المخزون (للسجل فقط، المخزون تم تحديثه بالفعل)
      for (final item in items) {
        final previousQty = stockSnapshots[item.productId];
        if (previousQty != null) {
          final movementId = _uuid.v4();
          final newQty = previousQty + item.qty;

          await _db.inventoryDao.recordAdjustment(
            id: movementId,
            productId: item.productId,
            storeId: sale.storeId,
            previousQty: previousQty,
            newQty: newQty,
            reason: reason ?? 'إلغاء بيع',
          );
        }
      }

      // إضافة للمزامنة
      await _syncService.enqueueUpdate(
        tableName: 'sales',
        recordId: saleId,
        changes: {
          'id': saleId,
          'status': 'voided',
          'reason': reason,
        },
        priority: SyncPriority.high,
      );
    });
  }
  
  /// توليد رقم إيصال فريد
  /// يستخدم عدد جميع مبيعات المتجر اليوم (بدون فلترة الكاشير)
  Future<String> _generateReceiptNo(String storeId) async {
    final today = DateTime.now();
    final prefix = 'POS-${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    // استخدام getTodayStoreCount بدلاً من getTodayCount
    // لإحصاء جميع مبيعات المتجر بغض النظر عن الكاشير
    final todayCount = await _db.salesDao.getTodayStoreCount(storeId);
    final sequence = (todayCount + 1).toString().padLeft(4, '0');

    return '$prefix-$sequence';
  }
  
  /// الحصول على مبيعات اليوم
  Future<List<SalesTableData>> getTodaySales(String storeId) {
    return _db.salesDao.getSalesByDate(storeId, DateTime.now());
  }
  
  /// إجمالي مبيعات اليوم
  Future<double> getTodayTotal(String storeId, String cashierId) {
    return _db.salesDao.getTodayTotal(storeId, cashierId);
  }
  
  /// عدد مبيعات اليوم
  Future<int> getTodayCount(String storeId, String cashierId) {
    return _db.salesDao.getTodayCount(storeId, cashierId);
  }
}
