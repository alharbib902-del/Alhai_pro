/// Lite Management Providers
///
/// Riverpod providers for Admin Lite management screens:
/// stock adjustment (all products), employee schedule,
/// price update, and pending approvals.
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';

import '../core/services/sentry_service.dart' as sentry;

// =============================================================================
// MANAGEMENT PROVIDERS
// =============================================================================

/// Provider: All products (for quick price/stock screens)
final liteAllProductsProvider =
    FutureProvider.autoDispose<List<ProductsTableData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];

      final db = GetIt.I<AppDatabase>();
      return db.productsDao.getAllProducts(storeId, limit: 500);
    });

/// Provider: Employee schedule from shifts
final liteEmployeeScheduleProvider =
    FutureProvider.autoDispose<List<ShiftWithCashier>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];

      final db = GetIt.I<AppDatabase>();
      final now = DateTime.now();
      final todayWeekday = now.weekday;
      final daysSinceSat = (todayWeekday + 1) % 7;
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: daysSinceSat));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      return db.shiftsDao.getShiftsWithCashierName(
        storeId,
        startDate: startOfWeek,
        endDate: endOfWeek,
      );
    });

/// Pending approvals data model (refunds + purchases)
class PendingApprovalItem {
  final String id;
  final String type; // 'refund' or 'purchase'
  final String reference;
  final String description;
  final double amount;
  final String requestedBy;
  final DateTime createdAt;
  const PendingApprovalItem({
    required this.id,
    required this.type,
    required this.reference,
    required this.description,
    required this.amount,
    required this.requestedBy,
    required this.createdAt,
  });
}

/// Fetches all pending approvals: refund requests (from returns table) and
/// pending purchase orders. Runs both queries in parallel, merges results
/// into [PendingApprovalItem] list sorted by creation date descending.
/// Errors are reported to Sentry; returns partial data on failure.
final litePendingApprovalsProvider =
    FutureProvider.autoDispose<List<PendingApprovalItem>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];

      final db = GetIt.I<AppDatabase>();
      final items = <PendingApprovalItem>[];

      try {
        // Batch both queries in parallel
        final batchResults = await Future.wait([
          db
              .customSelect(
                '''SELECT r.id, r.total_refund, r.reason, r.created_at, u.name as user_name
           FROM returns r
           LEFT JOIN users u ON r.cashier_id = u.id
           WHERE r.store_id = ? AND r.status = 'pending'
           ORDER BY r.created_at DESC''',
                variables: [Variable.withString(storeId)],
              )
              .get(),
          db.purchasesDao.getPurchasesByStatus(storeId, 'pending'),
        ]);

        final returns = batchResults[0] as List<QueryRow>;
        for (final row in returns) {
          items.add(
            PendingApprovalItem(
              id: row.data['id'] as String,
              type: 'refund',
              reference: row.data['id'] as String,
              description: row.data['reason'] as String? ?? 'Refund request',
              amount: _toDouble(row.data['total_refund']),
              requestedBy: row.data['user_name'] as String? ?? 'Unknown',
              createdAt:
                  DateTime.tryParse(row.data['created_at'].toString()) ??
                  DateTime.now(),
            ),
          );
        }

        final purchases = batchResults[1] as List<PurchasesTableData>;
        for (final p in purchases) {
          items.add(
            PendingApprovalItem(
              id: p.id,
              type: 'purchase',
              reference: p.id,
              description: 'Purchase order',
              amount: p.total,
              requestedBy: '',
              createdAt: p.createdAt,
            ),
          );
        }
      } catch (e, st) {
        sentry.reportError(
          e,
          stackTrace: st,
          hint: 'litePendingApprovalsProvider',
        );
      }

      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });

// =============================================================================
// HELPERS
// =============================================================================

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  return value as double;
}
