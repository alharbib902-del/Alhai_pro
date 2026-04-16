import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/utils/responsive_helper.dart';
import '../providers/orders_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلباتي'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'نشطة'),
              Tab(text: 'مكتملة'),
              Tab(text: 'ملغية'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: TabBarView(
            children: const [
              _OrdersList(
                statuses: [
                  OrderStatus.created,
                  OrderStatus.confirmed,
                  OrderStatus.preparing,
                  OrderStatus.ready,
                  OrderStatus.outForDelivery,
                ],
              ),
              _OrdersList(
                statuses: [OrderStatus.delivered, OrderStatus.completed],
              ),
              _OrdersList(statuses: [OrderStatus.cancelled]),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final List<OrderStatus> statuses;

  const _OrdersList({required this.statuses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusNames = statuses.map((s) => s.name).toList();
    final ordersAsync = ref.watch(ordersListByStatusesProvider(statusNames));

    return ordersAsync.when(
      loading: () => AlhaiShimmer(
        child: ListView.builder(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          itemCount: 5,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
            child: AlhaiSkeleton.listTile(),
          ),
        ),
      ),
      error: (_, __) => Center(
        child: AlhaiEmptyState.error(
          title: 'فشل تحميل الطلبات',
          description: 'تحقق من اتصالك بالإنترنت',
          actionText: 'إعادة المحاولة',
          onAction: () =>
              ref.invalidate(ordersListByStatusesProvider(statusNames)),
        ),
      ),
      data: (paginated) {
        final orders = paginated.items;

        if (orders.isEmpty) {
          return Center(
            child: AlhaiEmptyState.noOrders(
              title: 'لا توجد طلبات',
              description: 'ستظهر طلباتك هنا',
              compact: true,
            ),
          );
        }

        Widget buildOrderCard(dynamic order) => Card(
          child: InkWell(
            onTap: () => context.push('/orders/${order.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          order.displayNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _StatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  if (order.storeName != null)
                    Text(
                      order.storeName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.itemCount} منتجات',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        '${order.total.toStringAsFixed(2)} ر.س',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        final isTablet = ResponsiveHelper.isTablet(context);

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ordersListByStatusesProvider(statusNames));
          },
          child: isTablet
              ? GridView.builder(
                  padding: const EdgeInsets.all(AlhaiSpacing.lg),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isLargeTablet(context)
                        ? 3
                        : 2,
                    crossAxisSpacing: AlhaiSpacing.sm,
                    mainAxisSpacing: AlhaiSpacing.sm,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) =>
                      buildOrderCard(orders[index]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                    child: buildOrderCard(orders[index]),
                  ),
                ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<AlhaiStatusColors>()!;
    Color color;
    switch (status) {
      case OrderStatus.created:
      case OrderStatus.confirmed:
        color = statusColors.warning;
      case OrderStatus.preparing:
      case OrderStatus.ready:
        color = statusColors.info;
      case OrderStatus.outForDelivery:
        color = theme.colorScheme.primary;
      case OrderStatus.delivered:
      case OrderStatus.completed:
      case OrderStatus.pickedUp:
        color = statusColors.success;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        color = statusColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayNameAr,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
