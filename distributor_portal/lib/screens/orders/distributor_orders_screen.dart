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
import '../../ui/shared_widgets.dart';
import '../../ui/skeleton_loading.dart';

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

  // Sorting state
  int _sortColumnIndex = 2; // default sort by date
  bool _sortAscending = false; // newest first

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

  List<DistributorOrder> _sortOrders(List<DistributorOrder> orders) {
    final sorted = List<DistributorOrder>.from(orders);
    sorted.sort((a, b) {
      int result;
      switch (_sortColumnIndex) {
        case 2: // date
          result = a.createdAt.compareTo(b.createdAt);
        case 3: // amount
          result = a.total.compareTo(b.total);
        case 4: // status
          result = a.status.compareTo(b.status);
        default:
          result = 0;
      }
      return _sortAscending ? result : -result;
    });
    return sorted;
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
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),

          // Tabs with order count per tab
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              labelColor: AppColors.primary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: _buildTabWithCount(
                    l10n?.distributorAllOrders ?? 'All',
                    ordersAsync.valueOrNull?.length,
                    0,
                  ),
                ),
                Tab(
                  child: _buildTabWithCount(
                    l10n?.distributorPendingTab ?? 'Pending',
                    null,
                    1,
                  ),
                ),
                Tab(
                  child: _buildTabWithCount(
                    l10n?.distributorApprovedTab ?? 'Approved',
                    null,
                    2,
                  ),
                ),
                Tab(
                  child: _buildTabWithCount(
                    l10n?.distributorRejectedTab ?? 'Rejected',
                    null,
                    3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),

          // Orders list
          Expanded(
            child: ordersAsync.when(
              loading: () => const TableSkeleton(rows: 8, columns: 5),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                        Text(
                          l10n?.distributorNoOrders ?? 'No orders found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                        // Action button in empty state
                        FilledButton.icon(
                          onPressed: () =>
                              ref.invalidate(ordersProvider(statusFilter)),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(l10n?.distributorRetry ?? 'Refresh'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final sortedOrders = _sortOrders(orders);

                if (isWide) {
                  return _buildDataTable(sortedOrders, isDark, l10n);
                }
                return _buildCardList(sortedOrders, isDark, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithCount(String label, int? count, int tabIndex) {
    if (count != null && tabIndex == _tabController.index) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    }
    return Text(label);
  }

  Widget _buildDataTable(
      List<DistributorOrder> orders, bool isDark, AppLocalizations? l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        ),
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          columns: [
            DataColumn(
                label: Text(l10n?.distributorOrderNumber ?? 'Order #')),
            DataColumn(label: Text(l10n?.distributorStore ?? 'Store')),
            DataColumn(
              label: Text(l10n?.distributorDate ?? 'Date'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(l10n?.distributorAmount ?? 'Amount'),
              numeric: true,
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(l10n?.status ?? 'Status'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
          ],
          rows: orders.map((order) {
            return DataRow(
              onSelectChanged: (_) =>
                  context.go('/orders/${order.id}'),
              cells: [
                DataCell(Semantics(
                  label: '${l10n?.distributorOrderNumber ?? 'Order'} ${order.purchaseNumber}',
                  child: Text(
                    order.purchaseNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )),
                DataCell(Text(
                  order.storeName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )),
                DataCell(Text(
                  '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )),
                DataCell(Text(
                  '${NumberFormat('#,##0').format(order.total)} ${l10n?.distributorSar ?? 'SAR'}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                )),
                DataCell(
                  Semantics(
                    label: '${l10n?.status ?? 'Status'}: ${_statusLabel(order.status, l10n)}',
                    child: StatusBadge(
                      status: order.status,
                      label: _statusLabel(order.status, l10n),
                      isDark: isDark,
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
        return Semantics(
          button: true,
          label: '${order.purchaseNumber} - ${order.storeName} - ${_statusLabel(order.status, l10n)}',
          child: Card(
            margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
            ),
            elevation: isDark ? 0 : 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
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
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        StatusBadge(
                          status: order.status,
                          label: _statusLabel(order.status, l10n),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.xs),
                    Text(
                      order.storeName,
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
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
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                        Text(
                          '${NumberFormat('#,##0').format(order.total)} ${l10n?.distributorSar ?? 'SAR'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
