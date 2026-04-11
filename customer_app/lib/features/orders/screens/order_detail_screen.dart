import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';

import '../providers/orders_providers.dart';
import '../../../di/injection.dart';
import '../../checkout/data/orders_datasource.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    // Listen to real-time updates and auto-refresh order data
    ref.listen(orderRealtimeProvider(orderId), (prev, next) {
      next.whenData((data) {
        if (data != null) {
          ref.invalidate(orderDetailProvider(orderId));
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: AlhaiEmptyState.error(
            title: 'فشل تحميل الطلب',
            description: 'تحقق من اتصالك بالإنترنت',
            actionText: 'إعادة المحاولة',
            onAction: () => ref.invalidate(orderDetailProvider(orderId)),
          ),
        ),
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Card(
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
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildStatusChip(theme, order.status),
                        ],
                      ),
                      const SizedBox(height: AlhaiSpacing.xs),
                      Text(
                        _formatDate(order.createdAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Order status timeline
              Text(
                'حالة الطلب',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              _OrderTimeline(order: order),
              const SizedBox(height: AlhaiSpacing.md),

              // Items
              Text(
                'المنتجات',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              Card(
                child: Column(
                  children: order.items.map((item) {
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.unitPrice.toStringAsFixed(2)} ر.س × ${item.qty}',
                      ),
                      trailing: Text(
                        '${item.lineTotal.toStringAsFixed(2)} ر.س',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Totals
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  child: Column(
                    children: [
                      _TotalRow(
                        label: 'المجموع الفرعي',
                        value: '${order.subtotal.toStringAsFixed(2)} ر.س',
                      ),
                      if (order.discount > 0)
                        _TotalRow(
                          label: 'الخصم',
                          value: '-${order.discount.toStringAsFixed(2)} ر.س',
                        ),
                      _TotalRow(
                        label: 'التوصيل',
                        value: order.deliveryFee > 0
                            ? '${order.deliveryFee.toStringAsFixed(2)} ر.س'
                            : 'مجاني',
                      ),
                      const Divider(),
                      _TotalRow(
                        label: 'الإجمالي',
                        value: '${order.total.toStringAsFixed(2)} ر.س',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Actions
              if (order.canCancel)
                OutlinedButton(
                  onPressed: () => _cancelOrder(context, ref, order.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('إلغاء الطلب'),
                ),

              if (order.status == OrderStatus.outForDelivery)
                FilledButton(
                  onPressed: () => context.push('/orders/${order.id}/track'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('تتبع الطلب'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, OrderStatus status) {
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
        horizontal: AlhaiSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.displayNameAr,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _cancelOrder(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final datasource = locator<OrdersDatasource>();
        await datasource.cancelOrder(orderId);
        ref.invalidate(orderDetailProvider(orderId));
        ref.invalidate(ordersListProvider(null));
      } catch (_) {}
    }
  }
}

class _OrderTimeline extends StatelessWidget {
  final Order order;

  const _OrderTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = [
      (OrderStatus.created, 'تم الطلب', order.createdAt),
      (OrderStatus.confirmed, 'مؤكد', order.confirmedAt),
      (OrderStatus.preparing, 'قيد التحضير', order.preparingAt),
      (OrderStatus.ready, 'جاهز', order.readyAt),
      (OrderStatus.delivered, 'تم التوصيل', order.deliveredAt),
    ];

    final currentIndex = steps.indexWhere((s) => s.$1 == order.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          children: List.generate(steps.length, (index) {
            final (status, label, timestamp) = steps[index];
            final isComplete = index <= currentIndex;
            final isCurrent = index == currentIndex;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isComplete
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: isComplete
                          ? Icon(
                              Icons.check,
                              size: 14,
                              color: theme.colorScheme.onPrimary,
                            )
                          : null,
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 2,
                        height: 32,
                        color: isComplete
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                  ],
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AlhaiSpacing.md),
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isCurrent ? FontWeight.bold : null,
                        color: isComplete ? null : theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
