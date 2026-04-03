/// Lite Order Alerts Screen
///
/// Displays order-related alerts: new orders, delayed orders,
/// cancellations, and returns needing attention.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Order alerts screen for Admin Lite
class LiteOrderAlertsScreen extends StatelessWidget {
  const LiteOrderAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders),
        centerTitle: true,
      ),
      body: _alerts.isEmpty
          ? _buildEmptyState(context, isDark, l10n)
          : ListView.builder(
              padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                return _buildAlertCard(context, _alerts[index], isDark);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: isDark ? Colors.white24 : Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noResults,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, _OrderAlert alert, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: alert.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(alert.icon, color: alert.color, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      alert.orderNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
                decoration: BoxDecoration(
                  color: alert.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: alert.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            alert.description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: isDark ? Colors.white24 : Colors.black38),
              const SizedBox(width: AlhaiSpacing.xxs),
              Text(
                alert.time,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white24 : Colors.black38,
                ),
              ),
              const Spacer(),
              Text(
                alert.amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _alerts = [
    _OrderAlert(
      title: 'New Online Order',
      orderNumber: '#ORD-1052',
      description: 'Customer waiting for confirmation',
      status: 'NEW',
      time: '5 min ago',
      amount: '245 SAR',
      icon: Icons.fiber_new,
      color: AlhaiColors.info,
    ),
    _OrderAlert(
      title: 'Delayed Delivery',
      orderNumber: '#ORD-1048',
      description: 'Delivery overdue by 30 minutes',
      status: 'LATE',
      time: '35 min ago',
      amount: '180 SAR',
      icon: Icons.schedule,
      color: AlhaiColors.warning,
    ),
    _OrderAlert(
      title: 'Cancellation Request',
      orderNumber: '#ORD-1045',
      description: 'Customer requested order cancellation',
      status: 'CANCEL',
      time: '1 hour ago',
      amount: '92 SAR',
      icon: Icons.cancel_outlined,
      color: AlhaiColors.error,
    ),
    _OrderAlert(
      title: 'Return Request',
      orderNumber: '#ORD-1040',
      description: 'Items returned, pending refund approval',
      status: 'RETURN',
      time: '2 hours ago',
      amount: '155 SAR',
      icon: Icons.undo,
      color: Colors.orange,
    ),
  ];
}

class _OrderAlert {
  final String title;
  final String orderNumber;
  final String description;
  final String status;
  final String time;
  final String amount;
  final IconData icon;
  final Color color;

  const _OrderAlert({
    required this.title,
    required this.orderNumber,
    required this.description,
    required this.status,
    required this.time,
    required this.amount,
    required this.icon,
    required this.color,
  });
}
