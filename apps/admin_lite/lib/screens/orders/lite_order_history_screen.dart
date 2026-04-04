/// Lite Order History Screen
///
/// Shows completed/cancelled orders queried from ordersDao.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../providers/lite_screen_providers.dart';

/// Order history screen for Admin Lite
class LiteOrderHistoryScreen extends ConsumerWidget {
  const LiteOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(liteOrderHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderHistory),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(liteOrderHistoryProvider),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.sync,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: dataAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Text(l10n.noResults, style: TextStyle(color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(liteOrderHistoryProvider),
            child: ListView.builder(
              padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final showHeader = index == 0 || _dateKey(order.orderDate) != _dateKey(orders[index - 1].orderDate);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs, top: AlhaiSpacing.sm),
                        child: Text(
                          _formatDate(order.orderDate, l10n),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                    _buildOrderTile(context, order, isDark, l10n),
                  ],
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
                onPressed: () => ref.invalidate(liteOrderHistoryProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

  String _formatDate(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDay = DateTime(dt.year, dt.month, dt.day);

    if (orderDay == today) return l10n.today;
    if (orderDay == today.subtract(const Duration(days: 1))) return l10n.yesterday;
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _buildOrderTile(BuildContext context, OrderWithCustomer order, bool isDark, AppLocalizations l10n) {
    final isCompleted = order.status == 'delivered';
    final statusColor = isCompleted ? AlhaiColors.success : AlhaiColors.error;
    final time = '${order.orderDate.hour.toString().padLeft(2, '0')}:${order.orderDate.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () => context.go('/lite/orders/${order.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
        padding: const EdgeInsets.all(AlhaiSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(isCompleted ? Icons.check_circle : Icons.cancel, color: statusColor, size: 20),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${order.orderNumber}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                  Text('${order.customerName ?? ''} \u2022 $time', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${order.total.toStringAsFixed(0)} SAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                Text(isCompleted ? l10n.completed : l10n.cancelled, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
