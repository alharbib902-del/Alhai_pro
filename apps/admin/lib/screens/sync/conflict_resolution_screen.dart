import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Conflict Resolution Screen - Admin version
/// Displays sync conflicts with side-by-side comparison and resolution actions
class ConflictResolutionScreen extends ConsumerStatefulWidget {
  const ConflictResolutionScreen({super.key});

  @override
  ConsumerState<ConflictResolutionScreen> createState() =>
      _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState
    extends ConsumerState<ConflictResolutionScreen> {
  bool _isResolving = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final conflictItemsAsync = ref.watch(conflictSyncItemsProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.conflictResolutionTitle,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => smartNotificationsPush(context, ref, lowStockRoute: AppRoutes.inventoryAlerts),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () => ref.invalidate(conflictSyncItemsProvider),
            ),
          ],
        ),
        Expanded(
          child: conflictItemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(conflictSyncItemsProvider),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            data: (conflicts) {
              if (conflicts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppColors.success.withValues(
                          alpha: isDark ? 0.5 : 1.0,
                        ),
                      ),
                      const SizedBox(height: AlhaiSpacing.md),
                      Text(
                        l10n.noConflicts,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                child: _buildContent(
                  conflicts,
                  isWideScreen,
                  isMediumScreen,
                  isDark,
                  l10n,
                ),
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
    List<SyncQueueTableData> conflicts,
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning header
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.errorSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.conflictsNeedResolution(conflicts.length),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      l10n.chooseCorrectValue,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AlhaiSpacing.md),

        // Conflicts list
        ...List.generate(conflicts.length, (index) {
          final conflict = conflicts[index];
          return _ConflictCard(
            item: conflict,
            isDark: isDark,
            l10n: l10n,
            isResolving: _isResolving,
            onAcceptLocal: () => _resolveConflict(conflict, 'local'),
            onAcceptServer: () => _resolveConflict(conflict, 'server'),
            onRetry: () => _retryConflict(conflict),
            onDelete: () => _deleteConflict(conflict),
          );
        }),

        const SizedBox(height: AlhaiSpacing.xs),

        // Quick actions
        if (conflicts.isNotEmpty)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isResolving
                      ? null
                      : () => _resolveAll(conflicts, 'local'),
                  icon: const Icon(Icons.phone_android, size: 18),
                  label: Text(l10n.useAllLocal),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isResolving
                      ? null
                      : () => _resolveAll(conflicts, 'server'),
                  icon: const Icon(Icons.cloud, size: 18),
                  label: Text(l10n.useAllServer),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

  Future<void> _resolveConflict(
    SyncQueueTableData conflict,
    String choice,
  ) async {
    setState(() => _isResolving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.markResolved(conflict.id);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            choice == 'local'
                ? l10n.conflictResolvedLocal
                : l10n.conflictResolvedServer,
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  Future<void> _retryConflict(SyncQueueTableData conflict) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.retryItem(conflict.id);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.operationSynced)));
      final manager = ref.read(syncManagerProvider);
      manager.syncPending();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _deleteConflict(SyncQueueTableData conflict) {
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
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final syncService = ref.read(syncServiceProvider);
                await syncService.removeItem(conflict.id);
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('$e'),
                    backgroundColor: AppColors.error,
                  ),
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

  void _resolveAll(List<SyncQueueTableData> conflicts, String choice) {
    final l10n = AppLocalizations.of(context);
    final choiceLabel = choice == 'local'
        ? l10n.useLocalValues
        : l10n.useServerValues;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(choiceLabel),
        content: Text(l10n.applyToAllConflicts(choiceLabel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isResolving = true);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final syncService = ref.read(syncServiceProvider);
                for (final conflict in conflicts) {
                  await syncService.markResolved(conflict.id);
                }
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.allConflictsResolved),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('$e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } finally {
                if (mounted) setState(() => _isResolving = false);
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

/// Conflict card widget for displaying individual conflicts
class _ConflictCard extends StatelessWidget {
  final SyncQueueTableData item;
  final bool isDark;
  final AppLocalizations l10n;
  final bool isResolving;
  final VoidCallback onAcceptLocal;
  final VoidCallback onAcceptServer;
  final VoidCallback onRetry;
  final VoidCallback onDelete;

  const _ConflictCard({
    required this.item,
    required this.isDark,
    required this.l10n,
    required this.isResolving,
    required this.onAcceptLocal,
    required this.onAcceptServer,
    required this.onRetry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final recordIdDisplay = item.recordId.length > 8
        ? item.recordId.substring(0, 8)
        : item.recordId;
    final payloadPreview = _getPayloadPreview(item.payload);

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                _getTableIcon(item.tableName_),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.tableName_} - ${item.operation}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'ID: $recordIdDisplay',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.retryCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs,
                    vertical: AlhaiSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.retryCount}/${item.maxRetries}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: AlhaiSpacing.xs),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                tooltip: l10n.delete,
                onPressed: onDelete,
              ),
            ],
          ),

          // Error message
          if (item.lastError != null && item.lastError!.isNotEmpty) ...[
            const SizedBox(height: AlhaiSpacing.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AlhaiSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.lastError!,
                style: const TextStyle(fontSize: 11, color: AppColors.error),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // Local value option
          if (payloadPreview.isNotEmpty) ...[
            const SizedBox(height: AlhaiSpacing.sm),
            _ConflictOption(
              title: l10n.localValueLabel,
              value: payloadPreview,
              time: item.createdAt,
              color: AppColors.warning,
              isDark: isDark,
              onSelect: isResolving ? null : onAcceptLocal,
            ),
          ],

          const SizedBox(height: AlhaiSpacing.xs),

          // Server value option
          _ConflictOption(
            title: l10n.serverValueLabel,
            value: l10n.useServerValues,
            time: item.lastAttemptAt ?? item.createdAt,
            color: AppColors.info,
            isDark: isDark,
            onSelect: isResolving ? null : onAcceptServer,
          ),

          const SizedBox(height: AlhaiSpacing.xs),

          // Retry button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isResolving ? null : onRetry,
              icon: const Icon(Icons.sync, size: 16),
              label: Text(l10n.retry),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTableIcon(String tableName) {
    switch (tableName) {
      case 'products':
        return Icons.inventory;
      case 'sales':
        return Icons.receipt_long;
      case 'inventory_movements':
        return Icons.storage;
      case 'accounts':
        return Icons.people;
      case 'orders':
        return Icons.shopping_cart;
      default:
        return Icons.table_chart;
    }
  }

  String _getPayloadPreview(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final entries = data.entries.take(3).map((e) {
        final value = e.value;
        final valueStr = value is String ? value : value.toString();
        final displayValue = valueStr.length > 30
            ? '${valueStr.substring(0, 30)}...'
            : valueStr;
        return '${e.key}: $displayValue';
      });
      return entries.join(', ');
    } catch (_) {
      return payload.length > 60 ? '${payload.substring(0, 60)}...' : payload;
    }
  }
}

/// Conflict resolution option widget (local/server)
class _ConflictOption extends StatelessWidget {
  final String title;
  final String value;
  final DateTime? time;
  final Color color;
  final bool isDark;
  final VoidCallback? onSelect;

  const _ConflictOption({
    required this.title,
    required this.value,
    required this.time,
    required this.color,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.radio_button_unchecked, color: color),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (time != null)
              Text(
                '${time!.hour}:${time!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
