import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إدارة المصروفات
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'expenses';

  final List<_Expense> _expenses = [
    _Expense(id: '1', title: 'إيجار المحل', amount: 5000, category: 'rent', date: DateTime.now().subtract(const Duration(days: 1))),
    _Expense(id: '2', title: 'فاتورة الكهرباء', amount: 850, category: 'utilities', date: DateTime.now().subtract(const Duration(days: 3))),
    _Expense(id: '3', title: 'رواتب الموظفين', amount: 12000, category: 'salaries', date: DateTime.now().subtract(const Duration(days: 5))),
    _Expense(id: '4', title: 'صيانة أجهزة', amount: 500, category: 'maintenance', date: DateTime.now().subtract(const Duration(days: 7))),
  ];

  double get _totalExpenses => _expenses.fold(0, (sum, e) => sum + e.amount);

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard':
        context.go(AppRoutes.dashboard);
        break;
      case 'pos':
        context.go(AppRoutes.pos);
        break;
      case 'products':
        context.push(AppRoutes.products);
        break;
      case 'categories':
        context.push(AppRoutes.categories);
        break;
      case 'inventory':
        context.push(AppRoutes.inventory);
        break;
      case 'customers':
        context.push(AppRoutes.customers);
        break;
      case 'invoices':
        context.push(AppRoutes.invoices);
        break;
      case 'orders':
        context.push(AppRoutes.orders);
        break;
      case 'sales':
        context.push(AppRoutes.invoices);
        break;
      case 'returns':
        context.push(AppRoutes.returns);
        break;
      case 'reports':
        context.push(AppRoutes.reports);
        break;
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: Text(l10n.add), // TODO: l10n.addExpense
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
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
                  title: 'المصروفات', // TODO: l10n.expenses
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

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat cards
        _buildStatsSection(isWideScreen, isMediumScreen, isDark),
        SizedBox(height: isMediumScreen ? 24 : 16),

        // Categories row
        _buildCategoriesRow(isDark, isMediumScreen),
        SizedBox(height: isMediumScreen ? 24 : 16),

        // Expenses list
        _buildExpensesList(isDark, l10n),
      ],
    );
  }

  Widget _buildStatsSection(bool isWideScreen, bool isMediumScreen, bool isDark) {
    final thisMonth = _totalExpenses;
    final categoriesCount = {'rent', 'utilities', 'salaries', 'maintenance'}.length;
    final avgExpense = _expenses.isNotEmpty ? thisMonth / _expenses.length : 0.0;

    final cards = [
      _buildStatCard(
        title: 'إجمالي المصروفات', // TODO: l10n.totalExpenses
        value: '${thisMonth.toStringAsFixed(0)}',
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.error,
        isDark: isDark,
      ),
      _buildStatCard(
        title: 'هذا الشهر', // TODO: l10n.thisMonth
        value: '${_expenses.length}',
        icon: Icons.receipt_long_rounded,
        color: AppColors.warning,
        isDark: isDark,
      ),
      _buildStatCard(
        title: 'التصنيفات', // TODO: l10n.categories
        value: '$categoriesCount',
        icon: Icons.category_rounded,
        color: AppColors.info,
        isDark: isDark,
      ),
      _buildStatCard(
        title: 'متوسط المصروف', // TODO: l10n.averageExpense
        value: '${avgExpense.toStringAsFixed(0)}',
        icon: Icons.trending_down_rounded,
        color: AppColors.primary,
        isDark: isDark,
      ),
    ];

    final spacing = isMediumScreen ? 16.0 : 12.0;

    if (isWideScreen) {
      return Row(
        children: cards.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: entry.key < cards.length - 1 ? spacing : 0,
              ),
              child: entry.value,
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            SizedBox(width: spacing),
            Expanded(child: cards[1]),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(child: cards[2]),
            SizedBox(width: spacing),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow(bool isDark, bool isMediumScreen) {
    final categories = [
      _CategorySummary(icon: Icons.home_rounded, label: 'إيجار', amount: 5000, color: AppColors.info),
      _CategorySummary(icon: Icons.bolt_rounded, label: 'كهرباء', amount: 850, color: AppColors.warning),
      _CategorySummary(icon: Icons.people_rounded, label: 'رواتب', amount: 12000, color: AppColors.primary),
      _CategorySummary(icon: Icons.build_rounded, label: 'صيانة', amount: 500, color: AppColors.secondary),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            width: isMediumScreen ? 120 : 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cat.color.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.icon, color: cat.color, size: 24),
                const SizedBox(height: 4),
                Text(
                  cat.label,
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${cat.amount.toInt()}',
                  style: TextStyle(
                    color: cat.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpensesList(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'قائمة المصروفات', // TODO: l10n.expensesList
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list_rounded, size: 18),
                  label: Text(l10n.filter),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _expenses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final expense = _expenses[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: _getCategoryColor(expense.category),
                    size: 22,
                  ),
                ),
                title: Text(
                  expense.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  _formatDate(expense.date),
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  '-${expense.amount.toStringAsFixed(0)} ${l10n.sar}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                ),
                onTap: () => _showExpenseDetails(expense),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'rent':
        return AppColors.info;
      case 'utilities':
        return AppColors.warning;
      case 'salaries':
        return AppColors.primary;
      case 'maintenance':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'rent':
        return Icons.home_rounded;
      case 'utilities':
        return Icons.bolt_rounded;
      case 'salaries':
        return Icons.people_rounded;
      case 'maintenance':
        return Icons.build_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr • ${l10n.mainBranch}';
  }

  void _addExpense() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'utilities';
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.add), // TODO: l10n.addExpense
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: l10n.sar,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: l10n.categoryLabel,
                  prefixIcon: const Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'rent', child: Text('إيجار')),
                  DropdownMenuItem(value: 'utilities', child: Text('خدمات')),
                  DropdownMenuItem(value: 'salaries', child: Text('رواتب')),
                  DropdownMenuItem(value: 'maintenance', child: Text('صيانة')),
                  DropdownMenuItem(value: 'other', child: Text('أخرى')),
                ],
                onChanged: (v) => setDialogState(() => category = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  setState(() {
                    _expenses.insert(
                      0,
                      _Expense(
                        id: 'new_${_expenses.length}',
                        title: titleController.text,
                        amount: double.tryParse(amountController.text) ?? 0,
                        category: category,
                        date: DateTime.now(),
                      ),
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('فلترة المصروفات')),
    );
  }

  void _showExpenseDetails(_Expense expense) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: l10n.amount,
              value: '${expense.amount.toStringAsFixed(0)} ${l10n.sar}',
              isDark: isDark,
            ),
            _DetailRow(
              label: l10n.date,
              value: _formatDate(expense.date),
              isDark: isDark,
            ),
            _DetailRow(
              label: l10n.categoryLabel,
              value: expense.category,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.edit),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _expenses.remove(expense));
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                    icon: const Icon(Icons.delete),
                    label: Text(l10n.delete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  _Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });
}

class _CategorySummary {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _CategorySummary({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
