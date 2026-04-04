import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../providers/purchases_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Purchases List Screen - شاشة قائمة طلبات الشراء
class PurchasesListScreen extends ConsumerStatefulWidget {
  const PurchasesListScreen({super.key});

  @override
  ConsumerState<PurchasesListScreen> createState() =>
      _PurchasesListScreenState();
}

class _PurchasesListScreenState extends ConsumerState<PurchasesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = ['all', 'draft', 'sent', 'approved', 'received'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Returns the localized label for each tab
  String _tabLabel(String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'all':
        return l10n.statusAll;
      case 'draft':
        return l10n.statusDraft;
      case 'sent':
        return l10n.statusSent;
      case 'approved':
        return l10n.statusApprovedShort;
      case 'received':
        return l10n.statusReceived;
      default:
        return key;
    }
  }

  /// Returns badge color per status
  static Color statusColor(String status) {
    switch (status) {
      case 'draft':
        return AppColors.textSecondary;
      case 'sent':
        return AppColors.info;
      case 'approved':
        return AppColors.success;
      case 'received':
        return AppColors.credit;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Returns the localized label for a status
  static String statusLabel(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case 'draft':
        return l10n.statusDraft;
      case 'sent':
        return l10n.statusSent;
      case 'approved':
        return l10n.statusApprovedShort;
      case 'received':
        return l10n.statusReceived;
      case 'completed':
        return l10n.statusCompleted;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = AlhaiBreakpoints.isDesktop(size.width);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.purchaseOrders,
          onMenuTap: isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () =>
              context.push(AppRoutes.notificationsCenter),
          notificationsCount: 0,
          userName: l10n.cashCustomer,
          userRole: l10n.branchManager,
        ),
        // Tab bar
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            tabs: _tabs.map((t) => Tab(text: _tabLabel(t))).toList(),
          ),
        ),
        Divider(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              if (tab == 'all') {
                return _AllPurchasesTab(isWide: isWide, isDark: isDark);
              }
              return _FilteredPurchasesTab(
                status: tab,
                isWide: isWide,
                isDark: isDark,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ALL tab - uses purchasesListProvider
// ---------------------------------------------------------------------------
class _AllPurchasesTab extends ConsumerWidget {
  final bool isWide;
  final bool isDark;

  const _AllPurchasesTab({required this.isWide, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPurchases = ref.watch(purchasesListProvider);
    return asyncPurchases.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AlhaiSpacing.md),
        child: ShimmerList(itemCount: 6, itemHeight: 72),
      ),
      error: (e, _) => _ErrorView(error: e.toString()),
      data: (purchases) {
        if (purchases.isEmpty) return const _EmptyView();
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(purchasesListProvider),
          color: AppColors.primary,
          child: _PurchasesContent(
            purchases: purchases,
            isWide: isWide,
            isDark: isDark,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Filtered tab - uses purchasesByStatusProvider
// ---------------------------------------------------------------------------
class _FilteredPurchasesTab extends ConsumerWidget {
  final String status;
  final bool isWide;
  final bool isDark;

  const _FilteredPurchasesTab({
    required this.status,
    required this.isWide,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPurchases = ref.watch(purchasesByStatusProvider(status));
    return asyncPurchases.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AlhaiSpacing.md),
        child: ShimmerList(itemCount: 6, itemHeight: 72),
      ),
      error: (e, _) => _ErrorView(error: e.toString()),
      data: (purchases) {
        if (purchases.isEmpty) return const _EmptyView();
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(purchasesByStatusProvider(status)),
          color: AppColors.primary,
          child: _PurchasesContent(
            purchases: purchases,
            isWide: isWide,
            isDark: isDark,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Content - responsive: DataTable on wide, cards on mobile
// ---------------------------------------------------------------------------
class _PurchasesContent extends StatelessWidget {
  final List<PurchasesTableData> purchases;
  final bool isWide;
  final bool isDark;

  const _PurchasesContent({
    required this.purchases,
    required this.isWide,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        isWide ? _buildDataTable(context) : _buildCardList(context),
        // FAB
        Positioned(
          bottom: 24,
          left: 24,
          child: FloatingActionButton.extended(
            heroTag: 'purchases_fab',
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context).newPurchaseOrder),
            onPressed: () => context.go(AppRoutes.purchaseForm),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        // M123: wrap DataTable with horizontal scroll for mobile overflow
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              isDark ? Theme.of(context).colorScheme.surface : AppColors.grey50,
            ),
            columns: [
              DataColumn(label: Text(AppLocalizations.of(context).orderNumberColumn)),
              DataColumn(label: Text(AppLocalizations.of(context).supplierInfoLabel)),
              DataColumn(label: Text(AppLocalizations.of(context).statusColumn)),
              DataColumn(label: Text(AppLocalizations.of(context).totalLabel)),
              DataColumn(label: Text(AppLocalizations.of(context).dateLabel)),
            ],
            rows: purchases.map((p) {
              return DataRow(
                onSelectChanged: (_) =>
                    context.go(AppRoutes.purchaseDetailPath(p.id)),
                cells: [
                  DataCell(Text(
                    p.purchaseNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )),
                  DataCell(Text(
                    p.supplierName ?? '-',
                    style: TextStyle(
                      color: isDark
                          ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                    ),
                  )),
                  DataCell(_StatusBadge(
                    status: p.status,
                    isDark: isDark,
                  )),
                  DataCell(Text(
                    AppLocalizations.of(context).amountSar(p.total.toStringAsFixed(2)),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primaryDark,
                    ),
                  )),
                  DataCell(Text(
                    dateFormat.format(p.createdAt),
                    style: TextStyle(
                      color: isDark
                          ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                          : AppColors.textTertiary,
                    ),
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardList(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 80),
      itemCount: purchases.length,
      separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.sm),
      itemBuilder: (context, index) {
        final p = purchases[index];
        return GestureDetector(
          onTap: () => context.go(AppRoutes.purchaseDetailPath(p.id)),
          child: Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: PO number + status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p.purchaseNumber,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _StatusBadge(
                      status: p.status,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                // Supplier
                Row(
                  children: [
                    Icon(
                      Icons.store_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p.supplierName ?? '-',
                        style: TextStyle(
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                // Bottom row: total + date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).amountSar(p.total.toStringAsFixed(2)),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      dateFormat.format(p.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge chip
// ---------------------------------------------------------------------------
class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isDark;

  const _StatusBadge({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = _PurchasesListScreenState.statusColor(status);
    final label = _PurchasesListScreenState.statusLabel(status, context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? color.withValues(alpha: 0.9) : color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: l10n.noPurchaseOrders,
      description: l10n.createPurchaseToStart,
      actionText: l10n.createPurchaseOrder,
      onAction: () => context.go(AppRoutes.purchaseForm),
      actionIcon: Icons.add,
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              AppLocalizations.of(context).errorLoadingData,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
