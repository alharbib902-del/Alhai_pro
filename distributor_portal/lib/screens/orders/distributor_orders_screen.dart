/// Distributor Orders Screen
///
/// Shows incoming purchase orders from stores with status filtering.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// Mock order model
class _MockOrder {
  final String id;
  final String number;
  final String storeName;
  final double total;
  final String status;
  final DateTime date;

  const _MockOrder({
    required this.id,
    required this.number,
    required this.storeName,
    required this.total,
    required this.status,
    required this.date,
  });
}

class DistributorOrdersScreen extends StatefulWidget {
  const DistributorOrdersScreen({super.key});

  @override
  State<DistributorOrdersScreen> createState() =>
      _DistributorOrdersScreenState();
}

class _DistributorOrdersScreenState extends State<DistributorOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static final _mockOrders = [
    _MockOrder(id: '1', number: 'PO-1001', storeName: 'متجر الرياض المركزي', total: 15000, status: 'sent', date: DateTime(2026, 2, 22)),
    _MockOrder(id: '2', number: 'PO-1002', storeName: 'سوبر ماركت جدة', total: 8500, status: 'approved', date: DateTime(2026, 2, 21)),
    _MockOrder(id: '3', number: 'PO-1003', storeName: 'بقالة الدمام', total: 3200, status: 'received', date: DateTime(2026, 2, 20)),
    _MockOrder(id: '4', number: 'PO-1004', storeName: 'متجر المدينة', total: 12000, status: 'sent', date: DateTime(2026, 2, 19)),
    _MockOrder(id: '5', number: 'PO-1005', storeName: 'هايبر الخبر', total: 22000, status: 'approved', date: DateTime(2026, 2, 18)),
    _MockOrder(id: '6', number: 'PO-1006', storeName: 'متجر تبوك', total: 5600, status: 'rejected', date: DateTime(2026, 2, 17)),
    _MockOrder(id: '7', number: 'PO-1007', storeName: 'سوبر ماركت أبها', total: 9800, status: 'sent', date: DateTime(2026, 2, 16)),
    _MockOrder(id: '8', number: 'PO-1008', storeName: 'بقالة نجران', total: 4500, status: 'received', date: DateTime(2026, 2, 15)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_MockOrder> _filterOrders(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return _mockOrders.where((o) => o.status == 'sent').toList();
      case 2:
        return _mockOrders.where((o) => o.status == 'approved').toList();
      case 3:
        return _mockOrders
            .where((o) => o.status == 'rejected')
            .toList();
      default:
        return _mockOrders;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
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

  String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'sent':
        return 'منتظر';
      case 'approved':
        return 'موافق';
      case 'received':
        return 'مستلم';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width > 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.lg, AlhaiSpacing.lg, AlhaiSpacing.lg, 0),
            child: Text(
              'الطلبات الواردة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              labelColor: AppColors.primary,
              unselectedLabelColor:
                  isDark ? Colors.white54 : AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'الكل'),
                Tab(text: 'منتظرة'),
                Tab(text: 'موافق عليها'),
                Tab(text: 'مرفوضة'),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),

          // Orders list
          Expanded(
            child: Builder(
              builder: (context) {
                final orders = _filterOrders(_tabController.index);
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color:
                              isDark ? Colors.white30 : Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                        Text(
                          'لا توجد طلبات',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white54
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (isWide) {
                  return _buildDataTable(orders, isDark);
                }
                return _buildCardList(orders, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<_MockOrder> orders, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            isDark ? const Color(0xFF334155) : Theme.of(context).colorScheme.surfaceContainerLowest,
          ),
          columns: const [
            DataColumn(label: Text('رقم الطلب')),
            DataColumn(label: Text('المتجر')),
            DataColumn(label: Text('التاريخ')),
            DataColumn(label: Text('المبلغ')),
            DataColumn(label: Text('الحالة')),
          ],
          rows: orders.map((order) {
            return DataRow(
              onSelectChanged: (_) => context.go('/orders/${order.id}'),
              cells: [
                DataCell(Text(
                  order.number,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                )),
                DataCell(Text(
                  order.storeName,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                )),
                DataCell(Text(
                  '${order.date.day}/${order.date.month}/${order.date.year}',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                )),
                DataCell(Text(
                  '${order.total.toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                )),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _statusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel(order.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(order.status),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardList(List<_MockOrder> orders, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isDark ? 0 : 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.go('/orders/${order.id}'),
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.number,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel(order.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    order.storeName,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.date.day}/${order.date.month}/${order.date.year}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white54
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${order.total.toStringAsFixed(0)} ر.س',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
