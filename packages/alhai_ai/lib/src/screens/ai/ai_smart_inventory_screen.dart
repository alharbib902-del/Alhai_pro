/// شاشة المخزون الذكي بالذكاء الاصطناعي - AI Smart Inventory Screen
///
/// تبويبات: EOQ، تحليل ABC، توقع الهدر، إعادة الطلب
/// كل تبويب يحتوي على جداول بيانات وبطاقات
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../widgets/ai/eoq_calculator_card.dart';
import '../../widgets/ai/abc_analysis_chart.dart';
import '../../widgets/ai/waste_prediction_card.dart';
import '../../providers/ai_smart_inventory_providers.dart';
import '../../services/ai_smart_inventory_service.dart';

class AiSmartInventoryScreen extends ConsumerStatefulWidget {
  const AiSmartInventoryScreen({super.key});

  @override
  ConsumerState<AiSmartInventoryScreen> createState() => _AiSmartInventoryScreenState();
}

class _AiSmartInventoryScreenState extends ConsumerState<AiSmartInventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
              children: [
                AppHeader(
                  title: AppLocalizations.of(context)!.aiSmartInventoryTitle,
                  onMenuTap: !isWideScreen ? () => Scaffold.of(context).openDrawer() : null,
                ),
                Expanded(child: _buildContent(isDark, isWideScreen)),
              ],
            );
  }

  Widget _buildContent(bool isDark, bool isWideScreen) {
    final summaryAsync = ref.watch(smartInventorySummaryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          summaryAsync.when(
            data: (summary) => _buildSummaryCards(isDark, summary, isWideScreen),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Text('$e'),
          ),

          const SizedBox(height: 24),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              isScrollable: !isWideScreen,
              tabs: [
                const Tab(text: 'EOQ'),
                Tab(text: AppLocalizations.of(context)!.tabAbcAnalysis),
                Tab(text: AppLocalizations.of(context)!.tabWastePrediction),
                Tab(text: AppLocalizations.of(context)!.tabReorder),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab content
          SizedBox(
            height: isWideScreen ? 700 : 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEoqTab(isDark, isWideScreen),
                _buildAbcTab(isDark),
                _buildWasteTab(isDark, isWideScreen),
                _buildReorderTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(bool isDark, SmartInventorySummary summary, bool isWideScreen) {
    final l10n = AppLocalizations.of(context)!;
    final cards = [
      _SummaryData(
        title: l10n.totalProductsTitle,
        value: '${summary.totalProducts}',
        icon: Icons.inventory_2_rounded,
        color: AppColors.primary,
      ),
      _SummaryData(
        title: l10n.categoryATitle,
        value: '${summary.abcACount}',
        subtitle: l10n.mostImportant,
        icon: Icons.star_rounded,
        color: const Color(0xFF10B981),
      ),
      _SummaryData(
        title: l10n.nearExpiry,
        value: '${summary.expiringCount}',
        subtitle: l10n.withinDays,
        icon: Icons.timer_rounded,
        color: AppColors.error,
      ),
      _SummaryData(
        title: l10n.needReorder,
        value: '${summary.reorderCount}',
        subtitle: l10n.estimatedLossSar(summary.totalEstimatedLoss.toInt().toString()),
        icon: Icons.shopping_cart_rounded,
        color: AppColors.warning,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.map((card) {
            return SizedBox(
              width: isWideScreen
                  ? constraints.maxWidth / 4 - 16
                  : double.infinity,
              child: Container(
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: card.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(card.icon, color: card.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        card.value,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (card.subtitle != null)
                        Text(
                          card.subtitle!,
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
      },
    );
  }

  Widget _buildEoqTab(bool isDark, bool isWideScreen) {
    final eoqAsync = ref.watch(eoqResultsProvider);

    return eoqAsync.when(
      data: (results) {
        if (isWideScreen) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getResponsiveGridColumns(context, mobile: 2, desktop: 3),
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return EoqCalculatorCard(
                result: results[index],
                onOrderNow: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.orderUnitsSnack(results[index].eoq, results[index].name)),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              );
            },
          );
        }

        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return EoqCalculatorCard(
              result: results[index],
              onOrderNow: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.orderUnitsSnack(results[index].eoq, results[index].name)),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  Widget _buildAbcTab(bool isDark) {
    final abcAsync = ref.watch(filteredAbcItemsProvider);

    return abcAsync.when(
      data: (items) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // ABC filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildAbcFilterChip(null, AppLocalizations.of(context)!.filterAllLabel, isDark),
                    _buildAbcFilterChip(AbcCategory.a, AppLocalizations.of(context)!.categoryALabel, isDark),
                    _buildAbcFilterChip(AbcCategory.b, AppLocalizations.of(context)!.categoryBLabel, isDark),
                    _buildAbcFilterChip(AbcCategory.c, AppLocalizations.of(context)!.categoryCLabel, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AbcAnalysisChart(items: items),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  Widget _buildAbcFilterChip(AbcCategory? category, String label, bool isDark) {
    final currentFilter = ref.watch(abcCategoryFilterProvider);
    final isSelected = currentFilter == category;
    Color color;
    if (category == null) {
      color = AppColors.primary;
    } else {
      switch (category) {
        case AbcCategory.a:
          color = const Color(0xFF10B981);
        case AbcCategory.b:
          color = const Color(0xFFF59E0B);
        case AbcCategory.c:
          color = const Color(0xFF6B7280);
      }
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (_) {
          ref.read(abcCategoryFilterProvider.notifier).state = isSelected ? null : category;
        },
        selectedColor: color.withValues(alpha: 0.15),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: isSelected ? color : (isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildWasteTab(bool isDark, bool isWideScreen) {
    final wasteAsync = ref.watch(wastePredictionsProvider);

    return wasteAsync.when(
      data: (predictions) {
        // Sort by urgency (days to expiry)
        final sorted = [...predictions]..sort((a, b) => a.daysToExpiry.compareTo(b.daysToExpiry));

        if (isWideScreen) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getResponsiveGridColumns(context, mobile: 2, desktop: 3),
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              return WastePredictionCard(
                prediction: sorted[index],
                onActionTap: () {
                  final l10n = AppLocalizations.of(context)!;
                  final action = sorted[index].suggestedAction == WasteSuggestedAction.discount
                      ? l10n.actionDiscount
                      : sorted[index].suggestedAction == WasteSuggestedAction.transfer
                          ? l10n.actionTransfer
                          : l10n.actionDonate;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$action: ${sorted[index].name}'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              );
            },
          );
        }

        return ListView.separated(
          itemCount: sorted.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return WastePredictionCard(
              prediction: sorted[index],
              onActionTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.actionOnProduct(sorted[index].name)),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  Widget _buildReorderTab(bool isDark) {
    final reorderAsync = ref.watch(reorderSuggestionsProvider);

    return reorderAsync.when(
      data: (suggestions) {
        return ListView.separated(
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final sug = suggestions[index];
            return _ReorderCard(suggestion: sug, isDark: isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

/// بيانات الملخص - Summary Data
class _SummaryData {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _SummaryData({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });
}

/// بطاقة إعادة الطلب - Reorder Card
class _ReorderCard extends StatelessWidget {
  final ReorderSuggestion suggestion;
  final bool isDark;

  const _ReorderCard({
    required this.suggestion,
    required this.isDark,
  });

  Color _getUrgencyColor() {
    switch (suggestion.urgency) {
      case UrgencyLevel.critical:
        return AppColors.error;
      case UrgencyLevel.high:
        return const Color(0xFFEA580C);
      case UrgencyLevel.medium:
        return AppColors.warning;
      case UrgencyLevel.low:
        return AppColors.info;
    }
  }

  String _getUrgencyLabel(AppLocalizations l10n) {
    switch (suggestion.urgency) {
      case UrgencyLevel.critical:
        return l10n.urgencyCritical;
      case UrgencyLevel.high:
        return l10n.urgencyHigh;
      case UrgencyLevel.medium:
        return l10n.urgencyMedium;
      case UrgencyLevel.low:
        return l10n.urgencyLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final urgencyColor = _getUrgencyColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: suggestion.urgency == UrgencyLevel.critical
              ? urgencyColor.withValues(alpha: 0.3)
              : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
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
          // Header
          Row(
            children: [
              // Urgency indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: urgencyColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (suggestion.supplier != null)
                      Text(
                        suggestion.supplier!,
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getUrgencyLabel(l10n),
                  style: TextStyle(
                    color: urgencyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stock details
          Row(
            children: [
              _StockDetail(
                label: l10n.currentStockLabel,
                value: '${suggestion.currentStock}',
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _StockDetail(
                label: l10n.reorderPointLabel,
                value: '${suggestion.reorderPoint}',
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _StockDetail(
                label: l10n.suggestedQtyLabel,
                value: '${suggestion.suggestedQty}',
                isDark: isDark,
                highlight: true,
              ),
              const SizedBox(width: 16),
              _StockDetail(
                label: l10n.daysOfStockLabel,
                value: '${suggestion.daysOfStock}',
                isDark: isDark,
                color: suggestion.daysOfStock <= 3 ? AppColors.error : null,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Cost + order button
          Row(
            children: [
              Text(
                l10n.estimatedCostLabel(suggestion.estimatedCost.toStringAsFixed(0)),
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.purchaseOrderCreatedFor(suggestion.name)),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_rounded, size: 16),
                label: Text(
                  l10n.orderUnitsButton(suggestion.suggestedQty),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// تفاصيل المخزون - Stock Detail
class _StockDetail extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool highlight;
  final Color? color;

  const _StockDetail({
    required this.label,
    required this.value,
    required this.isDark,
    this.highlight = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? (highlight ? AppColors.primary : (isDark ? Colors.white : AppColors.textPrimary)),
            fontSize: 15,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
