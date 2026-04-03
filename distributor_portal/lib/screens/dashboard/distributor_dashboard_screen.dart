/// Distributor Dashboard Screen
///
/// Shows summary cards and charts for the distributor portal.
library;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

class DistributorDashboardScreen extends StatelessWidget {
  const DistributorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final crossCount = width > 900 ? 4 : (width > 600 ? 2 : 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'لوحة التحكم',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              'نظرة عامة على أداء التوزيع',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Summary cards
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                mainAxisSpacing: AlhaiSpacing.md,
                crossAxisSpacing: AlhaiSpacing.md,
                childAspectRatio: 1.8,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                const cards = [
                  ('إجمالي الطلبات', '156', Icons.shopping_bag_outlined, AppColors.primary, '+12%'),
                  ('طلبات منتظرة', '23', Icons.pending_outlined, Colors.orange, '-5%'),
                  ('تمت الموافقة', '89', Icons.check_circle_outline, Colors.green, '+8%'),
                  ('الإيرادات', '245,000 ر.س', Icons.payments_outlined, Colors.teal, '+15%'),
                ];
                final card = cards[index];
                return _SummaryCard(
                  title: card.$1,
                  value: card.$2,
                  icon: card.$3,
                  color: card.$4,
                  trend: card.$5,
                  isDark: isDark,
                );
              },
            ),

            const SizedBox(height: AlhaiSpacing.xl),

            // Chart section
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.mdl),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المبيعات الشهرية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'يناير', 'فبراير', 'مارس', 'أبريل',
                                  'مايو', 'يونيو',
                                ];
                                if (value.toInt() >= 0 &&
                                    value.toInt() < months.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
                                    child: Text(
                                      months[value.toInt()],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.white54
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}K',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textSecondary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: isDark
                                ? Colors.white10
                                : Theme.of(context).colorScheme.surfaceContainerLow,
                            strokeWidth: 1,
                          ),
                        ),
                        barGroups: [
                          _makeBarGroup(0, 45),
                          _makeBarGroup(1, 68),
                          _makeBarGroup(2, 55),
                          _makeBarGroup(3, 82),
                          _makeBarGroup(4, 73),
                          _makeBarGroup(5, 90),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AlhaiSpacing.xl),

            // Recent orders section
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.mdl),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'آخر الطلبات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  ..._mockRecentOrders.map((order) => _RecentOrderTile(
                        order: order,
                        isDark: isDark,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}

// Mock data
final _mockRecentOrders = [
  _MockOrder('PO-001', 'متجر الرياض المركزي', 15000, 'sent'),
  _MockOrder('PO-002', 'سوبر ماركت جدة', 8500, 'approved'),
  _MockOrder('PO-003', 'بقالة الدمام', 3200, 'received'),
  _MockOrder('PO-004', 'متجر المدينة', 12000, 'sent'),
  _MockOrder('PO-005', 'هايبر الخبر', 22000, 'approved'),
];

class _MockOrder {
  final String number;
  final String store;
  final double total;
  final String status;
  const _MockOrder(this.number, this.store, this.total, this.status);
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isDark;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.xs,
                  vertical: AlhaiSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: trend.startsWith('+')
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trend.startsWith('+')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final _MockOrder order;
  final bool isDark;

  const _RecentOrderTile({required this.order, required this.isDark});

  Color _statusColor() {
    switch (order.status) {
      case 'sent':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'received':
        return Colors.teal;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel() {
    switch (order.status) {
      case 'sent':
        return 'منتظر';
      case 'approved':
        return 'موافق';
      case 'received':
        return 'مستلم';
      case 'rejected':
        return 'مرفوض';
      default:
        return order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              order.number,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              order.store,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${order.total.toStringAsFixed(0)} ر.س',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statusLabel(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _statusColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
