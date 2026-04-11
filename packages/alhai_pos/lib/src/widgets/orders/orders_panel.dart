import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart'
    hide OrderStatus, PaymentStatus;
import 'package:get_it/get_it.dart';
import '../../models/online_order.dart';
import '../../providers/online_orders_provider.dart';
import 'order_card.dart';

/// لوحة الطلبات الأونلاين
///
/// تعرض الطلبات الواردة مع إجراءات سريعة
class OrdersPanel extends ConsumerWidget {
  final VoidCallback? onClose;

  const OrdersPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(onlineOrdersProvider);
    final theme = Theme.of(context);

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: BorderDirectional(
          end: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, ref, ordersState),

          // Status Tabs
          _buildStatusTabs(context, ordersState),

          // Orders List
          Expanded(
            child: ordersState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ordersState.orders.isEmpty
                ? _buildEmptyState(context)
                : _buildOrdersList(context, ref, ordersState),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    OnlineOrdersState state,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onlineOrdersTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  l10n.pendingOrdersCount(state.pendingOrders.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(onlineOrdersProvider.notifier).refreshOrders(),
            tooltip: l10n.refresh,
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              tooltip: l10n.close,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(BuildContext context, OnlineOrdersState state) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _StatusChip(
              label: l10n.all,
              count: state.orders.length,
              isSelected: true,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            _StatusChip(
              label: l10n.newLabel,
              count: state.pendingOrders.length,
              color: AlhaiColors.warning,
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            _StatusChip(
              label: l10n.inPreparationTab,
              count: state.preparingOrders.length,
              color: AlhaiColors.info,
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            _StatusChip(
              label: l10n.inDeliveryTab,
              count: state.deliveryOrders.length,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noOrdersMessage,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            l10n.newOrdersAppearHere,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    WidgetRef ref,
    OnlineOrdersState state,
  ) {
    // ترتيب الطلبات: المعلقة أولاً ثم بالوقت
    final sortedOrders = [...state.orders]
      ..sort((a, b) {
        if (a.status == OrderStatus.pending &&
            b.status != OrderStatus.pending) {
          return -1;
        }
        if (b.status == OrderStatus.pending &&
            a.status != OrderStatus.pending) {
          return 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(AlhaiSpacing.xs),
      itemCount: sortedOrders.length,
      itemBuilder: (context, index) {
        final order = sortedOrders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
          child: OrderCard(
            order: order,
            onAccept: () =>
                ref.read(onlineOrdersProvider.notifier).acceptOrder(order.id),
            onReject: () => _showRejectDialog(context, ref, order),
            onPrint: () => _printOrder(context, order),
            onAssignDriver: () => _showDriverDialog(context, ref, order),
          ),
        );
      },
    );
  }

  void _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    OnlineOrder order,
  ) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rejectOrderTitle),
        content: Text(l10n.rejectOrderConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(onlineOrdersProvider.notifier)
                  .cancelOrder(order.id, reason: l10n.rejectedBySeller);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.reject),
          ),
        ],
      ),
    );
  }

  void _printOrder(BuildContext context, OnlineOrder order) {
    final l10n = AppLocalizations.of(context);

    // TODO: طباعة الفاتورة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.printingOrderMessage(order.id)),
        action: SnackBarAction(label: l10n.done, onPressed: () {}),
      ),
    );
  }

  void _showDriverDialog(
    BuildContext context,
    WidgetRef ref,
    OnlineOrder order,
  ) {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    final db = GetIt.I<AppDatabase>();

    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<List<DriversTableData>>(
        future:
            (db.select(db.driversTable)
                  ..where(
                    (d) => d.storeId.equals(storeId) & d.isActive.equals(true),
                  )
                  ..orderBy([(d) => OrderingTerm.asc(d.name)]))
                .get(),
        builder: (ctx, snapshot) {
          final l10n = AppLocalizations.of(ctx);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              title: Text(l10n.selectDriverTitle),
              content: const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final drivers = snapshot.data ?? [];

          if (drivers.isEmpty) {
            return AlertDialog(
              title: Text(l10n.selectDriverTitle),
              content: const Padding(
                padding: EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                child: Center(child: Text('No active drivers found')),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.close),
                ),
              ],
            );
          }

          return AlertDialog(
            title: Text(l10n.selectDriverTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: drivers
                  .map(
                    (driver) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(driver.name),
                      subtitle: driver.phone != null
                          ? Text(driver.phone!)
                          : null,
                      onTap: () {
                        ref
                            .read(onlineOrdersProvider.notifier)
                            .assignDriver(order.id, driver.id, driver.name);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.orderDeliveredToDriver(driver.name),
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

/// شريحة الحالة
class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.count,
    this.isSelected = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? color : Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
