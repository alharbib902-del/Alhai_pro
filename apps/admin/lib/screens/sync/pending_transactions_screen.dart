import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';

/// Pending Transactions Screen - Admin version
/// Displays transactions waiting to sync with retry and bulk sync actions
class PendingTransactionsScreen extends ConsumerStatefulWidget {
  const PendingTransactionsScreen({super.key});

  @override
  ConsumerState<PendingTransactionsScreen> createState() =>
      _PendingTransactionsScreenState();
}

class _PendingTransactionsScreenState
    extends ConsumerState<PendingTransactionsScreen> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final pendingItemsAsync = ref.watch(pendingSyncItemsProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.pendingTransactionsTitle,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              onPressed: () => ref.invalidate(pendingSyncItemsProvider),
            ),
          ],
        ),
        Expanded(
          child: pendingItemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () =>
                        ref.invalidate(pendingSyncItemsProvider),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            data: (pendingItems) {
              if (pendingItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_done,
                          size: 64,
                          color: isDark
                              ? Colors.white24
                              : AppColors.success),
                      const SizedBox(height: 16),
                      Text(
                        l10n.allOperationsSynced,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noPendingOperations,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                child: _buildContent(
                    pendingItems, isWideScreen, isMediumScreen, isDark, l10n),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CONTENT
  // ===========================================================================

  Widget _buildContent(
    List<SyncQueueTableData> pendingItems,
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.warning.withValues(alpha: 0.1)
                : AppColors.warningSurface,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_off, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nPendingCount(pendingItems.length),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      l10n.willSyncWhenOnline,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _isSyncing ? null : _syncAll,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync, size: 18),
                label: Text(_isSyncing ? l10n.syncing : l10n.syncAll),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pending items list
        ...List.generate(pendingItems.length, (index) {
          final item = pendingItems[index];
          final recordIdDisplay = item.recordId.length > 8
              ? item.recordId.substring(0, 8)
              : item.recordId;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                backgroundColor:
                    _getOperationColor(item.operation).withValues(alpha: 0.1),
                child: Icon(
                  _getOperationIcon(item.operation),
                  color: _getOperationColor(item.operation),
                ),
              ),
              title: Text(
                _translateOperation(item.operation, l10n),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.tableName_} - $recordIdDisplay',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatDate(item.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : AppColors.textTertiary,
                        ),
                      ),
                      if (item.retryCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.retryCount}/${item.maxRetries}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.lastError != null &&
                      item.lastError!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.lastError!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.error),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.sync, color: AppColors.info),
                    tooltip: l10n.retry,
                    onPressed: () => _retryItem(item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    tooltip: l10n.delete,
                    onPressed: () => _deleteItem(item),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  Color _getOperationColor(String? operation) {
    switch (operation) {
      case 'INSERT':
      case 'CREATE':
        return AppColors.success;
      case 'UPDATE':
        return AppColors.info;
      case 'DELETE':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getOperationIcon(String? operation) {
    switch (operation) {
      case 'INSERT':
      case 'CREATE':
        return Icons.add;
      case 'UPDATE':
        return Icons.edit;
      case 'DELETE':
        return Icons.delete;
      default:
        return Icons.sync;
    }
  }

  String _translateOperation(String? operation, AppLocalizations l10n) {
    switch (operation) {
      case 'INSERT':
      case 'CREATE':
        return l10n.insertOperation;
      case 'UPDATE':
        return l10n.updateOperation;
      case 'DELETE':
        return l10n.delete;
      default:
        return l10n.operationLabel;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

  Future<void> _syncAll() async {
    setState(() => _isSyncing = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final manager = ref.read(syncManagerProvider);
      final result = await manager.syncPending();
      if (!mounted) return;
      if (result.hasErrors) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
                '${l10n.syncFailed}: ${result.failedCount} ${l10n.syncFailed}'),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.syncSuccessful),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _retryItem(SyncQueueTableData item) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.retryItem(item.id);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.operationSynced)),
      );
      final manager = ref.read(syncManagerProvider);
      manager.syncPending();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _deleteItem(SyncQueueTableData item) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteOperation),
        content: Text(l10n.deleteOperationConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final syncService = ref.read(syncServiceProvider);
                await syncService.removeItem(item.id);
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                      content: Text('$e'),
                      backgroundColor: AppColors.error),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
