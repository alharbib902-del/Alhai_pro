/// Lite Order Alerts Screen
///
/// Displays order-related alerts: new orders and pending orders,
/// queried from ordersDao with created/confirmed status.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../providers/lite_screen_providers.dart';

/// Order alerts screen for Admin Lite
class LiteOrderAlertsScreen extends ConsumerWidget {
  const LiteOrderAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(liteOrderAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders),
        centerTitle: true,
      ),
      body: dataAsync.when(
        data: (orders) {
          if (orders.isEmpty) return _buildEmptyState(context, isDark, l10n);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(liteOrderAlertsProvider),
            child: ListView.builder(
              padding:
                  EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildAlertCard(context, orders[index], isDark, l10n);
              },
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
                  onPressed: () => ref.invalidate(liteOrderAlertsProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.tryAgain)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 64,
              color: isDark
                  ? Colors.white24
                  : Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AlhaiSpacing.md),
          Text(l10n.noResults,
              style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? Colors.white54
                      : Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'created' => AlhaiColors.info,
      'confirmed' => AlhaiColors.warning,
      _ => AlhaiColors.primary,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'created' => 'NEW',
      'confirmed' => 'PENDING',
      _ => status.toUpperCase(),
    };
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildAlertCard(BuildContext context, OrderWithCustomer order,
      bool isDark, AppLocalizations l10n) {
    final color = _statusColor(order.status);
    final label = _statusLabel(order.status);
    final icon = order.status == 'created' ? Icons.fiber_new : Icons.schedule;

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        order.status == 'created'
                            ? 'New Online Order'
                            : 'Pending Order',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87)),
                    Text('#${order.orderNumber}',
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white38
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            order.customerName != null
                ? 'Customer: ${order.customerName}'
                : 'Waiting for confirmation',
            style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Colors.white54
                    : Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 14, color: isDark ? Colors.white24 : Colors.black38),
              const SizedBox(width: AlhaiSpacing.xxs),
              Text(_timeAgo(order.orderDate),
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white24 : Colors.black38)),
              const Spacer(),
              Text('${order.total.toStringAsFixed(0)} SAR',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}
