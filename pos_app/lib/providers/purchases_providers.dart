/// Purchases Providers - مزودات المشتريات
///
/// توفر بيانات المشتريات من قاعدة البيانات
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/local/app_database.dart';
import '../di/injection.dart';
import 'products_providers.dart';

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

/// قائمة جميع المشتريات
final purchasesListProvider =
    FutureProvider.autoDispose<List<PurchasesTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.purchasesDao.getAllPurchases(storeId);
});

/// المشتريات حسب الحالة
final purchasesByStatusProvider = FutureProvider.autoDispose
    .family<List<PurchasesTableData>, String>((ref, status) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.purchasesDao.getPurchasesByStatus(storeId, status);
});

/// تفاصيل مشتريات واحدة
final purchaseDetailProvider = FutureProvider.autoDispose
    .family<PurchaseDetailData?, String>((ref, id) async {
  final db = getIt<AppDatabase>();
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

  final db = getIt<AppDatabase>();
  final id = _uuid.v4();
  final purchaseNumber = 'PO-${DateTime.now().millisecondsSinceEpoch}';

  await db.purchasesDao.insertPurchase(PurchasesTableCompanion(
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
  ));

  if (items.isNotEmpty) {
    await db.purchasesDao.insertPurchaseItems(items);
  }

  ref.invalidate(purchasesListProvider);
  return id;
}

/// استلام المشتريات
Future<void> receivePurchase(WidgetRef ref, String id) async {
  final db = getIt<AppDatabase>();
  await db.purchasesDao.receivePurchase(id);
  ref.invalidate(purchasesListProvider);
  ref.invalidate(purchaseDetailProvider(id));
}
