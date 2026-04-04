import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../providers/marketing_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Discounts Screen - شاشة الخصومات
class DiscountsScreen extends ConsumerStatefulWidget {
  const DiscountsScreen({super.key});

  @override
  ConsumerState<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends ConsumerState<DiscountsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DiscountsTableData> _filterDiscounts(
      List<DiscountsTableData> discounts) {
    if (_searchQuery.isEmpty) return discounts;
    final query = _searchQuery.toLowerCase();
    return discounts.where((d) {
      return d.name.toLowerCase().contains(query) ||
          (d.nameEn?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final discountsAsync = ref.watch(discountsListProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.discountsTitle,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.cashCustomer,
          userRole: l10n.branchManager,
        ),
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value.trim()),
            decoration: InputDecoration(
              hintText: l10n.search,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: l10n.clearSearch,
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.border.withValues(alpha: 0.15),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
        Expanded(
          child: discountsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AppErrorState.general(
              context,
              message: error.toString(),
              onRetry: () => ref.invalidate(discountsListProvider),
            ),
            data: (discounts) {
              final filtered = _filterDiscounts(discounts);
              return SingleChildScrollView(
                padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                child: _DiscountsContent(
                  discounts: discounts,
                  filteredDiscounts: filtered,
                  isWideScreen: isWideScreen,
                  isMediumScreen: isMediumScreen,
                  isDark: isDark,
                  l10n: l10n,
                  searchActive: _searchQuery.isNotEmpty,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DiscountsContent extends ConsumerWidget {
  final List<DiscountsTableData> discounts;
  final List<DiscountsTableData> filteredDiscounts;
  final bool isWideScreen;
  final bool isMediumScreen;
  final bool isDark;
  final AppLocalizations l10n;
  final bool searchActive;

  const _DiscountsContent({
    required this.discounts,
    required this.filteredDiscounts,
    required this.isWideScreen,
    required this.isMediumScreen,
    required this.isDark,
    required this.l10n,
    this.searchActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = discounts.where((d) => d.isActive).length;
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.manageDiscounts,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            FilledButton.icon(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newDiscount),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.mdl),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(Icons.local_offer, l10n.totalLabel,
                    '${discounts.length}', AppColors.info, isDark, context)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(
                child: _buildStatCard(Icons.check_circle, l10n.active,
                    '$active', AppColors.success, isDark, context)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(
                child: _buildStatCard(
                    Icons.pause_circle,
                    l10n.stopped,
                    '${discounts.length - active}',
                    AppColors.textSecondary,
                    isDark,
                    context)),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.mdl),
        if (discounts.isEmpty)
          AppEmptyState.noOffers(context,
              onAdd: () => _showAddDialog(context, ref))
        else if (searchActive && filteredDiscounts.isEmpty)
          AppEmptyState.noSearchResults(context)
        else
          ...filteredDiscounts.map((discount) => Container(
                margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: !discount.isActive
                      ? Theme.of(context).colorScheme.surfaceContainerLowest
                      : cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (discount.isActive
                                      ? AppColors.success
                                      : AppColors.textSecondary)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.local_offer,
                                color: discount.isActive
                                    ? AppColors.success
                                    : AppColors.textSecondary),
                          ),
                          const SizedBox(width: AlhaiSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(discount.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColor)),
                                Text(
                                  discount.type == 'percentage'
                                      ? l10n.discountOff(
                                          '${discount.value.toInt()}')
                                      : l10n.sarDiscountOff(
                                          discount.value.toStringAsFixed(0)),
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: discount.isActive,
                            onChanged: (v) {
                              if (!v) {
                                showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(l10n.confirm),
                                    content: Text(
                                        '${l10n.deactivate} "${discount.name}"?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(l10n.cancel)),
                                      FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: Text(l10n.confirm)),
                                    ],
                                  ),
                                ).then((confirmed) {
                                  if (confirmed == true)
                                    _toggleActive(ref, discount, v);
                                });
                              } else {
                                _toggleActive(ref, discount, v);
                              }
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error, size: 20),
                            onPressed: () => _deleteDiscount(ref, discount),
                          ),
                        ],
                      ),
                      Divider(
                          height: 24, color: Theme.of(context).dividerColor),
                      Row(
                        children: [
                          Icon(Icons.category, size: 14, color: subtextColor),
                          const SizedBox(width: AlhaiSpacing.xxs),
                          Text(
                              discount.appliesTo == 'all'
                                  ? l10n.allProducts
                                  : l10n.specificCategory,
                              style:
                                  TextStyle(fontSize: 12, color: subtextColor)),
                          const Spacer(),
                          Icon(Icons.calendar_today,
                              size: 14, color: subtextColor),
                          const SizedBox(width: AlhaiSpacing.xxs),
                          Text(
                              '${_formatDate(discount.startDate)} - ${_formatDate(discount.endDate)}',
                              style:
                                  TextStyle(fontSize: 11, color: subtextColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color,
      bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 20)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) => d != null ? '${d.day}/${d.month}' : '-';

  Future<void> _toggleActive(
      WidgetRef ref, DiscountsTableData discount, bool value) async {
    try {
      final updated = DiscountsTableData(
        id: discount.id,
        storeId: discount.storeId,
        orgId: discount.orgId,
        name: discount.name,
        nameEn: discount.nameEn,
        type: discount.type,
        value: discount.value,
        minPurchase: discount.minPurchase,
        maxDiscount: discount.maxDiscount,
        appliesTo: discount.appliesTo,
        productIds: discount.productIds,
        categoryIds: discount.categoryIds,
        startDate: discount.startDate,
        endDate: discount.endDate,
        isActive: value,
        createdAt: discount.createdAt,
        updatedAt: DateTime.now(),
        syncedAt: discount.syncedAt,
      );
      await updateDiscount(ref, updated);
    } catch (e) {
      debugPrint('Error toggling discount: $e');
    }
  }

  Future<void> _deleteDiscount(
      WidgetRef ref, DiscountsTableData discount) async {
    try {
      await deleteDiscount(ref, discount.id);
    } catch (e) {
      debugPrint('Error deleting discount: $e');
    }
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    String type = 'percentage';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.newDiscount),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: l10n.discountName,
                        prefixIcon: const Icon(Icons.local_offer))),
                const SizedBox(height: AlhaiSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(l10n.percentageLabel),
                        leading: Icon(
                            type == 'percentage'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: AppColors.primary),
                        onTap: () => setDialogState(() => type = 'percentage'),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(l10n.fixedAmount),
                        leading: Icon(
                            type == 'fixed'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: AppColors.primary),
                        onTap: () => setDialogState(() => type = 'fixed'),
                      ),
                    ),
                  ],
                ),
                TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: type == 'percentage'
                            ? l10n.thePercentage
                            : l10n.theAmount,
                        prefixIcon: Icon(type == 'percentage'
                            ? Icons.percent
                            : Icons.attach_money))),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    valueController.text.isNotEmpty) {
                  try {
                    await addDiscount(ref,
                        name: nameController.text,
                        type: type,
                        value: double.tryParse(valueController.text) ?? 0);
                  } catch (e) {
                    debugPrint('Error adding discount: $e');
                  }
                }
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    ).then((_) {
      nameController.dispose();
      valueController.dispose();
    });
  }
}
