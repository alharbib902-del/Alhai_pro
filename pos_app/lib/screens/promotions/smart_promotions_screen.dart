import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';

/// Smart Promotions Screen
class SmartPromotionsScreen extends ConsumerStatefulWidget {
  const SmartPromotionsScreen({super.key});

  @override
  ConsumerState<SmartPromotionsScreen> createState() => _SmartPromotionsScreenState();
}

class _SmartPromotionsScreenState extends ConsumerState<SmartPromotionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  String? _error;

  List<PromotionsTableData> _activePromotions = [];
  List<ProductsTableData> _lowStockProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final promotions = await db.discountsDao.getActivePromotions(storeId);
      final lowStock = await db.productsDao.getLowStockProducts(storeId);

      if (mounted) {
        setState(() {
          _activePromotions = promotions;
          _lowStockProducts = lowStock;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.smartPromotionsTitle,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.cashCustomer,
                  userRole: l10n.branchManager,
                ),
                // Tab bar
                Container(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)))
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildSuggestionsTab(isMediumScreen, isDark, l10n),
                                _buildActiveTab(isMediumScreen, isDark, l10n),
                                _buildHistoryTab(isDark, l10n),
                              ],
                            ),
                ),
              ],
            );
  }
  Widget _buildSuggestionsTab(bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          // AI Header
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
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(12),
                  ),
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
          if (_lowStockProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.lightbulb_outline, size: 48, color: isDark ? Colors.white38 : AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text(
                    '\u0644\u0627 \u062a\u0648\u062c\u062f \u0627\u0642\u062a\u0631\u0627\u062d\u0627\u062a \u062d\u0627\u0644\u064a\u0627\u064b',
                    style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            ..._lowStockProducts.map((product) => _buildSuggestionCard(product, isDark, l10n)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(ProductsTableData product, bool isDark, AppLocalizations l10n) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    final deficit = product.minQty - product.stockQty;
    final suggestedDiscount = deficit > 10 ? 30 : (deficit > 5 ? 20 : 15);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
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
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(Icons.inventory, l10n.stockLabelCount(product.stockQty), null, isDark),
              const SizedBox(width: 8),
              if (product.stockQty <= 5)
                _buildInfoChip(Icons.warning, l10n.stockLabelCount(product.minQty), AppColors.error, isDark),
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

  Widget _buildInfoChip(IconData icon, String label, Color? color, bool isDark) {
    final chipColor = color ?? (isDark ? Colors.white54 : AppColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: chipColor)),
        ],
      ),
    );
  }

  Widget _buildActiveTab(bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    if (_activePromotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64, color: isDark ? Colors.white38 : AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              '\u0644\u0627 \u062a\u0648\u062c\u062f \u0639\u0631\u0648\u0636 \u0646\u0634\u0637\u0629',
              style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: _activePromotions.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          child: ListTile(
            onTap: () => _showPromotionDetails(p, l10n),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_offer, color: AppColors.success),
            ),
            title: Text(p.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text(
              '${_getTypeName(p.type, l10n)} - ${l10n.validityDays(p.endDate.difference(DateTime.now()).inDays)}',
              style: TextStyle(color: subtextColor, fontSize: 12),
            ),
            trailing: AdaptiveIcon(Icons.chevron_right, color: subtextColor),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildHistoryTab(bool isDark, AppLocalizations l10n) {
    final subtextColor = isDark ? Colors.white54 : AppColors.textSecondary;
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

  void _applyPromotionForProduct(ProductsTableData product, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.promotionApplied(product.name)), backgroundColor: AppColors.success),
    );
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
