/// Test data factories for Admin Lite tests
library;

import 'package:alhai_database/alhai_database.dart';
import 'package:admin_lite/providers/lite_dashboard_providers.dart';

// ============================================================================
// LITE STATS
// ============================================================================

LiteStatsData createTestLiteStats({
  int pendingApprovals = 3,
  double todaySales = 1500.0,
  int lowStockCount = 5,
  int activeShifts = 2,
  int todayOrders = 12,
  double salesChangePercent = 15.5,
}) {
  return LiteStatsData(
    pendingApprovals: pendingApprovals,
    todaySales: todaySales,
    lowStockCount: lowStockCount,
    activeShifts: activeShifts,
    todayOrders: todayOrders,
    salesChangePercent: salesChangePercent,
  );
}

ActivityEntry createTestActivity({
  String id = 'act-1',
  String userName = '\u0645\u0648\u0638\u0641 \u062a\u062c\u0631\u064a\u0628\u064a',
  String action = 'sale_completed',
  String? description = '\u062a\u0645 \u0625\u062a\u0645\u0627\u0645 \u0639\u0645\u0644\u064a\u0629 \u0628\u064a\u0639',
  DateTime? timestamp,
}) {
  return ActivityEntry(
    id: id,
    userName: userName,
    action: action,
    description: description,
    timestamp: timestamp ?? DateTime(2026, 1, 15, 14, 30),
  );
}

// ============================================================================
// PRODUCTS (for low stock display)
// ============================================================================

ProductsTableData createTestProduct({
  String id = 'prod-1',
  String storeId = 'test-store-1',
  String name = '\u0645\u0646\u062a\u062c \u062a\u062c\u0631\u064a\u0628\u064a',
  double price = 25.0,
  double? costPrice = 15.0,
  int stockQty = 3,
  int minQty = 5,
  bool isActive = true,
  bool trackInventory = true,
  bool autoReorder = false,
  bool onlineAvailable = false,
  double onlineReservedQty = 0,
  String? barcode,
  String? categoryId,
  DateTime? createdAt,
}) {
  return ProductsTableData(
    id: id,
    storeId: storeId,
    name: name,
    price: price,
    costPrice: costPrice,
    stockQty: stockQty,
    minQty: minQty,
    isActive: isActive,
    trackInventory: trackInventory,
    autoReorder: autoReorder,
    onlineAvailable: onlineAvailable,
    onlineReservedQty: onlineReservedQty,
    barcode: barcode,
    categoryId: categoryId,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

// ============================================================================
// RETURNS (for approval center)
// ============================================================================

ReturnsTableData createTestReturn({
  String id = 'ret-1',
  String storeId = 'test-store-1',
  String returnNumber = 'RET-001',
  String saleId = 'sale-1',
  String? customerId,
  String? customerName = '\u0639\u0645\u064a\u0644 \u062a\u062c\u0631\u064a\u0628\u064a',
  String? reason = '\u0639\u064a\u0628 \u0641\u064a \u0627\u0644\u0645\u0646\u062a\u062c',
  double totalRefund = 50.0,
  String status = 'pending',
  String type = 'refund',
  String refundMethod = 'cash',
  String? createdBy,
  String? notes,
  DateTime? createdAt,
}) {
  return ReturnsTableData(
    id: id,
    storeId: storeId,
    returnNumber: returnNumber,
    saleId: saleId,
    customerId: customerId,
    customerName: customerName,
    reason: reason,
    totalRefund: totalRefund,
    status: status,
    type: type,
    refundMethod: refundMethod,
    createdBy: createdBy,
    notes: notes,
    createdAt: createdAt ?? DateTime(2026, 1, 15),
  );
}

// ============================================================================
// AUDIT LOG (for recent activity)
// ============================================================================

AuditLogTableData createTestAuditLog({
  String id = 'log-1',
  String storeId = 'test-store-1',
  String userId = 'test-user-1',
  String userName = '\u0645\u0648\u0638\u0641 \u062a\u062c\u0631\u064a\u0628\u064a',
  String action = 'sale_completed',
  String? description = '\u062a\u0645 \u0625\u062a\u0645\u0627\u0645 \u0639\u0645\u0644\u064a\u0629 \u0628\u064a\u0639 \u0628\u0642\u064a\u0645\u0629 115 \u0631.\u0633',
  String? entityType = 'sale',
  String? entityId = 'sale-1',
  DateTime? createdAt,
}) {
  return AuditLogTableData(
    id: id,
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: action,
    description: description,
    entityType: entityType,
    entityId: entityId,
    createdAt: createdAt ?? DateTime(2026, 1, 15, 14, 30),
  );
}
