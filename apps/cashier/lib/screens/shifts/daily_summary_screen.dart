/// Daily Summary Screen - End of day report
///
/// Shows: total sales, refunds, cash movements, shift summary.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
// alhai_design_system is re-exported via alhai_shared_ui

/// شاشة ملخص اليوم
class DailySummaryScreen extends ConsumerWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.dailySummary,
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: ref.watch(todayShiftsProvider).when(
            data: (shifts) => SingleChildScrollView(
              padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
              child: _buildContent(
                  context, ref, shifts, isWideScreen, isMediumScreen, isDark, l10n),
            ),
            loading: () => const AppLoadingState(),
            error: (e, _) => AppErrorState.general(
              message: '$e',
              onRetry: () => ref.invalidate(todayShiftsProvider),
            ),
          ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<ShiftsTableData> shifts,
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // Aggregate data from all shifts today
    double totalSales = 0;
    double totalRefunds = 0;
    int totalSalesCount = 0;
    int totalRefundsCount = 0;
    double totalOpeningCash = 0;

    for (final shift in shifts) {
      totalSales += shift.totalSalesAmount;
      totalRefunds += shift.totalRefundsAmount;
      totalSalesCount += shift.totalSales;
      totalRefundsCount += shift.totalRefunds;
      totalOpeningCash += shift.openingCash;
    }

    final netRevenue = totalSales - totalRefunds;

    if (isWideScreen) {
      return Column(
        children: [
          // Stats row
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      l10n.totalSales,
                      CurrencyFormatter.formatCompact(totalSales),
                      '$totalSalesCount ${l10n.invoices}',
                      Icons.trending_up_rounded,
                      AppColors.success,
                      isDark)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(
                      l10n.returns,
                      CurrencyFormatter.formatCompact(totalRefunds),
                      '$totalRefundsCount ${l10n.returns}',
                      Icons.assignment_return_rounded,
                      AppColors.error,
                      isDark)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(
                      l10n.netRevenue,
                      CurrencyFormatter.formatCompact(netRevenue),
                      l10n.afterRefunds,
                      Icons.account_balance_wallet_rounded,
                      AppColors.primary,
                      isDark)),
            ],
          ),
          const SizedBox(height: 24),
          // Shifts details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildShiftsTable(context, shifts, isDark, l10n)),
              const SizedBox(width: 24),
              Expanded(
                  flex: 2,
                  child: _buildSummaryCard(
                      totalOpeningCash, totalSales, totalRefunds, netRevenue,
                      shifts.length, isDark, l10n)),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stats
        _buildStatCard(
            l10n.totalSales,
            CurrencyFormatter.formatCompact(totalSales),
            '$totalSalesCount ${l10n.invoices}',
            Icons.trending_up_rounded,
            AppColors.success,
            isDark),
        SizedBox(height: isMediumScreen ? 16 : 12),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    l10n.returns,
                    CurrencyFormatter.formatCompact(totalRefunds),
                    '$totalRefundsCount',
                    Icons.assignment_return_rounded,
                    AppColors.error,
                    isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(
                child: _buildStatCard(
                    l10n.netRevenue,
                    CurrencyFormatter.formatCompact(netRevenue),
                    l10n.afterRefunds,
                    Icons.account_balance_wallet_rounded,
                    AppColors.primary,
                    isDark)),
          ],
        ),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildSummaryCard(totalOpeningCash, totalSales, totalRefunds,
            netRevenue, shifts.length, isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildShiftsTable(context, shifts, isDark, l10n),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle,
      IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(isDark))),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.getTextMuted(isDark))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    double openingCash,
    double totalSales,
    double totalRefunds,
    double netRevenue,
    int shiftCount,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.summarize_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text(l10n.dailySummary,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: 20),
          _SummaryLine(
              label: l10n.shiftsCount,
              value: '$shiftCount',
              color: AppColors.info,
              isDark: isDark),
          _SummaryLine(
              label: l10n.openingBalance,
              value: CurrencyFormatter.formatCompact(openingCash),
              color: AppColors.info,
              isDark: isDark),
          _SummaryLine(
              label: l10n.totalSales,
              value: '+${CurrencyFormatter.formatCompact(totalSales)}',
              color: AppColors.success,
              isDark: isDark),
          _SummaryLine(
              label: l10n.returns,
              value: '-${CurrencyFormatter.formatCompact(totalRefunds)}',
              color: AppColors.error,
              isDark: isDark),
          Divider(height: 24, color: AppColors.getBorder(isDark)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.netRevenue,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.getTextPrimary(isDark))),
                Text(
                  CurrencyFormatter.formatCompact(netRevenue),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsTable(
      BuildContext context, List<ShiftsTableData> shifts, bool isDark, AppLocalizations l10n) {
    if (shifts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.timer_off_rounded,
                  size: 48,
                  color:
                      AppColors.getTextMuted(isDark).withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(l10n.noShiftsToday,
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColors.getTextMuted(isDark))),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 20,
                    color: AppColors.getTextSecondary(isDark)),
                const SizedBox(width: 10),
                Text(l10n.todayShifts,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('${shifts.length}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Shift items
          ...shifts.map((shift) => _buildShiftItem(context, shift, isDark, l10n)),
        ],
      ),
    );
  }

  Widget _buildShiftItem(
      BuildContext context, ShiftsTableData shift, bool isDark, AppLocalizations l10n) {
    final isOpen = shift.status == 'open';
    final statusColor = isOpen ? AppColors.success : Theme.of(context).colorScheme.outline;

    final openTime =
        '${shift.openedAt.hour.toString().padLeft(2, '0')}:${shift.openedAt.minute.toString().padLeft(2, '0')}';
    final closeTime = shift.closedAt != null
        ? '${shift.closedAt!.hour.toString().padLeft(2, '0')}:${shift.closedAt!.minute.toString().padLeft(2, '0')}'
        : l10n.ongoing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: AppColors.getBorder(isDark).withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shift.cashierName,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark))),
                const SizedBox(height: 4),
                Text('$openTime - $closeTime',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(isDark))),
              ],
            ),
          ),
          // Sales count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                  CurrencyFormatter.formatCompact(shift.totalSalesAmount),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark))),
              const SizedBox(height: 2),
              Text('${shift.totalSales} ${l10n.invoices}',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getTextMuted(isDark))),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _SummaryLine(
      {required this.label,
      required this.value,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: AppColors.getTextSecondary(isDark))),
          ),
          Text(value,
              style:
                  TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
