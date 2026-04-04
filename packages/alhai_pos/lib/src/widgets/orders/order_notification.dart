import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../models/online_order.dart';
import '../../providers/online_orders_provider.dart';

/// Popup إشعار الطلب الجديد
/// 
/// إشعار غير مزعج يظهر في زاوية الشاشة
class OrderNotificationPopup extends StatefulWidget {
  final OnlineOrder order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onDetails;
  final VoidCallback? onDismiss;
  final Duration autoDismissDuration;

  const OrderNotificationPopup({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
    this.onDetails,
    this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 15),
  });

  @override
  State<OrderNotificationPopup> createState() => _OrderNotificationPopupState();
}

class _OrderNotificationPopupState extends State<OrderNotificationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AlhaiDurations.slow,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AlhaiMotion.scaleUp,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.autoDismissDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1.0; // Skip to end state
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AlhaiSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        color: AppColors.warning,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.newOrderNotification(widget.order.id),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.now,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _dismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      tooltip: l10n.close,
                    ),
                  ],
                ),

                const SizedBox(height: AlhaiSpacing.sm),
                const Divider(),
                const SizedBox(height: AlhaiSpacing.sm),

                // Customer Info
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(widget.order.customerName),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(widget.order.customerPhone),
                  ],
                ),

                const SizedBox(height: AlhaiSpacing.sm),

                // Payment & Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxs),
                      decoration: BoxDecoration(
                        color: widget.order.isPaid
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.order.paymentStatus.icon),
                          const SizedBox(width: AlhaiSpacing.xxs),
                          Text(
                            widget.order.paymentStatus.arabicName,
                            style: TextStyle(
                              color: widget.order.isPaid ? AppColors.success : AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.priceSar(widget.order.total.toStringAsFixed(2)),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AlhaiSpacing.xs),

                // Items count
                Text(
                  '📦 ${AppLocalizations.of(context)!.productCountItems(widget.order.itemCount)}',
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: AlhaiSpacing.md),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _dismiss();
                          widget.onReject?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: Text(l10n.reject),
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _dismiss();
                          widget.onDetails?.call();
                        },
                        child: Text(l10n.details),
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: () {
                          _dismiss();
                          widget.onAccept?.call();
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(l10n.accept),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
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
  }
}

/// Badge عدد الطلبات للـ AppBar
class OrdersBadge extends ConsumerWidget {
  final VoidCallback? onTap;
  
  const OrdersBadge({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(actionRequiredCountProvider);
    final hasNew = ref.watch(hasNewOrdersProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            hasNew ? Icons.notifications_active : Icons.shopping_bag_outlined,
            color: hasNew ? AppColors.warning : null,
          ),
          onPressed: onTap,
          tooltip: AppLocalizations.of(context)!.onlineOrdersTooltip,
        ),
        if (count > 0)
          PositionedDirectional(
            end: 4,
            top: 4,
            child: _AnimatedBadge(count: count, isNew: hasNew),
          ),
      ],
    );
  }
}

class _AnimatedBadge extends StatefulWidget {
  final int count;
  final bool isNew;

  const _AnimatedBadge({
    required this.count,
    required this.isNew,
  });

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AlhaiDurations.loadingCycle,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AlhaiMotion.spring,
    ));

    if (widget.isNew) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNew && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isNew && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: widget.isNew ? AppColors.error : AppColors.warning,
          borderRadius: BorderRadius.circular(10),
          boxShadow: widget.isNew
              ? [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          widget.count > 9 ? '9+' : widget.count.toString(),
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// مدير إشعارات الطلبات
class OrderNotificationManager {
  static OverlayEntry? _currentNotification;

  /// عرض إشعار طلب جديد
  static void showNewOrderNotification(
    BuildContext context,
    OnlineOrder order, {
    VoidCallback? onAccept,
    VoidCallback? onReject,
    VoidCallback? onDetails,
  }) {
    // إزالة الإشعار السابق إن وجد
    _currentNotification?.remove();

    _currentNotification = OverlayEntry(
      builder: (context) => PositionedDirectional(
        top: 80,
        start: 16,
        child: OrderNotificationPopup(
          order: order,
          onAccept: onAccept,
          onReject: onReject,
          onDetails: onDetails,
          onDismiss: () {
            _currentNotification?.remove();
            _currentNotification = null;
          },
        ),
      ),
    );

    Overlay.of(context).insert(_currentNotification!);
  }

  /// إخفاء الإشعار الحالي
  static void hideNotification() {
    _currentNotification?.remove();
    _currentNotification = null;
  }
}
