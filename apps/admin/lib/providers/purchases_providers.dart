/// Purchases Providers - مزودات المشتريات
///
/// توفر بيانات المشتريات من قاعدة البيانات
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:get_it/get_it.dart';

const _uuid = Uuid();

// ============================================================================
// DATA MODELS
// ============================================================================

/// بيانات تفاصيل المشتريات
class PurchaseDetailData {
  final PurchasesTableData purchase;
  final List<PurchaseItemsTableData> items;

  const PurchaseDetailData({required this.purchase, required this.items});
}

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// قائمة جميع المشتريات (legacy - kept for backward compat)
final purchasesListProvider =
    FutureProvider.autoDispose<List<PurchasesTableData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.purchasesDao.getAllPurchases(storeId);
    });

/// المشتريات حسب الحالة (legacy - kept for backward compat)
final purchasesByStatusProvider = FutureProvider.autoDispose
    .family<List<PurchasesTableData>, String>((ref, status) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.purchasesDao.getPurchasesByStatus(storeId, status);
    });

// ============================================================================
// PAGINATED PROVIDERS
// ============================================================================

/// Parameter record for paginated queries
class PurchasesPageParams {
  final int page;
  final int pageSize;
  final String? status;

  const PurchasesPageParams({this.page = 1, this.pageSize = 20, this.status});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchasesPageParams &&
          page == other.page &&
          pageSize == other.pageSize &&
          status == other.status;

  @override
  int get hashCode => Object.hash(page, pageSize, status);
}

/// Result of a paginated purchases query
class PaginatedPurchases {
  final List<PurchasesTableData> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;

  const PaginatedPurchases({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });

  int get totalPages => (totalCount / pageSize).ceil().clamp(1, 999);
}

/// Paginated purchases provider (all statuses or filtered)
final paginatedPurchasesProvider = FutureProvider.autoDispose
    .family<PaginatedPurchases, PurchasesPageParams>((ref, params) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) {
        return const PaginatedPurchases(
          items: [],
          totalCount: 0,
          currentPage: 1,
          pageSize: 20,
        );
      }
      final db = GetIt.I<AppDatabase>();
      final offset = (params.page - 1) * params.pageSize;

      final results = await Future.wait([
        params.status == null
            ? db.purchasesDao.getPurchasesPaginated(
                storeId,
                offset: offset,
                limit: params.pageSize,
              )
            : db.purchasesDao.getPurchasesByStatusPaginated(
                storeId,
                params.status!,
                offset: offset,
                limit: params.pageSize,
              ),
        db.purchasesDao.getPurchasesCount(storeId, status: params.status),
      ]);

      return PaginatedPurchases(
        items: results[0] as List<PurchasesTableData>,
        totalCount: results[1] as int,
        currentPage: params.page,
        pageSize: params.pageSize,
      );
    });

/// تفاصيل مشتريات واحدة
final purchaseDetailProvider = FutureProvider.autoDispose
    .family<PurchaseDetailData?, String>((ref, id) async {
      final db = GetIt.I<AppDatabase>();
      final purchase = await db.purchasesDao.getPurchaseById(id);
      if (purchase == null) return null;
      final items = await db.purchasesDao.getPurchaseItems(id);
      return PurchaseDetailData(purchase: purchase, items: items);
    });

// ============================================================================
// ACTION HELPERS
// ============================================================================

/// إنشاء عملية شراء جديدة
Future<String> createPurchase(
  WidgetRef ref, {
  required String supplierId,
  required String supplierName,
  required double subtotal,
  required double tax,
  required double discount,
  required double total,
  String? notes,
  required List<PurchaseItemsTableCompanion> items,
}) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) throw Exception('لا يوجد متجر محدد');

  final db = GetIt.I<AppDatabase>();
  final id = _uuid.v4();
  final purchaseNumber = 'PO-${DateTime.now().millisecondsSinceEpoch}';

  await db.purchasesDao.insertPurchase(
    PurchasesTableCompanion(
      id: Value(id),
      storeId: Value(storeId),
      supplierId: Value(supplierId),
      supplierName: Value(supplierName),
      purchaseNumber: Value(purchaseNumber),
      status: const Value('draft'),
      subtotal: Value(subtotal),
      tax: Value(tax),
      discount: Value(discount),
      total: Value(total),
      notes: Value(notes),
      createdAt: Value(DateTime.now()),
    ),
  );

  if (items.isNotEmpty) {
    await db.purchasesDao.insertPurchaseItems(items);
  }

  try {
    await ref
        .read(syncServiceProvider)
        .enqueueCreate(
          tableName: 'purchases',
          recordId: id,
          data: {
            'id': id,
            'store_id': storeId,
            'supplier_id': supplierId,
            'supplier_name': supplierName,
            'purchase_number': purchaseNumber,
            'status': 'draft',
            'subtotal': subtotal,
            'tax': tax,
            'discount': discount,
            'total': total,
            'notes': notes,
          },
        );
  } catch (e) {
    debugPrint('فشل إضافة المشتريات لطابور المزامنة: $e');
  }

  ref.invalidate(purchasesListProvider);
  return id;
}

/// استلام المشتريات - تحديث حالة الشراء للمستلم
Future<void> receivePurchase(WidgetRef ref, String id) async {
  final db = GetIt.I<AppDatabase>();
  await db.purchasesDao.receivePurchase(id);

  try {
    await ref
        .read(syncServiceProvider)
        .enqueueUpdate(
          tableName: 'purchases',
          recordId: id,
          changes: {
            'id': id,
            'status': 'received',
            'received_at': DateTime.now().toIso8601String(),
          },
        );
  } catch (e) {
    debugPrint('فشل إضافة استلام المشتريات لطابور المزامنة: $e');
  }

  ref.invalidate(purchasesListProvider);
  ref.invalidate(purchaseDetailProvider(id));
}

/// إرسال طلب الشراء للموزع
Future<void> sendToDistributor(
  WidgetRef ref,
  String purchaseId, {
  String? supplierNotes,
}) async {
  final db = GetIt.I<AppDatabase>();
  await db.purchasesDao.updateStatus(purchaseId, 'sent');

  if (supplierNotes != null && supplierNotes.isNotEmpty) {
    final purchase = await db.purchasesDao.getPurchaseById(purchaseId);
    if (purchase != null) {
      final notesJson = '{"sentNotes":"$supplierNotes"}';
      await db.purchasesDao.updatePurchase(
        purchase.copyWith(notes: Value(notesJson)),
      );
    }
  }

  try {
    await ref
        .read(syncServiceProvider)
        .enqueueUpdate(
          tableName: 'purchases',
          recordId: purchaseId,
          changes: {
            'id': purchaseId,
            'status': 'sent',
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
  } catch (e) {
    debugPrint('فشل إضافة إرسال الطلب لطابور المزامنة: $e');
  }

  ref.invalidate(purchasesListProvider);
  ref.invalidate(purchaseDetailProvider(purchaseId));
}

/// استلام البضاعة مع تفاصيل كاملة
Future<void> receivePurchaseWithDetails(
  WidgetRef ref,
  String purchaseId, {
  required String receivedBy,
  required Map<String, int> receivedQuantities,
  String? receiveNotes,
}) async {
  final db = GetIt.I<AppDatabase>();

  // 1. تحديث حالة الشراء
  await db.purchasesDao.receivePurchase(purchaseId);

  // 2. تحديث الملاحظات بمعلومات المستلم
  final purchase = await db.purchasesDao.getPurchaseById(purchaseId);
  if (purchase != null) {
    final notesJson =
        '{"receivedBy":"$receivedBy","receiveNotes":"${receiveNotes ?? ''}","receivedDate":"${DateTime.now().toIso8601String()}"}';
    await db.purchasesDao.updatePurchase(
      purchase.copyWith(notes: Value(notesJson)),
    );
  }

  // 3. تحديث المخزون لكل بند
  final items = await db.purchasesDao.getPurchaseItems(purchaseId);
  final storeId = ref.read(currentStoreIdProvider);

  for (final item in items) {
    final receivedQty = receivedQuantities[item.id] ?? item.qty;
    final product = await db.productsDao.getProductById(item.productId);
    if (product != null) {
      final newStock = product.stockQty + receivedQty;
      await db.productsDao.updateStock(item.productId, newStock.toDouble());

      // تسجيل حركة المخزون
      if (storeId != null) {
        await db.inventoryDao.recordPurchaseMovement(
          id: _uuid.v4(),
          productId: item.productId,
          storeId: storeId,
          qty: receivedQty.toDouble(),
          previousQty: product.stockQty.toDouble(),
          purchaseId: purchaseId,
        );
      }
    }
  }

  // 4. مزامنة
  try {
    await ref
        .read(syncServiceProvider)
        .enqueueUpdate(
          tableName: 'purchases',
          recordId: purchaseId,
          changes: {
            'id': purchaseId,
            'status': 'received',
            'received_at': DateTime.now().toIso8601String(),
          },
        );
  } catch (e) {
    debugPrint('فشل إضافة استلام المشتريات لطابور المزامنة: $e');
  }

  ref.invalidate(purchasesListProvider);
  ref.invalidate(purchaseDetailProvider(purchaseId));
}
