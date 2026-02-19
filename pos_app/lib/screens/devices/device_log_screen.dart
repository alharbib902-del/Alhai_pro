import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../widgets/layout/app_header.dart';

class DeviceLogScreen extends ConsumerStatefulWidget {
  const DeviceLogScreen({super.key});

  @override
  ConsumerState<DeviceLogScreen> createState() => _DeviceLogScreenState();
}

class _DeviceLogScreenState extends ConsumerState<DeviceLogScreen> {
  List<AuditLogTableData>? _logs;
  bool _isLoading = true;
  String? _error;
  DateTimeRange? _dateRange;

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
          _error = 'لم يتم تحديد المتجر';
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
        _error = 'حدث خطأ أثناء تحميل السجلات: $e';
      });
    }
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

  /// الحصول على أيقونة ولون حسب نوع العملية
  ({IconData icon, Color color, String label}) _getActionMeta(String action) {
    switch (action) {
      case 'login':
        return (icon: Icons.login, color: Colors.green, label: 'تسجيل دخول');
      case 'logout':
        return (icon: Icons.logout, color: Colors.orange, label: 'تسجيل خروج');
      case 'saleCreate':
        return (icon: Icons.point_of_sale, color: Colors.blue, label: 'عملية بيع');
      case 'saleCancel':
        return (icon: Icons.cancel_outlined, color: Colors.red, label: 'إلغاء بيع');
      case 'saleRefund':
        return (icon: Icons.undo, color: Colors.deepOrange, label: 'مرتجع');
      case 'productCreate':
        return (icon: Icons.add_box_outlined, color: Colors.teal, label: 'إضافة منتج');
      case 'productEdit':
        return (icon: Icons.edit, color: Colors.indigo, label: 'تعديل منتج');
      case 'productDelete':
        return (icon: Icons.delete_outline, color: Colors.red, label: 'حذف منتج');
      case 'priceChange':
        return (icon: Icons.price_change, color: Colors.amber, label: 'تغيير سعر');
      case 'stockAdjust':
        return (icon: Icons.inventory, color: Colors.purple, label: 'تعديل مخزون');
      case 'stockReceive':
        return (icon: Icons.move_to_inbox, color: Colors.cyan, label: 'استلام مخزون');
      case 'shiftOpen':
        return (icon: Icons.play_circle_outline, color: Colors.green, label: 'فتح وردية');
      case 'shiftClose':
        return (icon: Icons.stop_circle_outlined, color: Colors.grey, label: 'إغلاق وردية');
      case 'settingsChange':
        return (icon: Icons.settings, color: Colors.blueGrey, label: 'تغيير إعدادات');
      case 'cashDrawerOpen':
        return (icon: Icons.point_of_sale_outlined, color: Colors.brown, label: 'فتح الدرج');
      default:
        return (icon: Icons.info_outline, color: Colors.grey, label: action);
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
          onMenuTap: isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            IconButton(
              icon: Icon(
                _dateRange != null ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: _dateRange != null ? AppColors.primary : (isDark ? Colors.white70 : AppColors.textSecondary),
              ),
              tooltip: l10n.filter,
              onPressed: _pickDateRange,
            ),
            if (_dateRange != null)
              IconButton(
                icon: Icon(Icons.clear, size: 20, color: isDark ? Colors.white70 : AppColors.textSecondary),
                tooltip: l10n.clearAll,
                onPressed: _clearDateFilter,
              ),
            IconButton(
              icon: Icon(Icons.refresh, color: isDark ? Colors.white70 : AppColors.textSecondary),
              tooltip: l10n.refresh,
              onPressed: _loadLogs,
            ),
          ],
        ),
        // Info banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _dateRange != null
                      ? '${l10n.filter}: ${DateFormat('yyyy/MM/dd').format(_dateRange!.start)} - ${DateFormat('yyyy/MM/dd').format(_dateRange!.end)}'
                      : l10n.allOperationsSynced,
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.info : AppColors.info),
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
            Text(l10n.loading, style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
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

    if (_logs == null || _logs!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_outlined, size: 48, color: isDark ? Colors.white38 : AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              l10n.noData,
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _logs!.length,
        itemBuilder: (context, index) {
          final log = _logs![index];
          return _buildLogItem(log, isDark);
        },
      ),
    );
  }

  Widget _buildLogItem(AuditLogTableData log, bool isDark) {
    final meta = _getActionMeta(log.action);
    final timeStr = DateFormat('yyyy/MM/dd  HH:mm:ss').format(log.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
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
                        style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        log.userName,
                        style: TextStyle(color: meta.color, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (log.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.description!,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: isDark ? Colors.white38 : AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColors.textTertiary),
                    ),
                    if (log.deviceInfo != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.devices, size: 12, color: isDark ? Colors.white38 : AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          log.deviceInfo!,
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColors.textTertiary),
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
}
