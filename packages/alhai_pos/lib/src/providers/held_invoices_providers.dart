/// مزودات الفواتير المعلقة - Held Invoices Providers
///
/// توفر بيانات الفواتير المعلقة من قاعدة البيانات المحلية (Drift)
/// بدلاً من الذاكرة المؤقتة (SharedPreferences)
/// مع دعم المزامنة عبر SyncQueue
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'cart_providers.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

const _uuid = Uuid();

// ============================================================================
// قائمة الفواتير المعلقة من قاعدة البيانات
// ============================================================================

/// مزود قائمة الفواتير المعلقة من DB
/// يحوّل بيانات الجدول إلى نموذج HeldInvoice المستخدم في الواجهة
final dbHeldInvoicesListProvider =
    FutureProvider.autoDispose<List<HeldInvoice>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();

  // جلب الفواتير المعلقة من قاعدة البيانات
  final rows = await (db.select(db.heldInvoicesTable)
        ..where((h) => h.storeId.equals(storeId))
        ..orderBy([(h) => OrderingTerm.desc(h.createdAt)]))
      .get();

  // تحويل كل صف إلى نموذج HeldInvoice
  final results = <HeldInvoice>[];
  for (final row in rows) {
    try {
      final invoice = _rowToHeldInvoice(row);
      results.add(invoice);
    } catch (e) {
      debugPrint('[HeldInvoicesDB] خطأ في تحويل الفاتورة ${row.id}: $e');
    }
  }

  return results;
});

/// مزود عدد الفواتير المعلقة من DB
final dbHeldInvoicesCountProvider = Provider.autoDispose<int>((ref) {
  final invoicesAsync = ref.watch(dbHeldInvoicesListProvider);
  return invoicesAsync.maybeWhen(
    data: (invoices) => invoices.length,
    orElse: () => 0,
  );
});

// ============================================================================
// عمليات الفواتير المعلقة (حفظ / استعادة / حذف)
// ============================================================================

/// تعليق الفاتورة الحالية وحفظها في قاعدة البيانات
Future<HeldInvoice> holdCurrentInvoice(
  WidgetRef ref, {
  String? name,
}) async {
  final cart = ref.read(cartStateProvider);
  final storeId = ref.read(currentStoreIdProvider) ?? '';
  final db = GetIt.I<AppDatabase>();

  final id = _uuid.v4();
  final now = DateTime.now();

  // تحويل عناصر السلة إلى JSON
  final itemsJson = jsonEncode(cart.items.map((item) => item.toJson()).toList());

  // حفظ في قاعدة البيانات
  await db.into(db.heldInvoicesTable).insert(
        HeldInvoicesTableCompanion.insert(
          id: id,
          storeId: storeId,
          cashierId: '', // سيتم تعيينه من المستخدم الحالي لاحقاً
          customerName: Value(cart.customerName),
          items: itemsJson,
          subtotal: Value(cart.subtotal),
          discount: Value(cart.discount),
          total: Value(cart.total),
          notes: Value(name),
          createdAt: now,
        ),
      );

  // إضافة للمزامنة
  await _enqueueSyncCreate(ref, id, {
    'id': id,
    'store_id': storeId,
    'cashier_id': '',
    'customer_name': cart.customerName,
    'items': itemsJson,
    'subtotal': cart.subtotal,
    'discount': cart.discount,
    'total': cart.total,
    'notes': name,
    'created_at': now.toIso8601String(),
  });

  // تفريغ السلة
  ref.read(cartStateProvider.notifier).clear();

  // تحديث قائمة الفواتير المعلقة
  ref.invalidate(dbHeldInvoicesListProvider);

  // بناء نموذج HeldInvoice
  return HeldInvoice(
    id: id,
    cart: cart,
    name: name,
    createdAt: now,
  );
}

/// استعادة فاتورة معلقة إلى السلة
Future<void> resumeHeldInvoice(WidgetRef ref, HeldInvoice invoice) async {
  final cartNotifier = ref.read(cartStateProvider.notifier);
  final currentCart = ref.read(cartStateProvider);

  // إذا السلة الحالية غير فارغة، نعلقها أولاً
  if (currentCart.isNotEmpty) {
    await holdCurrentInvoice(ref, name: 'تلقائي - ${DateTime.now()}');
  }

  // استعادة الفاتورة إلى السلة
  cartNotifier.restoreFromCart(invoice.cart);

  // حذف الفاتورة من قاعدة البيانات
  await _deleteHeldInvoiceFromDb(ref, invoice.id);
}

/// حذف فاتورة معلقة
Future<void> deleteHeldInvoice(WidgetRef ref, String id) async {
  await _deleteHeldInvoiceFromDb(ref, id);
}

/// حذف جميع الفواتير المعلقة
Future<void> deleteAllHeldInvoices(WidgetRef ref) async {
  final storeId = ref.read(currentStoreIdProvider) ?? '';
  final db = GetIt.I<AppDatabase>();

  // جلب كل الفواتير للمزامنة
  final rows = await (db.select(db.heldInvoicesTable)
        ..where((h) => h.storeId.equals(storeId)))
      .get();

  // حذف الكل من قاعدة البيانات
  await (db.delete(db.heldInvoicesTable)
        ..where((h) => h.storeId.equals(storeId)))
      .go();

  // إضافة كل عملية حذف للمزامنة
  for (final row in rows) {
    await _enqueueSyncDelete(ref, row.id);
  }

  // تحديث قائمة الفواتير
  ref.invalidate(dbHeldInvoicesListProvider);
}

// ============================================================================
// HELPERS - تحويل البيانات
// ============================================================================

/// تحويل صف من قاعدة البيانات إلى نموذج HeldInvoice
HeldInvoice _rowToHeldInvoice(HeldInvoicesTableData row) {
  // فك JSON العناصر
  List<PosCartItem> cartItems = [];
  try {
    final itemsList = jsonDecode(row.items) as List<dynamic>;
    cartItems = itemsList
        .map((e) => PosCartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint('[HeldInvoicesDB] خطأ في فك JSON العناصر: $e');
  }

  // بناء CartState من بيانات الجدول
  final cart = CartState(
    items: cartItems,
    discount: row.discount,
    customerName: row.customerName,
  );

  return HeldInvoice(
    id: row.id,
    cart: cart,
    name: row.notes, // notes تُستخدم كاسم للفاتورة
    createdAt: row.createdAt,
  );
}

/// حذف فاتورة من قاعدة البيانات وإضافة للمزامنة
Future<void> _deleteHeldInvoiceFromDb(WidgetRef ref, String id) async {
  final db = GetIt.I<AppDatabase>();

  await (db.delete(db.heldInvoicesTable)..where((h) => h.id.equals(id))).go();

  // إضافة للمزامنة
  await _enqueueSyncDelete(ref, id);

  // تحديث قائمة الفواتير
  ref.invalidate(dbHeldInvoicesListProvider);
}

/// إضافة عملية إنشاء للمزامنة
Future<void> _enqueueSyncCreate(
    WidgetRef ref, String recordId, Map<String, dynamic> data) async {
  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueCreate(
      tableName: 'held_invoices',
      recordId: recordId,
      data: data,
    );
  } catch (e) {
    debugPrint('[HeldInvoicesDB] خطأ في إضافة المزامنة: $e');
  }
}

/// إضافة عملية حذف للمزامنة
Future<void> _enqueueSyncDelete(WidgetRef ref, String id) async {
  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueDelete(
      tableName: 'held_invoices',
      recordId: id,
    );
  } catch (e) {
    debugPrint('[HeldInvoicesDB] خطأ في إضافة المزامنة: $e');
  }
}
