import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';

/// Device audit log screen with date range filtering, event type icons,
/// user info, and searchable event list.
class DeviceLogScreen extends ConsumerStatefulWidget {
  const DeviceLogScreen({super.key});

  @override
  ConsumerState<DeviceLogScreen> createState() =>
      _DeviceLogScreenState();
}

class _DeviceLogScreenState extends ConsumerState<DeviceLogScreen> {
  List<AuditLogTableData>? _logs;
  bool _isLoading = true;
  String? _error;
  DateTimeRange? _dateRange;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);

      if (storeId == null) {
        setState(() {
          _isLoading = false;
          _error = 'No store selected';
        });
        return;
      }

      List<AuditLogTableData> logs;
      if (_dateRange != null) {
        logs = await db.auditLogDao.getLogsByDateRange(
          storeId,
          _dateRange!.start,
          _dateRange!.end.add(const Duration(days: 1)),
        );
      } else {
        logs = await db.auditLogDao.getLogs(storeId, limit: 200);
      }

      if (!mounted) return;
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error loading logs: $e';
      });
    }
  }

  List<AuditLogTableData> get _filteredLogs {
    if (_logs == null) return [];
    if (_searchQuery.isEmpty) return _logs!;
    final query = _searchQuery.toLowerCase();
    return _logs!.where((log) {
      return log.userName.toLowerCase().contains(query) ||
          log.action.toLowerCase().contains(query) ||
          (log.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadLogs();
    }
  }

  void _clearDateFilter() {
    setState(() => _dateRange = null);
    _loadLogs();
  }

  /// Get icon and color based on action type
  ({IconData icon, Color color, String label}) _getActionMeta(
      String action) {
    switch (action) {
      case 'login':
        return (
          icon: Icons.login,
          color: AppColors.success,
          label: 'Login'
        );
      case 'logout':
        return (
          icon: Icons.logout,
          color: AppColors.warning,
          label: 'Logout'
        );
      case 'saleCreate':
        return (
          icon: Icons.point_of_sale,
          color: AppColors.info,
          label: 'Sale'
        );
      case 'saleCancel':
        return (
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          label: 'Cancel Sale'
        );
      case 'saleRefund':
        return (
          icon: Icons.undo,
          color: Colors.deepOrange, // specific audit action color
          label: 'Refund'
        );
      case 'productCreate':
        return (
          icon: Icons.add_box_outlined,
          color: Colors.teal, // specific audit action color
          label: 'Add Product'
        );
      case 'productEdit':
        return (
          icon: Icons.edit,
          color: Colors.indigo, // specific audit action color
          label: 'Edit Product'
        );
      case 'productDelete':
        return (
          icon: Icons.delete_outline,
          color: AppColors.error,
          label: 'Delete Product'
        );
      case 'priceChange':
        return (
          icon: Icons.price_change,
          color: AppColors.warning,
          label: 'Price Change'
        );
      case 'stockAdjust':
        return (
          icon: Icons.inventory,
          color: Colors.purple, // specific audit action color
          label: 'Stock Adjust'
        );
      case 'stockReceive':
        return (
          icon: Icons.move_to_inbox,
          color: Colors.cyan, // specific audit action color
          label: 'Stock Receive'
        );
      case 'shiftOpen':
        return (
          icon: Icons.play_circle_outline,
          color: AppColors.success,
          label: 'Open Shift'
        );
      case 'shiftClose':
        return (
          icon: Icons.stop_circle_outlined,
          color: Theme.of(context).hintColor,
          label: 'Close Shift'
        );
      case 'settingsChange':
        return (
          icon: Icons.settings,
          color: Colors.blueGrey,
          label: 'Settings Change'
        );
      case 'cashDrawerOpen':
        return (
          icon: Icons.point_of_sale_outlined,
          color: Colors.brown,
          label: 'Cash Drawer'
        );
      default:
        return (
          icon: Icons.info_outline,
          color: Theme.of(context).hintColor,
          label: action
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        AppHeader(
          title: l10n.deviceLog,
          onMenuTap:
              isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            IconButton(
              icon: Icon(
                _dateRange != null
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined,
                color: _dateRange != null
                    ? AppColors.primary
                    : (Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              tooltip: l10n.filter,
              onPressed: _pickDateRange,
            ),
            if (_dateRange != null)
              IconButton(
                icon: Icon(Icons.clear,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                tooltip: l10n.clearAll,
                onPressed: _clearDateFilter,
              ),
            IconButton(
              icon: Icon(Icons.refresh,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              tooltip: l10n.refresh,
              onPressed: _loadLogs,
            ),
          ],
        ),
        // Search bar
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surface,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search logs...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.border.withValues(alpha: 0.3),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        // Info banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.info.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.info, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _dateRange != null
                      ? '${l10n.filter}: ${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                      : l10n.allOperationsSynced,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
        // Content area
        Expanded(
          child: _buildContent(isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loading,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48,
                color: AppColors.error.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadLogs,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final filteredLogs = _filteredLogs;

    if (filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_outlined,
                size: 48,
                color: isDark
                    ? Colors.white38
                    : AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              l10n.noData,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredLogs.length,
        itemBuilder: (context, index) {
          final log = filteredLogs[index];
          return _buildLogItem(log, isDark);
        },
      ),
    );
  }

  Widget _buildLogItem(AuditLogTableData log, bool isDark) {
    final meta = _getActionMeta(log.action);
    final timeStr = _formatDateTime(log.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon, color: meta.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meta.label,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            meta.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        log.userName,
                        style: TextStyle(
                            color: meta.color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (log.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.description!,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 12,
                        color: isDark
                            ? Colors.white38
                            : AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : AppColors.textTertiary),
                    ),
                    if (log.deviceInfo != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.devices,
                          size: 12,
                          color: isDark
                              ? Colors.white38
                              : AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          log.deviceInfo!,
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : AppColors.textTertiary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
