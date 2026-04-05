/// Invoice Payment Methods Widget
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

class InvoicePaymentMethods extends StatelessWidget {
  final bool isDark;
  const InvoicePaymentMethods({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final methods = [
      _PaymentMethod(
          icon: Icons.payments_outlined,
          label: l10n.cashPayment,
          percent: 60,
          color: AppColors.success,
          bgColor: AppColors.successLight),
      _PaymentMethod(
          icon: Icons.credit_card,
          label: l10n.cardPayment,
          percent: 30,
          color: AppColors.info,
          bgColor: AppColors.infoLight),
      _PaymentMethod(
          icon: Icons.account_balance_wallet,
          label: l10n.walletPayment,
          percent: 10,
          color: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFFEDE9FE)),
    ];

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.paymentMethods,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
          SizedBox(height: AlhaiSpacing.mdl),
          ...methods.map((m) => _buildMethodRow(m, context)),
          SizedBox(height: AlhaiSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.saveCurrentFilter),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isDark ? AppColors.textMutedDark : AppColors.textMuted,
                side: BorderSide(
                    color: Theme.of(context).dividerColor,
                    style: BorderStyle.solid),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodRow(_PaymentMethod method, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: AlhaiSpacing.sm),
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.backgroundDark : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? method.color.withValues(alpha: 0.15)
                    : method.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(method.icon, color: method.color, size: 18),
            ),
            SizedBox(width: AlhaiSpacing.sm),
            Text(method.label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            Text('${method.percent}%',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final IconData icon;
  final String label;
  final int percent;
  final Color color;
  final Color bgColor;
  const _PaymentMethod(
      {required this.icon,
      required this.label,
      required this.percent,
      required this.color,
      required this.bgColor});
}
