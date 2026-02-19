import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إدارة درج النقد
class CashDrawerScreen extends ConsumerStatefulWidget {
  const CashDrawerScreen({super.key});

  @override
  ConsumerState<CashDrawerScreen> createState() => _CashDrawerScreenState();
}

class _CashDrawerScreenState extends ConsumerState<CashDrawerScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'pos';

  final double _openingBalance = 500.0;
  final double _cashIn = 8450.0;
  final double _cashOut = 350.0;
  final double _expectedBalance = 8600.0;
  double _actualBalance = 0;
  bool _isOpen = true;

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard': context.go(AppRoutes.dashboard); break;
      case 'pos': context.go(AppRoutes.pos); break;
      case 'products': context.push(AppRoutes.products); break;
      case 'categories': context.push(AppRoutes.categories); break;
      case 'inventory': context.push(AppRoutes.inventory); break;
      case 'customers': context.push(AppRoutes.customers); break;
      case 'invoices': context.push(AppRoutes.invoices); break;
      case 'orders': context.push(AppRoutes.orders); break;
      case 'sales': context.push(AppRoutes.invoices); break;
      case 'returns': context.push(AppRoutes.returns); break;
      case 'reports': context.push(AppRoutes.reports); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      body: Row(
        children: [
          if (isWideScreen)
            AppSidebar(
              storeName: l10n.brandName,
              groups: DefaultSidebarItems.getGroups(context),
              selectedId: _selectedNavId,
              onItemTap: _handleNavigation,
              onSettingsTap: () => context.push(AppRoutes.settings),
              onSupportTap: () {},
              onLogoutTap: () => context.go('/login'),
              collapsed: _sidebarCollapsed,
              userName: 'أحمد محمد',
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: l10n.cashDrawer,
                  subtitle: _getDateSubtitle(l10n),
                  showSearch: isWideScreen,
                  searchHint: l10n.searchPlaceholder,
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد',
                  userRole: l10n.branchManager,
                  onUserTap: () {},
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      child: AppSidebar(
        storeName: l10n.brandName,
        groups: DefaultSidebarItems.getGroups(context),
        selectedId: _selectedNavId,
        onItemTap: (item) {
          Navigator.pop(context);
          _handleNavigation(item);
        },
        onSettingsTap: () {
          Navigator.pop(context);
          context.push(AppRoutes.settings);
        },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
        userName: 'أحمد محمد',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr • ${l10n.mainBranch}';
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status card
        _buildStatusCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),

        // Balance summary + Quick actions
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildBalanceSummary(isDark, l10n)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildQuickActions(isDark, l10n)),
            ],
          )
        else ...[
          _buildBalanceSummary(isDark, l10n),
          SizedBox(height: isMediumScreen ? 24 : 16),
          _buildQuickActions(isDark, l10n),
        ],
        SizedBox(height: isMediumScreen ? 24 : 16),

        // Recent transactions
        _buildRecentTransactions(isDark, l10n),
      ],
    );
  }

  Widget _buildStatusCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isOpen
            ? AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08)
            : AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isOpen
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_isOpen ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: _isOpen ? AppColors.success : AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOpen ? 'الوردية مفتوحة' : 'الوردية مغلقة', // TODO: l10n
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isOpen ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'منذ: 8:00 صباحاً', // TODO: l10n
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (_isOpen)
            FilledButton.icon(
              onPressed: _closeDrawer,
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

  Widget _buildBalanceSummary(bool isDark, AppLocalizations l10n) {
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
            'ملخص الرصيد', // TODO: l10n.balanceSummary
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _BalanceRow(label: l10n.openingBalance, amount: _openingBalance, icon: Icons.account_balance_wallet_rounded, color: AppColors.info, isDark: isDark),
          _BalanceRow(label: 'النقد الوارد', amount: _cashIn, icon: Icons.add_circle_rounded, color: AppColors.success, isPositive: true, isDark: isDark),
          _BalanceRow(label: 'النقد الصادر', amount: _cashOut, icon: Icons.remove_circle_rounded, color: AppColors.error, isNegative: true, isDark: isDark),
          Divider(height: 24, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الرصيد المتوقع', // TODO: l10n.expectedBalance
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_expectedBalance.toStringAsFixed(0)} ${l10n.sar}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.success),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, AppLocalizations l10n) {
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
            'عمليات سريعة', // TODO: l10n.quickActions
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
                  label: 'إيداع نقدي', // TODO: l10n.cashDeposit
                  color: AppColors.success,
                  isDark: isDark,
                  onTap: () => _addCashMovement(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.remove_rounded,
                  label: 'سحب نقدي', // TODO: l10n.cashWithdrawal
                  color: AppColors.error,
                  isDark: isDark,
                  onTap: () => _addCashMovement(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(bool isDark, AppLocalizations l10n) {
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
                  'آخر الحركات', // TODO: l10n.recentTransactions
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: Text(l10n.viewAll)),
              ],
            ),
          ),
          const Divider(height: 1),
          _TransactionTile(title: 'بيع نقدي - فاتورة #125', amount: 150, time: '10:45', isIncome: true, isDark: isDark, currency: l10n.sar),
          _TransactionTile(title: 'سحب - مصروفات', amount: 100, time: '10:30', isIncome: false, isDark: isDark, currency: l10n.sar),
          _TransactionTile(title: 'بيع نقدي - فاتورة #124', amount: 85, time: '10:15', isIncome: true, isDark: isDark, currency: l10n.sar),
          _TransactionTile(title: 'بيع نقدي - فاتورة #123', amount: 230, time: '09:55', isIncome: true, isDark: isDark, currency: l10n.sar),
        ],
      ),
    );
  }

  void _addCashMovement(bool isDeposit) {
    final controller = TextEditingController();
    final noteController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDeposit ? 'إيداع نقدي' : 'سحب نقدي'), // TODO: l10n
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
                labelText: 'ملاحظة', // TODO: l10n.note
                prefixIcon: const Icon(Icons.note),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isDeposit ? 'تم الإيداع' : 'تم السحب')),
              );
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _closeDrawer() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.closeShift),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الرصيد المتوقع: ${_expectedBalance.toStringAsFixed(0)} ${l10n.sar}'),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'الرصيد الفعلي', suffixText: l10n.sar), // TODO: l10n
                onChanged: (v) => setDialogState(() => _actualBalance = double.tryParse(v) ?? 0),
              ),
              if (_actualBalance > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _actualBalance == _expectedBalance
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الفرق'), // TODO: l10n
                      Text(
                        '${(_actualBalance - _expectedBalance).toStringAsFixed(0)} ${l10n.sar}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _actualBalance == _expectedBalance ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isOpen = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إغلاق الوردية')),
                );
              },
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
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
            '${isPositive ? '+' : isNegative ? '-' : ''}${amount.toStringAsFixed(0)} ر.س',
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
