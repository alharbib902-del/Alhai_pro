/// شاشة فئات المصروفات - Expense Categories Screen
///
/// شاشة لإدارة فئات المصروفات
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/expenses_providers.dart';
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

  // Map icon name to IconData
  static final _iconMap = <String, IconData>{
    'people': Icons.people,
    'store': Icons.store,
    'bolt': Icons.bolt,
    'build': Icons.build,
    'inventory_2': Icons.inventory_2,
    'campaign': Icons.campaign,
    'local_shipping': Icons.local_shipping,
    'more_horiz': Icons.more_horiz,
  };

  static final _colorMap = <String, Color>{
    'primary': AppColors.primary,
    'warning': AppColors.warning,
    'amber': Colors.amber,
    'orange': AlhaiColors.warning,
    'info': AppColors.info,
    'purple': Colors.purple,
    'teal': Colors.teal,
    'grey': AppColors.grey500,
  };

  ExpenseCategory _fromData(ExpenseCategoriesTableData data) {
    return ExpenseCategory(
      id: data.id,
      name: data.name,
      icon: _iconMap[data.icon] ?? Icons.category,
      color: _colorMap[data.color] ?? AppColors.primary,
      budget: 0,
      spent: 0,
      expensesCount: 0,
      isActive: data.isActive,
    );
  }
  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add),
        label: Text(l10n.addCategory),
        backgroundColor: AppColors.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
              children: [
                AppHeader(
                  title: l10n.expenseCategoriesTitle,
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
                ),
                Expanded(
                  child: ref.watch(allExpenseCategoriesProvider).when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text(l10n.errorPrefix(e))),
                    data: (categoriesData) {
                      final categories = categoriesData.map(_fromData).toList();
                      final totalBudget = categories.fold(0.0, (sum, c) => sum + c.budget);
                      final totalSpent = categories.fold(0.0, (sum, c) => sum + c.spent);
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                        child: _buildContent(categories, isWideScreen, isMediumScreen, isDark, l10n, totalBudget, totalSpent),
                      );
                    },
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

  Widget _buildContent(List<ExpenseCategory> categories, bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n, double totalBudget, double totalSpent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Budget summary card
        _buildBudgetSummary(totalBudget, totalSpent, isDark),
        SizedBox(height: isMediumScreen ? 24 : 16),

        // Categories grid/list
        if (categories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.category_rounded, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text(l10n.noCategoriesFound, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          )
        else if (isWideScreen)
          _buildCategoriesGrid(categories, isDark, l10n)
        else
          _buildCategoriesList(categories, isDark, l10n),
      ],
    );
  }

  Widget _buildBudgetSummary(double totalBudget, double totalSpent, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.monthlyBudget,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatCompact(totalBudget),
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
              _buildSummaryStat(l10n.spentAmount, CurrencyFormatter.formatCompact(totalSpent), Icons.arrow_upward),
              Container(height: 40, width: 1, color: Colors.white24),
              _buildSummaryStat(l10n.remainingAmount, CurrencyFormatter.formatCompact(remaining), Icons.account_balance_wallet),
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

  Widget _buildCategoriesGrid(List<ExpenseCategory> categories, bool isDark, AppLocalizations l10n) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: categories.map((cat) => SizedBox(
        width: 340,
        child: _buildCategoryCard(cat, isDark, l10n),
      )).toList(),
    );
  }

  Widget _buildCategoriesList(List<ExpenseCategory> categories, bool isDark, AppLocalizations l10n) {
    return Column(
      children: categories.map((cat) => Padding(
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        boxShadow: AppShadows.of(context, size: ShadowSize.md),
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
                                color: Theme.of(context).colorScheme.onSurface,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.warning, size: 12, color: AppColors.error),
                                  const SizedBox(width: 2),
                                  Text(l10n.overBudget, style: const TextStyle(color: AppColors.error, fontSize: 10)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.expenseCount(category.expensesCount),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  l10n.spentLabel(CurrencyFormatter.formatCompact(category.spent)),
                  style: TextStyle(
                    color: isOverBudget ? AppColors.error : (Theme.of(context).colorScheme.onSurfaceVariant),
                    fontSize: 12,
                  ),
                ),
                Text(
                  l10n.remainingLabel2(CurrencyFormatter.formatCompact(category.budget - category.spent)),
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
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: context.screenHeight * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                        Text(category.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        Text(l10n.expensesThisMonth(category.expensesCount), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
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
                  Expanded(child: _buildDetailStat(l10n.budgetLabel, CurrencyFormatter.formatCompact(category.budget), AppColors.info, isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDetailStat(l10n.spentAmount, CurrencyFormatter.formatCompact(category.spent), AppColors.warning, isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDetailStat(l10n.remainingAmount, CurrencyFormatter.formatCompact(category.budget - category.spent), AppColors.success, isDark)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(l10n.recentExpenses, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
                    title: Text(l10n.expenseNumber(1000 + index), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    subtitle: Text(
                      '${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    trailing: Text(
                      CurrencyFormatter.formatCompact(category.spent / 5),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
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
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => _CategoryFormDialog(
        onSave: (name, icon, color, budget) async {
          // Find the icon/color key for storage
          final iconKey = _iconMap.entries.firstWhere((e) => e.value == icon, orElse: () => const MapEntry('category', Icons.category)).key;
          final colorKey = _colorMap.entries.firstWhere((e) => e.value == color, orElse: () => const MapEntry('primary', AppColors.primary)).key;
          await addExpenseCategory(ref, name: name, icon: iconKey, color: colorKey);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l10n.categorySavedSuccess}: $name'), backgroundColor: AppColors.success),
            );
          }
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
      builder: (dialogContext) => _CategoryFormDialog(
        category: category,
        onSave: (name, icon, color, budget) {
          // TODO: implement update category when DAO supports it
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
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await deleteExpenseCategory(ref, category.id);
              HapticFeedback.mediumImpact();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.categoryDeletedSuccess), backgroundColor: AppColors.error),
                );
              }
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
    Colors.purple, Colors.teal, AlhaiColors.warning, Colors.pink, Colors.indigo, Colors.brown, AppColors.grey500,
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
            TextField(controller: _nameController, decoration: InputDecoration(labelText: l10n.categoryName, hintText: l10n.categoryNameHint)),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l10n.monthlyBudgetLabel, hintText: '5000', suffixText: l10n.sar),
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
                      border: Border.all(color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.transparent, width: 3),
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
