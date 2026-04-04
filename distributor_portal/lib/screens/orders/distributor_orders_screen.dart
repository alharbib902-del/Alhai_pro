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

  // Bulk selection state
  final Set<String> _selectedOrderIds = {};

  // Search state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
        case 3: // date (shifted by 1 due to checkbox column)
          result = a.createdAt.compareTo(b.createdAt);
        case 4: // amount
          result = a.total.compareTo(b.total);
        case 5: // status
          result = a.status.compareTo(b.status);
        default:
          result = 0;
      }
      return _sortAscending ? result : -result;
    });
    return sorted;
  }

  List<DistributorOrder> _filterOrders(List<DistributorOrder> orders) {
    if (_searchQuery.isEmpty) return orders;
    final query = _searchQuery.toLowerCase();
    return orders.where((order) {
      return order.storeName.toLowerCase().contains(query) ||
          order.purchaseNumber.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleSelectAll(List<DistributorOrder> orders) {
    setState(() {
      final pendingOrders =
          orders.where((o) => o.status == 'sent' || o.status == 'pending');
      final pendingIds = pendingOrders.map((o) => o.id).toSet();
      if (pendingIds.every(_selectedOrderIds.contains)) {
        _selectedOrderIds.removeAll(pendingIds);
      } else {
        _selectedOrderIds.addAll(pendingIds);
      }
    });
  }

  bool _allPendingSelected(List<DistributorOrder> orders) {
    final pendingOrders =
        orders.where((o) => o.status == 'sent' || o.status == 'pending');
    if (pendingOrders.isEmpty) return false;
    return pendingOrders.every((o) => _selectedOrderIds.contains(o.id));
  }

  Future<void> _bulkUpdateStatus(String newStatus) async {
    if (_selectedOrderIds.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    final actionLabel = newStatus == 'approved'
        ? (l10n?.distributorAcceptSendQuote ?? 'Accept')
        : (l10n?.distributorRejectOrder ?? 'Reject');
    final count = _selectedOrderIds.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionLabel $count orders?'),
        content: Text(
            'This will $actionLabel all $count selected orders. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  newStatus == 'approved' ? AppColors.success : AppColors.error,
            ),
            child: Text(actionLabel,
                style: const TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ds = ref.read(distributorDatasourceProvider);
    for (final orderId in _selectedOrderIds.toList()) {
      await ds.updateOrderStatus(orderId, newStatus);
    }

    if (!mounted) return;

    setState(() => _selectedOrderIds.clear());

    // Refresh orders
    final statusFilter = _tabStatuses[_tabController.index];
    ref.invalidate(ordersProvider(statusFilter));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newStatus == 'approved'
            ? '$count orders accepted'
            : '$count orders rejected'),
        backgroundColor:
            newStatus == 'approved' ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;
    final l10n = AppLocalizations.of(context);
    final padding = responsivePadding(width);

    final statusFilter = _tabStatuses[_tabController.index];
    final ordersAsync = ref.watch(ordersProvider(statusFilter));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                padding, padding, padding, 0),
            child: Text(
              l10n?.distributorOrders ?? 'Incoming Orders',
              style: TextStyle(
                fontSize: responsiveHeaderFontSize(width),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Semantics(
              label: l10n?.search ?? 'Search orders',
              textField: true,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Search by store name or order number...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: ExcludeSemantics(
                    child: Icon(Icons.search,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? Semantics(
                          button: true,
                          label: 'Clear search',
                          child: IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.md),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.md),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.md),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),

          // Tabs with order count per tab
          Container(
            margin: EdgeInsets.symmetric(horizontal: padding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {
                _selectedOrderIds.clear();
              }),
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
                    ExcludeSemantics(
                      child: Icon(Icons.error_outline, size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
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
                final filteredOrders = _filterOrders(orders);

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ExcludeSemantics(
                          child: Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.inbox_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No orders match your search'
                              : (l10n?.distributorNoOrders ?? 'No orders found'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                        if (_searchQuery.isEmpty)
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

                final sortedOrders = _sortOrders(filteredOrders);

                return Stack(
                  children: [
                    if (isWide)
                      _buildDataTable(sortedOrders, isDark, l10n)
                    else
                      _buildCardList(sortedOrders, isDark, l10n),

                    // Floating bulk action bar
                    if (_selectedOrderIds.isNotEmpty)
                      Positioned(
                        bottom: AlhaiSpacing.lg,
                        left: AlhaiSpacing.lg,
                        right: AlhaiSpacing.lg,
                        child: _buildBulkActionBar(isDark, l10n),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar(bool isDark, AppLocalizations? l10n) {
    return Semantics(
      label: '${_selectedOrderIds.length} orders selected. Bulk actions available.',
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        color: Theme.of(context).colorScheme.inverseSurface,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.mdl, vertical: AlhaiSpacing.sm),
          child: Row(
            children: [
              Text(
                '${_selectedOrderIds.length} selected',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: 'Accept all selected orders',
                child: FilledButton.icon(
                  onPressed: () => _bulkUpdateStatus('approved'),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(l10n?.distributorAcceptSendQuote ?? 'Accept All'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Semantics(
                button: true,
                label: 'Reject all selected orders',
                child: OutlinedButton.icon(
                  onPressed: () => _bulkUpdateStatus('rejected'),
                  icon: const Icon(Icons.cancel_rounded, size: 18),
                  label: Text(l10n?.distributorRejectOrder ?? 'Reject All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Semantics(
                button: true,
                label: 'Clear selection',
                child: IconButton(
                  onPressed: () => setState(() => _selectedOrderIds.clear()),
                  icon: Icon(Icons.close,
                      color: Theme.of(context).colorScheme.onInverseSurface),
                  tooltip: 'Clear selection',
                ),
              ),
            ],
          ),
        ),
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
    final allPendingSelected = _allPendingSelected(orders);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsivePadding(MediaQuery.sizeOf(context).width)),
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
              label: Semantics(
                label: 'Select all pending orders',
                child: Checkbox(
                  value: allPendingSelected,
                  onChanged: (_) => _toggleSelectAll(orders),
                  activeColor: AppColors.primary,
                ),
              ),
            ),
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
            final isPending =
                order.status == 'sent' || order.status == 'pending';
            final isSelected = _selectedOrderIds.contains(order.id);

            return DataRow(
              selected: isSelected,
              onSelectChanged: (_) =>
                  context.go('/orders/${order.id}'),
              cells: [
                DataCell(
                  isPending
                      ? Semantics(
                          label: 'Select order ${order.purchaseNumber}',
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (_) {
                              setState(() {
                                if (isSelected) {
                                  _selectedOrderIds.remove(order.id);
                                } else {
                                  _selectedOrderIds.add(order.id);
                                }
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
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
      padding: EdgeInsets.symmetric(horizontal: responsivePadding(MediaQuery.sizeOf(context).width)),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isPending =
            order.status == 'sent' || order.status == 'pending';
        final isSelected = _selectedOrderIds.contains(order.id);

        return Semantics(
          button: true,
          label: '${order.purchaseNumber} - ${order.storeName} - ${_statusLabel(order.status, l10n)}',
          child: Card(
            margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
            color: isSelected
                ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                : Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
              side: isSelected
                  ? const BorderSide(color: AppColors.primary, width: 1.5)
                  : BorderSide.none,
            ),
            elevation: isDark ? 0 : 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
              onTap: () => context.go('/orders/${order.id}'),
              onLongPress: isPending
                  ? () {
                      setState(() {
                        if (isSelected) {
                          _selectedOrderIds.remove(order.id);
                        } else {
                          _selectedOrderIds.add(order.id);
                        }
                      });
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isPending && _selectedOrderIds.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 8),
                                child: Semantics(
                                  label: 'Select order ${order.purchaseNumber}',
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (_) {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedOrderIds
                                                .remove(order.id);
                                          } else {
                                            _selectedOrderIds.add(order.id);
                                          }
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            Text(
                              order.purchaseNumber,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
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
