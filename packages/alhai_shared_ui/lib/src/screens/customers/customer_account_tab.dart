import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_sizes.dart';
import '../../widgets/common/app_empty_state.dart';
import 'customer_purchases_tab.dart' show formatDate;

/// Account Ledger Tab - displays financial ledger entries and
/// a balance summary card with credit limit progress.
class CustomerAccountTab extends StatelessWidget {
  final List<TransactionsTableData> transactions;
  final double balance;
  final double creditLimit;
  final String? customerId;
  final String customerName;
  final bool isMobile;
  final bool isDesktop;
  final bool isDark;

  const CustomerAccountTab({
    super.key,
    required this.transactions,
    required this.balance,
    required this.creditLimit,
    required this.customerId,
    required this.customerName,
    required this.isMobile,
    required this.isDesktop,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isMobile) {
      return Column(
        children: [
          _buildBalanceSummaryCard(isDark, l10n),
          SizedBox(height: AlhaiSpacing.md),
          _buildLedgerList(context, isDark, l10n),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Financial Ledger
        Expanded(flex: 3, child: _buildLedgerList(context, isDark, l10n)),
        SizedBox(width: AlhaiSpacing.md),
        // Right: Balance summary card
        Expanded(
            flex: 2, child: _buildBalanceSummaryCard(isDark, l10n)),
      ],
    );
  }

  Widget _buildLedgerList(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    size: 20, color: AppColors.primary),
                SizedBox(width: AlhaiSpacing.xs),
                Text(
                  l10n.finance,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final id = customerId ?? '';
                    context.push(
                      '${AppRoutes.customerLedgerPath(id)}?name=${Uri.encodeComponent(customerName)}',
                    );
                  },
                  child: Text(l10n.viewAll,
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.getBorder(isDark)),
          // Entries from real transactions
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: AppEmptyState.noData(context,
                  title: l10n.noTransactions),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              itemCount:
                  transactions.length > 4 ? 4 : transactions.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: AlhaiSpacing.xs),
              itemBuilder: (context, index) {
                final entry = transactions[index];
                final isCredit = entry.amount < 0;
                final typeColor = getLedgerTypeColor(entry.type);
                final typeIcon = _getLedgerTypeIcon(entry.type);
                return Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(isDark),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          typeIcon,
                          size: 20,
                          color: typeColor,
                        ),
                      ),
                      SizedBox(width: AlhaiSpacing.sm),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.description ??
                                  entry.type,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextPrimary(
                                    isDark),
                              ),
                            ),
                            SizedBox(height: AlhaiSpacing.xxxs),
                            Text(
                              formatDate(entry.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    AppColors.getTextMuted(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Amount
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isCredit ? '-' : '+'}${entry.amount.abs().toStringAsFixed(0)} ${l10n.sar}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isCredit
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          Text(
                            '${l10n.balance}: ${entry.balanceAfter.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  AppColors.getTextMuted(isDark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummaryCard(
      bool isDark, AppLocalizations l10n) {
    final usedPercent = creditLimit > 0
        ? (balance / creditLimit * 100).clamp(0, 100)
        : 0.0;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.account_balance_wallet_rounded,
                size: 24, color: Colors.white),
          ),
          SizedBox(height: AlhaiSpacing.md),
          const Text(
            'Current Balance',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AlhaiSpacing.xxs),
          Text(
            '${balance.toStringAsFixed(0)} ${l10n.sar}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AlhaiSpacing.mdl),
          // Credit Limit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.credit,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${usedPercent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: AlhaiSpacing.xs),
          // Progress bar
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppSizes.radiusFull),
            child: LinearProgressIndicator(
              value: usedPercent / 100,
              backgroundColor:
                  Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.white),
              minHeight: 8,
            ),
          ),
          SizedBox(height: AlhaiSpacing.xs),
          Text(
            '${balance.toStringAsFixed(0)} / ${creditLimit.toStringAsFixed(0)} ${l10n.sar}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: AlhaiSpacing.mdl),
          // Top-up button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.payment),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                padding:
                    const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusLg),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLedgerTypeIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payments_outlined;
      case 'invoice':
        return Icons.receipt_long_outlined;
      case 'interest':
        return Icons.percent_rounded;
      case 'adjustment':
        return Icons.tune_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }
}

/// Returns the color associated with a ledger entry type.
Color getLedgerTypeColor(String type) {
  switch (type) {
    case 'payment':
      return const Color(0xFF22C55E);
    case 'invoice':
      return const Color(0xFF3B82F6);
    case 'interest':
      return const Color(0xFFF59E0B);
    case 'adjustment':
      return const Color(0xFF8B5CF6);
    default:
      return AppColors.grey400;
  }
}
