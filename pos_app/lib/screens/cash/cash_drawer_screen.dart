import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../providers/auth_providers.dart';
import '../../providers/shifts_providers.dart';
import '../../services/manager_approval_service.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إدارة درج النقد
class CashDrawerScreen extends ConsumerStatefulWidget {
  const CashDrawerScreen({super.key});

  @override
  ConsumerState<CashDrawerScreen> createState() => _CashDrawerScreenState();
}

class _CashDrawerScreenState extends ConsumerState<CashDrawerScreen> {
  /// Format time from DateTime
  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final userName = user?.name ?? l10n.defaultUserName;

    return Column(
      children: [
        AppHeader(
          title: l10n.cashDrawer,
          subtitle: _getDateSubtitle(l10n),
          showSearch: isWideScreen,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: userName,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: ref.watch(openShiftProvider).when(
            data: (shift) {
              if (shift == null) {
                return _buildNoShiftMessage(isDark, l10n, isMediumScreen);
              }
              return ref.watch(shiftMovementsProvider(shift.id)).when(
                data: (movements) => SingleChildScrollView(
                  padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                  child: _buildContent(
                    shift, movements,
                    isWideScreen, isMediumScreen, isDark, l10n,
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
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

  Widget _buildNoShiftMessage(bool isDark, AppLocalizations l10n, bool isMediumScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          // Closed status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock_rounded, color: AppColors.error, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.shiftIsClosed,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.noOpenShiftCurrently,
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr • ${l10n.mainBranch}';
  }

  Widget _buildContent(
    ShiftsTableData shift,
    List<CashMovementsTableData> movements,
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // Compute values from shift and movements
    final openingBalance = shift.openingCash;
    final cashIn = movements
        .where((m) => m.type == 'cash_in')
        .fold<double>(0, (sum, m) => sum + m.amount);
    final cashOut = movements
        .where((m) => m.type == 'cash_out')
        .fold<double>(0, (sum, m) => sum + m.amount);
    final expectedBalance = openingBalance + cashIn - cashOut;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status card
        _buildStatusCard(shift, isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),

        // Balance summary + Quick actions
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildBalanceSummary(openingBalance, cashIn, cashOut, expectedBalance, isDark, l10n)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildQuickActions(shift, isDark, l10n)),
            ],
          )
        else ...[
          _buildBalanceSummary(openingBalance, cashIn, cashOut, expectedBalance, isDark, l10n),
          SizedBox(height: isMediumScreen ? 24 : 16),
          _buildQuickActions(shift, isDark, l10n),
        ],
        SizedBox(height: isMediumScreen ? 24 : 16),

        // Recent transactions
        _buildRecentTransactions(movements, isDark, l10n),
      ],
    );
  }

  Widget _buildStatusCard(ShiftsTableData shift, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_open_rounded, color: AppColors.success, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shiftIsOpen,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.shiftOpenSince(_formatTime(shift.openedAt)),
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.shiftClose),
            icon: const Icon(Icons.lock_rounded, size: 18),
            label: Text(l10n.closeShift),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummary(
    double openingBalance,
    double cashIn,
    double cashOut,
    double expectedBalance,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.balanceSummary,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _BalanceRow(label: l10n.openingBalance, amount: openingBalance, icon: Icons.account_balance_wallet_rounded, color: AppColors.info, isDark: isDark),
          _BalanceRow(label: l10n.cashIncoming, amount: cashIn, icon: Icons.add_circle_rounded, color: AppColors.success, isPositive: true, isDark: isDark),
          _BalanceRow(label: l10n.cashOutgoing, amount: cashOut, icon: Icons.remove_circle_rounded, color: AppColors.error, isNegative: true, isDark: isDark),
          Divider(height: 24, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.expectedBalance,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${expectedBalance.toStringAsFixed(0)} ${l10n.sar}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.success),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ShiftsTableData shift, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.add_rounded,
                  label: l10n.cashIn,
                  color: AppColors.success,
                  isDark: isDark,
                  onTap: () => _addCashMovement(true, shift),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.remove_rounded,
                  label: l10n.cashOut,
                  color: AppColors.error,
                  isDark: isDark,
                  onTap: () => _addCashMovement(false, shift),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(List<CashMovementsTableData> movements, bool isDark, AppLocalizations l10n) {
    // Show movements sorted by most recent first
    final sortedMovements = List<CashMovementsTableData>.from(movements)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentMovements = sortedMovements.take(10).toList();

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
                  l10n.recentTransactions,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: Text(l10n.viewAll)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (recentMovements.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.noCashMovementsYet,
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                ),
              ),
            )
          else
            ...recentMovements.map((m) => _TransactionTile(
              title: m.reason ?? (m.type == 'cash_in' ? l10n.cashIn : l10n.cashOut),
              amount: m.amount,
              time: _formatTime(m.createdAt),
              isIncome: m.type == 'cash_in',
              isDark: isDark,
              currency: l10n.sar,
            )),
        ],
      ),
    );
  }

  void _addCashMovement(bool isDeposit, ShiftsTableData shift) {
    final controller = TextEditingController();
    final noteController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isDeposit ? l10n.cashIn : l10n.cashOut),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.amount,
                prefixIcon: Icon(isDeposit ? Icons.add : Icons.remove),
                suffixText: l10n.sar,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: l10n.noteLabel,
                prefixIcon: const Icon(Icons.note),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;

              Navigator.pop(dialogContext);

              // سحب نقدي: طلب موافقة المشرف عبر PinService
              if (!isDeposit) {
                if (!mounted) return;
                final approved = await ManagerApprovalService.requestPinApproval(
                  context: context,
                  action: 'cash_out',
                );
                if (!approved) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم رفض العملية - لم تتم الموافقة'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }
              }

              try {
                final user = ref.read(currentUserProvider);
                final addMovement = ref.read(addCashMovementProvider);
                await addMovement(
                  shiftId: shift.id,
                  type: isDeposit ? 'cash_in' : 'cash_out',
                  amount: amount,
                  reason: noteController.text.isNotEmpty ? noteController.text : null,
                  createdBy: user?.name,
                );

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isDeposit ? l10n.depositDone : l10n.withdrawalDone)),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
                );
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    ).then((_) {
      controller.dispose();
      noteController.dispose();
    });
  }
}

class _BalanceRow extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isPositive;
  final bool isNegative;
  final bool isDark;

  const _BalanceRow({
    required this.label, required this.amount, required this.icon, required this.color,
    this.isPositive = false, this.isNegative = false, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textPrimary)),
          ),
          Text(
            '${isPositive ? '+' : isNegative ? '-' : ''}${amount.toStringAsFixed(0)} ${l10n.sar}',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon, required this.label, required this.color,
    required this.isDark, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final double amount;
  final String time;
  final bool isIncome;
  final bool isDark;
  final String currency;

  const _TransactionTile({
    required this.title, required this.amount, required this.time,
    required this.isIncome, required this.isDark, required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isIncome ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: isIncome ? AppColors.success : AppColors.error,
          size: 20,
        ),
      ),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 14)),
      subtitle: Text(time, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)),
      trailing: Text(
        '${isIncome ? '+' : '-'}${amount.toStringAsFixed(0)} $currency',
        style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? AppColors.success : AppColors.error),
      ),
    );
  }
}
