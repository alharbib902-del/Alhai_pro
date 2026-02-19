/// Suppliers Providers - مزودات الموردين
///
/// توفر بيانات الموردين من قاعدة البيانات
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/local/app_database.dart';
import '../di/injection.dart';
import 'products_providers.dart';

const _uuid = Uuid();

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// قائمة جميع الموردين
final suppliersListProvider =
    FutureProvider.autoDispose<List<SuppliersTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.suppliersDao.getAllSuppliers(storeId);
});

/// الموردين النشطين فقط
final activeSuppliersProvider =
    FutureProvider.autoDispose<List<SuppliersTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.suppliersDao.getActiveSuppliers(storeId);
});

/// تفاصيل مورد واحد
final supplierDetailProvider = FutureProvider.autoDispose
    .family<SuppliersTableData?, String>((ref, id) async {
  final db = getIt<AppDatabase>();
  return db.suppliersDao.getSupplierById(id);
});

/// بحث الموردين
final supplierSearchProvider = FutureProvider.autoDispose
    .family<List<SuppliersTableData>, String>((ref, query) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null || query.isEmpty) return [];
  final db = getIt<AppDatabase>();
  return db.suppliersDao.searchSuppliers(storeId, query);
});

// ============================================================================
// ACTION HELPERS
// ============================================================================

/// إضافة مورد جديد
Future<void> addSupplier(
  WidgetRef ref, {
  required String name,
  String? phone,
  String? email,
  String? address,
  String? city,
  String? taxNumber,
  String? notes,
}) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) return;
  final db = getIt<AppDatabase>();
  await db.suppliersDao.insertSupplier(SuppliersTableCompanion(
    id: Value(_uuid.v4()),
    storeId: Value(storeId),
    name: Value(name),
    phone: Value(phone),
    email: Value(email),
    address: Value(address),
    city: Value(city),
    taxNumber: Value(taxNumber),
    notes: Value(notes),
    isActive: const Value(true),
    balance: const Value(0.0),
    createdAt: Value(DateTime.now()),
  ));
  ref.invalidate(suppliersListProvider);
  ref.invalidate(activeSuppliersProvider);
}

/// حذف مورد
Future<void> deleteSupplier(WidgetRef ref, String id) async {
  final db = getIt<AppDatabase>();
  await db.suppliersDao.deleteSupplier(id);
  ref.invalidate(suppliersListProvider);
  ref.invalidate(activeSuppliersProvider);
}
