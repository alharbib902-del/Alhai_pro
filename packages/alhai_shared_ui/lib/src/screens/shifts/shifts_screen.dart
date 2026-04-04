import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/router/routes.dart';
import '../../core/utils/currency_formatter.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../providers/shifts_providers.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إدارة الورديات
class ShiftsScreen extends ConsumerWidget {
  const ShiftsScreen({super.key});

  // Helper to format time from DateTime
  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        AppHeader(
          title: l10n.shift,
          subtitle: _getDateSubtitle(l10n),
          showSearch: isWideScreen,
          searchHint: l10n.searchPlaceholder,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          onUserTap: () {},
          actions: [
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.shiftOpen),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.openShift),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.md, vertical: 10),
              ),
            ),
          ],
        ),
        Expanded(
          child: ref.watch(todayShiftsProvider).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('${l10n.error}: $e')),
                data: (shifts) => SingleChildScrollView(
                  padding: EdgeInsets.all(
                      isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
                  child: _buildContent(
                      context, shifts, isWideScreen, isMediumScreen, l10n),
                ),
              ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr • ${l10n.mainBranch}';
  }

  Widget _buildContent(BuildContext context, List<ShiftsTableData> shifts,
      bool isWideScreen, bool isMediumScreen, AppLocalizations l10n) {
    final openShift = shifts.where((s) => s.status == 'open').firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current shift status card
        if (openShift != null) _buildCurrentShiftCard(context, openShift, l10n),
        if (openShift != null)
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),

        // Stats cards
        _buildStatsRow(context, shifts, isWideScreen, isMediumScreen, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),

        // Shifts list
        _buildShiftsList(context, shifts, l10n),
      ],
    );
  }

  Widget _buildCurrentShiftCard(
      BuildContext context, ShiftsTableData shift, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.lock_open_rounded,
                color: colorScheme.onPrimary, size: 32),
          ),
          SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentlyOpenShift,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  '${shift.cashierName} • ${l10n.since} ${_formatTime(shift.openedAt)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: AlhaiSpacing.xs),
                Row(
                  children: [
                    _ShiftBadge(
                        label: CurrencyFormatter.formatCompact(
                            shift.totalSalesAmount),
                        icon: Icons.attach_money),
                    SizedBox(width: AlhaiSpacing.sm),
                    _ShiftBadge(
                        label: '${shift.totalSales} ${l10n.transaction}',
                        icon: Icons.receipt_long_rounded),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.shiftClose),
            icon: const Icon(Icons.lock_rounded, size: 18),
            label: Text(l10n.closeShift),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.surface,
              foregroundColor: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, List<ShiftsTableData> shifts,
      bool isWideScreen, bool isMediumScreen, AppLocalizations l10n) {
    final totalSales = shifts.fold(0.0, (sum, s) => sum + s.totalSalesAmount);
    final totalTransactions = shifts.fold(0, (sum, s) => sum + s.totalSales);
    final openCount = shifts.where((s) => s.status == 'open').length;
    final closedCount = shifts.where((s) => s.status != 'open').length;

    final cards = [
      _buildStatCard(
        context,
        l10n.totalSales,
        CurrencyFormatter.formatCompact(totalSales),
        Icons.trending_up_rounded,
        AppColors.success,
      ),
      _buildStatCard(
        context,
        l10n.totalTransactions,
        '$totalTransactions',
        Icons.receipt_long_rounded,
        AppColors.info,
      ),
      _buildStatCard(
        context,
        l10n.openShifts,
        '$openCount',
        Icons.lock_open_rounded,
        AppColors.warning,
      ),
      _buildStatCard(
        context,
        l10n.closedShifts,
        '$closedCount',
        Icons.lock_rounded,
        AppColors.secondary,
      ),
    ];

    if (isWideScreen) {
      return Row(
        children: cards.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  end: entry.key < cards.length - 1 ? 16 : 0),
              child: entry.value,
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        Row(children: [
          Expanded(child: cards[0]),
          SizedBox(width: AlhaiSpacing.sm),
          Expanded(child: cards[1])
        ]),
        SizedBox(height: AlhaiSpacing.sm),
        Row(children: [
          Expanded(child: cards[2]),
          SizedBox(width: AlhaiSpacing.sm),
          Expanded(child: cards[3])
        ]),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.xs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: AlhaiSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AlhaiSpacing.xxs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsList(BuildContext context, List<ShiftsTableData> shifts,
      AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            child: Row(
              children: [
                Text(
                  l10n.shiftsLog,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.sm, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list_rounded,
                          size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(l10n.filter,
                          style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          if (shifts.isEmpty)
            AppEmptyState.noData(context,
                title: l10n.noShiftsToday, description: l10n.openShift)
          else
            ...(shifts.map((shift) => _buildShiftTile(context, shift, l10n))),
        ],
      ),
    );
  }

  Widget _buildShiftTile(
      BuildContext context, ShiftsTableData shift, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOpen = shift.status == 'open';
    return InkWell(
      onTap: () => _showShiftDetails(context, shift, l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.mdl, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isOpen
                    ? AppColors.success.withValues(alpha: 0.1)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                color:
                    isOpen ? AppColors.success : colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${l10n.shift} #${shift.id.substring(0, 6)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(width: AlhaiSpacing.xs),
                      if (isOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AlhaiSpacing.xs,
                              vertical: AlhaiSpacing.xxxs),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l10n.open,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AlhaiSpacing.xxs),
                  Text(
                    '${shift.cashierName} • ${_formatTime(shift.openedAt)} ${shift.closedAt != null ? '- ${_formatTime(shift.closedAt)}' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatCompact(shift.totalSalesAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  '${shift.totalSales} ${l10n.transaction}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(width: AlhaiSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showShiftDetails(
      BuildContext context, ShiftsTableData shift, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOpen = shift.status == 'open';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: AlhaiSpacing.mdl),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                    color: isOpen ? AppColors.success : AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.shift} #${shift.id.substring(0, 6)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        shift.cashierName,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (isOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.sm, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.open,
                      style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AlhaiSpacing.lg),
            _DetailRow(
                label: l10n.openTime,
                value: _formatTime(shift.openedAt),
                icon: Icons.login_rounded),
            if (shift.closedAt != null)
              _DetailRow(
                  label: l10n.closeTime,
                  value: _formatTime(shift.closedAt),
                  icon: Icons.logout_rounded),
            Divider(height: 32, color: colorScheme.outlineVariant),
            _DetailRow(
                label: l10n.openingBalance,
                value: CurrencyFormatter.formatCompact(shift.openingCash),
                icon: Icons.account_balance_wallet_rounded),
            _DetailRow(
                label: l10n.totalSales,
                value: CurrencyFormatter.formatCompact(shift.totalSalesAmount),
                icon: Icons.trending_up_rounded,
                valueColor: AppColors.success),
            _DetailRow(
                label: l10n.transactionCount,
                value: '${shift.totalSales}',
                icon: Icons.receipt_long_rounded),
            Divider(height: 32, color: colorScheme.outlineVariant),
            _DetailRow(
                label: l10n.expectedCash,
                value: CurrencyFormatter.formatCompact(shift.expectedCash ?? 0),
                icon: Icons.money_rounded,
                valueColor: AppColors.cash),
            if (shift.closingCash != null)
              _DetailRow(
                  label: l10n.closingCash,
                  value: CurrencyFormatter.formatCompact(shift.closingCash!),
                  icon: Icons.account_balance_wallet_rounded,
                  valueColor: AppColors.card),
            if (shift.difference != null)
              _DetailRow(
                  label: l10n.difference,
                  value: CurrencyFormatter.formatCompact(shift.difference!),
                  icon: Icons.compare_arrows_rounded,
                  valueColor: shift.difference! >= 0
                      ? AppColors.success
                      : AppColors.error),
            SizedBox(height: AlhaiSpacing.lg),
            if (isOpen)
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.shiftClose);
                },
                icon: const Icon(Icons.lock_rounded, size: 18),
                label: Text(l10n.closeShift),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShiftBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ShiftBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: AlhaiSpacing.xxs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 14),
          SizedBox(width: AlhaiSpacing.xxs),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
