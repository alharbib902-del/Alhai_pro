import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../utils/csv_export_helper.dart';

/// شاشة تقرير أداء الموظفين
class StaffPerformanceScreen extends ConsumerStatefulWidget {
  const StaffPerformanceScreen({super.key});

  @override
  ConsumerState<StaffPerformanceScreen> createState() =>
      _StaffPerformanceScreenState();
}

class _StaffPerformanceScreenState
    extends ConsumerState<StaffPerformanceScreen> {
  String _period = 'today';
  bool _isLoading = true;

  List<_StaffData> _staff = [];

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  /// حساب الفترة الزمنية المحددة
  ({DateTime start, DateTime end}) _getDateRange() {
    final now = DateTime.now();
    switch (_period) {
      case 'today':
        return (start: DateTime(now.year, now.month, now.day), end: now);
      case 'week':
        return (start: now.subtract(const Duration(days: 7)), end: now);
      case 'month':
        return (start: DateTime(now.year, now.month, 1), end: now);
      default:
        return (start: DateTime(now.year, now.month, now.day), end: now);
    }
  }

  Future<void> _loadStaff() async {
    try {
      setState(() => _isLoading = true);
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
      final users = await db.usersDao.getAllUsers(storeId);

      final dateRange = _getDateRange();

      // استعلام المبيعات مجمعة حسب الكاشير
      final staffSalesResults = await db
          .customSelect(
            '''SELECT
             cashier_id,
             COUNT(*) as sale_count,
             COALESCE(SUM(total), 0) as total_sales,
             COALESCE(AVG(total), 0) as avg_ticket
           FROM sales
           WHERE store_id = ?
             AND status = 'completed'
             AND created_at >= ?
             AND created_at < ?
           GROUP BY cashier_id
           ORDER BY total_sales DESC''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dateRange.start),
              Variable.withDateTime(dateRange.end),
            ],
          )
          .get();

      // تحويل النتائج إلى Map للبحث السريع
      final salesMap = <String, ({int count, double total, double avg})>{};
      for (final row in staffSalesResults) {
        final cashierId = row.data['cashier_id'] as String;
        final count = row.data['sale_count'] as int? ?? 0;
        final total = (row.data['total_sales'] is int)
            ? (row.data['total_sales'] as int).toDouble()
            : row.data['total_sales'] as double? ?? 0.0;
        final avg = (row.data['avg_ticket'] is int)
            ? (row.data['avg_ticket'] as int).toDouble()
            : row.data['avg_ticket'] as double? ?? 0.0;
        salesMap[cashierId] = (count: count, total: total, avg: avg);
      }

      // دمج بيانات المستخدمين مع بيانات المبيعات
      final staffList = users.map((u) {
        final sales = salesMap[u.id];
        return _StaffData(
          name: u.name,
          role: u.role,
          sales: sales?.total ?? 0,
          transactions: sales?.count ?? 0,
          avgTicket: (sales?.avg ?? 0).toInt(),
        );
      }).toList();

      // ترتيب حسب إجمالي المبيعات تنازلياً
      staffList.sort((a, b) => b.sales.compareTo(a.sales));

      if (mounted) {
        setState(() {
          _staff = staffList;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reports)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() => _period = v);
              _loadStaff();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'today', child: Text(l10n.today)),
              PopupMenuItem(value: 'week', child: Text(l10n.thisWeek)),
              PopupMenuItem(value: 'month', child: Text(l10n.thisMonth)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
              child: Row(
                children: [
                  Text(_getPeriodName()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'CSV',
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: _staff.isEmpty
          ? const Center(child: Text('لا توجد بيانات للفترة المحددة'))
          : ListView(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              children: [
                // Leader board
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AlhaiSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: AlhaiSpacing.xs),
                            Text(
                              'المتصدرون',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                        ...List.generate(_staff.length.clamp(0, 3), (index) {
                          final staff = _staff[index];
                          final colors = [
                            AppColors.warning,
                            AppColors.grey400,
                            const Color(0xFF795548),
                          ];
                          return _LeaderItem(
                            rank: index + 1,
                            name: staff.name,
                            sales: staff.sales,
                            color: colors[index],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.md),

                // Detailed stats
                ...List.generate(_staff.length, (index) {
                  final staff = _staff[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                    child: ExpansionTile(
                      leading: CircleAvatar(child: Text(staff.name[0])),
                      title: Text(staff.name),
                      subtitle: Text(staff.role),
                      trailing: Text(
                        '${staff.sales.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AlhaiSpacing.md),
                          child: Column(
                            children: [
                              _StatRow(
                                icon: Icons.receipt_long,
                                label: 'عدد الفواتير',
                                value: '${staff.transactions}',
                                color: AppColors.info,
                              ),
                              const SizedBox(height: AlhaiSpacing.sm),
                              _StatRow(
                                icon: Icons.trending_up,
                                label: 'متوسط الفاتورة',
                                value: '${staff.avgTicket} ر.س',
                                color: AppColors.success,
                              ),
                              const SizedBox(height: AlhaiSpacing.sm),
                              _StatRow(
                                icon: Icons.speed,
                                label: 'المبيعات/ساعة (تقديري)',
                                value:
                                    '${(staff.sales / 8).toStringAsFixed(0)} ر.س',
                                color: const Color(0xFF9C27B0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Comparison chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AlhaiSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مقارنة المبيعات',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                        ...List.generate(_staff.length, (index) {
                          final staff = _staff[index];
                          final rawMax = _staff.isEmpty
                              ? 0.0
                              : _staff
                                    .map((s) => s.sales)
                                    .reduce((a, b) => a > b ? a : b);
                          final maxSales = rawMax > 0 ? rawMax : 1.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AlhaiSpacing.xs,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: Text(staff.name.split(' ')[0]),
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: staff.sales / maxSales,
                                          backgroundColor: Theme.of(
                                            context,
                                          ).dividerColor.withValues(alpha: 0.2),
                                          minHeight: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AlhaiSpacing.xs),
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        staff.sales.toStringAsFixed(0),
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _exportCsv() async {
    final result = await CsvExportHelper.exportAndShare(
      context: context,
      fileName: 'أداء_الموظفين_${_getPeriodName()}',
      headers: ['الموظف', 'الدور', 'المبيعات', 'الفواتير', 'متوسط الفاتورة'],
      rows: _staff
          .map(
            (s) => [
              s.name,
              s.role,
              s.sales.toStringAsFixed(2),
              '${s.transactions}',
              '${s.avgTicket}',
            ],
          )
          .toList(),
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }

  String _getPeriodName() {
    switch (_period) {
      case 'today':
        return 'اليوم';
      case 'week':
        return 'الأسبوع';
      case 'month':
        return 'الشهر';
      default:
        return 'اليوم';
    }
  }
}

class _StaffData {
  final String name;
  final String role;
  final double sales;
  final int transactions;
  final int avgTicket;

  _StaffData({
    required this.name,
    required this.role,
    required this.sales,
    required this.transactions,
    required this.avgTicket,
  });
}

class _LeaderItem extends StatelessWidget {
  final int rank;
  final String name;
  final double sales;
  final Color color;

  const _LeaderItem({
    required this.rank,
    required this.name,
    required this.sales,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(child: Text(name)),
          Text(
            '${sales.toStringAsFixed(0)} ر.س',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
