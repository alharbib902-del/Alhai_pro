/// Inter-branch stock transfers list (M4).
///
/// Two tabs — Outgoing (this store sent these) and Incoming (another
/// store sent these to us). Workflow actions are exposed inline on
/// incoming rows: Approve → In-transit → Received, or Reject/Cancel.
///
/// Actual stock movement (updating `products.stock_qty` on both sides
/// + writing `inventory_movements` rows) is performed by whatever
/// service owns the transfer lifecycle — this screen only flips the
/// status via `StockTransfersDao`.
library;

import 'dart:convert';

import 'package:alhai_auth/alhai_auth.dart'
    show currentStoreIdProvider, currentUserProvider;
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show AppRoutes;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final _outgoingTransfersProvider =
    FutureProvider.autoDispose<List<StockTransfersTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const [];
  final db = GetIt.I<AppDatabase>();
  return db.stockTransfersDao.getOutgoing(storeId);
});

final _incomingTransfersProvider =
    FutureProvider.autoDispose<List<StockTransfersTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const [];
  final db = GetIt.I<AppDatabase>();
  return db.stockTransfersDao.getIncoming(storeId);
});

/// Inter-branch stock transfers — two-tab list with inline workflow
/// actions and FAB → new-transfer screen.
class StockTransfersScreen extends ConsumerWidget {
  const StockTransfersScreen({super.key});

  void _refresh(WidgetRef ref) {
    ref.invalidate(_outgoingTransfersProvider);
    ref.invalidate(_incomingTransfersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.stockTransfersTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.stockTransferTabOutgoing),
              Tab(text: l10n.stockTransferTabIncoming),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: l10n.retry,
              onPressed: () => _refresh(ref),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.stockTransferCreate),
          onPressed: () async {
            await context.push<bool>(AppRoutes.stockTransferNew);
            _refresh(ref);
          },
        ),
        body: TabBarView(
          children: [
            _TransferList(
              provider: _outgoingTransfersProvider,
              emptyMessage: l10n.stockTransferNoOutgoing,
              isIncoming: false,
            ),
            _TransferList(
              provider: _incomingTransfersProvider,
              emptyMessage: l10n.stockTransferNoIncoming,
              isIncoming: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferList extends ConsumerWidget {
  final AutoDisposeFutureProvider<List<StockTransfersTableData>> provider;
  final String emptyMessage;
  final bool isIncoming;

  const _TransferList({
    required this.provider,
    required this.emptyMessage,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(provider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(l10n.errorWithDetails('$err')),
      ),
      data: (transfers) {
        if (transfers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Text(
                emptyMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          itemCount: transfers.length,
          itemBuilder: (_, i) => _TransferCard(
            transfer: transfers[i],
            isIncoming: isIncoming,
            onActionDone: () {
              ref.invalidate(_outgoingTransfersProvider);
              ref.invalidate(_incomingTransfersProvider);
            },
          ),
        );
      },
    );
  }
}

class _TransferCard extends ConsumerWidget {
  final StockTransfersTableData transfer;
  final bool isIncoming;
  final VoidCallback onActionDone;

  const _TransferCard({
    required this.transfer,
    required this.isIncoming,
    required this.onActionDone,
  });

  int _itemCount() {
    try {
      final decoded = jsonDecode(transfer.items);
      if (decoded is List) return decoded.length;
    } catch (_) {
      // malformed items JSON — treat as zero
    }
    return 0;
  }

  String _statusLabel(AppLocalizations l10n) {
    switch (transfer.approvalStatus) {
      case 'pending':
        return l10n.stockTransferStatusPending;
      case 'approved':
        return l10n.stockTransferStatusApproved;
      case 'in_transit':
        return l10n.stockTransferStatusInTransit;
      case 'received':
        return l10n.stockTransferStatusReceived;
      case 'cancelled':
        return l10n.stockTransferStatusCancelled;
    }
    return transfer.approvalStatus;
  }

  Color _statusColor() {
    switch (transfer.approvalStatus) {
      case 'received':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'in_transit':
      case 'approved':
        return AppColors.info;
    }
    return AppColors.warning;
  }

  // M4 follow-up (pending design decision before wiring):
  //
  //   When a transfer is Approved → In-Transit, the source store's
  //   on-hand stock should decrement by each item's qty and a paired
  //   `inventory_movements` row should land (type = 'transfer_out',
  //   reference_type = 'stock_transfer'). Symmetric: on Received, the
  //   destination store's on-hand stock should increment (type =
  //   'transfer_in').
  //
  //   The blocker is cross-store product identity: `products.id` is
  //   store-scoped in the current schema, so a product in the source
  //   store doesn't exist as the same row in the destination. Three
  //   design options to choose from before wiring:
  //     (a) Match by barcode/SKU; auto-create a destination product
  //         row on first transfer (operator friction on mismatch).
  //     (b) Require the destination store to have a matching product
  //         row pre-created (reject transfer if missing).
  //     (c) Switch to an org-scoped `org_products` catalog with
  //         per-store stock rows (bigger schema change).
  //   Decide with the user before implementing; until then the
  //   workflow flips status only and stock is reconciled manually.
  //   Filed in the C-4 / M4 follow-up list.
  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final db = GetIt.I<AppDatabase>();
    final currentUser = ref.read(currentUserProvider);
    try {
      await db.stockTransfersDao.updateApprovalStatus(
        transfer.id,
        approvalStatus: 'approved',
        approvedBy: currentUser?.id,
      );
      await db.stockTransfersDao.markInTransit(transfer.id);
      onActionDone();
    } catch (e) {
      if (kDebugMode) debugPrint('Transfer approve failed: $e');
    }
  }

  Future<void> _receive(BuildContext context, WidgetRef ref) async {
    final db = GetIt.I<AppDatabase>();
    final currentUser = ref.read(currentUserProvider);
    try {
      await db.stockTransfersDao.markReceived(
        transfer.id,
        currentUser?.id ?? 'unknown',
      );
      onActionDone();
    } catch (e) {
      if (kDebugMode) debugPrint('Transfer receive failed: $e');
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final db = GetIt.I<AppDatabase>();
    try {
      await db.stockTransfersDao.cancelTransfer(transfer.id);
      onActionDone();
    } catch (e) {
      if (kDebugMode) debugPrint('Transfer reject failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    transfer.transferNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(l10n),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              '${l10n.stockTransferFromStore}: ${transfer.fromStoreId} · '
              '${l10n.stockTransferToStore}: ${transfer.toStoreId}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xxs),
            Text(
              l10n.stockTransferItemCount(_itemCount()),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (isIncoming && transfer.approvalStatus == 'pending') ...[
              const SizedBox(height: AlhaiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _reject(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: Text(l10n.stockTransferReject),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _approve(context, ref),
                      child: Text(l10n.stockTransferApprove),
                    ),
                  ),
                ],
              ),
            ] else if (isIncoming &&
                (transfer.approvalStatus == 'approved' ||
                    transfer.approvalStatus == 'in_transit')) ...[
              const SizedBox(height: AlhaiSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.icon(
                  onPressed: () => _receive(context, ref),
                  icon: const Icon(Icons.inventory_2_rounded, size: 18),
                  label: Text(l10n.stockTransferReceive),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
