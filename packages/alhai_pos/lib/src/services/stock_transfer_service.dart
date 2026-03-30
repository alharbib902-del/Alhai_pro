import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';

/// عنصر نقل مخزون
class TransferItem {
  final String productId;
  final String productName;
  final double quantity;

  const TransferItem({
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
      };
}

/// خدمة نقل المخزون بين الفروع
///
/// تدفق النقل:
/// 1. المرسل ينشئ طلب نقل (pending)
/// 2. المستقبل يوافق (approved)
/// 3. المرسل يشحن → خصم المخزون (in_transit)
/// 4. المستقبل يستلم → إضافة المخزون (received/completed)
class StockTransferService {
  final AppDatabase _db;
  final SupabaseClient _supabase;
  static const _uuid = Uuid();

  StockTransferService({
    required AppDatabase db,
    required SupabaseClient supabase,
  })  : _db = db,
        _supabase = supabase;

  /// إنشاء طلب نقل جديد
  Future<String> createTransfer({
    required String fromStoreId,
    required String toStoreId,
    required List<TransferItem> items,
    required String createdBy,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final transferNumber =
        'TRF-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 10000}';

    final itemsJson = jsonEncode(items.map((i) => i.toJson()).toList());

    await _db.stockTransfersDao.upsertTransfer(
      StockTransfersTableCompanion.insert(
        id: id,
        transferNumber: transferNumber,
        fromStoreId: fromStoreId,
        toStoreId: toStoreId,
        items: itemsJson,
        createdBy: Value(createdBy),
        notes: Value(notes),
        createdAt: now,
      ),
    );

    // Push إلى Supabase
    await _pushToRemote(id);

    return id;
  }

  /// موافقة على طلب النقل (من المتجر المستقبل)
  Future<void> approveTransfer(String transferId, String approvedBy) async {
    await _db.stockTransfersDao.updateApprovalStatus(
      transferId,
      approvalStatus: 'approved',
      approvedBy: approvedBy,
    );
    await _pushToRemote(transferId);
  }

  /// شحن النقل (من المتجر المرسل) → خصم المخزون
  Future<void> shipTransfer(String transferId) async {
    final transfer = await _db.stockTransfersDao.getById(transferId);
    if (transfer == null) return;

    await _db.transaction(() async {
      // تحديث حالة النقل
      await _db.stockTransfersDao.markInTransit(transferId);

      // خصم المخزون من المتجر المرسل
      final items = _parseItems(transfer.items);
      for (final item in items) {
        await _db.customStatement(
          'UPDATE products SET stock_qty = stock_qty - ? WHERE id = ? AND store_id = ?',
          [
            Variable.withReal(item['quantity'] as double),
            Variable.withString(item['product_id'] as String),
            Variable.withString(transfer.fromStoreId),
          ],
        );
      }
    });

    await _pushToRemote(transferId);
  }

  /// استلام النقل (من المتجر المستقبل) → إضافة المخزون
  Future<void> receiveTransfer(
      String transferId, String receivedBy) async {
    final transfer = await _db.stockTransfersDao.getById(transferId);
    if (transfer == null) return;

    await _db.transaction(() async {
      // تحديث حالة النقل
      await _db.stockTransfersDao.markReceived(transferId, receivedBy);

      // إضافة المخزون للمتجر المستقبل
      final items = _parseItems(transfer.items);
      for (final item in items) {
        await _db.customStatement(
          'UPDATE products SET stock_qty = stock_qty + ? WHERE id = ? AND store_id = ?',
          [
            Variable.withReal(item['quantity'] as double),
            Variable.withString(item['product_id'] as String),
            Variable.withString(transfer.toStoreId),
          ],
        );
      }
    });

    await _pushToRemote(transferId);
  }

  /// إلغاء النقل
  Future<void> cancelTransfer(String transferId) async {
    final transfer = await _db.stockTransfersDao.getById(transferId);
    if (transfer == null) return;

    await _db.transaction(() async {
      // إذا كان في حالة in_transit، أعد المخزون للمرسل
      if (transfer.status == 'in_transit') {
        final items = _parseItems(transfer.items);
        for (final item in items) {
          await _db.customStatement(
            'UPDATE products SET stock_qty = stock_qty + ? WHERE id = ? AND store_id = ?',
            [
              Variable.withReal(item['quantity'] as double),
              Variable.withString(item['product_id'] as String),
              Variable.withString(transfer.fromStoreId),
            ],
          );
        }
      }

      await _db.stockTransfersDao.cancelTransfer(transferId);
    });

    await _pushToRemote(transferId);
  }

  /// Parse items JSON
  List<Map<String, dynamic>> _parseItems(String itemsJson) {
    final list = jsonDecode(itemsJson) as List;
    return list.cast<Map<String, dynamic>>();
  }

  /// Push transfer to Supabase
  Future<void> _pushToRemote(String transferId) async {
    try {
      final transfer = await _db.stockTransfersDao.getById(transferId);
      if (transfer == null) return;

      final payload = {
        'id': transfer.id,
        'transfer_number': transfer.transferNumber,
        'from_store_id': transfer.fromStoreId,
        'to_store_id': transfer.toStoreId,
        'status': transfer.status,
        'items': jsonDecode(transfer.items),
        'notes': transfer.notes,
        'created_by': transfer.createdBy,
        'approved_by': transfer.approvedBy,
        'received_by': transfer.receivedBy,
        'approval_status': transfer.approvalStatus,
        'created_at': transfer.createdAt.toUtc().toIso8601String(),
        'approved_at': transfer.approvedAt?.toUtc().toIso8601String(),
        'completed_at': transfer.completedAt?.toUtc().toIso8601String(),
        'received_at': transfer.receivedAt?.toUtc().toIso8601String(),
      };

      await _supabase.from('stock_transfers').upsert(payload);
      await _db.stockTransfersDao.markAsSynced(transferId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StockTransferService: push failed: $e');
      }
    }
  }
}
