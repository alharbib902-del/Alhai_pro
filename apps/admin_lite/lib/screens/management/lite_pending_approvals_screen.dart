/// Lite Pending Approvals Screen
///
/// Shows all items requiring manager approval: refunds,
/// price overrides, void transactions, and discounts.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Pending approvals screen for Admin Lite
class LitePendingApprovalsScreen extends StatelessWidget {
  const LitePendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pendingItems),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsetsDirectional.only(end: AlhaiSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AlhaiSpacing.xxs),
            decoration: BoxDecoration(
              color: AlhaiColors.warning,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_items.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: _items.isEmpty
          ? _buildEmptyState(context, isDark, l10n)
          : ListView.builder(
              padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildApprovalCard(context, _items[index], isDark, l10n);
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
            color: isDark ? Colors.white24 : AlhaiColors.success.withValues(alpha: 0.5),
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

  Widget _buildApprovalCard(BuildContext context, _ApprovalItem item, bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
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
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      item.reference,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),

          // Details
          Text(
            item.description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: isDark ? Colors.white24 : Colors.black38),
              const SizedBox(width: AlhaiSpacing.xxs),
              Text(
                item.requestedBy,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Icon(Icons.access_time, size: 14, color: isDark ? Colors.white24 : Colors.black38),
              const SizedBox(width: AlhaiSpacing.xxs),
              Text(
                item.time,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AlhaiSpacing.sm),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close, size: 16),
                  label: Text(l10n.reject),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AlhaiColors.error,
                    side: const BorderSide(color: AlhaiColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(l10n.approve),
                  style: FilledButton.styleFrom(
                    backgroundColor: AlhaiColors.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _items = [
    _ApprovalItem(
      type: 'Refund Request',
      reference: '#R-2045',
      description: 'Customer returned 2 items - damaged goods',
      amount: '155 SAR',
      requestedBy: 'Ahmed Al-Salem',
      time: '10 min ago',
      icon: Icons.undo,
      color: AlhaiColors.warning,
    ),
    _ApprovalItem(
      type: 'Price Override',
      reference: 'Rice 10kg',
      description: 'Bulk discount for regular customer',
      amount: '-15 SAR',
      requestedBy: 'Sara Ibrahim',
      time: '25 min ago',
      icon: Icons.price_change,
      color: AlhaiColors.info,
    ),
    _ApprovalItem(
      type: 'Void Transaction',
      reference: '#TXN-8892',
      description: 'Duplicate charge on card payment',
      amount: '92 SAR',
      requestedBy: 'Mohammed Ali',
      time: '1 hour ago',
      icon: Icons.cancel_outlined,
      color: AlhaiColors.error,
    ),
    _ApprovalItem(
      type: 'Custom Discount',
      reference: '#ORD-1048',
      description: 'Manager discount 15% on full order',
      amount: '-48 SAR',
      requestedBy: 'Khalid Omar',
      time: '2 hours ago',
      icon: Icons.discount,
      color: Colors.purple,
    ),
  ];
}

class _ApprovalItem {
  final String type;
  final String reference;
  final String description;
  final String amount;
  final String requestedBy;
  final String time;
  final IconData icon;
  final Color color;

  const _ApprovalItem({
    required this.type,
    required this.reference,
    required this.description,
    required this.amount,
    required this.requestedBy,
    required this.time,
    required this.icon,
    required this.color,
  });
}
