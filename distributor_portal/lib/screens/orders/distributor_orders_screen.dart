/// Distributor Orders Screen
///
/// Shows incoming purchase orders from stores with status filtering.
/// Data from Supabase via Riverpod providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';

class DistributorOrdersScreen extends ConsumerStatefulWidget {
  const DistributorOrdersScreen({super.key});

  @override
  ConsumerState<DistributorOrdersScreen> createState() =>
      _DistributorOrdersScreenState();
}

class _DistributorOrdersScreenState
    extends ConsumerState<DistributorOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Maps tab index to status filter value (null = all)
  static const _tabStatuses = <String?>[null, 'sent', 'approved', 'rejected'];

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

  Color _statusColor(String status) {
    switch (status) {
      case 'sent':
      case 'draft':
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

  String _statusLabel(String status, AppLocalizations? l10n) {
    switch (status) {
      case 'draft':
        return l10n?.distributorStatusDraft ?? 'Draft';
      case 'sent':
        return l10n?.distributorStatusPending ?? 'Pending';
      case 'approved':
        return l10n?.distributorStatusApproved ?? 'Approved';
      case 'received':
        return l10n?.distributorStatusReceived ?? 'Received';
      case 'rejected':
        return l10n?.distributorStatusRejected ?? 'Rejected';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width > 900;
    final l10n = AppLocalizations.of(context);

    final statusFilter = _tabStatuses[_tabController.index];
    final ordersAsync = ref.watch(ordersProvider(statusFilter));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                AlhaiSpacing.lg, AlhaiSpacing.lg, AlhaiSpacing.lg, 0),
            child: Text(
              l10n?.distributorOrders ?? 'Incoming Orders',
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
              tabs: [
                Tab(text: l10n?.distributorAllOrders ?? 'All'),
                Tab(text: l10n?.distributorPendingTab ?? 'Pending'),
                Tab(text: l10n?.distributorApprovedTab ?? 'Approved'),
                Tab(text: l10n?.distributorRejectedTab ?? 'Rejected'),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),

          // Orders list
          Expanded(
            child: ordersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48,
                        color: isDark ? Colors.white30 : AppColors.textMuted),
                    const SizedBox(height: AlhaiSpacing.md),
                    Text(l10n?.distributorLoadError ?? 'Error loading data'),
                    const SizedBox(height: AlhaiSpacing.md),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.invalidate(ordersProvider(statusFilter)),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n?.distributorRetry ?? 'Retry'),
                    ),
                  ],
                ),
              ),
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: isDark
                              ? Colors.white30
                              : Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                        Text(
                          l10n?.distributorNoOrders ?? 'No orders found',
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
                  return _buildDataTable(orders, isDark, l10n);
                }
                return _buildCardList(orders, isDark, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
      List<DistributorOrder> orders, bool isDark, AppLocalizations? l10n) {
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
            isDark
                ? const Color(0xFF334155)
                : Theme.of(context).colorScheme.surfaceContainerLowest,
          ),
          columns: [
            DataColumn(
                label: Text(l10n?.distributorOrderNumber ?? 'Order #')),
            DataColumn(label: Text(l10n?.distributorStore ?? 'Store')),
            DataColumn(label: Text(l10n?.distributorDate ?? 'Date')),
            DataColumn(label: Text(l10n?.distributorAmount ?? 'Amount')),
            DataColumn(label: Text(l10n?.status ?? 'Status')),
          ],
          rows: orders.map((order) {
            return DataRow(
              onSelectChanged: (_) =>
                  context.go('/orders/${order.id}'),
              cells: [
                DataCell(Text(
                  order.purchaseNumber,
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
                  '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                )),
                DataCell(Text(
                  '${NumberFormat('#,##0').format(order.total)} ${l10n?.distributorSar ?? 'SAR'}',
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
                      color: _statusColor(order.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel(order.status, l10n),
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

  Widget _buildCardList(
      List<DistributorOrder> orders, bool isDark, AppLocalizations? l10n) {
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
                        order.purchaseNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              isDark ? Colors.white : AppColors.textPrimary,
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
                          _statusLabel(order.status, l10n),
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
                      color:
                          isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white54
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${NumberFormat('#,##0').format(order.total)} ${l10n?.distributorSar ?? 'SAR'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : AppColors.textPrimary,
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
