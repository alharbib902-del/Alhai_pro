import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

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

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                if (!isWide) IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
                const Icon(Icons.devices, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('سجل الأجهزة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                ),
                // زر فلتر التاريخ
                IconButton(
                  icon: Icon(
                    _dateRange != null ? Icons.filter_alt : Icons.filter_alt_outlined,
                    color: _dateRange != null ? AppColors.primary : null,
                  ),
                  tooltip: 'فلتر بالتاريخ',
                  onPressed: _pickDateRange,
                ),
                if (_dateRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    tooltip: 'إزالة الفلتر',
                    onPressed: _clearDateFilter,
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'تحديث',
                  onPressed: _loadLogs,
                ),
              ],
            ),
          ),
          // Info banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _dateRange != null
                        ? 'عرض السجلات من ${DateFormat('yyyy/MM/dd').format(_dateRange!.start)} إلى ${DateFormat('yyyy/MM/dd').format(_dateRange!.end)}'
                        : 'يتم تسجيل جميع العمليات على الأجهزة تلقائياً',
                    style: const TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: _buildContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل السجلات...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadLogs,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
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
            Icon(Icons.history_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'لا توجد سجلات${_dateRange != null ? ' في الفترة المحددة' : ''}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
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
                        style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
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
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: isDark ? Colors.white38 : Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey.shade400),
                    ),
                    if (log.deviceInfo != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.devices, size: 12, color: isDark ? Colors.white38 : Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          log.deviceInfo!,
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey.shade400),
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
