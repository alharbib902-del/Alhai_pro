/// شاشة التسعير الذكي - AI Smart Pricing Screen
///
/// اقتراحات أسعار ذكية مع حاسبة التأثير ورسم مرونة الطلب
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';
import '../../providers/ai_smart_pricing_providers.dart';
import '../../services/ai_smart_pricing_service.dart';
import '../../widgets/ai/price_suggestion_card.dart';
import '../../widgets/ai/profit_impact_calculator.dart';
import '../../widgets/ai/demand_elasticity_chart.dart';

/// شاشة التسعير الذكي
class AiSmartPricingScreen extends ConsumerStatefulWidget {
  const AiSmartPricingScreen({super.key});

  @override
  ConsumerState<AiSmartPricingScreen> createState() =>
      _AiSmartPricingScreenState();
}

class _AiSmartPricingScreenState extends ConsumerState<AiSmartPricingScreen> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
              children: [
                AppHeader(
                  title: AppLocalizations.of(context)!.aiSmartPricingTitle,
                  subtitle: AppLocalizations.of(context)!.aiSmartPricingSubtitle,
                  // AI-based price suggestions
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(isDark, isWideScreen, isMediumScreen),
                  ),
                ),
              ],
            );
  }

  Widget _buildContent(bool isDark, bool isWideScreen, bool isMediumScreen) {
    final suggestionsAsync = ref.watch(priceSuggestionsProvider);
    final selected = ref.watch(selectedPriceSuggestionProvider);
    final filter = ref.watch(priceFilterProvider);
    final sliderPrice = ref.watch(calculatorPriceProvider);
    final impactAsync = ref.watch(priceImpactProvider);
    final elasticityAsync = ref.watch(demandElasticityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ملخص سريع
        suggestionsAsync.when(
          data: (suggestions) =>
              _buildSummaryRow(suggestions, isDark, isWideScreen),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildErrorWidget(e.toString(), isDark),
        ),

        SizedBox(height: isMediumScreen ? 24 : 16),

        // فلتر
        _buildFilterChips(filter, isDark),

        SizedBox(height: isMediumScreen ? 24 : 16),

        // المحتوى الرئيسي
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قائمة الاقتراحات
              Expanded(
                flex: 3,
                child: suggestionsAsync.when(
                  data: (suggestions) => _buildSuggestionsList(
                    suggestions,
                    selected,
                    isDark,
                  ),
                  loading: () => _buildLoadingCard(isDark, 400),
                  error: (e, _) => _buildErrorWidget(e.toString(), isDark),
                ),
              ),
              const SizedBox(width: 24),
              // لوحة التفاصيل
              Expanded(
                flex: 2,
                child: selected != null
                    ? _buildDetailPanel(
                        selected, sliderPrice, impactAsync, elasticityAsync, isDark)
                    : _buildSelectProductHint(isDark),
              ),
            ],
          )
        else
          Column(
            children: [
              suggestionsAsync.when(
                data: (suggestions) => _buildSuggestionsList(
                  suggestions,
                  selected,
                  isDark,
                ),
                loading: () => _buildLoadingCard(isDark, 300),
                error: (e, _) => _buildErrorWidget(e.toString(), isDark),
              ),
              if (selected != null) ...[
                const SizedBox(height: 16),
                _buildDetailPanel(
                    selected, sliderPrice, impactAsync, elasticityAsync, isDark),
              ],
            ],
          ),
      ],
    );
  }

  /// ملخص سريع
  Widget _buildSummaryRow(
    List<PriceSuggestion> suggestions,
    bool isDark,
    bool isWideScreen,
  ) {
    final canIncrease = suggestions.where((s) => s.isIncrease).length;
    final shouldDecrease = suggestions.where((s) => s.isDecrease).length;
    final totalImpact = suggestions.fold<double>(
        0, (sum, s) => sum + s.expectedImpact.monthlyRevenueDelta);

    final l10n = AppLocalizations.of(context)!;
    final cards = [
      _SummaryData(
        label: l10n.totalSuggestionsLabel,
        value: '${suggestions.length}',
        icon: Icons.lightbulb_rounded,
        color: AppColors.info,
      ),
      _SummaryData(
        label: l10n.canIncreaseLabel,
        value: '$canIncrease',
        icon: Icons.arrow_upward_rounded,
        color: AppColors.primary,
      ),
      _SummaryData(
        label: l10n.shouldDecreaseLabel,
        value: '$shouldDecrease',
        icon: Icons.arrow_downward_rounded,
        color: AppColors.secondary,
      ),
      _SummaryData(
        label: l10n.expectedMonthlyImpact,
        value: '${totalImpact >= 0 ? '+' : ''}${l10n.amountSar(totalImpact.toStringAsFixed(0))}',
        icon: Icons.monetization_on_rounded,
        color: totalImpact >= 0 ? AppColors.primary : AppColors.error,
      ),
    ];

    if (isWideScreen) {
      return Row(
        children: cards.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: entry.key < cards.length - 1 ? 16 : 0,
              ),
              child: _buildSummaryCard(entry.value, isDark),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCard(cards[0], isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard(cards[1], isDark)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCard(cards[2], isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard(cards[3], isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(_SummaryData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    data.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// فلتر الأسعار
  Widget _buildFilterChips(PriceFilterType current, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final filters = [
      (PriceFilterType.all, l10n.filterAllLabel, Icons.list_rounded),
      (PriceFilterType.canIncrease, l10n.canIncreaseLabel, Icons.trending_up_rounded),
      (PriceFilterType.shouldDecrease, l10n.shouldDecreaseLabel,
          Icons.trending_down_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((f) {
        final isActive = current == f.$1;
        return FilterChip(
          selected: isActive,
          onSelected: (_) =>
              ref.read(priceFilterProvider.notifier).state = f.$1,
          avatar: Icon(
            f.$3,
            size: 16,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
          label: Text(
            f.$2,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? Colors.white
                  : isDark
                      ? Colors.white70
                      : AppColors.textSecondary,
            ),
          ),
          selectedColor: AppColors.primary,
          backgroundColor:
              isDark ? const Color(0xFF1E293B) : Colors.white,
          side: BorderSide(
            color: isActive
                ? AppColors.primary
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }).toList(),
    );
  }

  /// قائمة الاقتراحات
  Widget _buildSuggestionsList(
    List<PriceSuggestion> suggestions,
    PriceSuggestion? selected,
    bool isDark,
  ) {
    if (suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.price_check_rounded,
              size: 48,
              color: isDark ? Colors.white24 : AppColors.grey300,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.noSuggestionsInFilter,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: suggestions.map((suggestion) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PriceSuggestionCard(
            suggestion: suggestion,
            isSelected: selected?.productId == suggestion.productId,
            onTap: () {
              ref.read(selectedPriceSuggestionProvider.notifier).state =
                  suggestion;
              ref.read(calculatorPriceProvider.notifier).state =
                  suggestion.suggestedPrice;
            },
          ),
        );
      }).toList(),
    );
  }

  /// لوحة التفاصيل
  Widget _buildDetailPanel(
    PriceSuggestion selected,
    double sliderPrice,
    AsyncValue<PriceImpact?> impactAsync,
    AsyncValue<DemandElasticity?> elasticityAsync,
    bool isDark,
  ) {
    return Column(
      children: [
        // حاسبة التأثير
        ProfitImpactCalculator(
          suggestion: selected,
          currentSliderPrice: sliderPrice,
          impact: impactAsync.valueOrNull,
          isLoading: impactAsync.isLoading,
          onPriceChanged: (v) =>
              ref.read(calculatorPriceProvider.notifier).state = v,
          onApply: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.priceApplied(sliderPrice.toStringAsFixed(2), selected.name),
                ),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // رسم مرونة الطلب
        elasticityAsync.when(
          data: (elasticity) => DemandElasticityChart(
            elasticity: elasticity,
            currentPrice: selected.currentPrice,
            suggestedPrice: sliderPrice,
          ),
          loading: () => _buildLoadingCard(isDark, 220),
          error: (e, _) => _buildErrorWidget(e.toString(), isDark),
        ),
      ],
    );
  }

  /// تلميح اختيار منتج
  Widget _buildSelectProductHint(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectProductForDetails,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.selectProductHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(bool isDark, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border,
        ),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorWidget(String error, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.errorOccurredShort(error),
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
