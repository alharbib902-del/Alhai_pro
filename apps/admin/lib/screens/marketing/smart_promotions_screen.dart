import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:get_it/get_it.dart';
import '../../providers/marketing_providers.dart';

// مزود المنتجات بطيئة الحركة (low stock)
final _lowStockProductsProvider =
    FutureProvider.autoDispose<List<ProductsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.productsDao.getLowStockProducts(storeId);
});

/// Smart Promotions Screen - شاشة العروض الذكية
class SmartPromotionsScreen extends ConsumerStatefulWidget {
  const SmartPromotionsScreen({super.key});

  @override
  ConsumerState<SmartPromotionsScreen> createState() => _SmartPromotionsScreenState();
}

class _SmartPromotionsScreenState extends ConsumerState<SmartPromotionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final activePromotionsAsync = ref.watch(activePromotionsProvider);
    final lowStockAsync = ref.watch(_lowStockProductsProvider);

    final isLoading = activePromotionsAsync.isLoading || lowStockAsync.isLoading;
    final error = activePromotionsAsync.error ?? lowStockAsync.error;

    return Column(
      children: [
        AppHeader(
          title: l10n.smartPromotionsTitle,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.cashCustomer,
          userRole: l10n.branchManager,
        ),
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? Colors.white60 : AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: const Icon(Icons.lightbulb), text: l10n.tabAiSuggestions),
              Tab(icon: const Icon(Icons.local_offer), text: l10n.tabActivePromotions),
              Tab(icon: const Icon(Icons.history), text: l10n.tabHistory),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? AppErrorState.general(
                      message: error.toString(),
                      onRetry: () {
                        ref.invalidate(activePromotionsProvider);
                        ref.invalidate(_lowStockProductsProvider);
                      },
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSuggestionsTab(isMediumScreen, isDark, l10n, lowStockAsync.valueOrNull ?? []),
                        _buildActiveTab(isMediumScreen, isDark, l10n, activePromotionsAsync.valueOrNull ?? []),
                        _buildHistoryTab(isDark, l10n),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsTab(bool isMediumScreen, bool isDark, AppLocalizations l10n, List<ProductsTableData> lowStockProducts) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.info.withValues(alpha: 0.15) : AppColors.infoSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.info, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.smartSuggestions, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      Text(l10n.suggestionsBasedOnAnalysis, style: TextStyle(color: subtextColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (lowStockProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.lightbulb_outline, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text('\u0644\u0627 \u062a\u0648\u062c\u062f \u0627\u0642\u062a\u0631\u0627\u062d\u0627\u062a \u062d\u0627\u0644\u064a\u0627\u064b', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16)),
                ],
              ),
            )
          else
            ...lowStockProducts.map((product) => _buildSuggestionCard(product, isDark, l10n)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(ProductsTableData product, bool isDark, AppLocalizations l10n) {
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final deficit = product.minQty - product.stockQty;
    final suggestedDiscount = deficit > 10 ? 30 : (deficit > 5 ? 20 : 15);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(l10n.suggestedDiscountPercent(suggestedDiscount), style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.warning),
              const SizedBox(width: 4),
              Flexible(child: Text(l10n.slowMovementReason('${product.stockQty}'), style: TextStyle(color: subtextColor))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: Text(l10n.ignore)),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _applyPromotionForProduct(product, l10n),
                icon: const Icon(Icons.check, size: 18),
                label: Text(l10n.applyAction),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab(bool isMediumScreen, bool isDark, AppLocalizations l10n, List<PromotionsTableData> activePromotions) {
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    if (activePromotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('\u0644\u0627 \u062a\u0648\u062c\u062f \u0639\u0631\u0648\u0636 \u0646\u0634\u0637\u0629', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: activePromotions.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: ListTile(
            onTap: () => _showPromotionDetails(p, l10n),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.local_offer, color: AppColors.success),
            ),
            title: Text(p.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text(
              '${_getTypeName(p.type, l10n)} - ${l10n.validityDays(p.endDate.difference(DateTime.now()).inDays)}',
              style: TextStyle(color: subtextColor, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right, color: subtextColor),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildHistoryTab(bool isDark, AppLocalizations l10n) {
    final subtextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: subtextColor),
          const SizedBox(height: 16),
          Text(l10n.promotionHistory, style: TextStyle(color: subtextColor)),
        ],
      ),
    );
  }

  void _applyPromotionForProduct(ProductsTableData product, AppLocalizations l10n) async {
    try {
      await addPromotion(
        ref, name: '${l10n.applyAction}: ${product.name}', type: 'flash_sale',
        description: 'Auto-generated promotion for slow-moving product: ${product.name}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.promotionApplied(product.name)), backgroundColor: AppColors.success),
      );
    } catch (e) {
      debugPrint('Error applying promotion: $e');
    }
  }

  void _showPromotionDetails(PromotionsTableData promotion, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(promotion.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.promotionType(_getTypeName(promotion.type, l10n))),
            Text('${l10n.startDateLabel}: ${promotion.startDate.toString().split(' ').first}'),
            Text('${l10n.endDateLabel}: ${promotion.endDate.toString().split(' ').first}'),
            if (promotion.description != null && promotion.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(promotion.description!, style: const TextStyle(fontSize: 13)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); deletePromotion(ref, promotion.id); },
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.closeAction)),
          FilledButton(onPressed: () => Navigator.pop(context), child: Text(l10n.edit)),
        ],
      ),
    );
  }

  String _getTypeName(String type, AppLocalizations l10n) {
    switch (type) {
      case 'percentage': return l10n.percentageType;
      case 'buy_x_get_y': return l10n.buyXGetYType;
      case 'buyXgetY': return l10n.buyXGetYType;
      case 'fixed': return l10n.fixedAmountType;
      case 'bundle': return l10n.buyXGetYType;
      case 'flash_sale': return l10n.percentageType;
      default: return type;
    }
  }
}
