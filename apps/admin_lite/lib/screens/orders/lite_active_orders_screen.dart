/// Lite Active Orders Screen
///
/// Shows currently active orders with status indicators,
/// filtering by status, queried from ordersDao.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../providers/lite_screen_providers.dart';

/// Active orders list for Admin Lite
class LiteActiveOrdersScreen extends ConsumerStatefulWidget {
  const LiteActiveOrdersScreen({super.key});

  @override
  ConsumerState<LiteActiveOrdersScreen> createState() => _LiteActiveOrdersScreenState();
}

class _LiteActiveOrdersScreenState extends ConsumerState<LiteActiveOrdersScreen> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(liteActiveOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(liteActiveOrdersProvider),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.sync,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(isDark, l10n),
          Expanded(
            child: dataAsync.when(
              data: (orders) {
                final filtered = _filterOrders(orders);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(l10n.noResults, style: TextStyle(color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(liteActiveOrdersProvider),
                  child: ListView.builder(
                    padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return KeyedSubtree(
                        key: ValueKey(order.id),
                        child: _buildOrderCard(context, order, isDark),
                      );
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
                      onPressed: () => ref.invalidate(liteActiveOrdersProvider),
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

  List<OrderWithCustomer> _filterOrders(List<OrderWithCustomer> orders) {
    if (_filterIndex == 0) return orders;
    final statusFilter = ['confirmed', 'preparing', 'ready', 'out_for_delivery'][_filterIndex - 1];
    return orders.where((o) => o.status == statusFilter).toList();
  }

  Widget _buildFilterTabs(bool isDark, AppLocalizations l10n) {
    final filters = [
      l10n.all,
      l10n.orderStatusConfirmed,
      l10n.orderStatusPreparing,
      l10n.orderStatusReady,
      l10n.orderStatusDelivering,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final isSelected = _filterIndex == entry.key;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: AlhaiSpacing.xs),
              child: FilterChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (_) => setState(() => _filterIndex = entry.key),
                selectedColor: AlhaiColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AlhaiColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AlhaiColors.primary : (isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurface),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected ? AlhaiColors.primary : (isDark ? Colors.white24 : Theme.of(context).colorScheme.outlineVariant),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'confirmed' => AlhaiColors.info,
      'preparing' => AlhaiColors.warning,
      'ready' => AlhaiColors.success,
      'out_for_delivery' => AlhaiColors.primary,
      _ => AlhaiColors.info,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'confirmed' => 'Confirmed',
      'preparing' => 'Preparing',
      'ready' => 'Ready',
      'out_for_delivery' => 'Delivering',
      _ => status,
    };
  }

  Widget _buildOrderCard(BuildContext context, OrderWithCustomer order, bool isDark) {
    final statusColor = _statusColor(order.status);
    final statusLabel = _statusLabel(order.status);
    final time = '${order.orderDate.hour.toString().padLeft(2, '0')}:${order.orderDate.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () => context.go('/lite/orders/${order.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Theme.of(context).colorScheme.surface,
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
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt_long, color: statusColor, size: 20),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.orderNumber}',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      Text(
                        order.customerName ?? '',
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AlhaiSpacing.xxxs),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: AlhaiSpacing.xxs),
                Text(time, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                const Spacer(),
                Text(
                  '${order.total.toStringAsFixed(0)} SAR',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
