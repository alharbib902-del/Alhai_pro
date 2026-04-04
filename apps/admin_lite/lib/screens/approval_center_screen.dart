/// Approval Center Screen
///
/// Displays pending refund approvals with filter tabs (All/Pending/Approved/Rejected).
/// Each refund item has approve/reject buttons requiring PIN verification
/// via ManagerApprovalScreen.showApprovalDialog().
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../providers/approval_providers.dart';

/// Approval Center screen for managing pending refunds
class ApprovalCenterScreen extends ConsumerWidget {
  const ApprovalCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final currentFilter = ref.watch(approvalFilterProvider);
    final refundsAsync = ref.watch(pendingRefundsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.returns ?? 'Approval Center'),
        centerTitle: true,
        actions: [
          // Pending count badge
          Consumer(
            builder: (context, ref, _) {
              final countAsync = ref.watch(pendingApprovalsCountProvider);
              return countAsync.when(
                data: (count) => count > 0
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(
                            end: AlhaiSpacing.md),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AlhaiSpacing.xs,
                                vertical: AlhaiSpacing.xxs),
                            decoration: BoxDecoration(
                              color: AlhaiColors.warning,
                              borderRadius:
                                  BorderRadius.circular(AlhaiSpacing.sm),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _FilterTabs(
            currentFilter: currentFilter,
            onFilterChanged: (filter) {
              ref.read(approvalFilterProvider.notifier).state = filter;
            },
            isDark: isDark,
          ),

          // Refunds list
          Expanded(
            child: refundsAsync.when(
              data: (refunds) {
                if (refunds.isEmpty) {
                  return _buildEmptyState(context, isDark, currentFilter);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(pendingRefundsProvider);
                    ref.invalidate(pendingApprovalsCountProvider);
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(
                        isMobile ? AlhaiSpacing.sm : AlhaiSpacing.mdl),
                    itemCount: refunds.length,
                    itemBuilder: (context, index) {
                      final refund = refunds[index];
                      return KeyedSubtree(
                        key: ValueKey(refund.id),
                        child: _RefundCard(
                          refund: refund,
                          isDark: isDark,
                          isMobile: isMobile,
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: isDark
                          ? Colors.white30
                          : Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    Text(
                      l10n?.errorOccurred ?? 'An error occurred',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.sm),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(pendingRefundsProvider),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n?.tryAgain ?? 'Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, bool isDark, ApprovalFilter filter) {
    final l10n = AppLocalizations.of(context);
    final String message;
    final IconData icon;

    switch (filter) {
      case ApprovalFilter.pending:
        message = l10n?.noResults ?? 'No pending approvals';
        icon = Icons.check_circle_outline;
        break;
      case ApprovalFilter.approved:
        message = l10n?.noResults ?? 'No approved refunds';
        icon = Icons.thumb_up_outlined;
        break;
      case ApprovalFilter.rejected:
        message = l10n?.noResults ?? 'No rejected refunds';
        icon = Icons.thumb_down_outlined;
        break;
      case ApprovalFilter.all:
        message = l10n?.noResults ?? 'No refunds found';
        icon = Icons.receipt_long_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 64,
              color: isDark
                  ? Colors.white24
                  : Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? Colors.white54
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FILTER TABS
// =============================================================================

class _FilterTabs extends StatelessWidget {
  final ApprovalFilter currentFilter;
  final ValueChanged<ApprovalFilter> onFilterChanged;
  final bool isDark;

  const _FilterTabs({
    required this.currentFilter,
    required this.onFilterChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white12
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip(context, l10n?.all ?? 'All', ApprovalFilter.all),
            const SizedBox(width: AlhaiSpacing.xs),
            _buildChip(
                context, l10n?.pending ?? 'Pending', ApprovalFilter.pending),
            const SizedBox(width: AlhaiSpacing.xs),
            _buildChip(context, l10n?.completed ?? 'Approved',
                ApprovalFilter.approved),
            const SizedBox(width: AlhaiSpacing.xs),
            _buildChip(context, l10n?.cancelled ?? 'Rejected',
                ApprovalFilter.rejected),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, ApprovalFilter filter) {
    final isSelected = currentFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(filter),
      selectedColor: AlhaiColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AlhaiColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? AlhaiColors.primary
            : (isDark
                ? Colors.white70
                : Theme.of(context).colorScheme.onSurface),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? AlhaiColors.primary
            : (isDark
                ? Colors.white24
                : Theme.of(context).colorScheme.outlineVariant),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

// =============================================================================
// REFUND CARD
// =============================================================================

class _RefundCard extends ConsumerWidget {
  final ReturnsTableData refund;
  final bool isDark;
  final bool isMobile;

  const _RefundCard({
    required this.refund,
    required this.isDark,
    required this.isMobile,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AlhaiColors.warning;
      case 'approved':
      case 'completed':
        return AlhaiColors.success;
      case 'rejected':
        return AlhaiColors.error;
      default:
        return AlhaiColors.disabled;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor(refund.status);
    final isPending = refund.status.toLowerCase() == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      elevation: isDark ? 0 : 1,
      color: isDark ? Colors.white.withValues(alpha: 0.06) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.sm : AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Return number + Status badge
            Row(
              children: [
                // Return icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _statusIcon(refund.status),
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),

                // Return number + customer name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${refund.returnNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      if (refund.customerName != null)
                        Text(
                          refund.customerName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white54
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: AlhaiSpacing.xxs),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    refund.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AlhaiSpacing.sm),

            // Details row: Amount, Date, Reason
            Row(
              children: [
                _DetailChip(
                  icon: Icons.attach_money,
                  label: refund.totalRefund.toStringAsFixed(2),
                  isDark: isDark,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _DetailChip(
                  icon: Icons.calendar_today,
                  label: _formatDate(refund.createdAt),
                  isDark: isDark,
                ),
                if (refund.reason != null) ...[
                  const SizedBox(width: AlhaiSpacing.xs),
                  Expanded(
                    child: _DetailChip(
                      icon: Icons.note,
                      label: refund.reason!,
                      isDark: isDark,
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),

            // Action buttons for pending items
            if (isPending) ...[
              const SizedBox(height: AlhaiSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AlhaiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleReject(context, ref),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(l10n?.cancel ?? 'Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AlhaiColors.error,
                        side: const BorderSide(color: AlhaiColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _handleApprove(context, ref),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l10n?.confirm ?? 'Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AlhaiColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handle approve action with PIN verification
  Future<void> _handleApprove(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    // PIN verification via ManagerApprovalScreen
    final approved = await ManagerApprovalScreen.showApprovalDialog(
      context,
      action: l10n?.confirm ?? 'Approve refund #${refund.returnNumber}',
    );

    if (!approved) return;
    if (!context.mounted) return;

    final storeId = ref.read(currentStoreIdProvider);
    final user = ref.read(currentUserProvider);
    if (storeId == null) return;

    final success = await approveRefund(
      returnId: refund.id,
      storeId: storeId,
      userId: user?.id ?? 'unknown',
      userName: user?.name ?? 'Unknown',
    );

    if (!context.mounted) return;

    if (success) {
      ref.invalidate(pendingRefundsProvider);
      ref.invalidate(pendingApprovalsCountProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.success ?? 'Refund approved successfully'),
          backgroundColor: AlhaiColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Handle reject action with PIN verification
  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    // PIN verification via ManagerApprovalScreen
    final approved = await ManagerApprovalScreen.showApprovalDialog(
      context,
      action: l10n?.cancel ?? 'Reject refund #${refund.returnNumber}',
    );

    if (!approved) return;
    if (!context.mounted) return;

    final storeId = ref.read(currentStoreIdProvider);
    final user = ref.read(currentUserProvider);
    if (storeId == null) return;

    final success = await rejectRefund(
      returnId: refund.id,
      storeId: storeId,
      userId: user?.id ?? 'unknown',
      userName: user?.name ?? 'Unknown',
    );

    if (!context.mounted) return;

    if (success) {
      ref.invalidate(pendingRefundsProvider);
      ref.invalidate(pendingApprovalsCountProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.cancelled ?? 'Refund rejected'),
          backgroundColor: AlhaiColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// =============================================================================
// DETAIL CHIP
// =============================================================================

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final int? maxLines;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxs),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: isDark
                  ? Colors.white38
                  : Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: AlhaiSpacing.xxs),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.white54
                    : Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }
}
