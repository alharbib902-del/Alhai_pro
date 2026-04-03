import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';

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
        body: TabBarView(
          children: [
            _OrdersList(statuses: [
              OrderStatus.created,
              OrderStatus.confirmed,
              OrderStatus.preparing,
              OrderStatus.ready,
              OrderStatus.outForDelivery,
            ]),
            _OrdersList(statuses: [
              OrderStatus.delivered,
              OrderStatus.completed,
            ]),
            _OrdersList(statuses: [OrderStatus.cancelled]),
          ],
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
    // Use first status for query (simplified)
    final ordersAsync = ref.watch(ordersListProvider(null));

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('فشل تحميل الطلبات')),
      data: (paginated) {
        final orders = paginated.items
            .where((o) => statuses.contains(o.status))
            .toList();

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: theme.colorScheme.outline),
                const SizedBox(height: AlhaiSpacing.md),
                Text('لا توجد طلبات', style: theme.textTheme.titleMedium),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ordersListProvider(null));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
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
                            Text(
                              order.displayNumber,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _StatusChip(status: order.status),
                          ],
                        ),
                        const SizedBox(height: AlhaiSpacing.xs),
                        if (order.storeName != null)
                          Text(
                            order.storeName!,
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
            },
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
    Color color;
    switch (status) {
      case OrderStatus.created:
      case OrderStatus.confirmed:
        color = Colors.orange;
      case OrderStatus.preparing:
      case OrderStatus.ready:
        color = Colors.blue;
      case OrderStatus.outForDelivery:
        color = Colors.indigo;
      case OrderStatus.delivered:
      case OrderStatus.completed:
      case OrderStatus.pickedUp:
        color = Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AlhaiSpacing.xxs),
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
