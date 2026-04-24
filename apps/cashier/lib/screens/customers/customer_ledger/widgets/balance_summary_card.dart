/// بطاقة معلومات العميل + الرصيد الحالي (أعلى الشاشة)
///
/// تعرض: الاسم الأولي (initials)، الاسم، الهاتف، شارة
/// "مستحق على العميل"/"له رصيد"، ومبلغ الرصيد بلون دلالي.
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

class BalanceSummaryCard extends StatelessWidget {
  final AccountsTableData? account;
  final String customerName;
  final bool isMobile;

  const BalanceSummaryCard({
    super.key,
    required this.account,
    required this.customerName,
    required this.isMobile,
  });

  /// الأحرف الأولى من اسم العميل (للـ avatar)
  String get _customerInitials {
    final parts = customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customerName.isNotEmpty ? customerName[0].toUpperCase() : '?';
  }

  /// الرصيد الحالي بـ SAR (C-4: accounts.balance int cents)
  double get _currentBalance => (account?.balance ?? 0) / 100.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDebt = _currentBalance > 0;
    final balanceColor = isDebt ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppSizes.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 48 : 56,
            height: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              gradient: AppColors.avatarGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              _customerInitials,
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    Text(
                      account?.phone ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: AlhaiSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: balanceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isDebt ? l10n.dueOnCustomer : l10n.customerHasCredit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: balanceColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_currentBalance.abs().toStringAsFixed(2)} ${l10n.sar}',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  color: balanceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
