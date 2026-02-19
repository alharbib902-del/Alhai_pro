import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إدارة الورديات
class ShiftsScreen extends ConsumerStatefulWidget {
  const ShiftsScreen({super.key});

  @override
  ConsumerState<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends ConsumerState<ShiftsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'pos';

  // Mock shift data
  final List<_ShiftData> _shifts = [
    _ShiftData(id: 1, cashier: 'أحمد محمد', openTime: '08:00', closeTime: null, totalSales: 4200, transactions: 45, cashSales: 2350, cardSales: 1850, creditSales: 0, openingCash: 500, isOpen: true),
    _ShiftData(id: 2, cashier: 'سارة علي', openTime: '08:00', closeTime: '16:30', totalSales: 3800, transactions: 38, cashSales: 2100, cardSales: 1200, creditSales: 500, openingCash: 500, isOpen: false),
    _ShiftData(id: 3, cashier: 'أحمد محمد', openTime: '07:30', closeTime: '15:00', totalSales: 5100, transactions: 52, cashSales: 3200, cardSales: 1500, creditSales: 400, openingCash: 500, isOpen: false),
    _ShiftData(id: 4, cashier: 'خالد يوسف', openTime: '09:00', closeTime: '17:30', totalSales: 2900, transactions: 28, cashSales: 1600, cardSales: 1100, creditSales: 200, openingCash: 500, isOpen: false),
    _ShiftData(id: 5, cashier: 'سارة علي', openTime: '08:00', closeTime: '16:00', totalSales: 4500, transactions: 41, cashSales: 2500, cardSales: 1500, creditSales: 500, openingCash: 500, isOpen: false),
  ];

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
                  title: l10n.shift,
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
    final openShift = _shifts.firstWhere((s) => s.isOpen, orElse: () => _shifts.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current shift status card
        if (openShift.isOpen)
          _buildCurrentShiftCard(openShift, isDark, l10n),
        if (openShift.isOpen)
          SizedBox(height: isMediumScreen ? 24 : 16),

        // Stats cards
        _buildStatsRow(isWideScreen, isMediumScreen, isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),

        // Shifts list
        _buildShiftsList(isDark, l10n),
      ],
    );
  }

  Widget _buildCurrentShiftCard(_ShiftData shift, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                  'وردية مفتوحة حالياً', // TODO: l10n.currentShiftOpen
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${shift.cashier} • منذ ${shift.openTime}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ShiftBadge(label: '${shift.totalSales.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.attach_money),
                    const SizedBox(width: 12),
                    _ShiftBadge(label: '${shift.transactions} عملية', icon: Icons.receipt_long_rounded),
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

  Widget _buildStatsRow(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final totalSales = _shifts.fold(0.0, (sum, s) => sum + s.totalSales);
    final totalTransactions = _shifts.fold(0, (sum, s) => sum + s.transactions);
    final openCount = _shifts.where((s) => s.isOpen).length;
    final closedCount = _shifts.where((s) => !s.isOpen).length;

    final cards = [
      _buildStatCard(
        'إجمالي المبيعات', // TODO: l10n
        '${totalSales.toStringAsFixed(0)} ${l10n.sar}',
        Icons.trending_up_rounded,
        AppColors.success,
        isDark,
      ),
      _buildStatCard(
        'إجمالي العمليات', // TODO: l10n
        '$totalTransactions',
        Icons.receipt_long_rounded,
        AppColors.info,
        isDark,
      ),
      _buildStatCard(
        'ورديات مفتوحة', // TODO: l10n
        '$openCount',
        Icons.lock_open_rounded,
        AppColors.warning,
        isDark,
      ),
      _buildStatCard(
        'ورديات مغلقة', // TODO: l10n
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

  Widget _buildShiftsList(bool isDark, AppLocalizations l10n) {
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
                  'سجل الورديات', // TODO: l10n.shiftsLog
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
          ...(_shifts.map((shift) => _buildShiftTile(shift, isDark, l10n))),
        ],
      ),
    );
  }

  Widget _buildShiftTile(_ShiftData shift, bool isDark, AppLocalizations l10n) {
    return InkWell(
      onTap: () => _showShiftDetails(shift, isDark, l10n),
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
                color: shift.isOpen
                    ? AppColors.success.withValues(alpha: 0.1)
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.backgroundSecondary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                shift.isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                color: shift.isOpen ? AppColors.success : (isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted),
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
                        'وردية #${shift.id}', // TODO: l10n
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (shift.isOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'مفتوحة', // TODO: l10n.open
                            style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${shift.cashier} • ${shift.openTime} ${shift.closeTime != null ? '- ${shift.closeTime}' : ''}',
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
                  '${shift.totalSales.toStringAsFixed(0)} ${l10n.sar}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${shift.transactions} عملية', // TODO: l10n
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

  void _showShiftDetails(_ShiftData shift, bool isDark, AppLocalizations l10n) {
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
                    color: shift.isOpen
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    shift.isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                    color: shift.isOpen ? AppColors.success : AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'وردية #${shift.id}', // TODO: l10n
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        shift.cashier,
                        style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (shift.isOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'مفتوحة', // TODO: l10n.open
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(label: 'وقت الفتح', value: shift.openTime, icon: Icons.login_rounded, isDark: isDark),
            if (shift.closeTime != null)
              _DetailRow(label: 'وقت الإغلاق', value: shift.closeTime!, icon: Icons.logout_rounded, isDark: isDark),
            Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _DetailRow(label: l10n.openingBalance, value: '${shift.openingCash.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.account_balance_wallet_rounded, isDark: isDark),
            _DetailRow(label: 'إجمالي المبيعات', value: '${shift.totalSales.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.trending_up_rounded, isDark: isDark, valueColor: AppColors.success),
            _DetailRow(label: 'عدد العمليات', value: '${shift.transactions}', icon: Icons.receipt_long_rounded, isDark: isDark),
            Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _DetailRow(label: 'نقداً', value: '${shift.cashSales.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.money_rounded, isDark: isDark, valueColor: AppColors.cash),
            _DetailRow(label: 'بطاقة', value: '${shift.cardSales.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.credit_card_rounded, isDark: isDark, valueColor: AppColors.card),
            _DetailRow(label: 'آجل', value: '${shift.creditSales.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.schedule_rounded, isDark: isDark, valueColor: AppColors.debt),
            const SizedBox(height: 24),
            if (shift.isOpen)
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

class _ShiftData {
  final int id;
  final String cashier;
  final String openTime;
  final String? closeTime;
  final double totalSales;
  final int transactions;
  final double cashSales;
  final double cardSales;
  final double creditSales;
  final double openingCash;
  final bool isOpen;

  const _ShiftData({
    required this.id,
    required this.cashier,
    required this.openTime,
    this.closeTime,
    required this.totalSales,
    required this.transactions,
    required this.cashSales,
    required this.cardSales,
    required this.creditSales,
    required this.openingCash,
    required this.isOpen,
  });
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
