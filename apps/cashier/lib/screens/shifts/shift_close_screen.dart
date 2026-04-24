/// Shift Close Screen - Cashier-specific shift closing
///
/// Full implementation: shift details, sales summary, closing cash input,
/// difference indicator, close button with confirmation dialog.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../widgets/cash/denomination_counter_widget.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import 'package:alhai_core/alhai_core.dart' show UserRole;
import '../../core/services/sentry_service.dart';

/// Map [UserRole] to a localized label.
String _localizedRole(UserRole? role, AppLocalizations l10n) {
  switch (role) {
    case UserRole.superAdmin:
      return l10n.superAdminRole;
    case UserRole.storeOwner:
      return l10n.ownerRole;
    case UserRole.employee:
      return l10n.cashierRole;
    case UserRole.delivery:
      return l10n.employeeRole;
    case UserRole.customer:
      return l10n.cashierRole;
    case null:
      return l10n.cashierRole;
  }
}

/// شاشة إغلاق الوردية
class ShiftCloseScreen extends ConsumerStatefulWidget {
  const ShiftCloseScreen({super.key});

  @override
  ConsumerState<ShiftCloseScreen> createState() => _ShiftCloseScreenState();
}

class _ShiftCloseScreenState extends ConsumerState<ShiftCloseScreen> {
  final _actualCashController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _actualCashController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt, AppLocalizations l10n) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? l10n.pmPeriod : l10n.amPeriod;
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatDuration(DateTime openedAt, AppLocalizations l10n) {
    final duration = DateTime.now().difference(openedAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return l10n.hoursAndMinutes(hours, minutes);
    } else if (hours > 0) {
      return l10n.hoursOnly(hours);
    } else {
      return l10n.minutesOnly(minutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final userName = user?.name ?? l10n.defaultUserName;

    return Column(
      children: [
        AppHeader(
          title: l10n.closeShift,
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: ref.watch(unreadNotificationsCountProvider),
          userName: userName,
          userRole: _localizedRole(ref.watch(currentUserProvider)?.role, l10n),
          onUserTap: () {},
        ),
        Expanded(
          child: ref
              .watch(openShiftProvider)
              .when(
                data: (shift) {
                  if (shift == null) {
                    return _buildNoShiftMessage(isDark, l10n);
                  }
                  final movementsAsync = ref.watch(
                    shiftMovementsProvider(shift.id),
                  );
                  final cashTotalsAsync = ref.watch(
                    shiftCashTotalsProvider(shift.id),
                  );
                  return movementsAsync.when(
                    data: (movements) => cashTotalsAsync.when(
                      data: (cashTotals) => SingleChildScrollView(
                        padding: EdgeInsets.all(
                          isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                        ),
                        child: _buildContent(
                          shift,
                          movements,
                          cashTotals,
                          isWideScreen,
                          isMediumScreen,
                          isDark,
                          l10n,
                        ),
                      ),
                      loading: () => const AppLoadingState(),
                      error: (e, _) => AppErrorState.general(
                        context,
                        message: '$e',
                        onRetry: () =>
                            ref.invalidate(shiftCashTotalsProvider(shift.id)),
                      ),
                    ),
                    loading: () => const AppLoadingState(),
                    error: (e, _) => AppErrorState.general(
                      context,
                      message: '$e',
                      onRetry: () =>
                          ref.invalidate(shiftMovementsProvider(shift.id)),
                    ),
                  );
                },
                loading: () => const AppLoadingState(),
                error: (e, _) => AppErrorState.general(
                  context,
                  message: '$e',
                  onRetry: () => ref.invalidate(openShiftProvider),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildNoShiftMessage(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_off_rounded,
            size: 64,
            color: AppColors.getTextMuted(isDark),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noOpenShift,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(l10n.goBack),
          ),
        ],
      ),
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr \u2022 ${l10n.mainBranch}';
  }

  Widget _buildContent(
    ShiftsTableData shift,
    List<CashMovementsTableData> movements,
    ({double cashSales, double cashRefunds}) cashTotals,
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final user = ref.watch(currentUserProvider);

    // C-4 Session 3: shifts.opening_cash and cash_movements.amount are int
    // cents; convert to SAR doubles for display/math here.
    final openingCash = shift.openingCash / 100.0;
    final cashIn = movements
        .where((m) => m.type == 'cash_in')
        .fold<double>(0, (sum, m) => sum + m.amount / 100.0);
    final cashOut = movements
        .where((m) => m.type == 'cash_out')
        .fold<double>(0, (sum, m) => sum + m.amount / 100.0);
    // BUG FIX: use cash-only sales/refunds for expected drawer calculation
    // Previously used shift.totalSalesAmount which included card/credit sales,
    // causing a false deficit on shift close.
    final totalSalesAmount = cashTotals.cashSales;
    final totalRefundsAmount = cashTotals.cashRefunds;
    final expectedCash =
        openingCash + cashIn - cashOut + totalSalesAmount - totalRefundsAmount;

    // P0-10: distinguish empty/invalid from a legitimate "0" entry.
    // Empty or non-numeric input MUST NOT silently render a full-expected
    // deficit — that blames the cashier for money they never received.
    final parsedActualCash = double.tryParse(_actualCashController.text.trim());
    final hasValidActualCash = parsedActualCash != null;
    final actualCash = parsedActualCash ?? 0;
    final difference = actualCash - expectedCash;

    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildShiftInfoCard(user, shift, isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSalesSummaryCard(
                  openingCash,
                  totalSalesAmount,
                  totalRefundsAmount,
                  cashIn,
                  cashOut,
                  expectedCash,
                  isDark,
                  l10n,
                ),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildActualCashCard(actualCash, difference, hasValidActualCash, isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildCloseButton(shift, expectedCash, isDark, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildShiftInfoCard(user, shift, isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildSalesSummaryCard(
          openingCash,
          totalSalesAmount,
          totalRefundsAmount,
          cashIn,
          cashOut,
          expectedCash,
          isDark,
          l10n,
        ),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildActualCashCard(actualCash, difference, hasValidActualCash, isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildCloseButton(shift, expectedCash, isDark, l10n),
      ],
    );
  }

  Widget _buildShiftInfoCard(
    dynamic user,
    ShiftsTableData shift,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.shiftInfoLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _InfoRow(
            label: l10n.cashierLabel,
            value: shift.cashierName,
            icon: Icons.person_rounded,
            isDark: isDark,
          ),
          Divider(height: 20, color: AppColors.getBorder(isDark)),
          _InfoRow(
            label: l10n.openTime,
            value: _formatTime(shift.openedAt, l10n),
            icon: Icons.login_rounded,
            isDark: isDark,
          ),
          Divider(height: 20, color: AppColors.getBorder(isDark)),
          _InfoRow(
            label: l10n.duration,
            value: _formatDuration(shift.openedAt, l10n),
            icon: Icons.timer_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummaryCard(
    double openingCash,
    double totalSalesAmount,
    double totalRefundsAmount,
    double cashIn,
    double cashOut,
    double expectedCash,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.salesSummaryLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _SummaryRow(
            label: l10n.openingBalance,
            value: openingCash,
            color: AppColors.info,
            isDark: isDark,
            currency: l10n.sar,
          ),
          _SummaryRow(
            label: l10n.totalSales,
            value: totalSalesAmount,
            color: AppColors.success,
            prefix: '+',
            isDark: isDark,
            currency: l10n.sar,
          ),
          _SummaryRow(
            label: l10n.cashRefundsLabel,
            value: totalRefundsAmount,
            color: AppColors.error,
            prefix: '-',
            isDark: isDark,
            currency: l10n.sar,
          ),
          _SummaryRow(
            label: l10n.cashDepositLabel,
            value: cashIn,
            color: AppColors.success,
            prefix: '+',
            isDark: isDark,
            currency: l10n.sar,
          ),
          _SummaryRow(
            label: l10n.cashWithdrawalLabel,
            value: cashOut,
            color: AppColors.secondary,
            prefix: '-',
            isDark: isDark,
            currency: l10n.sar,
          ),
          Divider(height: 24, color: AppColors.getBorder(isDark)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.expectedInDrawer,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormatter.formatCompact(expectedCash),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActualCashCard(
    double actualCash,
    double difference,
    bool hasValidActualCash,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.actualCashInDrawer,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // زر عد العملات
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final total = await showDenominationCounterSheet(
                  context,
                  initialTotal:
                      double.tryParse(_actualCashController.text) ?? 0,
                );
                if (total != null && mounted) {
                  setState(() {
                    _actualCashController.text = total.toStringAsFixed(2);
                  });
                }
              },
              icon: const Icon(Icons.calculate_rounded, size: 18),
              label: Text(
                '${AppLocalizations.of(context).countDenominationsBtn} 🪙',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          TextField(
            controller: _actualCashController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: AppColors.getTextMuted(isDark),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              suffixText: l10n.sar,
              suffixStyle: TextStyle(
                fontSize: 16,
                color: AppColors.getTextSecondary(isDark),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                child: Icon(
                  Icons.money_rounded,
                  size: 28,
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
            ),
          ),
          if (hasValidActualCash) ...[
            const SizedBox(height: AlhaiSpacing.md),
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: difference == 0
                    ? AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08)
                    : (difference > 0
                          ? AppColors.warning.withValues(
                              alpha: isDark ? 0.15 : 0.08,
                            )
                          : AppColors.error.withValues(
                              alpha: isDark ? 0.15 : 0.08,
                            )),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: difference == 0
                      ? AppColors.success.withValues(alpha: 0.3)
                      : (difference > 0
                            ? AppColors.warning.withValues(alpha: 0.3)
                            : AppColors.error.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        difference == 0
                            ? Icons.check_circle_rounded
                            : (difference > 0
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded),
                        color: difference == 0
                            ? AppColors.success
                            : (difference > 0
                                  ? AppColors.warning
                                  : AppColors.error),
                        size: 20,
                      ),
                      const SizedBox(width: AlhaiSpacing.xs),
                      Text(
                        difference == 0
                            ? l10n.drawerMatched
                            : (difference > 0
                                  ? l10n.surplusStatus
                                  : l10n.deficitStatus),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: difference == 0
                              ? AppColors.success
                              : (difference > 0
                                    ? AppColors.warning
                                    : AppColors.error),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${difference >= 0 ? '+' : ''}${CurrencyFormatter.formatCompact(difference)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: difference == 0
                          ? AppColors.success
                          : (difference > 0
                                ? AppColors.warning
                                : AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCloseButton(
    ShiftsTableData shift,
    double expectedCash,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isLoading || _actualCashController.text.trim().isEmpty
            ? null
            : () => _closeShift(shift, expectedCash),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : const Icon(Icons.lock_rounded, size: 20),
        label: Text(
          l10n.closeShift,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _closeShift(ShiftsTableData shift, double expectedCash) async {
    final l10n = AppLocalizations.of(context);
    // P0-10: do NOT coerce invalid text to 0. The cashier must enter an
    // explicit amount — "0" is a valid value meaning "drawer was empty",
    // but empty / whitespace / non-numeric input is a validation error.
    final parsedActualCash = double.tryParse(_actualCashController.text.trim());
    if (parsedActualCash == null) {
      AlhaiSnackbar.warning(context, l10n.requiredField);
      return;
    }
    final actualCash = parsedActualCash;
    final difference = actualCash - expectedCash;
    final hasDiscrepancy = difference != 0;

    // Phase 2, task 2.7 — Cash Drawer mismatch UX:
    // When the drawer doesn't balance (difference != 0) we force the cashier
    // to enter a note explaining the shortage/surplus before allowing close.
    // Previously the confirm dialog accepted any discrepancy silently — a
    // cashier could lose cash over days without any audit trail of why.
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await ResponsiveDialog.showAlert<bool>(
      context,
      title: Text(l10n.closeShift),
      content: StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.expectedAmountCurrency(
                    CurrencyFormatter.formatCompact(expectedCash),
                    l10n.sar,
                  ),
                ),
                Text(
                  l10n.actualAmountCurrency(
                    CurrencyFormatter.formatCompact(actualCash),
                    l10n.sar,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  difference == 0
                      ? l10n.drawerMatchedMessage
                      : difference > 0
                      ? l10n.surplusAmount(
                          CurrencyFormatter.formatCompact(difference),
                          l10n.sar,
                        )
                      : l10n.deficitAmount(
                          CurrencyFormatter.formatCompact(difference),
                          l10n.sar,
                        ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: difference == 0
                        ? AppColors.success
                        : (difference > 0
                              ? AppColors.warning
                              : AppColors.error),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                Text(l10n.confirmCloseShift),
                if (hasDiscrepancy) ...[
                  const SizedBox(height: AlhaiSpacing.md),
                  // Notes field required for discrepancies — cashier must
                  // explain shortage/surplus for audit trail.
                  TextFormField(
                    controller: notesController,
                    maxLines: 3,
                    minLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: '${l10n.reason} *',
                      hintText: l10n.optionalNoteHint,
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            // P2-#10: Only require form validation if there's a discrepancy.
            // Guard with try/catch: validate() can throw if the Form state is
            // disposed mid-dialog (tapped confirm while widget is unmounting).
            if (hasDiscrepancy) {
              bool valid = false;
              try {
                valid = formKey.currentState?.validate() ?? false;
              } catch (_) {
                // Form was disposed before we could validate — treat as
                // invalid and keep dialog open so user can retry.
                valid = false;
              }
              if (!valid) return;
            }
            Navigator.of(context).pop(true);
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: Text(l10n.confirm),
        ),
      ],
    );

    if (confirmed != true) {
      notesController.dispose();
      return;
    }

    final shiftNotes = hasDiscrepancy ? notesController.text.trim() : null;
    notesController.dispose();

    setState(() => _isLoading = true);

    try {
      final closeShift = ref.read(closeShiftActionProvider);
      await closeShift(
        shiftId: shift.id,
        closingCash: actualCash,
        expectedCash: expectedCash,
        difference: difference,
        totalSales: shift.totalSales,
        // C-4 Session 3: shifts money columns are int cents; closeShift
        // action takes SAR doubles.
        totalSalesAmount: shift.totalSalesAmount / 100.0,
        totalRefunds: shift.totalRefunds,
        totalRefundsAmount: shift.totalRefundsAmount / 100.0,
        // Phase 2, task 2.7: pass mandatory discrepancy note to audit trail.
        // null when drawer matches; non-empty string required otherwise (the
        // dialog form validator above blocks confirm on empty notes).
        notes: shiftNotes,
      );

      addBreadcrumb(
        message: 'Shift closed',
        category: 'shift',
        data: {
          'closingCash': actualCash,
          'difference': difference,
          'totalSales': shift.totalSales,
        },
      );

      if (!mounted) return;
      context.push(AppRoutes.shiftSummary);
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Close shift');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.errorClosingShift),
          content: Text(l10n.errorOccurred),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.getTextMuted(isDark)),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(color: AppColors.getTextSecondary(isDark)),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String prefix;
  final bool isDark;
  final String currency;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.prefix = '',
    required this.isDark,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.getTextSecondary(isDark)),
            ),
          ),
          Text(
            '$prefix${CurrencyFormatter.formatCompact(value)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
