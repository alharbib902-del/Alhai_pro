import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../providers/marketing_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Special Offers Screen - شاشة العروض الخاصة
class SpecialOffersScreen extends ConsumerWidget {
  const SpecialOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final promotionsAsync = ref.watch(promotionsListProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.specialOffersTitle,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.cashCustomer,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: promotionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AppErrorState.general(
              context,
              message: error.toString(),
              onRetry: () => ref.invalidate(promotionsListProvider),
            ),
            data: (promotions) => SingleChildScrollView(
              padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
              child: _OffersContent(
                promotions: promotions,
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

class _OffersContent extends ConsumerWidget {
  final List<PromotionsTableData> promotions;
  final bool isWideScreen;
  final bool isMediumScreen;
  final bool isDark;
  final AppLocalizations l10n;

  const _OffersContent({
    required this.promotions,
    required this.isWideScreen,
    required this.isMediumScreen,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              l10n.manageSpecialOffers,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showAddPromotionDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newOffer),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.mdl),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                Icons.local_offer,
                l10n.totalLabel,
                '${promotions.length}',
                AppColors.info,
                isDark,
              ),
            ),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.check_circle,
                l10n.active,
                '${promotions.where((p) => p.isActive).length}',
                AppColors.success,
                isDark,
              ),
            ),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.timer,
                l10n.expiringSoon,
                '${promotions.where((p) => p.isActive && p.endDate.difference(DateTime.now()).inDays <= 7).length}',
                AppColors.secondary,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.mdl),
        if (promotions.isEmpty)
          AppEmptyState.noOffers(context)
        else
          ...promotions.map((promotion) {
            final isExpired = promotion.endDate.isBefore(DateTime.now());
            return Container(
              margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: isExpired
                    ? Theme.of(context).colorScheme.surfaceContainerLowest
                    : cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md,
                  vertical: AlhaiSpacing.xs,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: _getTypeColor(promotion.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(promotion.type),
                    color: _getTypeColor(promotion.type),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        promotion.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.offerExpired,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeLabel(promotion, l10n),
                      style: TextStyle(color: subtextColor, fontSize: 12),
                    ),
                    Text(
                      '${promotion.endDate.day}/${promotion.endDate.month}/${promotion.endDate.year}',
                      style: TextStyle(fontSize: 11, color: subtextColor),
                    ),
                  ],
                ),
                trailing: Switch(
                  value: promotion.isActive && !isExpired,
                  onChanged: isExpired
                      ? null
                      : (v) => _toggleActive(ref, promotion, v),
                  activeThumbColor: AppColors.primary,
                ),
                onTap: () => _showPromotionDetails(context, ref, promotion),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
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
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) =>
      {
        'bundle': const Color(0xFF8B5CF6),
        'buy_x_get_y': AppColors.info,
        'flash_sale': AppColors.success,
      }[type] ??
      AppColors.textSecondary;

  IconData _getTypeIcon(String type) =>
      {
        'bundle': Icons.inventory_2,
        'buy_x_get_y': Icons.card_giftcard,
        'flash_sale': Icons.flash_on,
      }[type] ??
      Icons.local_offer;

  String _getTypeLabel(PromotionsTableData p, AppLocalizations l10n) {
    switch (p.type) {
      case 'bundle':
        return l10n.bundleDiscount('0');
      case 'buy_x_get_y':
        return l10n.buyAndGetFree;
      case 'flash_sale':
        return l10n.offerDiscountPercent('0');
      default:
        return '';
    }
  }

  Future<void> _toggleActive(
    WidgetRef ref,
    PromotionsTableData promotion,
    bool value,
  ) async {
    try {
      final updated = PromotionsTableData(
        id: promotion.id,
        storeId: promotion.storeId,
        orgId: promotion.orgId,
        name: promotion.name,
        nameEn: promotion.nameEn,
        description: promotion.description,
        type: promotion.type,
        rules: promotion.rules,
        startDate: promotion.startDate,
        endDate: promotion.endDate,
        isActive: value,
        createdAt: promotion.createdAt,
        updatedAt: DateTime.now(),
        syncedAt: promotion.syncedAt,
      );
      await updatePromotion(ref, updated);
    } catch (e) {
      if (kDebugMode) debugPrint('Error toggling promotion: $e');
    }
  }

  Future<void> _deletePromotion(
    WidgetRef ref,
    PromotionsTableData promotion,
  ) async {
    try {
      await deletePromotion(ref, promotion.id);
    } catch (e) {
      if (kDebugMode) debugPrint('Error deleting promotion: $e');
    }
  }

  void _showAddPromotionDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String type = 'flash_sale';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.newOffer),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.offerName,
                    prefixIcon: const Icon(Icons.local_offer),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(
                    labelText: l10n.offerType,
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'flash_sale',
                      child: Text(l10n.percentageDiscount),
                    ),
                    DropdownMenuItem(
                      value: 'bundle',
                      child: Text(l10n.bundleLabel),
                    ),
                    DropdownMenuItem(
                      value: 'buy_x_get_y',
                      child: Text(l10n.buyAndGet),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await addPromotion(
                      ref,
                      name: nameController.text,
                      type: type,
                    );
                  } catch (e) {
                    if (kDebugMode) debugPrint('Error adding promotion: $e');
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
    );
  }

  void _showPromotionDetails(
    BuildContext context,
    WidgetRef ref,
    PromotionsTableData p,
  ) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTypeIcon(p.type),
                  size: 32,
                  color: _getTypeColor(p.type),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),
            _DetailRow(
              label: l10n.offerType,
              value: _getTypeLabel(p, l10n),
              isDark: isDarkTheme,
            ),
            _DetailRow(
              label: l10n.startDateLabel,
              value:
                  '${p.startDate.day}/${p.startDate.month}/${p.startDate.year}',
              isDark: isDarkTheme,
            ),
            _DetailRow(
              label: l10n.endDateLabel,
              value: '${p.endDate.day}/${p.endDate.month}/${p.endDate.year}',
              isDark: isDarkTheme,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deletePromotion(ref, p);
                    },
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    label: Text(
                      l10n.delete,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.edit),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
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

class _DetailRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _DetailRow({
    required this.label,
    required this.value,
    this.isDark = false,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ),
  );
}
