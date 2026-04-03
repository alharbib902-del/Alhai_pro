/// Lite Active Orders Screen
///
/// Shows currently active orders with status indicators,
/// filtering by status, and quick actions.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Active orders list for Admin Lite
class LiteActiveOrdersScreen extends StatefulWidget {
  const LiteActiveOrdersScreen({super.key});

  @override
  State<LiteActiveOrdersScreen> createState() => _LiteActiveOrdersScreenState();
}

class _LiteActiveOrdersScreenState extends State<LiteActiveOrdersScreen> {
  int _filterIndex = 0;

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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            tooltip: l10n.sync,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(isDark, l10n),

          // Orders list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {},
              child: ListView.builder(
                padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
                itemCount: _getFilteredOrders().length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(context, _getFilteredOrders()[index], isDark);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_OrderData> _getFilteredOrders() {
    if (_filterIndex == 0) return _orders;
    final status = [_OrderStatus.confirmed, _OrderStatus.preparing, _OrderStatus.ready, _OrderStatus.delivering][_filterIndex - 1];
    return _orders.where((o) => o.status == status).toList();
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
                  color: isSelected
                      ? AlhaiColors.primary
                      : (isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurface),
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

  Widget _buildOrderCard(BuildContext context, _OrderData order, bool isDark) {
    final statusColor = switch (order.status) {
      _OrderStatus.confirmed => AlhaiColors.info,
      _OrderStatus.preparing => AlhaiColors.warning,
      _OrderStatus.ready => AlhaiColors.success,
      _OrderStatus.delivering => AlhaiColors.primary,
    };
    final statusLabel = switch (order.status) {
      _OrderStatus.confirmed => 'Confirmed',
      _OrderStatus.preparing => 'Preparing',
      _OrderStatus.ready => 'Ready',
      _OrderStatus.delivering => 'Delivering',
    };

    return InkWell(
      onTap: () => context.go('/lite/orders/${order.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
        padding: const EdgeInsets.all(AlhaiSpacing.md),
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
                        '#${order.number}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        order.customerName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: isDark ? Colors.white24 : Colors.black38),
                const SizedBox(width: AlhaiSpacing.xxs),
                Text(
                  order.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.md),
                Icon(Icons.shopping_bag_outlined, size: 14, color: isDark ? Colors.white24 : Colors.black38),
                const SizedBox(width: AlhaiSpacing.xxs),
                Text(
                  '${order.itemCount} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
                const Spacer(),
                Text(
                  '${order.total} SAR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
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
    _OrderData('1', 'ORD-1052', 'Ahmed Ali', _OrderStatus.confirmed, '10:30 AM', 5, '245'),
    _OrderData('2', 'ORD-1051', 'Sara Hassan', _OrderStatus.preparing, '10:15 AM', 3, '180'),
    _OrderData('3', 'ORD-1050', 'Mohammed Omar', _OrderStatus.ready, '09:45 AM', 8, '420'),
    _OrderData('4', 'ORD-1049', 'Fatima Nasser', _OrderStatus.delivering, '09:30 AM', 2, '95'),
    _OrderData('5', 'ORD-1048', 'Khalid Ibrahim', _OrderStatus.delivering, '09:00 AM', 6, '310'),
    _OrderData('6', 'ORD-1047', 'Noura Salem', _OrderStatus.confirmed, '08:45 AM', 4, '215'),
  ];
}

enum _OrderStatus { confirmed, preparing, ready, delivering }

class _OrderData {
  final String id;
  final String number;
  final String customerName;
  final _OrderStatus status;
  final String time;
  final int itemCount;
  final String total;
  const _OrderData(this.id, this.number, this.customerName, this.status, this.time, this.itemCount, this.total);
}
