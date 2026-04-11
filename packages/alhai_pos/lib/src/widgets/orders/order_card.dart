import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../models/online_order.dart';

/// بطاقة الطلب الأونلاين
///
/// تعرض تفاصيل الطلب مع إجراءات سريعة
class OrderCard extends StatelessWidget {
  final OnlineOrder order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onPrint;
  final VoidCallback? onAssignDriver;

  const OrderCard({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
    this.onPrint,
    this.onAssignDriver,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: order.status == OrderStatus.pending ? 4 : 1,
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        duration: AlhaiDurations.slow,
        decoration: BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(color: _getStatusColor(order.status), width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            const Divider(height: 1),

            // Items
            _buildItemsList(context),

            const Divider(height: 1),

            // Footer with total and actions
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      color: order.status == OrderStatus.pending
          ? AppColors.warning.withValues(alpha: 0.1)
          : null,
      child: Row(
        children: [
          // Order ID & Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '#${order.id}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    if (order.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.newLabel,
                          style: const TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  _formatTime(order.createdAt, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.xs,
              vertical: AlhaiSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(order.status.icon, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: AlhaiSpacing.xxs),
                Text(
                  order.status.arabicName,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Info
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: theme.colorScheme.outline,
                semanticLabel: AppLocalizations.of(context).customer,
              ),
              const SizedBox(width: AlhaiSpacing.xxs),
              Flexible(
                child: Text(
                  order.customerName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Icon(
                Icons.phone_outlined,
                size: 16,
                color: theme.colorScheme.outline,
                semanticLabel: AppLocalizations.of(context).phone,
              ),
              const SizedBox(width: AlhaiSpacing.xxs),
              Flexible(
                child: Text(
                  order.customerPhone,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.xs),

          // Address
          if (order.customerAddress != null)
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: theme.colorScheme.outline,
                  semanticLabel: AppLocalizations.of(context).address,
                ),
                const SizedBox(width: AlhaiSpacing.xxs),
                Expanded(
                  child: Text(
                    order.customerAddress!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          const SizedBox(height: AlhaiSpacing.sm),

          // Items
          ...order.items
              .take(3)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.xs),
                      Expanded(
                        child: Text(
                          item.productName,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).priceSar(item.total.toStringAsFixed(2)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

          if (order.items.length > 3)
            Text(
              AppLocalizations.of(
                context,
              ).moreProductsLabel(order.items.length - 3),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      child: Column(
        children: [
          // Payment Status & Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Payment Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.xs,
                  vertical: AlhaiSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: order.isPaid
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(order.paymentStatus.icon),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    Text(
                      order.paymentStatus.arabicName,
                      style: TextStyle(
                        color: order.isPaid
                            ? AppColors.success
                            : AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.total,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).priceSar(order.total.toStringAsFixed(2)),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.sm),

          // Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close, size: 18),
                label: Text(l10n.reject),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () {
                  onAccept?.call();
                  onPrint?.call();
                },
                icon: const Icon(Icons.check, size: 18),
                label: Text(AppLocalizations.of(context).acceptAndPrint),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
              ),
            ),
          ],
        );

      case OrderStatus.accepted:
      case OrderStatus.preparing:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrint,
                icon: const Icon(Icons.print, size: 18),
                label: Text(l10n.print),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: onAssignDriver,
                icon: const Icon(Icons.delivery_dining, size: 18),
                label: Text(AppLocalizations.of(context).deliverToDriver),
              ),
            ),
          ],
        );

      case OrderStatus.outForDelivery:
        return Row(
          children: [
            Icon(
              Icons.delivery_dining,
              color: Theme.of(context).colorScheme.tertiary,
              semanticLabel: AppLocalizations.of(context).onTheWayStatus,
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).onTheWayStatus,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (order.driverName != null)
                    Text(
                      AppLocalizations.of(
                        context,
                      ).driverNameLabel(order.driverName!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

      case OrderStatus.delivered:
        return Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              semanticLabel: AppLocalizations.of(context).deliveredStatus,
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Text(
              AppLocalizations.of(context).deliveredStatus,
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );

      case OrderStatus.cancelled:
        return Row(
          children: [
            Icon(
              Icons.cancel,
              color: AppColors.error,
              semanticLabel: l10n.cancelled,
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cancelled,
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (order.cancellationReason != null)
                    Text(
                      order.cancellationReason!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Color _getStatusColor(OrderStatus status) {
    // Status colors for order pipeline badges
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.accepted:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.warning;
      case OrderStatus.outForDelivery:
        return Colors.purple; // pipeline status color
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _formatTime(DateTime time, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return l10n.now;
    } else if (diff.inMinutes < 60) {
      return l10n.agoMinutes(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.agoHours(diff.inHours);
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
