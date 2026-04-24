/// Sales summary header — count + total + payment-methods breakdown
///
/// C-4 Phase 1: جميع الحقول النقدية في جدول sales مخزّنة كـ int cents.
/// يجب القسمة على 100 قبل العرض بـ SAR. قبل 3.3 كانت الشاشة تعرض
/// الأرقام بدون قسمة (bug 100× مكتشف في Phase 1 ضمن split_receipt).
/// هذا الـ widget يُصلح نفس الصنف من الأخطاء في إحصائيات السجل.
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

/// رأس الإحصائيات لسجل المبيعات.
class SalesSummaryHeader extends StatelessWidget {
  const SalesSummaryHeader({super.key, required this.orders});

  /// قائمة المبيعات المعروضة حالياً (بعد الفلترة).
  final List<SalesTableData> orders;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // جميع الحسابات بـ cents ثم نقسم على 100 عند العرض (C-4).
    final totalCents = orders.fold<int>(0, (sum, o) => sum + o.total);

    int cashCents = 0;
    int cardCents = 0;
    int creditCents = 0;

    for (final o in orders) {
      // الأعمدة الجديدة (split payments) — نقرأ مباشرة القيم الفعلية
      // بدون تخمين. إن وجدت قيمة واحدة موجبة على الأقل اعتمد الأعمدة
      // الجديدة؛ القيم صفر/null تبقى 0 ولا تخترع شيئاً.
      final oCash = o.cashAmount ?? 0;
      final oCard = o.cardAmount ?? 0;
      final oCredit = o.creditAmount ?? 0;
      final hasExplicitSplits = oCash > 0 || oCard > 0 || oCredit > 0;
      if (hasExplicitSplits) {
        cashCents += oCash;
        cardCents += oCard;
        creditCents += oCredit;
      } else {
        switch (o.paymentMethod) {
          case 'cash':
            cashCents += o.total;
          case 'card':
            cardCents += o.total;
          case 'credit':
            creditCents += o.total;
          case 'mixed':
            // Fallback محافظ: لا نخمّن "card" للمتبقي — ذلك يُحدث
            // debit مزدوج عند البيانات المتسقة ظاهرياً. نضيف المقبوض
            // إلى cash، وإذا كان البيع غير مدفوع والباقي موجب فهو
            // credit. وإذا كان isPaid=true لكن received<total فهو
            // data-mismatch ولا نوزّعه على card اختلاقاً.
            final received = o.amountReceived ?? 0;
            if (received > 0) cashCents += received;
            if (!o.isPaid && received < o.total) {
              creditCents += (o.total - received);
            }
            // isPaid=true && received<total: نتجاهل الفرق (لا نختلق card).
        }
      }
    }

    return Column(
      children: [
        _TotalRow(
          count: orders.length,
          totalCents: totalCents,
          isDark: isDark,
          l10n: l10n,
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        _PaymentBreakdownRow(
          cashCents: cashCents,
          cardCents: cardCents,
          creditCents: creditCents,
          isDark: isDark,
          l10n: l10n,
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.count,
    required this.totalCents,
    required this.isDark,
    required this.l10n,
  });

  final int count;
  final int totalCents;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // C-4: قسمة cents إلى SAR لأجل العرض فقط.
    final totalSar = totalCents / 100.0;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.totalSales,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.getBorder(isDark),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.amount,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  '${totalSar.toStringAsFixed(2)} ${l10n.sar}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBreakdownRow extends StatelessWidget {
  const _PaymentBreakdownRow({
    required this.cashCents,
    required this.cardCents,
    required this.creditCents,
    required this.isDark,
    required this.l10n,
  });

  final int cashCents;
  final int cardCents;
  final int creditCents;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.sm,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PaymentItem(
              icon: Icons.payments_outlined,
              label: l10n.cash,
              amountCents: cashCents,
              color: AppColors.success,
              isDark: isDark,
              l10n: l10n,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.getBorder(isDark),
          ),
          Expanded(
            child: _PaymentItem(
              icon: Icons.credit_card_rounded,
              label: l10n.card,
              amountCents: cardCents,
              color: AppColors.info,
              isDark: isDark,
              l10n: l10n,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.getBorder(isDark),
          ),
          Expanded(
            child: _PaymentItem(
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.credit,
              amountCents: creditCents,
              color: AppColors.warning,
              isDark: isDark,
              l10n: l10n,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentItem extends StatelessWidget {
  const _PaymentItem({
    required this.icon,
    required this.label,
    required this.amountCents,
    required this.color,
    required this.isDark,
    required this.l10n,
  });

  final IconData icon;
  final String label;
  final int amountCents;
  final Color color;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // C-4: قسمة cents إلى SAR لأجل العرض فقط.
    final amountSar = amountCents / 100.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AlhaiSpacing.xxs),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.xxs),
        Text(
          '${amountSar.toStringAsFixed(2)} ${l10n.sar}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
