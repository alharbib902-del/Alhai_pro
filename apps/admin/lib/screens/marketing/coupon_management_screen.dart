import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../providers/marketing_providers.dart';

/// Coupon Management Screen - شاشة إدارة الكوبونات
class CouponManagementScreen extends ConsumerWidget {
  const CouponManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final couponsAsync = ref.watch(couponsListProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.manageCoupons,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.cashCustomer,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: couponsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AppErrorState.general(
              message: error.toString(),
              onRetry: () => ref.invalidate(couponsListProvider),
            ),
            data: (coupons) => SingleChildScrollView(
              padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
              child: _CouponsContent(
                coupons: coupons,
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

class _CouponsContent extends ConsumerWidget {
  final List<CouponsTableData> coupons;
  final bool isWideScreen;
  final bool isMediumScreen;
  final bool isDark;
  final AppLocalizations l10n;

  const _CouponsContent({
    required this.coupons, required this.isWideScreen,
    required this.isMediumScreen, required this.isDark, required this.l10n,
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
            Text(l10n.couponsTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            FilledButton.icon(
              onPressed: () => _showAddCouponDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newCoupon),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.confirmation_number, l10n.couponsTitle, '${coupons.length}', AppColors.info, isDark, context)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.check_circle, l10n.active, '${coupons.where((c) => c.isActive).length}', AppColors.success, isDark, context)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.analytics, l10n.usages, '${coupons.fold(0, (sum, c) => sum + c.currentUses)}', AppColors.secondary, isDark, context)),
          ],
        ),
        const SizedBox(height: 20),
        if (coupons.isEmpty)
          AppEmptyState.noOffers()
        else
        ...coupons.map((coupon) {
          final isExpired = coupon.expiresAt?.isBefore(DateTime.now()) ?? false;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: !coupon.isActive || isExpired ? Theme.of(context).colorScheme.surfaceContainerLowest : cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(coupon.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getTypeIcon(coupon.type), color: _getTypeColor(coupon.type)),
              ),
              title: Row(
                children: [
                  Text(coupon.code, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: textColor)),
                  const SizedBox(width: 8),
                  if (!coupon.isActive || isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(4)),
                      child: Text(isExpired ? l10n.expired : l10n.deactivated, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                ],
              ),
              subtitle: Text(
                '${_getTypeLabel(coupon, l10n)} - ${l10n.usageCount(coupon.currentUses, coupon.maxUses)}',
                style: TextStyle(color: subtextColor, fontSize: 12),
              ),
              trailing: Switch(
                value: coupon.isActive && !isExpired,
                onChanged: isExpired ? null : (v) => _toggleActive(ref, coupon, v),
                activeThumbColor: AppColors.primary,
              ),
              onTap: () => _showDetails(context, ref, coupon),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color, bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20)),
          Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  String _getTypeLabel(CouponsTableData c, AppLocalizations l10n) {
    switch (c.type) {
      case 'percentage': return l10n.percentageDiscountLabel(c.value.toInt());
      case 'fixed': return l10n.fixedDiscountLabel(c.value.toInt());
      case 'freeDelivery': return l10n.freeDelivery;
      default: return '';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'percentage': return AppColors.success;
      case 'fixed': return AppColors.info;
      case 'freeDelivery': return AppColors.secondary;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'percentage': return Icons.percent;
      case 'fixed': return Icons.attach_money;
      case 'freeDelivery': return Icons.local_shipping;
      default: return Icons.confirmation_number;
    }
  }

  Future<void> _toggleActive(WidgetRef ref, CouponsTableData coupon, bool value) async {
    try {
      final updated = CouponsTableData(
        id: coupon.id, storeId: coupon.storeId, orgId: coupon.orgId,
        code: coupon.code, discountId: coupon.discountId, type: coupon.type,
        value: coupon.value, maxUses: coupon.maxUses,
        currentUses: coupon.currentUses, minPurchase: coupon.minPurchase,
        isActive: value, expiresAt: coupon.expiresAt,
        createdAt: coupon.createdAt, syncedAt: coupon.syncedAt,
      );
      await updateCoupon(ref, updated);
    } catch (e) {
      debugPrint('Error toggling coupon: $e');
    }
  }

  Future<void> _deleteCoupon(WidgetRef ref, CouponsTableData coupon) async {
    try {
      await deleteCoupon(ref, coupon.id);
    } catch (e) {
      debugPrint('Error deleting coupon: $e');
    }
  }

  void _showAddCouponDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    String type = 'percentage';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.newCoupon),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(labelText: l10n.couponCode, prefixIcon: const Icon(Icons.confirmation_number)),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(labelText: l10n.couponTypeLabel, prefixIcon: const Icon(Icons.category)),
                  items: [
                    DropdownMenuItem(value: 'percentage', child: Text(l10n.percentageDiscountOption)),
                    DropdownMenuItem(value: 'fixed', child: Text(l10n.fixedDiscountOption)),
                    DropdownMenuItem(value: 'freeDelivery', child: Text(l10n.freeDeliveryOption)),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                if (type != 'freeDelivery') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: type == 'percentage' ? l10n.percentageField : l10n.theAmount,
                      prefixIcon: Icon(type == 'percentage' ? Icons.percent : Icons.attach_money),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () async {
                if (codeController.text.isNotEmpty) {
                  try {
                    await addCoupon(ref, code: codeController.text.toUpperCase(), type: type, value: double.tryParse(valueController.text) ?? 0);
                  } catch (e) {
                    debugPrint('Error adding coupon: $e');
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

  void _showDetails(BuildContext context, WidgetRef ref, CouponsTableData c) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkTheme ? const Color(0xFF1E293B) : Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.code, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: isDarkTheme ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 16),
            _DetailRow(label: l10n.couponTypeLabel, value: _getTypeLabel(c, l10n), isDark: isDarkTheme),
            _DetailRow(label: l10n.minimumOrder, value: '${c.minPurchase.toInt()} ${l10n.currency}', isDark: isDarkTheme),
            _DetailRow(label: l10n.usages, value: '${c.currentUses}/${c.maxUses}', isDark: isDarkTheme),
            _DetailRow(label: l10n.expiryDate, value: c.expiresAt != null ? '${c.expiresAt!.day}/${c.expiresAt!.month}/${c.expiresAt!.year}' : '-', isDark: isDarkTheme),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); _deleteCoupon(ref, c); },
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    label: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.copyCode),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _DetailRow({required this.label, required this.value, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
