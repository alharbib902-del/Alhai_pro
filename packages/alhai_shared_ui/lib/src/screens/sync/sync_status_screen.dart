import '../../widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_header.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/router/routes.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../providers/sync_providers.dart';
import 'package:alhai_sync/alhai_sync.dart';

/// شاشة حالة المزامنة
class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {

  bool _isLoading = true;
  bool _isSyncing = false;
  String? _error;
  int _pendingCount = 0;
  int _conflictCount = 0;
  DateTime? _lastSyncTime;
  SyncHealthStatus _healthStatus = SyncHealthStatus.healthy;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final db = GetIt.I<AppDatabase>();

      // جلب عدد العناصر المعلقة
      final pendingCount = await db.syncQueueDao.getPendingCount();

      // جلب العناصر المتعارضة
      final conflictItems = await db.syncQueueDao.getConflictItems();

      // جلب آخر وقت مزامنة من SyncStatusTracker
      final tracker = ref.read(syncStatusTrackerProvider);
      await tracker.refreshAll();
      final overview = tracker.currentOverview;

      setState(() {
        _pendingCount = pendingCount;
        _conflictCount = conflictItems.length;
        _lastSyncTime = overview.lastFullSyncAt;
        _healthStatus = overview.health;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('SyncStatusScreen: Error loading status: $e');
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // مراقبة حالة الاتصال من المزود الحقيقي
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isOnline = isOnlineAsync.valueOrNull ?? true;

    return Column(
              children: [
                AppHeader(
                  title: l10n.syncStatusTitle,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.cashCustomer,
                  userRole: l10n.branchManager,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      onPressed: _loadStatus,
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? AppErrorState.general(context, message: _error, onRetry: _loadStatus)
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
                          child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n, isOnline),
                        ),
                ),
              ],
            );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n, bool isOnline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Connection status card
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          decoration: BoxDecoration(
            color: isDark
                ? (isOnline ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1))
                : (isOnline ? AppColors.successSurface : AppColors.errorSurface),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isOnline ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              SizedBox(width: AlhaiSpacing.mdl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? l10n.connectedToServer : l10n.notConnected,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : (isOnline ? AppColors.success : AppColors.error),
                      ),
                    ),
                    if (_lastSyncTime != null)
                      Text(
                        l10n.lastSyncAt(_formatTime(_lastSyncTime!, l10n)),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AlhaiSpacing.md),

        // Pending items card
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: InkWell(
            onTap: () => context.push(AppRoutes.pendingTransactions),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _pendingCount > 0
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    child: Icon(
                      _pendingCount > 0 ? Icons.hourglass_empty : Icons.check,
                      color: _pendingCount > 0 ? AppColors.warning : AppColors.success,
                    ),
                  ),
                  SizedBox(width: AlhaiSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pendingOperations,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _pendingCount > 0 ? l10n.nPendingOperations(_pendingCount) : l10n.noPendingOperations,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (_pendingCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xxs),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('$_pendingCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  SizedBox(width: AlhaiSpacing.xs),
                  AdaptiveIcon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: AlhaiSpacing.md),

        // Conflict items card (يظهر فقط إن وجدت تعارضات)
        if (_conflictCount > 0) ...[
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
                CircleAvatar(
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                ),
                SizedBox(width: AlhaiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.syncConflicts,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        l10n.itemsNeedReview(_conflictCount),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xxs),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('$_conflictCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(height: AlhaiSpacing.md),
        ],

        // Sync info card
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.syncInfo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AlhaiSpacing.sm),
              _InfoRow(label: l10n.lastFullSync, value: _lastSyncTime != null ? _formatDate(_lastSyncTime!) : '-', isDark: isDark),
              Divider(height: 16, color: Theme.of(context).dividerColor),
              _InfoRow(
                label: l10n.databaseStatus,
                value: _getHealthLabel(l10n),
                isDark: isDark,
                valueColor: _getHealthColor(),
              ),
              Divider(height: 16, color: Theme.of(context).dividerColor),
              _InfoRow(label: l10n.pendingOperations, value: '$_pendingCount', isDark: isDark),
            ],
          ),
        ),
        SizedBox(height: AlhaiSpacing.lg),

        // Sync button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSyncing ? null : _forceSync,
            icon: _isSyncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.sync),
            label: Text(_isSyncing ? l10n.syncing : l10n.syncNow),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md)),
          ),
        ),
      ],
    );
  }

  /// تسمية صحة المزامنة
  String _getHealthLabel(AppLocalizations l10n) {
    switch (_healthStatus) {
      case SyncHealthStatus.healthy:
        return l10n.healthy;
      case SyncHealthStatus.syncing:
        return l10n.syncing;
      case SyncHealthStatus.warning:
        return l10n.needsAttention;
      case SyncHealthStatus.critical:
        return l10n.seriousProblems;
    }
  }

  /// لون صحة المزامنة
  Color _getHealthColor() {
    switch (_healthStatus) {
      case SyncHealthStatus.healthy:
        return AppColors.success;
      case SyncHealthStatus.syncing:
        return AppColors.info;
      case SyncHealthStatus.warning:
        return AppColors.warning;
      case SyncHealthStatus.critical:
        return AppColors.error;
    }
  }

  String _formatTime(DateTime time, AppLocalizations l10n) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _forceSync() async {
    setState(() => _isSyncing = true);
    try {
      // تنفيذ المزامنة الحقيقية عبر SyncManager
      final manager = ref.read(syncManagerProvider);
      final result = await manager.syncPending();

      // إعادة تحميل الحالة بعد المزامنة
      await _loadStatus();

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;

      if (result.hasErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncPartialSuccess(result.successCount, result.failedCount)),
            backgroundColor: AppColors.warning,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.syncSuccessful), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      debugPrint('SyncStatusScreen: Force sync error: $e');
      if (mounted) {
        final errL10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errL10n.syncErrorMessage('$e')), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, required this.isDark, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
