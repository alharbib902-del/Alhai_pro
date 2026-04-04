/// Lite Delivery Tracking Screen
///
/// Shows active deliveries queried from ordersDao
/// (out_for_delivery status). Supports RTL, dark mode,
/// and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../providers/lite_screen_providers.dart';

/// Delivery tracking screen for Admin Lite
class LiteDeliveryTrackingScreen extends ConsumerWidget {
  const LiteDeliveryTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(liteDeliveryOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.delivery),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMapPlaceholder(context, isDark, l10n),
          Expanded(
            child: dataAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Text(l10n.noResults, style: TextStyle(color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(liteDeliveryOrdersProvider),
                  child: ListView.builder(
                    padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _buildDeliveryCard(context, orders[index], isDark);
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
                      onPressed: () => ref.invalidate(liteDeliveryOrdersProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      height: 180,
      width: double.infinity,
      color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: isDark ? Colors.white24 : Colors.grey.shade400),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(l10n.trackingMap, style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'out_for_delivery' => AlhaiColors.primary,
      'delivered' => AlhaiColors.success,
      _ => AlhaiColors.info,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'out_for_delivery' => 'On Route',
      'delivered' => 'Completed',
      _ => status,
    };
  }

  Widget _buildDeliveryCard(BuildContext context, OrderWithCustomer order, bool isDark) {
    final color = _statusColor(order.status);
    final label = _statusLabel(order.status);
    final time = '${order.orderDate.hour.toString().padLeft(2, '0')}:${order.orderDate.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AlhaiColors.primary.withValues(alpha: 0.15),
                child: const Icon(Icons.local_shipping, color: AlhaiColors.primary, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                    Text('#${order.orderNumber}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AlhaiSpacing.xxxs),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Row(
            children: [
              _DetailChip(Icons.access_time, time, isDark, context),
              const SizedBox(width: AlhaiSpacing.xs),
              _DetailChip(Icons.attach_money, '${order.total.toStringAsFixed(0)} SAR', isDark, context),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final BuildContext parentContext;

  const _DetailChip(this.icon, this.label, this.isDark, this.parentContext);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Theme.of(parentContext).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white38 : Theme.of(parentContext).colorScheme.onSurfaceVariant),
          const SizedBox(width: AlhaiSpacing.xxs),
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Theme.of(parentContext).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
