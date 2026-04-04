/// شاشة تحليل المنافسين - AI Competitor Analysis Screen
///
/// تعرض مقارنة الأسعار مع المنافسين وخريطة الموقع السوقي والتنبيهات
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../providers/ai_competitor_analysis_providers.dart';
import '../../services/ai_competitor_analysis_service.dart';
import '../../widgets/ai/competitor_price_table.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../widgets/ai/market_position_chart.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

class AiCompetitorAnalysisScreen extends ConsumerStatefulWidget {
  const AiCompetitorAnalysisScreen({super.key});

  @override
  ConsumerState<AiCompetitorAnalysisScreen> createState() =>
      _AiCompetitorAnalysisScreenState();
}

class _AiCompetitorAnalysisScreenState
    extends ConsumerState<AiCompetitorAnalysisScreen>
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        AppHeader(
          title: l10n.aiCompetitorAnalysis,
          onMenuTap:
              !isWideScreen ? () => Scaffold.of(context).openDrawer() : null,
        ),
        Expanded(child: _buildContent(isDark, isWideScreen)),
      ],
    );
  }

  Widget _buildContent(bool isDark, bool isWideScreen) {
    final l10n = AppLocalizations.of(context)!;
    final summary = ref.watch(competitorSummaryProvider);
    final alerts = ref.watch(competitorAlertsProvider);
    final unreadAlerts = alerts.where((a) => !a.isRead).length;

    return Column(
      children: [
        // Tab bar
        Container(
          margin: EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl,
              AlhaiSpacing.md, AlhaiSpacing.mdl, AlhaiSpacing.zero),
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
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.textSecondary,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            dividerHeight: 0,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.compare_arrows_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(l10n.aiPriceComparison),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.scatter_plot_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(l10n.aiMarketPosition),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_active_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(l10n.alerts),
                    if (unreadAlerts > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: AlhaiSpacing.xxxs),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unreadAlerts',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Summary cards
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl,
              AlhaiSpacing.md, AlhaiSpacing.mdl, AlhaiSpacing.zero),
          child: _buildSummaryCards(summary, isDark, isWideScreen),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPriceComparisonTab(isDark),
              _buildMarketPositionTab(isDark),
              _buildAlertsTab(isDark, alerts),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(
      CompetitorAnalysisSummary summary, bool isDark, bool isWideScreen) {
    final l10n = AppLocalizations.of(context)!;
    final cards = [
      _SummaryData(
        icon: Icons.inventory_2_rounded,
        label: l10n.aiTrackedProducts,
        value: '${summary.totalProductsTracked}',
        color: AppColors.info,
      ),
      _SummaryData(
        icon: Icons.trending_down_rounded,
        label: l10n.aiCheaperThanCompetitors,
        value: '${summary.cheaperThanCompetitors}',
        color: AppColors.success,
      ),
      _SummaryData(
        icon: Icons.trending_up_rounded,
        label: l10n.aiMoreExpensive,
        value: '${summary.moreExpensiveThanCompetitors}',
        color: AppColors.error,
      ),
      _SummaryData(
        icon: Icons.percent_rounded,
        label: l10n.aiAvgPriceDiff,
        value: '${summary.averagePriceDifference}%',
        color: summary.averagePriceDifference < 0
            ? AppColors.success
            : AppColors.warning,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards.map((data) {
            return SizedBox(
              width: isWideScreen
                  ? constraints.maxWidth / 4 - 12
                  : double.infinity,
              child: _buildSummaryCard(data, isDark),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSummaryCard(_SummaryData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.border),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceComparisonTab(bool isDark) {
    final comparisons = ref.watch(priceComparisonsProvider);
    final filter = ref.watch(competitorFilterProvider);
    final sort = ref.watch(competitorSortProvider);

    return comparisons.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
          child: Text(
              AppLocalizations.of(context)!.aiErrorWithMessage(e.toString()))),
      data: (data) {
        final l10n = AppLocalizations.of(context)!;
        var filtered = filter == l10n.all
            ? data
            : data.where((c) => c.category == filter).toList();
        final notifier = ref.read(priceComparisonsProvider.notifier);
        filtered = notifier.sortComparisons(filtered, sort);

        final categories = [l10n.all, ...data.map((c) => c.category).toSet()];

        return Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          child: Column(
            children: [
              // Filter row
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = cat == filter;
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(
                                start: AlhaiSpacing.xs),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(cat),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : AppColors.textSecondary),
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              selectedColor: const Color(0xFF8B5CF6),
                              backgroundColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF8B5CF6)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : AppColors.border),
                              ),
                              onSelected: (_) => ref
                                  .read(competitorFilterProvider.notifier)
                                  .state = cat,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  PopupMenuButton<CompetitorSortType>(
                    initialValue: sort,
                    onSelected: (v) =>
                        ref.read(competitorSortProvider.notifier).state = v,
                    itemBuilder: (_) => [
                      PopupMenuItem(
                          value: CompetitorSortType.name,
                          child: Text(l10n.aiSortByName)),
                      PopupMenuItem(
                          value: CompetitorSortType.priceDiff,
                          child: Text(l10n.aiSortByPriceDiff)),
                      PopupMenuItem(
                          value: CompetitorSortType.ourPrice,
                          child: Text(l10n.aiSortByOurPrice)),
                      PopupMenuItem(
                          value: CompetitorSortType.category,
                          child: Text(l10n.aiSortByCategory)),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.sm,
                          vertical: AlhaiSpacing.xs),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort_rounded,
                              size: 18,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(l10n.aiSortLabel,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : AppColors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.md),
              Expanded(
                child: CompetitorPriceTable(comparisons: filtered),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarketPositionTab(bool isDark) {
    final position = ref.watch(marketPositionProvider);
    final isWide = context.isDesktop;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      child: Column(
        children: [
          MarketPositionChart(position: position, height: isWide ? 400 : 300),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Competitor cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                AiCompetitorAnalysisService.mockCompetitors.map((competitor) {
              return SizedBox(
                width: isWide ? 280 : double.infinity,
                child: _buildCompetitorCard(competitor, isDark),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitorCard(Competitor competitor, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final competitorColors = {
      'بنده': const Color(0xFFF97316),
      'الدانوب': const Color(0xFF3B82F6),
      'كارفور': const Color(0xFFEF4444),
      'التميمي': const Color(0xFF8B5CF6),
      'العثيم': const Color(0xFF14B8A6),
    };
    final color = competitorColors[competitor.nameAr] ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    competitor.nameAr[0],
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      competitor.nameAr,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      competitor.type,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildCompetitorStat(
                  l10n.aiPriceIndex,
                  '${(competitor.overallPriceIndex * 100).toInt()}%',
                  isDark,
                  color),
              const SizedBox(width: AlhaiSpacing.sm),
              _buildCompetitorStat(l10n.aiQuality,
                  '${competitor.qualityScore}/10', isDark, color),
              const SizedBox(width: AlhaiSpacing.sm),
              _buildCompetitorStat(
                  l10n.aiBranches, '${competitor.branchCount}', isDark, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitorStat(
      String label, String value, bool isDark, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: color,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xxxs),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsTab(bool isDark, List<CompetitorAlert> alerts) {
    final l10n = AppLocalizations.of(context)!;
    final alertsNotifier = ref.read(competitorAlertsProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl,
              AlhaiSpacing.md, AlhaiSpacing.mdl, AlhaiSpacing.zero),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => alertsNotifier.markAllAsRead(),
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: Text(l10n.aiMarkAllRead),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: alerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_rounded,
                          size: 48,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : AppColors.textMuted),
                      const SizedBox(height: AlhaiSpacing.sm),
                      Text(l10n.aiNoAlertsCurrently,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppColors.textSecondary,
                          )),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AlhaiSpacing.mdl),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    return _buildAlertCard(
                        alerts[index], isDark, alertsNotifier);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(
      CompetitorAlert alert, bool isDark, CompetitorAlertsNotifier notifier) {
    Color alertColor;
    IconData alertIcon;
    switch (alert.alertType) {
      case AlertType.priceDecrease:
        alertColor = AppColors.error;
        alertIcon = Icons.arrow_downward_rounded;
      case AlertType.priceIncrease:
        alertColor = AppColors.success;
        alertIcon = Icons.arrow_upward_rounded;
      case AlertType.promotion:
        alertColor = AppColors.warning;
        alertIcon = Icons.local_offer_rounded;
      case AlertType.outOfStock:
        alertColor = AppColors.info;
        alertIcon = Icons.inventory_rounded;
      case AlertType.newProduct:
        alertColor = const Color(0xFF8B5CF6);
        alertIcon = Icons.new_releases_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alert.isRead
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.border)
              : alertColor.withValues(alpha: 0.3),
          width: alert.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => notifier.markAsRead(alert.id),
        borderRadius: BorderRadius.circular(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(alertIcon, color: alertColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.competitorName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: alertColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Row(
                    children: [
                      if (alert.changePercent != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AlhaiSpacing.xs, vertical: 3),
                          decoration: BoxDecoration(
                            color: alertColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${alert.changePercent > 0 ? '+' : ''}${alert.changePercent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: alertColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (alert.changePercent != 0)
                        const SizedBox(width: AlhaiSpacing.xs),
                      Text(
                        '${alert.oldPrice.toStringAsFixed(2)} ر.س → ${alert.newPrice.toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : AppColors.textMuted,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(alert.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return l10n.aiMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.aiHoursAgo(diff.inHours);
    return l10n.aiDaysAgo(diff.inDays);
  }
}

class _SummaryData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
