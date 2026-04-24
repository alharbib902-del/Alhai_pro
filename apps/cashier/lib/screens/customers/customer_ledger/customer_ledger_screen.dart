/// Container شاشة كشف حساب العميل
///
/// يُنسّق بين:
/// - [accountLedgerDataProvider]: جلب البيانات (account + transactions)
/// - [ledgerFiltersProvider]: حالة الفلاتر
/// - [filteredLedgerTxnsProvider] / [ledgerTotalsProvider]: البيانات المشتقّة
/// - [ledgerAdjustingProvider]: حالة "جاري حفظ تسوية"
/// - [saveLedgerAdjustment]: DB transaction لحفظ تسوية يدوية
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_core/alhai_core.dart' show UserRole;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;

import 'providers/adjustment_service.dart';
import 'providers/customer_ledger_providers.dart';
import 'providers/ledger_derived_providers.dart';
import 'providers/ledger_filters_notifier.dart';
import 'widgets/adjustment_dialog.dart';
import 'widgets/balance_summary_card.dart';
import 'widgets/ledger_header.dart';
import 'widgets/ledger_mobile_bottom_summary.dart';
import 'widgets/ledger_summary_bar.dart';
import 'widgets/transaction_filters_bar.dart';
import 'widgets/transactions_mobile_list.dart';
import 'widgets/transactions_table.dart';

/// شاشة كشف حساب العميل
class CustomerLedgerScreen extends ConsumerWidget {
  final String id;

  const CustomerLedgerScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final ledgerAsync = ref.watch(accountLedgerDataProvider(id));
    final isAdjusting = ref.watch(ledgerAdjustingProvider);

    return Scaffold(
      floatingActionButton: _buildFab(
        context,
        ref,
        colorScheme,
        l10n,
        isAdjusting,
      ),
      body: ledgerAsync.when(
        loading: () => const AppLoadingState(),
        error: (err, _) => AppErrorState.general(
          context,
          message: '$err',
          onRetry: () => ref.invalidate(accountLedgerDataProvider(id)),
        ),
        data: (data) => _LedgerBody(accountId: id, data: data),
      ),
    );
  }

  Widget _buildFab(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    bool isAdjusting,
  ) {
    // Hotfix 2026-04-24: manual ledger adjustment is a fraud-sensitive
    // operation (any cashier could adjust any customer's balance with only
    // a post-hoc audit log). Restrict to storeOwner + superAdmin until RLS
    // lands (Sprint 2). A 'manager' role doesn't exist in UserRole yet;
    // widen this check if/when it's added.
    // Cf. D:\alhai_reports\_analysis\01_TRUE_P0.md § P0-28.
    final user = ref.watch(currentUserProvider);
    final role = user?.role;
    final canAdjust =
        role == UserRole.storeOwner || role == UserRole.superAdmin;
    if (!canAdjust) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      tooltip: l10n.manualAdjustment,
      onPressed: isAdjusting
          ? null
          : () => showAdjustmentDialog(
              context,
              onSave: (type, amount, reason, date) => saveLedgerAdjustment(
                context: context,
                ref: ref,
                accountId: id,
                type: type,
                amount: amount,
                reason: reason,
                date: date,
                l10n: l10n,
              ),
            ),
      backgroundColor: isAdjusting
          ? AppColors.primary.withValues(alpha: 0.5)
          : AppColors.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: isAdjusting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textOnPrimary,
              ),
            )
          : const Icon(Icons.tune_rounded, size: 20),
      label: Text(l10n.manualAdjustment),
    );
  }
}

class _LedgerBody extends ConsumerWidget {
  final String accountId;
  final CustomerLedgerData data;

  const _LedgerBody({required this.accountId, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= AlhaiBreakpoints.desktop;
    final isMobile = screenWidth < AlhaiBreakpoints.tablet;
    final customerName = data.account?.name ?? accountId;
    final txnsMaps = ref.watch(filteredLedgerTxnsProvider(accountId));
    final totals = ref.watch(ledgerTotalsProvider(accountId));

    return Column(
      children: [
        LedgerHeader(
          customerName: customerName,
          onRefresh: () => ref.invalidate(accountLedgerDataProvider(accountId)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen
                  ? AlhaiSpacing.xxxl
                  : (isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              vertical: AlhaiSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BalanceSummaryCard(
                  account: data.account,
                  customerName: customerName,
                  isMobile: isMobile,
                ),
                const SizedBox(height: AlhaiSpacing.md),
                TransactionFiltersBar(
                  onSelectCustomDateRange: () => _selectDateRange(context, ref),
                ),
                const SizedBox(height: AlhaiSpacing.md),
                isMobile
                    ? LedgerMobileList(transactions: txnsMaps)
                    : LedgerDesktopTable(transactions: txnsMaps),
                const SizedBox(height: AlhaiSpacing.md),
                if (!isMobile)
                  LedgerSummaryBar(
                    totalDebit: totals.debit,
                    totalCredit: totals.credit,
                    finalBalance: totals.finalBalance,
                  ),
                const SizedBox(height: AlhaiSpacing.lg),
              ],
            ),
          ),
        ),
        if (isMobile)
          LedgerMobileBottomSummary(
            totalDebit: totals.debit,
            totalCredit: totals.credit,
            finalBalance: totals.finalBalance,
          ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final existing = ref.read(ledgerFiltersProvider).customDateRange;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: existing,
    );
    if (picked != null) {
      ref.read(ledgerFiltersProvider.notifier).setCustomDateRange(picked);
    }
  }
}
