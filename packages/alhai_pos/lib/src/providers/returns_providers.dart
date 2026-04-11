/// Returns Providers - مزودات المرتجعات
///
/// توفر بيانات المرتجعات من قاعدة البيانات
library;

import 'package:alhai_auth/alhai_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

const _uuid = Uuid();

// ============================================================================
// DATA MODELS
// ============================================================================

/// بيانات تفاصيل المرتجع
class ReturnDetailData {
  final ReturnsTableData returnData;
  final List<ReturnItemsTableData> items;

  const ReturnDetailData({required this.returnData, required this.items});
}

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// قائمة جميع المرتجعات
final returnsListProvider = FutureProvider.autoDispose<List<ReturnsTableData>>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.returnsDao.getAllReturns(storeId);
});

/// تفاصيل مرتجع واحد
final returnDetailProvider = FutureProvider.autoDispose
    .family<ReturnDetailData?, String>((ref, id) async {
      final db = GetIt.I<AppDatabase>();
      final returnData = await db.returnsDao.getReturnById(id);
      if (returnData == null) return null;
      final items = await db.returnsDao.getReturnItems(id);
      return ReturnDetailData(returnData: returnData, items: items);
    });

// ============================================================================
// ACTION HELPERS
// ============================================================================

/// إنشاء مرتجع جديد
Future<String> createReturn(
  WidgetRef ref, {
  required String saleId,
  String? customerId,
  String? customerName,
  required String reason,
  required double totalRefund,
  String refundMethod = 'cash',
  String? notes,
  String? createdBy,
  required List<ReturnItemsTableCompanion> items,
}) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) throw Exception('لا يوجد متجر محدد');

  final db = GetIt.I<AppDatabase>();
  final id = _uuid.v4();
  final returnNumber = 'RET-${DateTime.now().millisecondsSinceEpoch}';

  await db.returnsDao.insertReturn(
    ReturnsTableCompanion(
      id: Value(id),
      returnNumber: Value(returnNumber),
      saleId: Value(saleId),
      storeId: Value(storeId),
      customerId: Value(customerId),
      customerName: Value(customerName),
      reason: Value(reason),
      totalRefund: Value(totalRefund),
      refundMethod: Value(refundMethod),
      status: const Value('completed'),
      notes: Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(DateTime.now()),
    ),
  );

  if (items.isNotEmpty) {
    await db.returnsDao.insertReturnItems(items);
  }

  // إضافة للطابور المزامنة
  await db.syncQueueDao.enqueue(
    id: _uuid.v4(),
    tableName: 'returns',
    recordId: id,
    operation: 'CREATE',
    payload:
        '{"id":"$id","sale_id":"$saleId","store_id":"$storeId","total_refund":$totalRefund,"reason":"$reason","refund_method":"$refundMethod"}',
    idempotencyKey: 'return_create_$id',
  );

  ref.invalidate(returnsListProvider);
  return id;
}
