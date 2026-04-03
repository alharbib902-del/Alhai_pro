/// Lite Order Detail Screen
///
/// Displays full order details including items, customer info,
/// status timeline, and action buttons.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Order detail view for Admin Lite
class LiteOrderDetailScreen extends StatelessWidget {
  final String orderId;

  const LiteOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.orderDetails} #ORD-1052'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            _buildStatusCard(context, isDark, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Customer info
            _buildInfoSection(context, isDark, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Order items
            _buildItemsSection(context, isDark, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Status timeline
            _buildTimeline(context, isDark, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Totals
            _buildTotals(context, isDark, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Action buttons
            _buildActions(context, isDark, l10n),

            const SizedBox(height: AlhaiSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AlhaiColors.info.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AlhaiColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AlhaiColors.info.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle, color: AlhaiColors.info, size: 24),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderStatusConfirmed,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AlhaiColors.info,
                  ),
                ),
                Text(
                  '10:30 AM \u2022 ${l10n.today}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : AlhaiColors.info.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customer,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _buildInfoRow(Icons.person, 'Ahmed Ali', isDark, context),
          _buildInfoRow(Icons.phone, '0551234567', isDark, context),
          _buildInfoRow(Icons.location_on, 'Riyadh, Al-Olaya District', isDark, context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: AlhaiSpacing.sm),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, bool isDark, AppLocalizations l10n) {
    final items = [
      _OrderItem('Rice 10kg', 2, '90'),
      _OrderItem('Sugar 5kg', 1, '35'),
      _OrderItem('Cooking Oil 2L', 3, '72'),
      _OrderItem('Milk 1L', 2, '24'),
      _OrderItem('Bread', 2, '24'),
    ];

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.products,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : null,
                ),
              ),
              const Spacer(),
              Text(
                '${items.length} items',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      'x${item.qty}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.md),
                    Text(
                      '${item.price} SAR',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, bool isDark, AppLocalizations l10n) {
    final steps = [
      _TimelineStep(l10n.orderStatusConfirmed, '10:30 AM', true),
      _TimelineStep(l10n.orderStatusPreparing, '', false),
      _TimelineStep(l10n.orderStatusReady, '', false),
      _TimelineStep(l10n.orderStatusDelivering, '', false),
      _TimelineStep(l10n.completed, '', false),
    ];

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.status,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...steps.asMap().entries.map((entry) {
            final step = entry.value;
            final isLast = entry.key == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: step.completed ? AlhaiColors.success : (isDark ? Colors.white12 : Colors.grey.shade200),
                        shape: BoxShape.circle,
                      ),
                      child: step.completed
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 24,
                        color: step.completed ? AlhaiColors.success : (isDark ? Colors.white12 : Colors.grey.shade200),
                      ),
                  ],
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                    child: Row(
                      children: [
                        Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: step.completed ? FontWeight.w600 : FontWeight.normal,
                            color: step.completed
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                        if (step.time.isNotEmpty) ...[
                          const Spacer(),
                          Text(
                            step.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotals(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          _buildTotalRow(l10n.subtotal, '230 SAR', isDark, context),
          _buildTotalRow(l10n.vat, '15 SAR', isDark, context),
          _buildTotalRow(l10n.delivery, '0 SAR', isDark, context),
          const Divider(height: AlhaiSpacing.lg),
          _buildTotalRow(l10n.grandTotal, '245 SAR', isDark, context, isBold: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, bool isDark, BuildContext context, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? (isBold ? Colors.white : Colors.white54) : (isBold ? Colors.black87 : Colors.black54),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.close, size: 18),
            label: Text(l10n.cancel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AlhaiColors.error,
              side: const BorderSide(color: AlhaiColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check, size: 18),
            label: Text(l10n.next),
            style: FilledButton.styleFrom(
              backgroundColor: AlhaiColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderItem {
  final String name;
  final int qty;
  final String price;
  const _OrderItem(this.name, this.qty, this.price);
}

class _TimelineStep {
  final String label;
  final String time;
  final bool completed;
  const _TimelineStep(this.label, this.time, this.completed);
}
