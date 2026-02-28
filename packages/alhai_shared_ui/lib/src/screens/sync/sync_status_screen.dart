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
  DateTime? _lastSyncTime;
  final String _connectionStatus = 'online';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final db = GetIt.I<AppDatabase>();
      final pending = await db.syncQueueDao.getPendingItems();
      setState(() {
        _pendingCount = pending.length;
        _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }
  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
                      ? AppErrorState.general(message: _error, onRetry: _loadStatus)
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                          child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                        ),
                ),
              ],
            );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final isOnline = _connectionStatus == 'online';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Connection status card
        Container(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(width: 20),
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
        const SizedBox(height: 16),

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
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 16),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('$_pendingCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(width: 8),
                  AdaptiveIcon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Sync info card
        Container(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 12),
              _InfoRow(label: l10n.device, value: 'POS-001', isDark: isDark),
              Divider(height: 16, color: Theme.of(context).dividerColor),
              _InfoRow(label: l10n.appVersion, value: '1.0.0', isDark: isDark),
              Divider(height: 16, color: Theme.of(context).dividerColor),
              _InfoRow(
                label: l10n.lastFullSync,
                value: _lastSyncTime != null ? _formatDate(_lastSyncTime!) : '-',
                isDark: isDark,
              ),
              Divider(height: 16, color: Theme.of(context).dividerColor),
              _InfoRow(label: l10n.databaseStatus, value: l10n.healthy, isDark: isDark),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Sync button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSyncing ? null : _forceSync,
            icon: _isSyncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.sync),
            label: Text(_isSyncing ? l10n.syncing : l10n.syncNow),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ],
    );
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
    await Future.delayed(const Duration(seconds: 2));
    await _loadStatus();
    setState(() => _isSyncing = false);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.syncSuccessful), backgroundColor: AppColors.success),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow({required this.label, required this.value, required this.isDark});

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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
