import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
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
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.shift,
                  subtitle: _getDateSubtitle(l10n),
                  showSearch: isWideScreen,
                  searchHint: l10n.searchPlaceholder,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
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
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ref.watch(todayShiftsProvider).when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('${l10n.error}: $e')),
                    data: (shifts) => SingleChildScrollView(
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: _buildContent(context, shifts, isWideScreen, isMediumScreen, isDark, l10n),
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

  Widget _buildContent(BuildContext context, List<ShiftsTableData> shifts, bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final openShift = shifts.where((s) => s.status == 'open').firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current shift status card
        if (openShift != null)
          _buildCurrentShiftCard(context, openShift, isDark, l10n),
        if (openShift != null)
          SizedBox(height: isMediumScreen ? 24 : 16),

        // Stats cards
        _buildStatsRow(shifts, isWideScreen, isMediumScreen, isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),

        // Shifts list
        _buildShiftsList(context, shifts, isDark, l10n),
      ],
    );
  }

  Widget _buildCurrentShiftCard(BuildContext context, ShiftsTableData shift, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Text(
                  '${shift.cashierName} • ${l10n.since} ${_formatTime(shift.openedAt)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ShiftBadge(label: '${shift.totalSalesAmount.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.attach_money),
                    const SizedBox(width: 12),
                    _ShiftBadge(label: '${shift.totalSales} ${l10n.transaction}', icon: Icons.receipt_long_rounded),
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
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<ShiftsTableData> shifts, bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final totalSales = shifts.fold(0.0, (sum, s) => sum + s.totalSalesAmount);
    final totalTransactions = shifts.fold(0, (sum, s) => sum + s.totalSales);
    final openCount = shifts.where((s) => s.status == 'open').length;
    final closedCount = shifts.where((s) => s.status != 'open').length;

    final cards = [
      _buildStatCard(
        l10n.totalSales,
        '${totalSales.toStringAsFixed(0)} ${l10n.sar}',
        Icons.trending_up_rounded,
        AppColors.success,
        isDark,
      ),
      _buildStatCard(
        l10n.totalTransactions,
        '$totalTransactions',
        Icons.receipt_long_rounded,
        AppColors.info,
        isDark,
      ),
      _buildStatCard(
        l10n.openShifts,
        '$openCount',
        Icons.lock_open_rounded,
        AppColors.warning,
        isDark,
      ),
      _buildStatCard(
        l10n.closedShifts,
        '$closedCount',
        Icons.lock_rounded,
        AppColors.secondary,
        isDark,
      ),
    ];

    if (isWideScreen) {
      return Row(
        children: cards.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: entry.key < cards.length - 1 ? 16 : 0),
              child: entry.value,
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        Row(children: [Expanded(child: cards[0]), const SizedBox(width: 12), Expanded(child: cards[1])]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: cards[2]), const SizedBox(width: 12), Expanded(child: cards[3])]),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsList(BuildContext context, List<ShiftsTableData> shifts, bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  l10n.shiftsLog,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list_rounded, size: 16, color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(l10n.filter, style: TextStyle(fontSize: 13, color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          if (shifts.isEmpty)
            AppEmptyState.noData(title: l10n.noShiftsToday, description: l10n.openShift)
          else
            ...(shifts.map((shift) => _buildShiftTile(context, shift, isDark, l10n))),
        ],
      ),
    );
  }

  Widget _buildShiftTile(BuildContext context, ShiftsTableData shift, bool isDark, AppLocalizations l10n) {
    final isOpen = shift.status == 'open';
    return InkWell(
      onTap: () => _showShiftDetails(context, shift, isDark, l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.border.withValues(alpha: 0.5),
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
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.backgroundSecondary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                color: isOpen ? AppColors.success : (isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted),
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
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l10n.open,
                            style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${shift.cashierName} • ${_formatTime(shift.openedAt)} ${shift.closedAt != null ? '- ${_formatTime(shift.closedAt)}' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${shift.totalSalesAmount.toStringAsFixed(0)} ${l10n.sar}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${shift.totalSales} ${l10n.transaction}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showShiftDetails(BuildContext context, ShiftsTableData shift, bool isDark, AppLocalizations l10n) {
    final isOpen = shift.status == 'open';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        shift.cashierName,
                        style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (isOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.open,
                      style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(label: l10n.openTime, value: _formatTime(shift.openedAt), icon: Icons.login_rounded, isDark: isDark),
            if (shift.closedAt != null)
              _DetailRow(label: l10n.closeTime, value: _formatTime(shift.closedAt), icon: Icons.logout_rounded, isDark: isDark),
            Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _DetailRow(label: l10n.openingBalance, value: '${shift.openingCash.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.account_balance_wallet_rounded, isDark: isDark),
            _DetailRow(label: l10n.totalSales, value: '${shift.totalSalesAmount.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.trending_up_rounded, isDark: isDark, valueColor: AppColors.success),
            _DetailRow(label: l10n.transactionCount, value: '${shift.totalSales}', icon: Icons.receipt_long_rounded, isDark: isDark),
            Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _DetailRow(label: l10n.expectedCash, value: '${(shift.expectedCash ?? 0).toStringAsFixed(0)} ${l10n.sar}', icon: Icons.money_rounded, isDark: isDark, valueColor: AppColors.cash),
            if (shift.closingCash != null)
              _DetailRow(label: l10n.closingCash, value: '${shift.closingCash!.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.account_balance_wallet_rounded, isDark: isDark, valueColor: AppColors.card),
            if (shift.difference != null)
              _DetailRow(label: l10n.difference, value: '${shift.difference!.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.compare_arrows_rounded, isDark: isDark, valueColor: shift.difference! >= 0 ? AppColors.success : AppColors.error),
            const SizedBox(height: 24),
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
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.95), fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
