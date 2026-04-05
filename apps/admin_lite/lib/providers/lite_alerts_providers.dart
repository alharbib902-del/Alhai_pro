/// Lite Alerts Providers
///
/// Riverpod providers for Admin Lite alert screens:
/// notifications, stock alerts, order alerts, and system alerts.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';

// =============================================================================
// ALERTS PROVIDERS
// =============================================================================

/// Provider: Notifications list
final liteNotificationsProvider =
    FutureProvider.autoDispose<List<NotificationsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();
  return db.notificationsDao.getAllNotifications(storeId, limit: 50);
});

/// Provider: Low stock products (for stock alerts screen)
final liteStockAlertsProvider =
    FutureProvider.autoDispose<List<ProductsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();
  return db.productsDao.getLowStockProducts(storeId);
});

/// Provider: Order alerts (new/pending orders)
final liteOrderAlertsProvider =
    FutureProvider.autoDispose<List<OrderWithCustomer>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();
  try {
    final results = await Future.wait([
      db.ordersDao.getOrdersWithCustomer(storeId, status: 'created', limit: 20),
      db.ordersDao
          .getOrdersWithCustomer(storeId, status: 'confirmed', limit: 20),
    ]);
    final all = <OrderWithCustomer>[];
    for (final list in results) {
      all.addAll(list);
    }
    all.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return all;
  } catch (_) {
    return [];
  }
});

/// System alert data model
class SystemAlertData {
  final String title;
  final String description;
  final String severity; // HIGH, MEDIUM, LOW
  final DateTime timestamp;
  final String? actionLabel;

  const SystemAlertData({
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    this.actionLabel,
  });
}

/// Provider: System alerts (sync health, pending sync items)
final liteSystemAlertsProvider =
    FutureProvider.autoDispose<List<SystemAlertData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();
  final alerts = <SystemAlertData>[];

  try {
    // Check pending sync items
    final pendingSync = await db.syncQueueDao.getPendingCount();
    if (pendingSync > 0) {
      alerts.add(SystemAlertData(
        title: 'Sync Pending',
        description:
            '$pendingSync items waiting to sync. Check internet connection.',
        severity: pendingSync > 10 ? 'HIGH' : 'MEDIUM',
        timestamp: DateTime.now(),
        actionLabel: 'Retry',
      ));
    }

    // Check unsynced sales
    final unsyncedSales = await db.salesDao.getUnsyncedSales(storeId: storeId);
    if (unsyncedSales.length > 5) {
      alerts.add(SystemAlertData(
        title: 'Unsynced Sales',
        description: '${unsyncedSales.length} sales not yet synchronized.',
        severity: 'HIGH',
        timestamp: DateTime.now(),
        actionLabel: 'Sync Now',
      ));
    }

    // Check low stock count as a system concern
    final lowStock = await db.productsDao.getLowStockProducts(storeId);
    if (lowStock.length > 10) {
      alerts.add(SystemAlertData(
        title: 'Inventory Warning',
        description: '${lowStock.length} products below minimum stock level.',
        severity: 'MEDIUM',
        timestamp: DateTime.now(),
      ));
    }
  } catch (_) {}

  return alerts;
});
