import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart'
    show TextInputSanitizer;

import '../core/errors/app_exceptions.dart';
import 'package:alhai_database/alhai_database.dart';
import '../providers/cart_providers.dart';
import 'package:alhai_sync/alhai_sync.dart';

import 'invoice_service.dart';
import 'terminal_suffix_service.dart';

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

  const SaleResult({required this.saleId, this.priceCorrections = const []});

  bool get hadPriceCorrections => priceCorrections.isNotEmpty;
}

/// خدمة المبيعات
/// تدير إنشاء المبيعات وخصم المخزون مع دعم offline
class SaleService {
  final AppDatabase _db;
  final SyncService _syncService;
  final InvoiceService? _invoiceService;

  /// Optional clock offset callback. When provided, returns the measured
  /// difference (device - server). Used to generate ZATCA-compliant timestamps.
  /// If null or returns Duration.zero, `DateTime.now()` is used as-is.
  final Duration Function()? _clockOffsetProvider;

  /// C-1: per-device 4-hex-char suffix injected into the receipt number
  /// to prevent cross-device offline collisions. Falls back to a
  /// freshly-constructed service when not supplied (production) or when
  /// a test doesn't care about the suffix value.
  final TerminalSuffixService _terminalSuffix;

  static const _uuid = Uuid();

  SaleService({
    required AppDatabase db,
    required SyncService syncService,
    InvoiceService? invoiceService,
    Duration Function()? clockOffsetProvider,
    TerminalSuffixService? terminalSuffix,
  }) : _db = db,
       _syncService = syncService,
       _invoiceService = invoiceService,
       _clockOffsetProvider = clockOffsetProvider,
       _terminalSuffix = terminalSuffix ?? TerminalSuffixService();

  /// Get a corrected timestamp that accounts for device clock drift.
  /// ZATCA requires accurate timestamps; this uses the server-measured offset.
  DateTime _correctedNow() {
    final offset = _clockOffsetProvider?.call() ?? Duration.zero;
    return DateTime.now().subtract(offset);
  }

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
    String? shiftId,
  }) async {
    final saleId = _uuid.v4();
    // Use corrected time for ZATCA-compliant timestamps
    final now = _correctedNow();
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
    // Per-item snapshot captured inside the transaction so the post-commit
    // sync block can enqueue one inventory_movements row per sale item.
    // Bug-B-shape fix (Session 50 audit): inventory_movements is in
    // pushTables, but recordSaleMovement was never enqueued → server-side
    // inventory reports showed 0 POS activity.
    late List<
      ({String id, String productId, double previousQty, double qty})
    >
    insertedInventoryMovements;
    late Map<String, double> correctedPrices;

    // Fetch org_id BEFORE the transaction so the local sales row and the
    // downstream invoice (which reads sale.orgId from Drift) have a non-null
    // org_id. Required for the invoices RLS policy, which gates INSERT on
    //   org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid())
    // and silently denies NULL. Fetched outside the retry loop — org_id is
    // tied to storeId and does not change across receipt-collision retries.
    try {
      final store = await _db.storesDao.getStoreById(storeId);
      orgId = store?.orgId;
    } catch (e) {
      debugPrint('[SaleService] orgId fetch failed: $e');
    }

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
              await _db.usersDao.ensureUser(
                UsersTableCompanion.insert(
                  id: cashierId,
                  storeId: Value(storeId),
                  name: 'Cashier',
                  role: const Value('cashier'),
                  isActive: const Value(true),
                  createdAt: now,
                ),
              );
            }
          }

          // Validate customerId exists in DB (FK requirement)
          // walk-in or null = no customer linked
          validCustomerId = customerId;
          if (customerId != null &&
              customerId != 'walk-in' &&
              customerId.isNotEmpty) {
            final existingCustomer = await _db.customersDao.getCustomerById(
              customerId,
            );
            if (existingCustomer == null) {
              if (kDebugMode) {
                debugPrint(
                  '[SaleService] Customer $customerId not found in DB, setting to null',
                );
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
            final product = await _db.productsDao.getProductById(
              item.product.id,
            );
            if (product == null) {
              throw SaleException(
                message: 'Product not found in DB: ${item.product.id}',
                userMessage:
                    'المنتج "${item.product.name}" غير موجود في قاعدة البيانات',
                code: 'PRODUCT_NOT_FOUND',
              );
            }
            freshProducts[item.product.id] = product;

            // تصحيح السعر: إذا لم يحدد المستخدم سعراً مخصصاً والسعر تغير في قاعدة البيانات
            // C-4 Stage B: product.price is int cents; cart math in double SAR.
            final dbPriceSar = product.price / 100.0;
            if (item.customPrice == null &&
                dbPriceSar != item.effectivePrice) {
              correctedPrices[item.product.id] = dbPriceSar;
              priceCorrections.add(
                PriceCorrection(
                  productId: item.product.id,
                  productName: item.product.name,
                  cartPrice: item.effectivePrice,
                  dbPrice: dbPriceSar,
                  quantity: item.quantity,
                ),
              );
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
              final unitPrice =
                  correctedPrices[item.product.id] ?? item.effectivePrice;
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
          } else if (paymentMethod == 'mixed' &&
              amountReceived != null &&
              amountReceived < correctedTotal) {
            isPaid = false;
          } else {
            isPaid = true;
          }
          await _db.salesDao.insertSale(
            SalesTableCompanion.insert(
              id: saleId,
              orgId: Value(orgId),
              storeId: storeId,
              receiptNo: receiptNo,
              cashierId: cashierId,
              shiftId: Value(shiftId),
              customerId: Value(validCustomerId),
              customerName: Value(customerName),
              customerPhone: Value(customerPhone),
              // C-4 Session 3: sales money columns are int cents. Caller
              // still passes SAR doubles; convert at the Drift boundary.
              subtotal: (correctedSubtotal * 100).round(),
              discount: Value((discount * 100).round()),
              tax: Value((correctedTax * 100).round()),
              total: (correctedTotal * 100).round(),
              paymentMethod: paymentMethod,
              amountReceived: Value(
                amountReceived == null
                    ? null
                    : (amountReceived * 100).round(),
              ),
              changeAmount: Value(
                changeAmount == null ? null : (changeAmount * 100).round(),
              ),
              cashAmount: Value(
                cashAmount == null ? null : (cashAmount * 100).round(),
              ),
              cardAmount: Value(
                cardAmount == null ? null : (cardAmount * 100).round(),
              ),
              creditAmount: Value(
                creditAmount == null ? null : (creditAmount * 100).round(),
              ),
              notes: Value(notes ?? ''),
              channel: const Value('POS'),
              status: const Value('completed'),
              isPaid: Value(isPaid),
              createdAt: now,
            ),
          );

          // 3. إضافة عناصر البيع وخصم المخزون
          // (org_id was fetched before the transaction — see top of createSale)
          insertedItemIds = <String>[];
          insertedInventoryMovements = <
            ({String id, String productId, double previousQty, double qty})
          >[];
          for (final item in items) {
            final freshProduct = freshProducts[item.product.id]!;
            final unitPrice =
                correctedPrices[item.product.id] ?? item.effectivePrice;
            final itemId = _uuid.v4();
            insertedItemIds.add(itemId);
            await _db.saleItemsDao.insertItem(
              SaleItemsTableCompanion.insert(
                id: itemId,
                saleId: saleId,
                productId: item.product.id,
                productName: item.product.name,
                unitPrice: (unitPrice * 100).round(),
                qty: item.quantity.toDouble(),
                subtotal: (unitPrice * item.quantity * 100).round(),
                discount: const Value(0),
                total: (unitPrice * item.quantity * 100).round(),
              ),
            );

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
            insertedInventoryMovements.add((
              id: movementId,
              productId: item.product.id,
              previousQty: freshProduct.stockQty.toDouble(),
              qty: item.quantity.toDouble(),
            ));

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

          // [FIX: BUG 1] 4. تسجيل الدين إذا كانت المبيعة تحتوي جزء آجل (credit)
          // تسجيل الدين جزء من المعاملة — إذا فشل، يُلغى البيع بالكامل
          // لأن بيع آجل بدون تسجيل دين = خسارة مالية صامتة
          if (!isPaid && validCustomerId != null) {
            final debtAmount = paymentMethod == 'credit'
                ? correctedTotal
                : correctedTotal - (amountReceived ?? 0);

            if (debtAmount > 0) {
              var account = await _db.accountsDao.getCustomerAccount(
                validCustomerId!,
                storeId,
              );

              if (account == null) {
                final accountId = _uuid.v4();
                // Sanitize name/phone at write boundary — upstream callers
                // may pass raw UI text (bidi overrides, zero-width chars).
                final safeName = TextInputSanitizer.sanitizeName(
                  customerName ?? 'عميل',
                );
                final safePhone = TextInputSanitizer.sanitizePhone(
                  customerPhone,
                );
                await _db.accountsDao.insertAccount(
                  AccountsTableCompanion.insert(
                    id: accountId,
                    storeId: storeId,
                    orgId: Value(orgId),
                    type: 'receivable',
                    customerId: Value(validCustomerId),
                    name: safeName.isEmpty ? 'عميل' : safeName,
                    phone: Value(safePhone.isEmpty ? null : safePhone),
                    // C-4 Session 4: accounts.balance is int cents.
                    balance: Value((debtAmount * 100).round()),
                    createdAt: now,
                  ),
                );
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
                // C-4 Session 4: accounts.balance is int cents.
                // debtAmount & newBalance are SAR doubles (DAO handles ×100 conversion).
                final newBalance = account.balance / 100.0 + debtAmount;
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
                debugPrint(
                  '[SaleService] Recorded credit debt: $debtAmount for customer $validCustomerId',
                );
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
        final isUniqueViolation =
            errorStr.contains('unique constraint failed') ||
            errorStr.contains('unique constraint') ||
            errorStr.contains('idx_sales_store_receipt_unique');
        if (isUniqueViolation && attempt < maxRetries - 1) {
          if (kDebugMode) {
            debugPrint(
              '[SaleService] Receipt number collision (attempt ${attempt + 1}/$maxRetries), retrying...',
            );
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
      // C-4 §4h (Session 53): Supabase sales + sale_items money columns are
      // INTEGER (cents) — confirmed by column-type audit 2026-04-25. Caller
      // variables below are still SAR doubles (POS cart math runs in SAR);
      // convert to cents at the wire boundary so Postgres doesn't reject
      // the INSERT for invalid-integer-syntax on a fractional value.
      await _syncService.enqueueCreate(
        tableName: 'sales',
        recordId: saleId,
        data: {
          'id': saleId,
          'orgId': orgId,
          'storeId': storeId,
          'receiptNo': receiptNo,
          'cashierId': cashierId,
          'shiftId': shiftId,
          'customerId': validCustomerId,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'subtotal': (correctedSubtotal * 100).round(),
          'discount': (discount * 100).round(),
          'tax': (correctedTax * 100).round(),
          'total': (correctedTotal * 100).round(),
          'paymentMethod': paymentMethod,
          'amountReceived':
              amountReceived == null ? null : (amountReceived * 100).round(),
          'changeAmount':
              changeAmount == null ? null : (changeAmount * 100).round(),
          'cashAmount':
              cashAmount == null ? null : (cashAmount * 100).round(),
          'cardAmount':
              cardAmount == null ? null : (cardAmount * 100).round(),
          'creditAmount':
              creditAmount == null ? null : (creditAmount * 100).round(),
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
        final unitPrice =
            correctedPrices[item.product.id] ?? item.effectivePrice;
        final unitPriceCents = (unitPrice * 100).round();
        final lineTotalCents =
            (unitPrice * item.quantity * 100).round();
        await _syncService.enqueueCreate(
          tableName: 'sale_items',
          recordId: itemId,
          data: {
            'id': itemId,
            'saleId': saleId,
            'productId': item.product.id,
            'productName': item.product.name,
            'unitPrice': unitPriceCents,
            'qty': item.quantity.toDouble(),
            'subtotal': lineTotalCents,
            'discount': 0,
            'total': lineTotalCents,
          },
          priority: SyncPriority.high,
        );
      }

      // Bug-B-shape fix (Session 50 audit) — enqueue inventory_movements
      // alongside sales + sale_items. Matches the Drift row written by
      // InventoryDao.recordSaleMovement inside the transaction:
      //   type='sale', qty=-quantity, referenceType='sale', referenceId=saleId
      for (final m in insertedInventoryMovements) {
        await _syncService.enqueueCreate(
          tableName: 'inventory_movements',
          recordId: m.id,
          data: {
            'id': m.id,
            'productId': m.productId,
            'storeId': storeId,
            'type': 'sale',
            'qty': -m.qty,
            'previousQty': m.previousQty,
            'newQty': m.previousQty - m.qty,
            'referenceType': 'sale',
            'referenceId': saleId,
            'userId': cashierId,
            'createdAt': now.toIso8601String(),
          },
          priority: SyncPriority.high,
        );
      }
    } catch (e) {
      // Sync enqueue failed -- sale is saved locally, next sync cycle will pick it up
      if (kDebugMode) {
        debugPrint(
          '[SaleService] Sync enqueue failed (non-blocking, sale saved locally): $e',
        );
      }
    }

    // إنشاء فاتورة تلقائية بعد إتمام البيع.
    // القاعدة: فشل البنية التحتية (شبكة/قاعدة/تصادم رقم فاتورة) = غير
    // حاجب — البيع يكتمل والفاتورة تُعاد لاحقاً. أما فشل توافق ZATCA
    // (QR لا يمكن توليده لمتجر بمعطيات غير صالحة) فهو حاجب لأن
    // الفاتورة بدون QR مخالفة قانونية ولا يصح تمرير المعاملة بصمت.
    if (_invoiceService != null) {
      try {
        final sale = await _db.salesDao.getSaleById(saleId);
        final saleItems = await _db.saleItemsDao.getItemsBySaleId(saleId);
        if (sale != null && saleItems.isNotEmpty) {
          await _invoiceService.createFromSale(sale: sale, items: saleItems);
          if (kDebugMode) {
            debugPrint('[SaleService] Invoice created for sale $saleId');
          }
        }
      } on ZatcaComplianceException {
        // لا نبتلع — أعد الرفع ليستقبله مسار POS ويُظهِر للمستخدم حواراً
        // واضحاً (إعدادات ZATCA للمتجر ناقصة / VAT غير صالح / اسم بائع
        // طويل جداً) بدل إتمام بيع بفاتورة معطوبة.
        rethrow;
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[SaleService] Invoice creation failed (non-blocking): $e',
          );
        }
      }
    }

    return SaleResult(saleId: saleId, priceCorrections: priceCorrections);
  }

  /// إلغاء بيع
  Future<void> voidSale(String saleId, {String? reason}) async {
    final sale = await _db.salesDao.getSaleById(saleId);
    if (sale == null) throw SaleException.notFound(saleId);

    // التحقق من أن البيع ليس ملغياً مسبقاً
    if (sale.status == 'voided') {
      throw SaleException.alreadyVoided(saleId);
    }

    // إلغاء البيع (يستعيد المخزون + يسجل حركات المخزون ودلتا المزامنة تلقائياً)
    await _db.salesDao.voidSale(saleId);

    // =========================================================================
    // Sync enqueue: OUTSIDE the transaction.
    // If sync enqueue fails, the void is still saved locally and will be picked
    // up by the next sync cycle.
    // =========================================================================
    try {
      await _syncService.enqueueUpdate(
        tableName: 'sales',
        recordId: saleId,
        changes: {'id': saleId, 'status': 'voided', 'reason': reason},
        priority: SyncPriority.high,
      );
    } catch (e) {
      // Sync enqueue failed -- void is saved locally, next sync cycle will pick it up
      if (kDebugMode) {
        debugPrint(
          '[SaleService] voidSale sync enqueue failed (non-blocking, void saved locally): $e',
        );
      }
    }
  }

  /// توليد رقم إيصال فريد
  ///
  /// **Format (C-1):** `POS-YYYYMMDD-<deviceSuffix>-NNNN` where
  /// `deviceSuffix` is a stable 4-hex-char per-device value from
  /// [TerminalSuffixService]. The suffix breaks multi-device offline
  /// collisions on the Supabase `idx_sales_store_receipt_unique` index —
  /// even if two devices each see their own `todayCount == 5`, their
  /// receipts land as `POS-20260423-A3F7-0006` and `POS-20260423-B2C8-0006`
  /// and never collide.
  ///
  /// Sales created before the C-1 fix have the legacy format
  /// `POS-YYYYMMDD-NNNN` — they continue to work (consumers treat the
  /// column as an opaque string).
  Future<String> _generateReceiptNo(String storeId) async {
    final today = DateTime.now();
    final prefix =
        'POS-${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    final suffix = await _terminalSuffix.getSuffix();

    // استخدام getTodayStoreCount بدلاً من getTodayCount
    // لإحصاء جميع مبيعات المتجر بغض النظر عن الكاشير
    final todayCount = await _db.salesDao.getTodayStoreCount(storeId);
    final sequence = (todayCount + 1).toString().padLeft(4, '0');

    return '$prefix-$suffix-$sequence';
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
      final salesRows = await _db
          .customSelect(
            "SELECT id FROM sales WHERE status = 'completed' AND deleted_at IS NULL AND created_at >= ?",
            variables: [Variable.withDateTime(sevenDaysAgo)],
          )
          .get();

      if (kDebugMode) {
        debugPrint(
          '[SaleService] Repair: checking ${salesRows.length} recent sales for missing items sync',
        );
      }

      for (final row in salesRows) {
        final saleId = row.data['id'] as String;

        // التحقق: هل يوجد أي عنصر sale_items في طابور المزامنة لهذا البيع؟
        // نبحث في payload عن saleId (يغطي الـ UUIDs القديمة والجديدة)
        final existingSyncEntries = await _db
            .customSelect(
              "SELECT COUNT(*) as cnt FROM sync_queue WHERE table_name = 'sale_items' AND payload LIKE ?",
              variables: [Variable.withString('%"saleId":"$saleId"%')],
            )
            .getSingle();

        final syncedItemsCount = existingSyncEntries.data['cnt'] as int? ?? 0;

        // الحصول على عناصر البيع المحلية
        final localItems = await _db.saleItemsDao.getItemsBySaleId(saleId);
        if (localItems.isEmpty) continue;

        // إذا عدد العناصر في طابور المزامنة يطابق العدد المحلي، لا نحتاج إصلاح
        if (syncedItemsCount >= localItems.length) {
          if (kDebugMode) {
            debugPrint(
              '[SaleService] Sale $saleId: $syncedItemsCount sync entries for ${localItems.length} local items -- OK',
            );
          }
          continue;
        }

        if (kDebugMode) {
          debugPrint(
            '[SaleService] Sale $saleId: $syncedItemsCount sync entries for ${localItems.length} local items -- needs repair',
          );
        }

        // إذا لم يكن هناك أي عناصر في طابور المزامنة لهذا البيع، نضيف الكل
        // إذا كان هناك بعضها (حالة نادرة)، نتخطى لتجنب التعقيد
        if (syncedItemsCount > 0) {
          if (kDebugMode) {
            debugPrint(
              '[SaleService] Skipping partial repair for sale $saleId (has $syncedItemsCount/${localItems.length})',
            );
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
              debugPrint(
                '[SaleService] Repaired: sale_items/${item.id} for sale $saleId',
              );
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[SaleService] Repair failed for item ${item.id}: $e');
            }
          }
        }
      }

      if (kDebugMode) {
        debugPrint(
          '[SaleService] Repair complete: $repairedCount items added to sync queue',
        );
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
      final salesInQueue = await _db
          .customSelect(
            "SELECT id, payload FROM sync_queue WHERE table_name = 'sales' AND (status = 'failed' OR status = 'pending') AND payload LIKE '%\"customerId\":\"%'",
          )
          .get();

      if (kDebugMode) {
        debugPrint(
          '[SaleService] RepairSync: checking ${salesInQueue.length} sales with customerId in queue',
        );
      }

      for (final row in salesInQueue) {
        final queueId = row.data['id'] as String;
        final payload = row.data['payload'] as String;

        // استخراج customerId من الـ payload (قيمة غير null)
        final customerIdMatch = RegExp(
          r'"customerId":"([^"]+)"',
        ).firstMatch(payload);
        if (customerIdMatch == null) continue;

        final customerId = customerIdMatch.group(1)!;

        if (kDebugMode) {
          debugPrint(
            '[SaleService] Sale queue $queueId has customerId: $customerId -- removing to fix FK',
          );
        }

        // إزالة customerId من الـ payload
        final fixedPayload = payload.replaceAll(
          '"customerId":"$customerId"',
          '"customerId":null',
        );

        // استخدام customUpdate (يعمل مع web/wasm على عكس customStatement)
        await _db.customUpdate(
          "UPDATE sync_queue SET payload = ?, status = 'pending', retry_count = 0, last_error = NULL WHERE id = ?",
          variables: [
            Variable.withString(fixedPayload),
            Variable.withString(queueId),
          ],
          updates: {},
          updateKind: UpdateKind.update,
        );

        repairedCount++;
        if (kDebugMode) {
          debugPrint('[SaleService] Fixed sync payload for sale $queueId');
        }
      }

      if (kDebugMode) {
        debugPrint(
          '[SaleService] RepairSync complete: $repairedCount sales fixed',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SaleService] RepairSync failed: $e');
      }
    }
    return repairedCount;
  }
}
