/// شاشة فئات المصروفات - Expense Categories Screen
///
/// شاشة لإدارة فئات المصروفات
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة فئات المصروفات
class ExpenseCategoriesScreen extends ConsumerStatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  ConsumerState<ExpenseCategoriesScreen> createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState
    extends ConsumerState<ExpenseCategoriesScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'expenses';

  // بيانات تجريبية
  final List<ExpenseCategory> _categories = [
    ExpenseCategory(id: '1', name: 'رواتب الموظفين', icon: Icons.people, color: AppColors.primary, budget: 50000.0, spent: 45000.0, expensesCount: 12, isActive: true),
    ExpenseCategory(id: '2', name: 'إيجار المحل', icon: Icons.store, color: AppColors.warning, budget: 15000.0, spent: 15000.0, expensesCount: 1, isActive: true),
    ExpenseCategory(id: '3', name: 'فواتير الكهرباء', icon: Icons.bolt, color: Colors.amber, budget: 3000.0, spent: 2800.0, expensesCount: 1, isActive: true),
    ExpenseCategory(id: '4', name: 'صيانة وإصلاحات', icon: Icons.build, color: Colors.orange, budget: 5000.0, spent: 3200.0, expensesCount: 5, isActive: true),
    ExpenseCategory(id: '5', name: 'مستلزمات المكتب', icon: Icons.inventory_2, color: AppColors.info, budget: 2000.0, spent: 1500.0, expensesCount: 8, isActive: true),
    ExpenseCategory(id: '6', name: 'تسويق وإعلانات', icon: Icons.campaign, color: Colors.purple, budget: 10000.0, spent: 7500.0, expensesCount: 4, isActive: true),
    ExpenseCategory(id: '7', name: 'نقل ومواصلات', icon: Icons.local_shipping, color: Colors.teal, budget: 4000.0, spent: 2800.0, expensesCount: 15, isActive: true),
    ExpenseCategory(id: '8', name: 'أخرى', icon: Icons.more_horiz, color: AppColors.grey500, budget: 5000.0, spent: 1200.0, expensesCount: 6, isActive: true),
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

    final totalBudget = _categories.fold(0.0, (sum, c) => sum + c.budget);
    final totalSpent = _categories.fold(0.0, (sum, c) => sum + c.spent);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add),
        label: Text(l10n.addCategory),
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
                  title: 'فئات المصروفات', // TODO: l10n.expenseCategories
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
                    child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n, totalBudget, totalSpent),
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

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n, double totalBudget, double totalSpent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Budget summary card
        _buildBudgetSummary(totalBudget, totalSpent, isDark),
        SizedBox(height: isMediumScreen ? 24 : 16),

        // Categories grid/list
        if (isWideScreen)
          _buildCategoriesGrid(isDark, l10n)
        else
          _buildCategoriesList(isDark, l10n),
      ],
    );
  }

  Widget _buildBudgetSummary(double totalBudget, double totalSpent, bool isDark) {
    final percentage = totalBudget > 0 ? totalSpent / totalBudget * 100 : 0.0;
    final remaining = totalBudget - totalSpent;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الميزانية الشهرية', // TODO: l10n.monthlyBudget
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalBudget.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(percentage > 90 ? AppColors.error : Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat('المصروف', '${totalSpent.toStringAsFixed(0)} ر.س', Icons.arrow_upward),
              Container(height: 40, width: 1, color: Colors.white24),
              _buildSummaryStat('المتبقي', '${remaining.toStringAsFixed(0)} ر.س', Icons.account_balance_wallet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(bool isDark, AppLocalizations l10n) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _categories.map((cat) => SizedBox(
        width: 340,
        child: _buildCategoryCard(cat, isDark, l10n),
      )).toList(),
    );
  }

  Widget _buildCategoriesList(bool isDark, AppLocalizations l10n) {
    return Column(
      children: _categories.map((cat) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildCategoryCard(cat, isDark, l10n),
      )).toList(),
    );
  }

  Widget _buildCategoryCard(ExpenseCategory category, bool isDark, AppLocalizations l10n) {
    final percentage = category.budget > 0 ? category.spent / category.budget * 100 : 0.0;
    final isOverBudget = percentage > 100;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: () => _showCategoryDetails(category),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category.icon, color: category.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isOverBudget)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning, size: 12, color: AppColors.error),
                                  SizedBox(width: 2),
                                  Text('تجاوز', style: TextStyle(color: AppColors.error, fontSize: 10)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.expensesCount} مصروف',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
                  onSelected: (value) => _handleCategoryAction(value, category),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: ListTile(leading: const Icon(Icons.edit), title: Text(l10n.edit), contentPadding: EdgeInsets.zero, dense: true)),
                    PopupMenuItem(value: 'view', child: ListTile(leading: const Icon(Icons.visibility), title: Text(l10n.viewDetails), contentPadding: EdgeInsets.zero, dense: true)),
                    PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete, color: AppColors.error), title: Text(l10n.delete, style: const TextStyle(color: AppColors.error)), contentPadding: EdgeInsets.zero, dense: true)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.grey200,
                      valueColor: AlwaysStoppedAnimation(isOverBudget ? AppColors.error : category.color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: isOverBudget ? AppColors.error : category.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المصروف: ${category.spent.toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    color: isOverBudget ? AppColors.error : (isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'المتبقي: ${(category.budget - category.spent).toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    color: isOverBudget ? AppColors.error : AppColors.success,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDetails(ExpenseCategory category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: category.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(category.icon, color: category.color, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                        Text('${category.expensesCount} مصروف هذا الشهر', style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _buildDetailStat('الميزانية', '${category.budget.toStringAsFixed(0)} ر.س', AppColors.info, isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDetailStat('المصروف', '${category.spent.toStringAsFixed(0)} ر.س', AppColors.warning, isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDetailStat('المتبقي', '${(category.budget - category.spent).toStringAsFixed(0)} ر.س', AppColors.success, isDark)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('آخر المصروفات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: Text(AppLocalizations.of(context)!.viewAll)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category.color.withValues(alpha: 0.1),
                      child: Icon(Icons.receipt, color: category.color, size: 20),
                    ),
                    title: Text('مصروف #${1000 + index}', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
                    subtitle: Text(
                      '${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary),
                    ),
                    trailing: Text(
                      '${(category.spent / 5).toStringAsFixed(0)} ر.س',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(
        onSave: (name, icon, color, budget) {
          setState(() {
            _categories.add(ExpenseCategory(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              icon: icon,
              color: color,
              budget: budget,
              spent: 0,
              expensesCount: 0,
              isActive: true,
            ));
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.categorySavedSuccess}: $name'), backgroundColor: AppColors.success),
          );
        },
      ),
    );
  }

  void _handleCategoryAction(String action, ExpenseCategory category) {
    switch (action) {
      case 'edit': _editCategory(category); break;
      case 'view': _showCategoryDetails(category); break;
      case 'delete': _deleteCategory(category); break;
    }
  }

  void _editCategory(ExpenseCategory category) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(
        category: category,
        onSave: (name, icon, color, budget) {
          setState(() {
            final index = _categories.indexWhere((c) => c.id == category.id);
            if (index != -1) {
              _categories[index] = ExpenseCategory(
                id: category.id, name: name, icon: icon, color: color,
                budget: budget, spent: category.spent, expensesCount: category.expensesCount, isActive: category.isActive,
              );
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.categorySavedSuccess}: $name'), backgroundColor: AppColors.success),
          );
        },
      ),
    );
  }

  void _deleteCategory(ExpenseCategory category) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _categories.removeWhere((c) => c.id == category.id));
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.categoryDeletedSuccess), backgroundColor: AppColors.error),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

/// نافذة إضافة/تعديل فئة
class _CategoryFormDialog extends StatefulWidget {
  final ExpenseCategory? category;
  final Function(String name, IconData icon, Color color, double budget) onSave;

  const _CategoryFormDialog({this.category, required this.onSave});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = AppColors.primary;

  final List<IconData> _icons = [
    Icons.category, Icons.people, Icons.store, Icons.bolt, Icons.build, Icons.inventory_2,
    Icons.campaign, Icons.local_shipping, Icons.restaurant, Icons.phone, Icons.computer,
    Icons.cleaning_services, Icons.security, Icons.card_giftcard, Icons.medical_services, Icons.more_horiz,
  ];

  final List<Color> _colors = [
    AppColors.primary, AppColors.success, AppColors.warning, AppColors.error, AppColors.info,
    Colors.purple, Colors.teal, Colors.orange, Colors.pink, Colors.indigo, Colors.brown, AppColors.grey500,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _budgetController = TextEditingController(text: widget.category?.budget.toStringAsFixed(0) ?? '');
    _selectedIcon = widget.category?.icon ?? Icons.category;
    _selectedColor = widget.category?.color ?? AppColors.primary;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.category == null ? l10n.addCategory : l10n.editCategory),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: l10n.categoryName, hintText: 'مثال: رواتب الموظفين')),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: 'الميزانية الشهرية', hintText: '5000', suffixText: l10n.sar),
            ),
            const SizedBox(height: 16),
            Text(l10n.categoryIcon, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((icon) {
                final isSelected = icon == _selectedIcon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? _selectedColor : AppColors.grey300),
                    ),
                    child: Icon(icon, color: isSelected ? _selectedColor : AppColors.textMuted, size: 24),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(l10n.categoryColor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                final isSelected = color == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 3),
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave(_nameController.text, _selectedIcon, _selectedColor, double.tryParse(_budgetController.text) ?? 0);
              Navigator.pop(context);
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// نموذج فئة المصروفات
class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double budget;
  final double spent;
  final int expensesCount;
  final bool isActive;

  ExpenseCategory({
    required this.id, required this.name, required this.icon, required this.color,
    required this.budget, required this.spent, required this.expensesCount, required this.isActive,
  });
}
