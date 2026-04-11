import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_pos/alhai_pos.dart' show showDenominationCounterSheet;
import 'package:alhai_design_system/alhai_design_system.dart';

/// Shift Close Screen - Admin version
/// Displays shift summary and allows closing with actual cash count
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

  /// Format shift open time from DateTime
  String _formatTime(DateTime dt, AppLocalizations l10n) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? l10n.pmPeriod : l10n.amPeriod;
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Compute shift duration string
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
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
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
          notificationsCount: 3,
          userName: userName,
          userRole: l10n.branchManager,
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
                        padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
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
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('$e')),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
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
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : AppColors.textMuted,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noOpenShift,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.pop(),
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_back_rounded,
            ),
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
    // Compute values from shift and movements
    final openingCash = shift.openingCash;
    final cashIn = movements
        .where((m) => m.type == 'cash_in')
        .fold<double>(0, (sum, m) => sum + m.amount);
    final cashOut = movements
        .where((m) => m.type == 'cash_out')
        .fold<double>(0, (sum, m) => sum + m.amount);
    // BUG FIX: use cash-only sales/refunds for expected drawer calculation
    final totalSalesAmount = cashTotals.cashSales;
    final totalRefundsAmount = cashTotals.cashRefunds;
    final expectedCash =
        openingCash + cashIn - cashOut + totalSalesAmount - totalRefundsAmount;

    final actualCash = double.tryParse(_actualCashController.text) ?? 0;
    final difference = actualCash - expectedCash;

    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildShiftInfoCard(shift, isDark, l10n),
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
                _buildActualCashCard(actualCash, difference, isDark, l10n),
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
        _buildShiftInfoCard(shift, isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
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
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildActualCashCard(actualCash, difference, isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildCloseButton(shift, expectedCash, isDark, l10n),
      ],
    );
  }

  Widget _buildShiftInfoCard(
    ShiftsTableData shift,
    bool isDark,
    AppLocalizations l10n,
  ) {
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
                  color: Theme.of(context).colorScheme.onSurface,
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
          Divider(height: 20, color: Theme.of(context).dividerColor),
          _InfoRow(
            label: l10n.openTime,
            value: _formatTime(shift.openedAt, l10n),
            icon: Icons.login_rounded,
            isDark: isDark,
          ),
          Divider(height: 20, color: Theme.of(context).dividerColor),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
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
                  color: Theme.of(context).colorScheme.onSurface,
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
          Divider(height: 24, color: Theme.of(context).dividerColor),
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${expectedCash.toStringAsFixed(0)} ${l10n.sar}',
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
    bool isDark,
    AppLocalizations l10n,
  ) {
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          TextField(
            controller: _actualCashController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : AppColors.textMuted,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              suffixText: l10n.sar,
              suffixStyle: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                child: Icon(
                  Icons.money_rounded,
                  size: 28,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : AppColors.textMuted,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          // زر عد العملات بالفئات
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
                  setState(
                    () => _actualCashController.text = total.toStringAsFixed(2),
                  );
                }
              },
              icon: const Icon(Icons.calculate_rounded, size: 18),
              label: Text(l10n.countDenominationsBtn),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
              ),
            ),
          ),
          if (_actualCashController.text.isNotEmpty) ...[
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
                    '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(0)} ${l10n.sar}',
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
        onPressed: _isLoading || _actualCashController.text.isEmpty
            ? null
            : () => _closeShift(shift, expectedCash),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.lock_rounded, size: 20),
        label: Text(
          l10n.closeShift,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
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
    final actualCash = double.tryParse(_actualCashController.text) ?? 0;
    final difference = actualCash - expectedCash;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.closeShift),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.expectedAmountCurrency(
                expectedCash.toStringAsFixed(0),
                l10n.sar,
              ),
            ),
            Text(
              l10n.actualAmountCurrency(
                actualCash.toStringAsFixed(0),
                l10n.sar,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              difference == 0
                  ? l10n.drawerMatchedMessage
                  : difference > 0
                  ? l10n.surplusAmount(difference.toStringAsFixed(0), l10n.sar)
                  : l10n.deficitAmount(difference.toStringAsFixed(0), l10n.sar),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: difference == 0
                    ? AppColors.success
                    : (difference > 0 ? AppColors.warning : AppColors.error),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Text(l10n.confirmCloseShift),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final closeShift = ref.read(closeShiftActionProvider);
      await closeShift(
        shiftId: shift.id,
        closingCash: actualCash,
        expectedCash: expectedCash,
        difference: difference,
        totalSales: shift.totalSales,
        totalSalesAmount: shift.totalSalesAmount,
        totalRefunds: shift.totalRefunds,
        totalRefundsAmount: shift.totalRefundsAmount,
        notes: null,
      );

      if (!mounted) return;
      context.push(AppRoutes.shiftSummary);
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.errorClosingShift),
          content: Text('$e'),
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
          Icon(
            icon,
            size: 18,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : AppColors.textMuted,
          ),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
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
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '$prefix${value.toStringAsFixed(0)} $currency',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
