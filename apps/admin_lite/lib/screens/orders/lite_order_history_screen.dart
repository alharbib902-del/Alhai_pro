/// Lite Order History Screen
///
/// Shows completed/cancelled orders with search and date filter.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Order history screen for Admin Lite
class LiteOrderHistoryScreen extends StatelessWidget {
  const LiteOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderHistory),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            tooltip: l10n.search,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.filter,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          // Insert date headers
          final order = _orders[index];
          final showHeader = index == 0 || order.date != _orders[index - 1].date;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs, top: AlhaiSpacing.sm),
                  child: Text(
                    order.date,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
              _buildOrderTile(context, order, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderTile(BuildContext context, _HistoryOrder order, bool isDark) {
    final statusColor = order.isCompleted ? AlhaiColors.success : AlhaiColors.error;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => context.go('/lite/orders/${order.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
        padding: const EdgeInsets.all(AlhaiSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                order.isCompleted ? Icons.check_circle : Icons.cancel,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.number}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '${order.customerName} \u2022 ${order.time}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${order.total} SAR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  order.isCompleted ? l10n.completed : l10n.cancelled,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _orders = [
    _HistoryOrder('1', 'ORD-1045', 'Ahmed Ali', '245', '11:30', 'Today', true),
    _HistoryOrder('2', 'ORD-1044', 'Sara Hassan', '180', '10:15', 'Today', true),
    _HistoryOrder('3', 'ORD-1043', 'Mohammed Omar', '92', '09:45', 'Today', false),
    _HistoryOrder('4', 'ORD-1042', 'Fatima Nasser', '420', '16:30', 'Yesterday', true),
    _HistoryOrder('5', 'ORD-1041', 'Khalid Ibrahim', '155', '14:00', 'Yesterday', true),
    _HistoryOrder('6', 'ORD-1040', 'Noura Salem', '310', '11:20', 'Yesterday', true),
    _HistoryOrder('7', 'ORD-1039', 'Omar Ali', '88', '09:00', 'Yesterday', false),
    _HistoryOrder('8', 'ORD-1038', 'Layla Hassan', '275', '15:45', 'Mar 31', true),
    _HistoryOrder('9', 'ORD-1037', 'Youssef Omar', '195', '12:30', 'Mar 31', true),
  ];
}

class _HistoryOrder {
  final String id;
  final String number;
  final String customerName;
  final String total;
  final String time;
  final String date;
  final bool isCompleted;
  const _HistoryOrder(this.id, this.number, this.customerName, this.total, this.time, this.date, this.isCompleted);
}
