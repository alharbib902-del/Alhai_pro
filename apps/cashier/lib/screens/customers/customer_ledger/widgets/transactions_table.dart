/// جدول حركات الحساب للعرض على Desktop/Tablet
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '_ledger_helpers.dart';
import 'ledger_empty_state.dart';

class LedgerDesktopTable extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const LedgerDesktopTable({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    if (transactions.isEmpty) return const LedgerEmptyState();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppSizes.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _TableHeader(l10n: l10n, colorScheme: colorScheme),
          ...transactions.asMap().entries.map(
            (e) => _LedgerTableRow(txn: e.value, index: e.key),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  const _TableHeader({required this.l10n, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.mdl,
        vertical: 14,
      ),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
      child: Row(
        children: [
          _cell(l10n.date, flex: 2),
          _cell(l10n.statementCol, flex: 3),
          _cell(l10n.referenceCol, flex: 2),
          _cell(l10n.debitCol, flex: 2, align: TextAlign.end),
          _cell(l10n.creditCol, flex: 2, align: TextAlign.end),
          _cell(l10n.balanceCol, flex: 2, align: TextAlign.end),
        ],
      ),
    );
  }

  Widget _cell(String text, {required int flex, TextAlign align = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LedgerTableRow extends StatelessWidget {
  final Map<String, dynamic> txn;
  final int index;

  const _LedgerTableRow({required this.txn, required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final type = txn['type'] as String;
    final date = txn['date'] as DateTime;
    final debit = txn['debit'] as double;
    final credit = txn['credit'] as double;
    final balance = txn['balance'] as double;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.mdl,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: type == 'adjustment'
            ? AppColors.warning.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.08
                    : 0.05,
              )
            : (index.isEven
                  ? Colors.transparent
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              formatLedgerDate(date),
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: ledgerTypeColor(type, context).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    ledgerTypeIcon(type),
                    size: 15,
                    color: ledgerTypeColor(type, context),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    ledgerTypeLabel(type, l10n),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              txn['reference'] as String,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              debit > 0 ? debit.toStringAsFixed(2) : '-',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: debit > 0 ? FontWeight.w600 : FontWeight.w400,
                color: debit > 0 ? AppColors.error : colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              credit > 0 ? credit.toStringAsFixed(2) : '-',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: credit > 0 ? FontWeight.w600 : FontWeight.w400,
                color: credit > 0 ? AppColors.success : colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              balance.toStringAsFixed(2),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
