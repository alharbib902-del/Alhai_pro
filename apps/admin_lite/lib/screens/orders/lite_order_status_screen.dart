/// Lite Order Status Update Screen
///
/// Allows updating order status through predefined steps.
/// Queries ordersDao for current status and writes updates.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show updateOrderStatus;

import '../../providers/lite_screen_providers.dart';

/// Order status update screen for Admin Lite
class LiteOrderStatusScreen extends ConsumerWidget {
  final String orderId;

  const LiteOrderStatusScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(liteOrderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.status), centerTitle: true),
      body: dataAsync.when(
        data: (data) {
          if (data == null) return Center(child: Text(l10n.noResults));
          final order = data.order;
          final currentStep = _statusToStep(order.status);

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(context, isDark, order, data.items.length),
                const SizedBox(height: AlhaiSpacing.lg),
                ..._buildStatusSteps(context, isDark, l10n, order, currentStep),
                const SizedBox(height: AlhaiSpacing.xl),
                if (currentStep < 4)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final nextStatus = _stepToStatus(currentStep + 1);
                        if (nextStatus != null) {
                          await updateOrderStatus(ref, order.id, nextStatus);
                          ref.invalidate(liteOrderDetailProvider(orderId));
                          ref.invalidate(liteActiveOrdersProvider);
                        }
                      },
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_back
                            : Icons.arrow_forward,
                        size: 18,
                      ),
                      label: Text(_getNextStepLabel(l10n, currentStep)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AlhaiColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (currentStep >= 4) ...[
                  const SizedBox(height: AlhaiSpacing.md),
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 48,
                          color: AlhaiColors.success,
                        ),
                        const SizedBox(height: AlhaiSpacing.sm),
                        Text(
                          l10n.completed,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AlhaiColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AlhaiSpacing.lg),
              ],
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
                onPressed: () =>
                    ref.invalidate(liteOrderDetailProvider(orderId)),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _statusToStep(String status) {
    return switch (status) {
      'created' || 'confirmed' => 0,
      'preparing' => 1,
      'ready' => 2,
      'out_for_delivery' => 3,
      'delivered' => 4,
      _ => 0,
    };
  }

  String? _stepToStatus(int step) {
    return switch (step) {
      0 => 'confirmed',
      1 => 'preparing',
      2 => 'ready',
      3 => 'out_for_delivery',
      4 => 'delivered',
      _ => null,
    };
  }

  Widget _buildOrderHeader(
    BuildContext context,
    bool isDark,
    OrdersTableData order,
    int itemCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AlhaiColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AlhaiColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '$itemCount items \u2022 ${order.total.toStringAsFixed(0)} SAR',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white54
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatusSteps(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    OrdersTableData order,
    int currentStep,
  ) {
    final steps = [
      _StatusStep(
        l10n.orderStatusConfirmed,
        Icons.check_circle,
        order.confirmedAt,
      ),
      _StatusStep(
        l10n.orderStatusPreparing,
        Icons.restaurant,
        order.preparingAt,
      ),
      _StatusStep(l10n.orderStatusReady, Icons.inventory_2, order.readyAt),
      _StatusStep(
        l10n.orderStatusDelivering,
        Icons.local_shipping,
        order.deliveringAt,
      ),
      _StatusStep(l10n.completed, Icons.done_all, order.deliveredAt),
    ];

    return steps.asMap().entries.map((entry) {
      final step = entry.value;
      final index = entry.key;
      final isCompleted = index <= currentStep;
      final isCurrent = index == currentStep;
      final isLast = index == steps.length - 1;
      final color = isCompleted
          ? AlhaiColors.success
          : (isDark ? Colors.white12 : Colors.grey.shade300);

      return Padding(
        padding: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AlhaiColors.primary
                        : (isCompleted
                              ? AlhaiColors.success.withValues(alpha: 0.15)
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.grey.shade100)),
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent ? null : Border.all(color: color),
                  ),
                  child: Icon(
                    step.icon,
                    size: 20,
                    color: isCurrent
                        ? Colors.white
                        : (isCompleted
                              ? AlhaiColors.success
                              : (isDark ? Colors.white24 : Colors.grey)),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    margin: const EdgeInsets.symmetric(
                      vertical: AlhaiSpacing.xxxs,
                    ),
                    color: isCompleted
                        ? AlhaiColors.success.withValues(alpha: 0.4)
                        : (isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
              ],
            ),
            const SizedBox(width: AlhaiSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isCurrent || isCompleted
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isCurrent
                            ? AlhaiColors.primary
                            : (isCompleted
                                  ? (isDark ? Colors.white : Colors.black87)
                                  : (isDark ? Colors.white38 : Colors.black38)),
                      ),
                    ),
                    if (step.timestamp != null)
                      Text(
                        '${step.timestamp!.hour.toString().padLeft(2, '0')}:${step.timestamp!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getNextStepLabel(AppLocalizations l10n, int currentStep) {
    return switch (currentStep) {
      0 => l10n.orderStatusPreparing,
      1 => l10n.orderStatusReady,
      2 => l10n.orderStatusDelivering,
      3 => l10n.completed,
      _ => l10n.done,
    };
  }
}

class _StatusStep {
  final String label;
  final IconData icon;
  final DateTime? timestamp;
  const _StatusStep(this.label, this.icon, this.timestamp);
}
