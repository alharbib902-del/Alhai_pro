import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/validators/input_sanitizer.dart';
import '../../providers/expenses_providers.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/layout/app_header.dart';
import '../../widgets/common/shimmer_loading.dart';

/// شاشة إدارة المصروفات
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addExpense(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addExpense),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          AppHeader(
            title: l10n.expenses,
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
            child: ref
                .watch(expensesStreamProvider)
                .when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AlhaiSpacing.md),
                    child: ShimmerList(itemCount: 6, itemHeight: 72),
                  ),
                  error: (e, _) => AppErrorState.general(
                    context,
                    message: e.toString(),
                    onRetry: () => ref.invalidate(expensesStreamProvider),
                  ),
                  data: (expenses) => RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(expensesStreamProvider),
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(
                        isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                      ),
                      child: _buildContent(
                        context,
                        ref,
                        isWideScreen,
                        isMediumScreen,
                        isDark,
                        l10n,
                        expenses,
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
    List<ExpensesTableData> expenses,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat cards
        _buildStatsSection(
          context,
          isWideScreen,
          isMediumScreen,
          isDark,
          l10n,
          expenses,
        ),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),

        // Categories row - تحميل التصنيفات من قاعدة البيانات
        _buildCategoriesRow(isDark, isMediumScreen, l10n, ref, expenses),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),

        // Expenses list
        _buildExpensesList(context, isDark, l10n, expenses),
      ],
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
    List<ExpensesTableData> expenses,
  ) {
    final thisMonth = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final categoriesCount = expenses.map((e) => e.categoryId).toSet().length;
    final avgExpense = expenses.isNotEmpty ? thisMonth / expenses.length : 0.0;

    final cards = [
      _buildStatCard(
        context: context,
        title: l10n.totalExpenses,
        value: thisMonth.toStringAsFixed(0),
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.error,
        isDark: isDark,
      ),
      _buildStatCard(
        context: context,
        title: l10n.thisMonth,
        value: '${expenses.length}',
        icon: Icons.receipt_long_rounded,
        color: AppColors.warning,
        isDark: isDark,
      ),
      _buildStatCard(
        context: context,
        title: l10n.categories,
        value: '$categoriesCount',
        icon: Icons.category_rounded,
        color: AppColors.info,
        isDark: isDark,
      ),
      _buildStatCard(
        context: context,
        title: l10n.averageExpense,
        value: avgExpense.toStringAsFixed(0),
        icon: Icons.trending_down_rounded,
        color: AppColors.primary,
        isDark: isDark,
      ),
    ];

    final spacing = isMediumScreen ? AlhaiSpacing.md : AlhaiSpacing.sm;

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
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
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
          SizedBox(height: AlhaiSpacing.md),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AlhaiSpacing.xxs),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow(
    bool isDark,
    bool isMediumScreen,
    AppLocalizations l10n,
    WidgetRef ref,
    List<ExpensesTableData> expenses,
  ) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: ShimmerList(itemCount: 1, itemHeight: 80),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (dbCategories) {
        // حساب المبالغ لكل تصنيف من المصروفات الفعلية
        final categoryTotals = <String, double>{};
        for (final expense in expenses) {
          final catId = expense.categoryId ?? 'other';
          categoryTotals[catId] = (categoryTotals[catId] ?? 0) + expense.amount;
        }

        // بناء قائمة التصنيفات من قاعدة البيانات
        final categories = dbCategories.map((cat) {
          return _CategorySummary(
            icon: _getCategoryIcon(cat.id),
            label: cat.name,
            amount: categoryTotals[cat.id] ?? 0,
            color: _parseCategoryColor(cat.color),
          );
        }).toList();

        // إذا لم توجد تصنيفات في قاعدة البيانات، نعرض تصنيفات افتراضية فارغة
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => SizedBox(width: AlhaiSpacing.sm),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                width: isMediumScreen ? 120 : 100,
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cat.color.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat.icon, color: cat.color, size: 24),
                    SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      cat.label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  /// تحويل لون التصنيف من نص إلى Color
  Color _parseCategoryColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return AppColors.textSecondary;
    try {
      // دعم الألوان بصيغة hex مثل "#FF5722" أو "FF5722"
      final hex = colorStr.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return AppColors.textSecondary;
  }

  Widget _buildExpensesList(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n, [
    List<ExpensesTableData>? expensesData,
  ]) {
    final expenses = expensesData ?? [];
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            child: Row(
              children: [
                Text(
                  l10n.expensesList,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showFilterDialog(context),
                  icon: const Icon(Icons.filter_list_rounded, size: 18),
                  label: Text(l10n.filter),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.xxl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    SizedBox(height: AlhaiSpacing.sm),
                    Text(
                      l10n.noExpenses,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final category = expense.categoryId ?? 'other';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.mdl,
                    vertical: AlhaiSpacing.xs,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: _getCategoryColor(category),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    expense.description ?? l10n.expense,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    _formatDate(expense.expenseDate),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  void _addExpense(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'utilities';
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addExpense),
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
              SizedBox(height: AlhaiSpacing.sm),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: l10n.sar,
                ),
              ),
              SizedBox(height: AlhaiSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                  labelText: l10n.categoryLabel,
                  prefixIcon: const Icon(Icons.category),
                ),
                items: [
                  DropdownMenuItem(value: 'rent', child: Text(l10n.rent)),
                  DropdownMenuItem(
                    value: 'utilities',
                    child: Text(l10n.services),
                  ),
                  DropdownMenuItem(
                    value: 'salaries',
                    child: Text(l10n.salaries),
                  ),
                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text(l10n.maintenance),
                  ),
                  DropdownMenuItem(value: 'other', child: Text(l10n.other)),
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
                if (titleController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  // Security: Check for dangerous content in description
                  if (InputSanitizer.containsDangerousContent(
                    titleController.text,
                  )) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.inputContainsDangerousContent),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                    return;
                  }
                  addExpense(
                    ref,
                    categoryId: category,
                    amount: double.tryParse(amountController.text) ?? 0,
                    description: InputSanitizer.sanitize(titleController.text),
                  );
                }
                Navigator.pop(context);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    ).then((_) {
      titleController.dispose();
      amountController.dispose();
    });
  }

  void _showFilterDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.filterExpenses)));
  }
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
