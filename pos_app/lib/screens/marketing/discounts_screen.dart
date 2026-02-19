import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../providers/marketing_providers.dart';
import '../../widgets/common/app_empty_state.dart';

/// Discounts Screen - شاشة الخصومات
class DiscountsScreen extends ConsumerWidget {
  const DiscountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final discountsAsync = ref.watch(discountsListProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.discountsTitle,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.cashCustomer,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: discountsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AppErrorState.general(
              message: error.toString(),
              onRetry: () => ref.invalidate(discountsListProvider),
            ),
            data: (discounts) => SingleChildScrollView(
              padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
              child: _DiscountsContent(
                discounts: discounts,
                isWideScreen: isWideScreen,
                isMediumScreen: isMediumScreen,
                isDark: isDark,
                l10n: l10n,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiscountsContent extends ConsumerWidget {
  final List<DiscountsTableData> discounts;
  final bool isWideScreen;
  final bool isMediumScreen;
  final bool isDark;
  final AppLocalizations l10n;

  const _DiscountsContent({
    required this.discounts,
    required this.isWideScreen,
    required this.isMediumScreen,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = discounts.where((d) => d.isActive).length;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with title and add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.manageDiscounts,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            FilledButton.icon(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newDiscount),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats cards
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.local_offer, l10n.totalLabel, '${discounts.length}', AppColors.info, isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.check_circle, l10n.active, '$active', AppColors.success, isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.pause_circle, l10n.stopped, '${discounts.length - active}', AppColors.textSecondary, isDark)),
          ],
        ),
        const SizedBox(height: 20),

        // Discounts list
        if (discounts.isEmpty)
          AppEmptyState.noOffers()
        else
        ...discounts.map((discount) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: !discount.isActive ? (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.grey.shade100) : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (discount.isActive ? AppColors.success : AppColors.textSecondary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.local_offer, color: discount.isActive ? AppColors.success : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(discount.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                          Text(
                            discount.type == 'percentage' ? l10n.discountOff('${discount.value.toInt()}') : l10n.sarDiscountOff(discount.value.toStringAsFixed(0)),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: discount.isActive,
                      onChanged: (v) => _toggleActive(ref, discount, v),
                      activeThumbColor: AppColors.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      onPressed: () => _deleteDiscount(ref, discount),
                    ),
                  ],
                ),
                Divider(height: 24, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                Row(
                  children: [
                    Icon(Icons.category, size: 14, color: subtextColor),
                    const SizedBox(width: 4),
                    Text(discount.appliesTo == 'all' ? l10n.allProducts : l10n.specificCategory, style: TextStyle(fontSize: 12, color: subtextColor)),
                    const Spacer(),
                    Icon(Icons.calendar_today, size: 14, color: subtextColor),
                    const SizedBox(width: 4),
                    Text('${_formatDate(discount.startDate)} - ${_formatDate(discount.endDate)}', style: TextStyle(fontSize: 11, color: subtextColor)),

                  ],
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20)),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textSecondary)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) => d != null ? '${d.day}/${d.month}' : '-';

  /// تبديل حالة النشاط مع مزامنة
  Future<void> _toggleActive(WidgetRef ref, DiscountsTableData discount, bool value) async {
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

  /// حذف خصم مع مزامنة
  Future<void> _deleteDiscount(WidgetRef ref, DiscountsTableData discount) async {
    try {
      await deleteDiscount(ref, discount.id);
    } catch (e) {
      debugPrint('Error deleting discount: $e');
    }
  }

  /// عرض نافذة إضافة خصم جديد
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
                TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.discountName, prefixIcon: const Icon(Icons.local_offer))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(l10n.percentageLabel),
                        leading: Icon(type == 'percentage' ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.primary),
                        onTap: () => setDialogState(() => type = 'percentage'),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(l10n.fixedAmount),
                        leading: Icon(type == 'fixed' ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.primary),
                        onTap: () => setDialogState(() => type = 'fixed'),
                      ),
                    ),
                  ],
                ),
                TextField(controller: valueController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: type == 'percentage' ? l10n.thePercentage : l10n.theAmount, prefixIcon: Icon(type == 'percentage' ? Icons.percent : Icons.attach_money))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                  try {
                    await addDiscount(
                      ref,
                      name: nameController.text,
                      type: type,
                      value: double.tryParse(valueController.text) ?? 0,
                    );
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
