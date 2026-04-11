/// Suppliers Providers - مزودات الموردين
///
/// توفر بيانات الموردين من قاعدة البيانات
library;

import 'package:alhai_auth/alhai_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'sync_providers.dart';

const _uuid = Uuid();

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// قائمة جميع الموردين
final suppliersListProvider =
    FutureProvider.autoDispose<List<SuppliersTableData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.suppliersDao.getAllSuppliers(storeId);
    });

/// الموردين النشطين فقط
final activeSuppliersProvider =
    FutureProvider.autoDispose<List<SuppliersTableData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.suppliersDao.getActiveSuppliers(storeId);
    });

/// تفاصيل مورد واحد
final supplierDetailProvider = FutureProvider.autoDispose
    .family<SuppliersTableData?, String>((ref, id) async {
      final db = GetIt.I<AppDatabase>();
      return db.suppliersDao.getSupplierById(id);
    });

/// بحث الموردين
final supplierSearchProvider = FutureProvider.autoDispose
    .family<List<SuppliersTableData>, String>((ref, query) async {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null || query.isEmpty) return [];
      final db = GetIt.I<AppDatabase>();
      return db.suppliersDao.searchSuppliers(query, storeId);
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
  final db = GetIt.I<AppDatabase>();
  final id = _uuid.v4();

  await db.suppliersDao.insertSupplier(
    SuppliersTableCompanion(
      id: Value(id),
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
    ),
  );

  // إضافة للطابور المحلي للمزامنة لاحقاً
  try {
    await ref
        .read(syncServiceProvider)
        .enqueueCreate(
          tableName: 'suppliers',
          recordId: id,
          data: {
            'id': id,
            'store_id': storeId,
            'name': name,
            'phone': phone,
            'email': email,
            'address': address,
            'city': city,
            'tax_number': taxNumber,
            'notes': notes,
            'is_active': true,
            'balance': 0.0,
          },
        );
  } catch (e) {
    debugPrint('فشل إضافة المورد لطابور المزامنة: $e');
  }

  ref.invalidate(suppliersListProvider);
  ref.invalidate(activeSuppliersProvider);
}

/// تحديث مورد موجود
Future<void> updateSupplier(
  WidgetRef ref, {
  required SuppliersTableData supplier,
}) async {
  final db = GetIt.I<AppDatabase>();
  await db.suppliersDao.updateSupplier(supplier);

  // إضافة عملية التحديث لطابور المزامنة
  try {
    await ref
        .read(syncServiceProvider)
        .enqueueUpdate(
          tableName: 'suppliers',
          recordId: supplier.id,
          changes: {
            'id': supplier.id,
            'name': supplier.name,
            'phone': supplier.phone,
            'email': supplier.email,
            'address': supplier.address,
            'tax_number': supplier.taxNumber,
            'notes': supplier.notes,
            'is_active': supplier.isActive,
            'balance': supplier.balance,
          },
        );
  } catch (e) {
    debugPrint('فشل إضافة تحديث المورد لطابور المزامنة: $e');
  }

  ref.invalidate(suppliersListProvider);
  ref.invalidate(activeSuppliersProvider);
  ref.invalidate(supplierDetailProvider(supplier.id));
}

/// حذف مورد
Future<void> deleteSupplier(WidgetRef ref, String id) async {
  final db = GetIt.I<AppDatabase>();
  await db.suppliersDao.deleteSupplier(id);

  // إضافة عملية الحذف لطابور المزامنة
  try {
    await ref
        .read(syncServiceProvider)
        .enqueueDelete(tableName: 'suppliers', recordId: id);
  } catch (e) {
    debugPrint('فشل إضافة حذف المورد لطابور المزامنة: $e');
  }

  ref.invalidate(suppliersListProvider);
  ref.invalidate(activeSuppliersProvider);
}
