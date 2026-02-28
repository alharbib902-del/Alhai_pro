/// شاشة توقع المبيعات - AI Sales Forecasting Screen
///
/// عرض توقعات المبيعات مع الأنماط الموسمية ومحاكاة "ماذا لو"
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../providers/ai_sales_forecasting_providers.dart';
import '../../services/ai_sales_forecasting_service.dart';
import '../../widgets/ai/forecast_chart.dart';
import '../../widgets/ai/seasonal_patterns_card.dart';
import '../../widgets/ai/what_if_panel.dart';

/// شاشة توقع المبيعات بالذكاء الاصطناعي
class AiSalesForecastingScreen extends ConsumerStatefulWidget {
  const AiSalesForecastingScreen({super.key});

  @override
  ConsumerState<AiSalesForecastingScreen> createState() =>
      _AiSalesForecastingScreenState();
}

class _AiSalesForecastingScreenState
    extends ConsumerState<AiSalesForecastingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final periods = [
          ForecastPeriod.daily,
          ForecastPeriod.weekly,
          ForecastPeriod.monthly,
        ];
        ref.read(selectedForecastPeriodProvider.notifier).state =
            periods[_tabController.index];
      }
    });
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

    return Column(
              children: [
                AppHeader(
                  title: l10n.aiSalesForecasting,
                  subtitle: l10n.aiSmartForecastSubtitle,
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
    final forecastAsync = ref.watch(forecastResultProvider);
    final patternsAsync = ref.watch(seasonalPatternsProvider);
    final whatIfAsync = ref.watch(whatIfResultProvider);
    final discount = ref.watch(whatIfDiscountProvider);
    final priceChange = ref.watch(whatIfPriceChangeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // مؤشرات سريعة
        forecastAsync.when(
          data: (result) => _buildMetricsRow(result, isDark, isWideScreen),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildErrorWidget(e.toString(), isDark),
        ),

        SizedBox(height: isMediumScreen ? 24 : 16),

        // اختيار الفترة
        _buildPeriodTabs(isDark),

        SizedBox(height: isMediumScreen ? 24 : 16),

        // المحتوى الرئيسي
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // الرسم البياني
                    forecastAsync.when(
                      data: (result) =>
                          ForecastChart(forecasts: result.forecasts),
                      loading: () => _buildLoadingCard(isDark, 280),
                      error: (e, _) => _buildErrorWidget(e.toString(), isDark),
                    ),
                    const SizedBox(height: 24),
                    // الأنماط الموسمية
                    patternsAsync.when(
                      data: (patterns) =>
                          SeasonalPatternsCard(patterns: patterns),
                      loading: () => _buildLoadingCard(isDark, 200),
                      error: (e, _) => _buildErrorWidget(e.toString(), isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // ملخص التوقع
                    forecastAsync.when(
                      data: (result) => _buildSummaryCard(result, isDark),
                      loading: () => _buildLoadingCard(isDark, 180),
                      error: (e, _) => _buildErrorWidget(e.toString(), isDark),
                    ),
                    const SizedBox(height: 24),
                    // ماذا لو
                    WhatIfPanel(
                      discountPercent: discount,
                      priceChangePercent: priceChange,
                      result: whatIfAsync.valueOrNull,
                      isLoading: whatIfAsync.isLoading,
                      onDiscountChanged: (v) => ref
                          .read(whatIfDiscountProvider.notifier)
                          .state = v,
                      onPriceChanged: (v) => ref
                          .read(whatIfPriceChangeProvider.notifier)
                          .state = v,
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              forecastAsync.when(
                data: (result) =>
                    ForecastChart(forecasts: result.forecasts, height: 240),
                loading: () => _buildLoadingCard(isDark, 240),
                error: (e, _) => _buildErrorWidget(e.toString(), isDark),
              ),
              const SizedBox(height: 16),
              forecastAsync.when(
                data: (result) => _buildSummaryCard(result, isDark),
                loading: () => _buildLoadingCard(isDark, 180),
                error: (e, _) => _buildErrorWidget(e.toString(), isDark),
              ),
              const SizedBox(height: 16),
              patternsAsync.when(
                data: (patterns) => SeasonalPatternsCard(patterns: patterns),
                loading: () => _buildLoadingCard(isDark, 200),
                error: (e, _) => _buildErrorWidget(e.toString(), isDark),
              ),
              const SizedBox(height: 16),
              WhatIfPanel(
                discountPercent: discount,
                priceChangePercent: priceChange,
                result: whatIfAsync.valueOrNull,
                isLoading: whatIfAsync.isLoading,
                onDiscountChanged: (v) =>
                    ref.read(whatIfDiscountProvider.notifier).state = v,
                onPriceChanged: (v) =>
                    ref.read(whatIfPriceChangeProvider.notifier).state = v,
              ),
            ],
          ),
      ],
    );
  }

  /// بطاقات المؤشرات السريعة
  Widget _buildMetricsRow(
      ForecastResult result, bool isDark, bool isWideScreen) {
    final l10n = AppLocalizations.of(context)!;
    final cards = [
      _MetricData(
        label: l10n.aiForecastAccuracy,
        value: '${(result.accuracy * 100).toStringAsFixed(0)}%',
        icon: Icons.gps_fixed_rounded,
        color: AppColors.primary,
      ),
      _MetricData(
        label: l10n.aiTrend,
        value: result.trend == TrendDirection.up
            ? l10n.aiTrendUp
            : result.trend == TrendDirection.down
                ? l10n.aiTrendDown
                : l10n.aiTrendStable,
        icon: result.trend == TrendDirection.up
            ? Icons.trending_up_rounded
            : result.trend == TrendDirection.down
                ? Icons.trending_down_rounded
                : Icons.trending_flat_rounded,
        color: result.trend == TrendDirection.up
            ? AppColors.primary
            : result.trend == TrendDirection.down
                ? AppColors.error
                : AppColors.warning,
      ),
      _MetricData(
        label: l10n.aiNextWeekForecast,
        value: '${result.nextWeekTotal.toStringAsFixed(0)} ${l10n.sar}',
        icon: Icons.calendar_today_rounded,
        color: AppColors.info,
      ),
      _MetricData(
        label: l10n.aiMonthForecast,
        value: '${result.nextMonthTotal.toStringAsFixed(0)} ${l10n.sar}',
        icon: Icons.date_range_rounded,
        color: AppColors.secondary,
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
              child: _buildMetricCard(entry.value, isDark),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard(cards[0], isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(cards[1], isDark)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(cards[2], isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(cards[3], isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(_MetricData data, bool isDark) {
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

  /// اختيار الفترة
  Widget _buildPeriodTabs(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? Colors.white54 : AppColors.textSecondary,
        dividerColor: Colors.transparent,
        labelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: AppLocalizations.of(context)!.daily),
          Tab(text: AppLocalizations.of(context)!.weekly),
          Tab(text: AppLocalizations.of(context)!.monthly),
        ],
      ),
    );
  }

  /// بطاقة الملخص
  Widget _buildSummaryCard(ForecastResult result, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, AppColors.primarySurface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.aiForecastSummary,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            result.summary,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          // اتجاه الأيام القادمة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  result.trend == TrendDirection.up
                      ? Icons.trending_up_rounded
                      : result.trend == TrendDirection.down
                          ? Icons.trending_down_rounded
                          : Icons.trending_flat_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.trend == TrendDirection.up
                        ? l10n.aiSalesTrendingUp
                        : result.trend == TrendDirection.down
                            ? l10n.aiSalesDeclining
                            : l10n.aiSalesStable,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.primaryDark,
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
              AppLocalizations.of(context)!.aiErrorOccurred(error),
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
