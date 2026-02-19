import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إقفال الشهر وحساب الفوائد
class MonthlyCloseScreen extends ConsumerStatefulWidget {
  const MonthlyCloseScreen({super.key});

  @override
  ConsumerState<MonthlyCloseScreen> createState() => _MonthlyCloseScreenState();
}

class _MonthlyCloseScreenState extends ConsumerState<MonthlyCloseScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'reports';

  final _db = getIt<AppDatabase>();
  List<_CustomerDebt> _customers = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _lastCloseDate;
  double _interestRate = 5.0;
  int _graceDays = 30;
  String _currentPeriod = '';

  @override
  void initState() {
    super.initState();
    _currentPeriod = _getPeriodKey(DateTime.now());
    _loadData();
  }

  String _getPeriodKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _lastCloseDate = prefs.getString('last_month_close');
      _interestRate = prefs.getDouble('interest_rate') ?? 5.0;
      _graceDays = prefs.getInt('interest_grace_days') ?? 30;

      final storeId = prefs.getString('selected_store_id') ?? '';
      final accounts = await _db.accountsDao.getReceivableAccounts(storeId);

      final customers = <_CustomerDebt>[];
      final gracePeriod = DateTime.now().subtract(Duration(days: _graceDays));

      for (final account in accounts) {
        if (account.balance > 0) {
          final hasInterest = await _db.transactionsDao.hasInterestForPeriod(account.id, _currentPeriod);
          final isOverdue = account.lastTransactionAt != null && account.lastTransactionAt!.isBefore(gracePeriod);

          if (!hasInterest && isOverdue) {
            customers.add(_CustomerDebt(
              account: account,
              expectedInterest: account.balance * (_interestRate / 100),
              isSelected: true,
            ));
          }
        }
      }

      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

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
                  title: 'إقفال الشهر', // TODO: l10n.monthlyClose
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
                  actions: [
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary),
                      onPressed: _loadData,
                    ),
                  ],
                  onUserTap: () {},
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                                child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                              ),
                            ),
                            _buildBottomBar(isDark, l10n),
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
        _buildPeriodInfo(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildSummary(isWideScreen, isMediumScreen, isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildCustomersList(isDark, l10n),
      ],
    );
  }

  Widget _buildPeriodInfo(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: AppColors.info, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فترة الإقفال: $_currentPeriod', // TODO: l10n
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                if (_lastCloseDate != null)
                  Text(
                    'آخر إقفال: $_lastCloseDate', // TODO: l10n
                    style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary, fontSize: 12),
                  ),
                Text(
                  'نسبة الفائدة: $_interestRate% | فترة السماح: $_graceDays يوم', // TODO: l10n
                  style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final selectedCustomers = _customers.where((c) => c.isSelected).toList();
    final totalInterest = selectedCustomers.fold<double>(0, (sum, c) => sum + c.expectedInterest);
    final totalDebt = selectedCustomers.fold<double>(0, (sum, c) => sum + c.account.balance);

    final cards = [
      _buildSummaryCard(
        title: 'العملاء المختارين', // TODO: l10n
        value: '${selectedCustomers.length}',
        icon: Icons.people_rounded,
        color: AppColors.info,
        isDark: isDark,
      ),
      _buildSummaryCard(
        title: 'إجمالي الديون', // TODO: l10n
        value: '${totalDebt.toStringAsFixed(0)} ${l10n.sar}',
        icon: Icons.account_balance_rounded,
        color: AppColors.warning,
        isDark: isDark,
      ),
      _buildSummaryCard(
        title: 'الفوائد المتوقعة', // TODO: l10n
        value: '${totalInterest.toStringAsFixed(2)} ${l10n.sar}',
        icon: Icons.trending_up_rounded,
        color: AppColors.success,
        isDark: isDark,
      ),
    ];

    final spacing = isMediumScreen ? 16.0 : 12.0;

    if (isWideScreen) {
      return Row(
        children: cards.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: entry.key < cards.length - 1 ? spacing : 0),
              child: entry.value,
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        Row(children: [Expanded(child: cards[0]), SizedBox(width: spacing), Expanded(child: cards[1])]),
        SizedBox(height: spacing),
        cards[2],
      ],
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required IconData icon, required Color color, required bool isDark}) {
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCustomersList(bool isDark, AppLocalizations l10n) {
    if (_customers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              Text(
                'لا توجد ديون تحتاج إقفال', // TODO: l10n
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'جميع العملاء ضمن فترة السماح أو تم إقفالهم مسبقاً', // TODO: l10n
                style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

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
                  l10n.debtors,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                ),
                const Spacer(),
                Text(
                  '${_customers.length}',
                  style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _customers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final customer = _customers[index];
              return CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                value: customer.isSelected,
                onChanged: (v) => setState(() => _customers[index] = customer.copyWith(isSelected: v!)),
                title: Text(customer.account.name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الدين: ${customer.account.balance.toStringAsFixed(2)} ${l10n.sar}',
                      style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary, fontSize: 12),
                    ),
                    Text(
                      'الفائدة المتوقعة: ${customer.expectedInterest.toStringAsFixed(2)} ${l10n.sar}',
                      style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                secondary: CircleAvatar(
                  backgroundColor: AppColors.info.withValues(alpha: 0.15),
                  child: Text(
                    customer.account.name.isNotEmpty ? customer.account.name[0] : '?',
                    style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.bold),
                  ),
                ),
                isThreeLine: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark, AppLocalizations l10n) {
    final selectedCount = _customers.where((c) => c.isSelected).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$selectedCount عميل مختار', // TODO: l10n
              style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
            ),
          ),
          FilledButton.icon(
            onPressed: selectedCount > 0 && !_isProcessing ? _showConfirmationDialog : null,
            icon: _isProcessing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_rounded),
            label: Text(_isProcessing ? 'جاري المعالجة...' : 'تنفيذ الإقفال'), // TODO: l10n
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    final l10n = AppLocalizations.of(context)!;
    final selectedCustomers = _customers.where((c) => c.isSelected).toList();
    final totalInterest = selectedCustomers.fold<double>(0, (sum, c) => sum + c.expectedInterest);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سيتم إضافة فوائد على ${selectedCustomers.length} عميل'), // TODO: l10n
            const SizedBox(height: 8),
            Text(
              'إجمالي الفوائد: ${totalInterest.toStringAsFixed(2)} ${l10n.sar}', // TODO: l10n
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: AppColors.warning),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('هذه العملية لا يمكن التراجع عنها', style: TextStyle(fontSize: 13))), // TODO: l10n
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _processMonthlyClose();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _processMonthlyClose() async {
    setState(() => _isProcessing = true);

    try {
      final selectedCustomers = _customers.where((c) => c.isSelected).toList();

      for (final customer in selectedCustomers) {
        final newBalance = customer.account.balance + customer.expectedInterest;

        await _db.transactionsDao.recordInterest(
          id: 'INT-${DateTime.now().millisecondsSinceEpoch}-${customer.account.id}',
          storeId: customer.account.storeId,
          accountId: customer.account.id,
          amount: customer.expectedInterest,
          balanceAfter: newBalance,
          periodKey: _currentPeriod,
        );

        await _db.accountsDao.addToBalance(customer.account.id, customer.expectedInterest);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_month_close', _currentPeriod);

      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إقفال الشهر لـ ${selectedCustomers.length} عميل'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadData();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _CustomerDebt {
  final AccountsTableData account;
  final double expectedInterest;
  final bool isSelected;

  _CustomerDebt({required this.account, required this.expectedInterest, required this.isSelected});

  _CustomerDebt copyWith({bool? isSelected}) {
    return _CustomerDebt(account: account, expectedInterest: expectedInterest, isSelected: isSelected ?? this.isSelected);
  }
}
