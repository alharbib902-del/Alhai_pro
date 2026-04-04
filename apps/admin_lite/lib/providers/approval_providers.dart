/// Approval Center Providers
///
/// Providers for managing pending refund approvals in Admin Lite.
/// Queries the local database for returns with pending status,
/// and provides approve/reject actions with audit logging.
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';

// =============================================================================
// FILTER STATE
// =============================================================================

/// Filter for approval list
enum ApprovalFilter { all, pending, approved, rejected }

/// Current filter selection
final approvalFilterProvider =
    StateProvider<ApprovalFilter>((ref) => ApprovalFilter.all);

// =============================================================================
// PENDING REFUNDS PROVIDER
// =============================================================================

/// All refunds for the current store, optionally filtered by status
final pendingRefundsProvider =
    FutureProvider.autoDispose<List<ReturnsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();
  final filter = ref.watch(approvalFilterProvider);

  switch (filter) {
    case ApprovalFilter.all:
      return db.returnsDao.getAllReturns(storeId);
    case ApprovalFilter.pending:
      return db.returnsDao.getReturnsByStatus(storeId, 'pending');
    case ApprovalFilter.approved:
      return db.returnsDao
          .getReturnsByStatuses(storeId, ['approved', 'completed']);
    case ApprovalFilter.rejected:
      return db.returnsDao.getReturnsByStatus(storeId, 'rejected');
  }
});

// =============================================================================
// PENDING APPROVALS COUNT
// =============================================================================

/// Count of pending approvals (for badges)
final pendingApprovalsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return 0;

  final db = GetIt.I<AppDatabase>();

  try {
    final result = await db.customSelect(
      '''SELECT COUNT(*) as count
         FROM returns
         WHERE store_id = ?
         AND status = 'pending' ''',
      variables: [Variable.withString(storeId)],
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  } catch (_) {
    return 0;
  }
});

// =============================================================================
// APPROVE / REJECT ACTIONS
// =============================================================================

/// Approve a refund by ID
Future<bool> approveRefund({
  required String returnId,
  required String storeId,
  required String userId,
  required String userName,
}) async {
  try {
    final db = GetIt.I<AppDatabase>();

    // Update return status to approved
    await db.customStatement(
      '''UPDATE returns SET status = 'approved' WHERE id = ?''',
      [Variable.withString(returnId)],
    );

    // Log the approval in audit log
    await db.auditLogDao.log(
      storeId: storeId,
      userId: userId,
      userName: userName,
      action: AuditAction.saleRefund,
      entityType: 'return',
      entityId: returnId,
      description: 'Approved refund: $returnId',
    );

    return true;
  } catch (_) {
    return false;
  }
}

/// Reject a refund by ID
Future<bool> rejectRefund({
  required String returnId,
  required String storeId,
  required String userId,
  required String userName,
  String? reason,
}) async {
  try {
    final db = GetIt.I<AppDatabase>();

    // Update return status to rejected
    await db.customStatement(
      '''UPDATE returns SET status = 'rejected' WHERE id = ?''',
      [Variable.withString(returnId)],
    );

    // Log the rejection in audit log
    await db.auditLogDao.log(
      storeId: storeId,
      userId: userId,
      userName: userName,
      action: AuditAction.saleRefund,
      entityType: 'return',
      entityId: returnId,
      description:
          'Rejected refund: $returnId${reason != null ? ' - $reason' : ''}',
    );

    return true;
  } catch (_) {
    return false;
  }
}
