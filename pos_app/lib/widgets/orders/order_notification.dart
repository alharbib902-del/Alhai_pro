import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';
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
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.5),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب جديد #${widget.order.id}',
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
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Customer Info
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 8),
                    Text(widget.order.customerName),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16),
                    const SizedBox(width: 8),
                    Text(widget.order.customerPhone),
                  ],
                ),

                const SizedBox(height: 12),

                // Payment & Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.order.isPaid
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.order.paymentStatus.icon),
                          const SizedBox(width: 4),
                          Text(
                            widget.order.paymentStatus.arabicName,
                            style: TextStyle(
                              color: widget.order.isPaid ? Colors.green : Colors.amber[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${widget.order.total.toStringAsFixed(2)} ر.س',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Items count
                Text(
                  '📦 ${widget.order.itemCount} منتج',
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 16),

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
                          foregroundColor: Colors.red,
                        ),
                        child: Text(l10n.reject),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _dismiss();
                          widget.onDetails?.call();
                        },
                        child: Text(l10n.details),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          backgroundColor: Colors.green,
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
            color: hasNew ? Colors.orange : null,
          ),
          onPressed: onTap,
          tooltip: 'الطلبات الأونلاين',
        ),
        if (count > 0)
          Positioned(
            right: 4,
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
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
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
          color: widget.isNew ? Colors.red : Colors.orange,
          borderRadius: BorderRadius.circular(10),
          boxShadow: widget.isNew
              ? [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          widget.count > 9 ? '9+' : widget.count.toString(),
          style: const TextStyle(
            color: Colors.white,
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
      builder: (context) => Positioned(
        top: 80,
        left: 16,
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
