/// شاشة تحليل السلة بالذكاء الاصطناعي - AI Basket Analysis Screen
///
/// خريطة حرارية للارتباطات، بطاقات الحزم، لوحة رؤى السلة
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../widgets/ai/association_matrix.dart';
import '../../widgets/ai/bundle_suggestion_card.dart';
import '../../providers/ai_basket_analysis_providers.dart';
import '../../services/ai_basket_analysis_service.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

class AiBasketAnalysisScreen extends ConsumerStatefulWidget {
  const AiBasketAnalysisScreen({super.key});

  @override
  ConsumerState<AiBasketAnalysisScreen> createState() =>
      _AiBasketAnalysisScreenState();
}

class _AiBasketAnalysisScreenState extends ConsumerState<AiBasketAnalysisScreen>
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
    final isWideScreen = context.isDesktop;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.aiBasketAnalysis,
          onMenuTap:
              !isWideScreen ? () => Scaffold.of(context).openDrawer() : null,
        ),
        Expanded(child: _buildContent(isDark, isWideScreen)),
      ],
    );
  }

  Widget _buildContent(bool isDark, bool isWideScreen) {
    final insightsAsync = ref.watch(basketInsightsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Insights summary
          insightsAsync.when(
            data: (insights) =>
                _buildInsightsSummary(isDark, insights, isWideScreen),
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Text('$e'),
          ),

          const SizedBox(height: AlhaiSpacing.lg),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: AppLocalizations.of(context).aiAssociations),
                Tab(text: AppLocalizations.of(context).aiBundleSuggestions),
                Tab(text: AppLocalizations.of(context).aiCrossSell),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.md),

          // Tab content
          SizedBox(
            height: isWideScreen ? 600 : 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAssociationsTab(isDark),
                _buildBundlesTab(isDark, isWideScreen),
                _buildCrossSellTab(isDark, isWideScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSummary(
      bool isDark, BasketInsight insights, bool isWideScreen) {
    final l10n = AppLocalizations.of(context);
    final cards = [
      _InsightCardData(
        title: l10n.aiAvgBasketSize,
        value: insights.avgBasketSize.toStringAsFixed(1),
        subtitle: l10n.aiProductUnit,
        icon: Icons.shopping_basket_rounded,
        color: AppColors.primary,
      ),
      _InsightCardData(
        title: l10n.aiAvgBasketValue,
        value: '${insights.avgBasketValue.toStringAsFixed(0)} ${l10n.sar}',
        subtitle: l10n.aiSaudiRiyal,
        icon: Icons.payments_rounded,
        color: AppColors.info,
      ),
      _InsightCardData(
        title: l10n.aiStrongestAssociation,
        value: '${(insights.topPairs.first.confidence * 100).toInt()}%',
        subtitle: insights.topPairs.first.productAName,
        icon: Icons.link_rounded,
        color: AppColors.success,
      ),
      _InsightCardData(
        title: l10n.aiConversionRate,
        value: '${insights.conversionRate.toStringAsFixed(1)}%',
        subtitle: l10n.aiFromSuggestions,
        icon: Icons.trending_up_rounded,
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
                  ? (constraints.maxWidth) / 4 - 16
                  : double.infinity,
              child: Container(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
                    const SizedBox(width: AlhaiSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.title,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xxxs),
                          Text(
                            card.value,
                            style: TextStyle(
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            card.subtitle,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : AppColors.textMuted,
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

  Widget _buildAssociationsTab(bool isDark) {
    final associationsAsync = ref.watch(filteredAssociationsProvider);

    return associationsAsync.when(
      data: (associations) => AssociationMatrix(
        associations: associations,
        onPairTap: (pair) {
          // Show pair details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).aiAssociationFrequency(
                  pair.productAName, pair.productBName, pair.frequency)),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  Widget _buildBundlesTab(bool isDark, bool isWideScreen) {
    final bundlesAsync = ref.watch(bundleSuggestionsProvider);

    return bundlesAsync.when(
      data: (bundles) {
        if (isWideScreen) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  getResponsiveGridColumns(context, mobile: 2, desktop: 3),
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: bundles.length,
            itemBuilder: (context, index) {
              return BundleSuggestionCard(
                bundle: bundles[index],
                onActivate: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)
                          .aiBundleActivated(bundles[index].name)),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              );
            },
          );
        }

        return ListView.separated(
          itemCount: bundles.length,
          separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.md),
          itemBuilder: (context, index) {
            return BundleSuggestionCard(
              bundle: bundles[index],
              onActivate: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تفعيل حزمة: ${bundles[index].name}'),
                    backgroundColor: AppColors.success,
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

  Widget _buildCrossSellTab(bool isDark, bool isWideScreen) {
    final insightsAsync = ref.watch(basketInsightsProvider);

    return insightsAsync.when(
      data: (insights) {
        final opportunities = insights.crossSellOpportunities;
        return ListView.separated(
          itemCount: opportunities.length,
          separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.sm),
          itemBuilder: (context, index) {
            final opp = opportunities[index];
            return Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  // Trigger product
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AlhaiSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined,
                              color: AppColors.info, size: 24),
                        ),
                        const SizedBox(height: AlhaiSpacing.xs),
                        Text(
                          opp.triggerProduct,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Arrow with probability
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AlhaiSpacing.xs, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${(opp.probability * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Suggested product
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AlhaiSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_shopping_cart_rounded,
                              color: AppColors.success, size: 24),
                        ),
                        const SizedBox(height: AlhaiSpacing.xs),
                        Text(
                          opp.suggestedProduct,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _InsightCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InsightCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
