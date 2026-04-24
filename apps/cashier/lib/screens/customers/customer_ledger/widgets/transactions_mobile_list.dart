/// قائمة بطاقات حركات الحساب للعرض على الهاتف
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '_ledger_helpers.dart';
import 'ledger_empty_state.dart';

class LedgerMobileList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const LedgerMobileList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const LedgerEmptyState();

    return Column(
      children: transactions
          .map(
            (txn) => Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10),
              child: _LedgerMobileCard(txn: txn),
            ),
          )
          .toList(),
    );
  }
}

class _LedgerMobileCard extends StatelessWidget {
  final Map<String, dynamic> txn;

  const _LedgerMobileCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final type = txn['type'] as String;
    final date = txn['date'] as DateTime;
    final debit = txn['debit'] as double;
    final credit = txn['credit'] as double;
    final balance = txn['balance'] as double;
    final isDebitTx = debit > 0;
    final amount = isDebitTx ? debit : credit;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: type == 'adjustment'
              ? AppColors.warning.withValues(alpha: 0.4)
              : colorScheme.outlineVariant,
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppSizes.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (type == 'adjustment')
              Container(width: 4, color: AppColors.warning),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: type == 'adjustment' ? 12 : 16,
                  end: 16,
                  top: 14,
                  bottom: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ledgerTypeColor(type, context).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        ledgerTypeIcon(type),
                        size: 16,
                        color: ledgerTypeColor(type, context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ledgerTypeLabel(type, l10n),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            formatLedgerDateTime(date),
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          // P1 #14: CurrencyFormatter yields thousands
                          // separators + proper decimals in Arabic digits.
                          '${isDebitTx ? '+' : '-'}'
                          '${CurrencyFormatter.formatNumberWithContext(context, amount)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDebitTx
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.xxxs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.xs,
                            vertical: AlhaiSpacing.xxxs,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${l10n.balanceCol}: '
                            '${CurrencyFormatter.formatNumberWithContext(context, balance, decimalDigits: 0)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
