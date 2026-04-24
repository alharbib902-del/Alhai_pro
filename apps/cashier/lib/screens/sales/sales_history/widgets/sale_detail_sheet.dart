/// Sale detail bottom sheet — quick peek at a sale from the history list.
///
/// Opens from [SalesListView] when a row is tapped. Shows ID, timestamp,
/// customer, payment breakdown, and total. All monetary values are
/// converted from int cents (C-4) before rendering.
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

/// عرض bottom sheet بتفاصيل بيع.
Future<void> showSaleDetailSheet(
  BuildContext context,
  SalesTableData order,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SaleDetailSheet(order: order),
  );
}

/// Sheet يعرض تفاصيل بيع مختارة.
class SaleDetailSheet extends StatelessWidget {
  const SaleDetailSheet({super.key, required this.order});

  final SalesTableData order;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final utc = order.createdAt.toUtc();
    final time =
        '${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}';
    final date = '${utc.day}/${utc.month}/${utc.year}';

    // C-4: total int cents → SAR للعرض.
    final totalSar = (order.total / 100.0).toStringAsFixed(2);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.getBorder(isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.md),
                Text(
                  '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                _InfoRow(
                  label: l10n.date,
                  value: '$date $time',
                  isDark: isDark,
                ),
                const Divider(),
                _InfoRow(
                  label: l10n.customerName,
                  value:
                      order.customerName ??
                      order.customerId ??
                      l10n.cashCustomer,
                  isDark: isDark,
                ),
                const Divider(),
                _InfoRow(
                  label: l10n.amount,
                  value: '$totalSar ${l10n.sar}',
                  isDark: isDark,
                  emphasized: true,
                ),
                const Divider(),
                _PaymentBreakdown(order: order, isDark: isDark, l10n: l10n),
                const SizedBox(height: AlhaiSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.back),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasized ? 16 : 14,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
              color: emphasized
                  ? AppColors.primary
                  : AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBreakdown extends StatelessWidget {
  const _PaymentBreakdown({
    required this.order,
    required this.isDark,
    required this.l10n,
  });

  final SalesTableData order;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // C-4: جميع الحقول cents.
    final cash = order.cashAmount;
    final card = order.cardAmount;
    final credit = order.creditAmount;

    final rows = <Widget>[];
    if (cash != null && cash > 0) {
      rows.add(
        _BreakdownRow(
          icon: Icons.payments_outlined,
          color: AppColors.success,
          label: l10n.cash,
          amountCents: cash,
          isDark: isDark,
          l10n: l10n,
        ),
      );
    }
    if (card != null && card > 0) {
      rows.add(
        _BreakdownRow(
          icon: Icons.credit_card_rounded,
          color: AppColors.info,
          label: l10n.card,
          amountCents: card,
          isDark: isDark,
          l10n: l10n,
        ),
      );
    }
    if (credit != null && credit > 0) {
      rows.add(
        _BreakdownRow(
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.warning,
          label: l10n.credit,
          amountCents: credit,
          isDark: isDark,
          l10n: l10n,
        ),
      );
    }
    if (rows.isEmpty) {
      // بيع قديم بدون تفاصيل — اعرض طريقة الدفع فقط.
      rows.add(
        _BreakdownRow(
          icon: Icons.receipt_long_rounded,
          color: AppColors.info,
          label: order.paymentMethod,
          amountCents: order.total,
          isDark: isDark,
          l10n: l10n,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.amountCents,
    required this.isDark,
    required this.l10n,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int amountCents;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // C-4: cents → SAR للعرض.
    final sar = (amountCents / 100.0).toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AlhaiSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
          Text(
            '$sar ${l10n.sar}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
