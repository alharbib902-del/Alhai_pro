/// Lite Order Detail Screen
///
/// Displays full order details including items, customer info,
/// status timeline, and action buttons. Queries ordersDao.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

import '../../providers/lite_screen_providers.dart';

/// Order detail view for Admin Lite
class LiteOrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const LiteOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(liteOrderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderDetails),
        centerTitle: true,
      ),
      body: dataAsync.when(
        data: (data) {
          if (data == null) {
            return Center(child: Text(l10n.noResults));
          }
          final order = data.order;
          final items = data.items;
          return SingleChildScrollView(
            padding:
                EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(context, isDark, l10n, order),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildItemsSection(context, isDark, l10n, items),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildTimeline(context, isDark, l10n, order),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildTotals(context, isDark, l10n, order),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildActions(context, isDark, l10n, order, ref),
                const SizedBox(height: AlhaiSpacing.lg),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorOccurred),
              TextButton.icon(
                onPressed: () =>
                    ref.invalidate(liteOrderDetailProvider(orderId)),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'created' || 'confirmed' => AlhaiColors.info,
      'preparing' => AlhaiColors.warning,
      'ready' => AlhaiColors.success,
      'out_for_delivery' => AlhaiColors.primary,
      'delivered' => AlhaiColors.success,
      'cancelled' => AlhaiColors.error,
      _ => AlhaiColors.info,
    };
  }

  Widget _buildStatusCard(BuildContext context, bool isDark,
      AppLocalizations l10n, OrdersTableData order) {
    final color = _statusColor(order.status);
    final time =
        '${order.orderDate.hour.toString().padLeft(2, '0')}:${order.orderDate.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.check_circle, color: color, size: 24),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.orderNumber}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : color),
                ),
                Text(
                  '$time \u2022 ${order.status}',
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.white54
                          : color.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, bool isDark,
      AppLocalizations l10n, List<OrderItemWithProduct> items) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white12
                : Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.products,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : null)),
              const Spacer(),
              Text(l10n.nItems(items.length),
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(item.productName,
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(context).colorScheme.onSurface))),
                    Text('x${item.qty.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                    const SizedBox(width: AlhaiSpacing.md),
                    Text('${item.total.toStringAsFixed(0)} ${l10n.sar}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, bool isDark,
      AppLocalizations l10n, OrdersTableData order) {
    final steps = [
      _TimelineStep(l10n.orderStatusConfirmed, order.confirmedAt),
      _TimelineStep(l10n.orderStatusPreparing, order.preparingAt),
      _TimelineStep(l10n.orderStatusReady, order.readyAt),
      _TimelineStep(l10n.orderStatusDelivering, order.deliveringAt),
      _TimelineStep(l10n.completed, order.deliveredAt),
    ];

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white12
                : Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.status,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : null)),
          const SizedBox(height: AlhaiSpacing.md),
          ...steps.asMap().entries.map((entry) {
            final step = entry.value;
            final isLast = entry.key == steps.length - 1;
            final completed = step.timestamp != null;
            final timeStr = step.timestamp != null
                ? '${step.timestamp!.hour.toString().padLeft(2, '0')}:${step.timestamp!.minute.toString().padLeft(2, '0')}'
                : '';
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: completed
                            ? AlhaiColors.success
                            : (isDark
                                ? Colors.white12
                                : Theme.of(context).colorScheme.outlineVariant),
                        shape: BoxShape.circle,
                      ),
                      child: completed
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Container(
                          width: 2,
                          height: 24,
                          color: completed
                              ? AlhaiColors.success
                              : (isDark
                                  ? Colors.white12
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant)),
                  ],
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                    child: Row(
                      children: [
                        Text(step.label,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: completed
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: completed
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.outline)),
                        if (timeStr.isNotEmpty) ...[
                          const Spacer(),
                          Text(timeStr,
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).colorScheme.outline)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotals(BuildContext context, bool isDark, AppLocalizations l10n,
      OrdersTableData order) {
    final vat = order.total * 0.15 / 1.15;
    final subtotal = order.total - vat;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white12
                : Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildTotalRow(l10n.subtotal,
              '${subtotal.toStringAsFixed(0)} ${l10n.sar}', isDark, context),
          _buildTotalRow(l10n.vat, '${vat.toStringAsFixed(0)} ${l10n.sar}',
              isDark, context),
          const Divider(height: AlhaiSpacing.lg),
          _buildTotalRow(l10n.grandTotal,
              '${order.total.toStringAsFixed(0)} ${l10n.sar}', isDark, context,
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
      String label, String value, bool isDark, BuildContext context,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 16 : 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: isBold ? 18 : 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark, AppLocalizations l10n,
      OrdersTableData order, WidgetRef ref) {
    if (order.status == 'delivered' || order.status == 'cancelled') {
      return const SizedBox.shrink();
    }

    final nextStatus = switch (order.status) {
      'created' => 'confirmed',
      'confirmed' => 'preparing',
      'preparing' => 'ready',
      'ready' => 'out_for_delivery',
      'out_for_delivery' => 'delivered',
      _ => null,
    };

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final db = GetIt.I<AppDatabase>();
              await db.ordersDao.cancelOrder(order.id, l10n.cancelledByAdmin);
              if (context.mounted) {
                ref.invalidate(liteOrderDetailProvider(orderId));
                ref.invalidate(liteActiveOrdersProvider);
              }
            },
            icon: const Icon(Icons.close, size: 18),
            label: Text(l10n.cancel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AlhaiColors.error,
              side: const BorderSide(color: AlhaiColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (nextStatus != null) ...[
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                final db = GetIt.I<AppDatabase>();
                await db.ordersDao.updateOrderStatus(order.id, nextStatus);
                if (context.mounted) {
                  ref.invalidate(liteOrderDetailProvider(orderId));
                  ref.invalidate(liteActiveOrdersProvider);
                }
              },
              icon: const Icon(Icons.check, size: 18),
              label: Text(l10n.next),
              style: FilledButton.styleFrom(
                backgroundColor: AlhaiColors.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TimelineStep {
  final String label;
  final DateTime? timestamp;
  const _TimelineStep(this.label, this.timestamp);
}
