import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/errors/app_exceptions.dart';
import 'package:alhai_database/alhai_database.dart';
import '../providers/cart_providers.dart';
import 'package:alhai_sync/alhai_sync.dart';

import 'invoice_service.dart';

/// تسجيل فرق سعر بين السلة وقاعدة البيانات
class PriceCorrection {
  final String productId;
  final String productName;
  final double cartPrice;
  final double dbPrice;
  final int quantity;

  const PriceCorrection({
    required this.productId,
    required this.productName,
    required this.cartPrice,
    required this.dbPrice,
    required this.quantity,
  });

  double get priceDifference => dbPrice - cartPrice;
  double get totalDifference => priceDifference * quantity;

  @override
  String toString() =>
      '$productName: cart=${cartPrice.toStringAsFixed(2)} -> db=${dbPrice.toStringAsFixed(2)} (diff=${priceDifference.toStringAsFixed(2)} x$quantity)';
}

/// نتيجة إنشاء البيع
class SaleResult {
  final String saleId;
  final List<PriceCorrection> priceCorrections;

  const SaleResult({
    required this.saleId,
    this.priceCorrections = const [],
  });

  bool get hadPriceCorrections => priceCorrections.isNotEmpty;
}

/// خدمة المبيعات
/// تدير إنشاء المبيعات وخصم المخزون مع دعم offline
class SaleService {
  final AppDatabase _db;
  final SyncService _syncService;
  final InvoiceService? _invoiceService;
  static const _uuid = Uuid();

  SaleService({
    required AppDatabase db,
    required SyncService syncService,
    InvoiceService? invoiceService,
  }) : _db = db,
       _syncService = syncService,
       _invoiceService = invoiceService;

  /// إنشاء بيع جديد
  Future<SaleResult> createSale({
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
    String? customerPhone,
    String? notes,
    double? amountReceived,
    double? changeAmount,
    double? cashAmount,
    double? cardAmount,
    double? creditAmount,
  }) async {
    final saleId = _uuid.v4();
    final now = DateTime.now();
    final priceCorrections = <PriceCorrection>[];

    // Variables captured from inside the transaction, needed for sync enqueue after commit.
    late String receiptNo;
    String? validCustomerId;
    String? orgId;
    late double correctedSubtotal;
    late double correctedTax;
    late double correctedTotal;
    late bool isPaid;
    late List<String> insertedItemIds;
    late Map<String, double> correctedPrices;

    // Retry loop: if receipt number collides (unique constraint on idx_sales_store_receipt_unique),
    // regenerate and retry up to 3 times before giving up.
    const maxRetries = 3;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await _db.transaction(() async {
          // [FIX: BUG 2] Generate receipt number INSIDE the transaction to prevent race conditions.
          // Two concurrent sales reading the same count outside the transaction would
          // produce duplicate receipt numbers. Inside, the unique index enforces correctness.
          receiptNo = await _generateReceiptNo(storeId);

          // Ensure cashier exists in local users table (FK requirement)
          if (cashierId.isNotEmpty) {
            final existingUser = await _db.usersDao.getUserById(cashierId);
            if (existingUser == null) {
              await _db.usersDao.ensureUser(UsersTableCompanion.insert(
                id: cashierId,
                storeId: Value(storeId),
                name: 'Cashier',
                role: const Value('cashier'),
                isActive: const Value(true),
                createdAt: now,
              ));
            }
          }

          // Validate customerId exists in DB (FK requirement)
          // walk-in or null = no customer linked
          validCustomerId = customerId;
          if (customerId != null && customerId != 'walk-in' && customerId.isNotEmpty) {
            final existingCustomer = await _db.customersDao.getCustomerById(customerId);
            if (existingCustomer == null) {
              if (kDebugMode) {
                debugPrint('[SaleService] Customer $customerId not found in DB, setting to null');
              }
              validCustomerId = null;
            }
          } else if (customerId == 'walk-in') {
            validCustomerId = null;
          }

          // 1. التحقق من توفر المخزون وتصحيح الأسعار (قراءة حية من قاعدة البيانات)
          final freshProducts = <String, ProductsTableData>{};
          correctedPrices = <String, double>{};
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

            // تصحيح السعر: إذا لم يحدد المستخدم سعراً مخصصاً والسعر تغير في قاعدة البيانات
            if (item.customPrice == null && product.price != item.effectivePrice) {
              correctedPrices[item.product.id] = product.price;
              priceCorrections.add(PriceCorrection(
                productId: item.product.id,
                productName: item.product.name,
                cartPrice: item.effectivePrice,
                dbPrice: product.price,
                quantity: item.quantity,
              ));
              if (kDebugMode) {
                debugPrint(
                  '[SaleService] Price correction: "${item.product.name}" '
                  'cart=${item.effectivePrice} -> db=${product.price} '
                  '(diff=${(product.price - item.effectivePrice).toStringAsFixed(2)})',
                );
              }
            }

            // تخطي المنتجات التي لا تتبع المخزون
            if (!product.trackInventory) continue;

            if (product.stockQty < item.quantity) {
              throw SaleException.insufficientStock(
                product.name,
                product.stockQty,
                item.quantity.toDouble(),
              );
            }
          }

          // إعادة حساب الإجمالي إذا تم تصحيح أي أسعار
          correctedSubtotal = subtotal;
          correctedTotal = total;
          correctedTax = tax;
          if (correctedPrices.isNotEmpty) {
            correctedSubtotal = 0;
            for (final item in items) {
              final unitPrice = correctedPrices[item.product.id] ?? item.effectivePrice;
              correctedSubtotal += unitPrice * item.quantity;
            }
            final taxRate = subtotal > 0 ? tax / subtotal : 0.15;
            correctedTax = correctedSubtotal * taxRate;
            correctedTotal = correctedSubtotal - discount + correctedTax;

            if (kDebugMode) {
              debugPrint(
                '[SaleService] Totals corrected: '
                'subtotal $subtotal -> $correctedSubtotal, '
                'tax $tax -> $correctedTax, '
                'total $total -> $correctedTotal',
              );
            }
          }

          // 2. Create sale record
          if (paymentMethod == 'credit') {
            isPaid = false;
          } else if (paymentMethod == 'mixed' && amountReceived != null && amountReceived < correctedTotal) {
            isPaid = false;
          } else {
            isPaid = true;
          }
          await _db.salesDao.insertSale(SalesTableCompanion.insert(
            id: saleId,
            storeId: storeId,
            receiptNo: receiptNo,
            cashierId: cashierId,
            customerId: Value(validCustomerId),
            customerName: Value(customerName),
            customerPhone: Value(customerPhone),
            subtotal: correctedSubtotal,
            discount: Value(discount),
            tax: Value(correctedTax),
            total: correctedTotal,
            paymentMethod: paymentMethod,
            amountReceived: Value(amountReceived),
            changeAmount: Value(changeAmount),
            cashAmount: Value(cashAmount),
            cardAmount: Value(cardAmount),
            creditAmount: Value(creditAmount),
            notes: Value(notes ?? ''),
            channel: const Value('POS'),
            status: const Value('completed'),
            isPaid: Value(isPaid),
            createdAt: now,
          ));

          // 3. جلب org_id من المتجر (نحتاجه لدلتا المخزون والدين)
          try {
            final store = await _db.storesDao.getStoreById(storeId);
            orgId = store?.orgId;
          } catch (_) {}

          // 4. إضافة عناصر البيع وخصم المخزون
          insertedItemIds = <String>[];
          for (final item in items) {
            final freshProduct = freshProducts[item.product.id]!;
            final unitPrice = correctedPrices[item.product.id] ?? item.effectivePrice;
            final itemId = _uuid.v4();
            insertedItemIds.add(itemId);
            await _db.saleItemsDao.insertItem(SaleItemsTableCompanion.insert(
              id: itemId,
              saleId: saleId,
              productId: item.product.id,
              productName: item.product.name,
              unitPrice: unitPrice,
              qty: item.quantity.toDouble(),
              subtotal: unitPrice * item.quantity,
              discount: const Value(0),
              total: unitPrice * item.quantity,
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

            // تسجيل دلتا المخزون (للمزامنة بين الأجهزة المتعددة)
            await _db.stockDeltasDao.addDelta(
              id: _uuid.v4(),
              productId: item.product.id,
              storeId: storeId,
              orgId: orgId,
              quantityChange: -item.quantity.toDouble(),
              deviceId: cashierId,
              operationType: 'sale',
              referenceId: saleId,
            );
          }

          // [FIX: BUG 1] 5. تسجيل الدين إذا كانت المبيعة تحتوي جزء آجل (credit)
          // تسجيل الدين جزء من المعاملة — إذا فشل، يُلغى البيع بالكامل
          // لأن بيع آجل بدون تسجيل دين = خسارة مالية صامتة
          if (!isPaid && validCustomerId != null) {
            final debtAmount = paymentMethod == 'credit'
                ? correctedTotal
                : correctedTotal - (amountReceived ?? 0);

            if (debtAmount > 0) {
              var account = await _db.accountsDao.getCustomerAccount(validCustomerId!, storeId);

              if (account == null) {
                final accountId = _uuid.v4();
                await _db.accountsDao.insertAccount(AccountsTableCompanion.insert(
                  id: accountId,
                  storeId: storeId,
                  orgId: Value(orgId),
                  type: 'receivable',
                  customerId: Value(validCustomerId),
                  name: customerName ?? 'عميل',
                  phone: Value(customerPhone),
                  balance: Value(debtAmount),
                  createdAt: now,
                ));
                await _db.transactionsDao.recordInvoice(
                  id: _uuid.v4(),
                  storeId: storeId,
                  accountId: accountId,
                  amount: debtAmount,
                  balanceAfter: debtAmount,
                  saleId: saleId,
                  createdBy: cashierId,
                );
              } else {
                final newBalance = account.balance + debtAmount;
                await _db.accountsDao.addToBalance(account.id, debtAmount);
                await _db.transactionsDao.recordInvoice(
                  id: _uuid.v4(),
                  storeId: storeId,
                  accountId: account.id,
                  amount: debtAmount,
                  balanceAfter: newBalance,
                  saleId: saleId,
                  createdBy: cashierId,
                );
              }
              if (kDebugMode) {
                debugPrint('[SaleService] Recorded credit debt: $debtAmount for customer $validCustomerId');
              }
            }
          }
        });
        // Transaction committed successfully -- break out of retry loop
        break;
      } catch (e) {
        // [FIX: BUG 2] Check if this is a unique constraint violation on receipt_no (race condition).
        // The unique index idx_sales_store_receipt_unique catches concurrent duplicates.
        final errorStr = e.toString().toLowerCase();
        final isUniqueViolation = errorStr.contains('unique constraint failed') ||
            errorStr.contains('unique constraint') ||
            errorStr.contains('idx_sales_store_receipt_unique');
        if (isUniqueViolation && attempt < maxRetries - 1) {
          if (kDebugMode) {
            debugPrint('[SaleService] Receipt number collision (attempt ${attempt + 1}/$maxRetries), retrying...');
          }
          // Clear price corrections collected in the failed attempt to avoid duplicates on retry
          priceCorrections.clear();
          await Future.delayed(Duration(milliseconds: 50 * (attempt + 1)));
          continue;
        }
        // Not a receipt collision, or exhausted retries -- rethrow
        rethrow;
      }
    }

    // =========================================================================
    // [FIX: BUG 3] Sync enqueue: OUTSIDE the transaction.
    // If sync enqueue fails, the sale is still saved locally and will be picked
    // up by the next sync cycle (via getUnsyncedSales / repairMissingSaleItemsSync).
    // =========================================================================
    try {
      await _syncService.enqueueCreate(
        tableName: 'sales',
        recordId: saleId,
        data: {
          'id': saleId,
          'orgId': orgId,
          'storeId': storeId,
          'receiptNo': receiptNo,
          'cashierId': cashierId,
          'customerId': validCustomerId,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'subtotal': correctedSubtotal,
          'discount': discount,
          'tax': correctedTax,
          'total': correctedTotal,
          'paymentMethod': paymentMethod,
          'amountReceived': amountReceived,
          'changeAmount': changeAmount,
          'cashAmount': cashAmount,
          'cardAmount': cardAmount,
          'creditAmount': creditAmount,
          'notes': notes,
          'channel': 'POS',
          'status': 'completed',
          'isPaid': isPaid,
          'createdAt': now.toIso8601String(),
        },
        priority: SyncPriority.high,
      );

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final itemId = insertedItemIds[i];
        final unitPrice = correctedPrices[item.product.id] ?? item.effectivePrice;
        await _syncService.enqueueCreate(
          tableName: 'sale_items',
          recordId: itemId,
          data: {
            'id': itemId,
            'saleId': saleId,
            'productId': item.product.id,
            'productName': item.product.name,
            'unitPrice': unitPrice,
            'qty': item.quantity.toDouble(),
            'subtotal': unitPrice * item.quantity,
            'discount': 0,
            'total': unitPrice * item.quantity,
          },
          priority: SyncPriority.high,
        );
      }
    } catch (e) {
      // Sync enqueue failed -- sale is saved locally, next sync cycle will pick it up
      if (kDebugMode) {
        debugPrint('[SaleService] Sync enqueue failed (non-blocking, sale saved locally): $e');
      }
    }

    // إنشاء فاتورة تلقائية بعد إتمام البيع (لا تمنع البيع عند الفشل)
    if (_invoiceService != null) {
      try {
        final sale = await _db.salesDao.getSaleById(saleId);
        final saleItems = await _db.saleItemsDao.getItemsBySaleId(saleId);
        if (sale != null && saleItems.isNotEmpty) {
          await _invoiceService.createFromSale(
            sale: sale,
            items: saleItems,
          );
          if (kDebugMode) {
            debugPrint('[SaleService] Invoice created for sale $saleId');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SaleService] Invoice creation failed (non-blocking): $e');
        }
      }
    }

    return SaleResult(
      saleId: saleId,
      priceCorrections: priceCorrections,
    );
  }

  /// إلغاء بيع
  Future<void> voidSale(String saleId, {String? reason}) async {
    // Variables captured from inside the transaction, needed for sync enqueue after commit.
    late String storeId;
    late String cashierId;

    await _db.transaction(() async {
      final sale = await _db.salesDao.getSaleById(saleId);
      if (sale == null) throw SaleException.notFound(saleId);

      // التحقق من أن البيع ليس ملغياً مسبقاً
      if (sale.status == 'voided') {
        throw SaleException.alreadyVoided(saleId);
      }

      // Capture values needed for sync enqueue outside the transaction
      storeId = sale.storeId;
      cashierId = sale.cashierId;

      final items = await _db.saleItemsDao.getItemsBySaleId(saleId);

      // جلب org_id من المتجر (لدلتا المخزون)
      String? orgId;
      try {
        final store = await _db.storesDao.getStoreById(sale.storeId);
        orgId = store?.orgId;
      } catch (_) {}

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

      // تسجيل حركة المخزون ودلتا المخزون
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

          // تسجيل دلتا المخزون (موجب لاستعادة المخزون)
          await _db.stockDeltasDao.addDelta(
            id: _uuid.v4(),
            productId: item.productId,
            storeId: sale.storeId,
            orgId: orgId,
            quantityChange: item.qty,
            deviceId: sale.cashierId,
            operationType: 'void',
            referenceId: saleId,
          );
        }
      }
    });

    // =========================================================================
    // Sync enqueue: OUTSIDE the transaction.
    // If sync enqueue fails, the void is still saved locally and will be picked
    // up by the next sync cycle.
    // =========================================================================
    try {
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
    } catch (e) {
      // Sync enqueue failed -- void is saved locally, next sync cycle will pick it up
      if (kDebugMode) {
        debugPrint('[SaleService] voidSale sync enqueue failed (non-blocking, void saved locally): $e');
      }
    }
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

  /// إصلاح عناصر البيع المفقودة في طابور المزامنة
  /// يفحص المبيعات المحلية ويُدرج العناصر غير الموجودة في الطابور
  /// يعمل مرة واحدة عند بدء التشغيل لإصلاح البيانات التاريخية
  ///
  /// ملاحظة: كان هناك bug سابق حيث كانت المزامنة تستخدم UUIDs مختلفة عن الـ IDs المحلية.
  /// لذلك نتحقق عبر البحث في payload عن saleId بدلاً من الاعتماد على idempotency key.
  Future<int> repairMissingSaleItemsSync() async {
    int repairedCount = 0;
    try {
      // استعلام مباشر: جميع المبيعات المكتملة في آخر 7 أيام
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final salesRows = await _db.customSelect(
        "SELECT id FROM sales WHERE status = 'completed' AND deleted_at IS NULL AND created_at >= ?",
        variables: [Variable.withDateTime(sevenDaysAgo)],
      ).get();

      if (kDebugMode) {
        debugPrint('[SaleService] Repair: checking ${salesRows.length} recent sales for missing items sync');
      }

      for (final row in salesRows) {
        final saleId = row.data['id'] as String;

        // التحقق: هل يوجد أي عنصر sale_items في طابور المزامنة لهذا البيع؟
        // نبحث في payload عن saleId (يغطي الـ UUIDs القديمة والجديدة)
        final existingSyncEntries = await _db.customSelect(
          "SELECT COUNT(*) as cnt FROM sync_queue WHERE table_name = 'sale_items' AND payload LIKE ?",
          variables: [Variable.withString('%"saleId":"$saleId"%')],
        ).getSingle();

        final syncedItemsCount = existingSyncEntries.data['cnt'] as int? ?? 0;

        // الحصول على عناصر البيع المحلية
        final localItems = await _db.saleItemsDao.getItemsBySaleId(saleId);
        if (localItems.isEmpty) continue;

        // إذا عدد العناصر في طابور المزامنة يطابق العدد المحلي، لا نحتاج إصلاح
        if (syncedItemsCount >= localItems.length) {
          if (kDebugMode) {
            debugPrint('[SaleService] Sale $saleId: $syncedItemsCount sync entries for ${localItems.length} local items -- OK');
          }
          continue;
        }

        if (kDebugMode) {
          debugPrint('[SaleService] Sale $saleId: $syncedItemsCount sync entries for ${localItems.length} local items -- needs repair');
        }

        // إذا لم يكن هناك أي عناصر في طابور المزامنة لهذا البيع، نضيف الكل
        // إذا كان هناك بعضها (حالة نادرة)، نتخطى لتجنب التعقيد
        if (syncedItemsCount > 0) {
          if (kDebugMode) {
            debugPrint('[SaleService] Skipping partial repair for sale $saleId (has $syncedItemsCount/${ localItems.length})');
          }
          continue;
        }

        // لا يوجد أي عنصر — نضيف الكل
        for (final item in localItems) {
          try {
            await _syncService.enqueueCreate(
              tableName: 'sale_items',
              recordId: item.id,
              data: {
                'id': item.id,
                'saleId': item.saleId,
                'productId': item.productId,
                'productName': item.productName,
                'unitPrice': item.unitPrice,
                'qty': item.qty,
                'subtotal': item.subtotal,
                'discount': item.discount,
                'total': item.total,
              },
              priority: SyncPriority.high,
            );
            repairedCount++;
            if (kDebugMode) {
              debugPrint('[SaleService] Repaired: sale_items/${item.id} for sale $saleId');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[SaleService] Repair failed for item ${item.id}: $e');
            }
          }
        }
      }

      if (kDebugMode) {
        debugPrint('[SaleService] Repair complete: $repairedCount items added to sync queue');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SaleService] Repair failed: $e');
      }
    }

    return repairedCount;
  }

  /// إصلاح مبيعات عالقة في طابور المزامنة بسبب customer_id غير موجود
  /// يبحث عن مبيعات فاشلة ويحذف customer_id من الـ payload إذا كان غير صالح
  Future<int> repairFailedSalesSync() async {
    int repairedCount = 0;
    try {
      // البحث عن مبيعات فاشلة أو معلقة تحتوي على customerId في طابور المزامنة
      final salesInQueue = await _db.customSelect(
        "SELECT id, payload FROM sync_queue WHERE table_name = 'sales' AND (status = 'failed' OR status = 'pending') AND payload LIKE '%\"customerId\":\"%'",
      ).get();

      if (kDebugMode) {
        debugPrint('[SaleService] RepairSync: checking ${salesInQueue.length} sales with customerId in queue');
      }

      for (final row in salesInQueue) {
        final queueId = row.data['id'] as String;
        final payload = row.data['payload'] as String;

        // استخراج customerId من الـ payload (قيمة غير null)
        final customerIdMatch = RegExp(r'"customerId":"([^"]+)"').firstMatch(payload);
        if (customerIdMatch == null) continue;

        final customerId = customerIdMatch.group(1)!;

        if (kDebugMode) {
          debugPrint('[SaleService] Sale queue $queueId has customerId: $customerId -- removing to fix FK');
        }

        // إزالة customerId من الـ payload
        final fixedPayload = payload
            .replaceAll('"customerId":"$customerId"', '"customerId":null');

        // استخدام customUpdate (يعمل مع web/wasm على عكس customStatement)
        await _db.customUpdate(
          "UPDATE sync_queue SET payload = ?, status = 'pending', retry_count = 0, last_error = NULL WHERE id = ?",
          variables: [Variable.withString(fixedPayload), Variable.withString(queueId)],
          updates: {},
          updateKind: UpdateKind.update,
        );

        repairedCount++;
        if (kDebugMode) {
          debugPrint('[SaleService] Fixed sync payload for sale $queueId');
        }
      }

      if (kDebugMode) {
        debugPrint('[SaleService] RepairSync complete: $repairedCount sales fixed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SaleService] RepairSync failed: $e');
      }
    }
    return repairedCount;
  }
}
