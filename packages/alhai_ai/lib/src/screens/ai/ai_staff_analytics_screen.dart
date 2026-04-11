/// شاشة تحليلات الموظفين - AI Staff Analytics Screen
///
/// لوحة الترتيب، بطاقات الموظفين الفردية، خريطة حرارية للورديات
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../providers/ai_staff_analytics_providers.dart';
import '../../services/ai_staff_analytics_service.dart';
import '../../widgets/ai/staff_performance_card.dart';
import '../../widgets/ai/shift_optimization_chart.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

class AiStaffAnalyticsScreen extends ConsumerStatefulWidget {
  const AiStaffAnalyticsScreen({super.key});

  @override
  ConsumerState<AiStaffAnalyticsScreen> createState() =>
      _AiStaffAnalyticsScreenState();
}

class _AiStaffAnalyticsScreenState extends ConsumerState<AiStaffAnalyticsScreen>
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
          title: l10n.aiStaffAnalytics,
          onMenuTap: !isWideScreen
              ? () => Scaffold.of(context).openDrawer()
              : null,
        ),
        Expanded(child: _buildContent(isDark, isWideScreen)),
      ],
    );
  }

  Widget _buildContent(bool isDark, bool isWideScreen) {
    final teamSummary = ref.watch(teamSummaryProvider);

    return Column(
      children: [
        // Summary cards
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            AlhaiSpacing.mdl,
            AlhaiSpacing.md,
            AlhaiSpacing.mdl,
            AlhaiSpacing.zero,
          ),
          child: _buildSummaryRow(teamSummary, isDark, isWideScreen),
        ),

        // Tabs
        Container(
          margin: EdgeInsetsDirectional.fromSTEB(
            AlhaiSpacing.mdl,
            AlhaiSpacing.md,
            AlhaiSpacing.mdl,
            AlhaiSpacing.zero,
          ),
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
                colors: [Color(0xFFF97316), Color(0xFFEA580C)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            dividerHeight: 0,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.leaderboard_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context).aiLeaderboard),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context).aiIndividualPerformance),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_view_week_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context).aiShiftOptimization),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLeaderboardTab(isDark, isWideScreen),
              _buildIndividualTab(isDark, isWideScreen),
              _buildShiftOptimizationTab(isDark, isWideScreen),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    TeamPerformanceSummary summary,
    bool isDark,
    bool isWideScreen,
  ) {
    final l10n = AppLocalizations.of(context);
    final items = [
      _SummaryItem(
        Icons.grade_rounded,
        l10n.aiAvgPerformance,
        '${summary.avgScore}%',
        AppColors.primary,
      ),
      _SummaryItem(
        Icons.attach_money_rounded,
        l10n.aiTotalSalesLabel,
        '${(summary.totalSales / 1000).toStringAsFixed(0)}K ر.س',
        AppColors.success,
      ),
      _SummaryItem(
        Icons.receipt_long_rounded,
        l10n.aiTotalTransactions,
        '${summary.totalTransactions}',
        AppColors.info,
      ),
      _SummaryItem(
        Icons.cancel_outlined,
        l10n.aiAvgVoidRate,
        '${summary.avgVoidRate}%',
        summary.avgVoidRate > 3 ? AppColors.error : AppColors.warning,
      ),
      _SummaryItem(
        Icons.trending_up_rounded,
        l10n.aiTeamGrowth,
        '+${summary.teamGrowth}%',
        AppColors.primary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(
              width: isWideScreen
                  ? constraints.maxWidth / 5 - 12
                  : (constraints.maxWidth - 12) / 2,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, size: 18, color: item.color),
                    const SizedBox(height: AlhaiSpacing.xs),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppColors.textMuted,
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

  Widget _buildLeaderboardTab(bool isDark, bool isWideScreen) {
    final rankings = ref.watch(staffRankingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AlhaiSpacing.xs),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Text(
                    AppLocalizations.of(context).aiLeaderboardThisWeek,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ...rankings.map((ranking) => _buildRankingRow(ranking, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingRow(StaffRanking ranking, bool isDark) {
    Color rankColor;
    IconData rankIcon;
    switch (ranking.rank) {
      case 1:
        rankColor = const Color(0xFFFFD700);
        rankIcon = Icons.emoji_events_rounded;
      case 2:
        rankColor = const Color(0xFFC0C0C0);
        rankIcon = Icons.emoji_events_rounded;
      case 3:
        rankColor = const Color(0xFFCD7F32);
        rankIcon = Icons.emoji_events_rounded;
      default:
        rankColor = isDark
            ? Colors.white.withValues(alpha: 0.4)
            : AppColors.textMuted;
        rankIcon = Icons.person_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.grey100,
          ),
        ),
        color: ranking.rank == 1
            ? (isDark
                  ? const Color(0xFFFFD700).withValues(alpha: 0.05)
                  : const Color(0xFFFFF8E1))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: ranking.rank <= 3
                ? Icon(rankIcon, color: rankColor, size: 24)
                : Text(
                    '#${ranking.rank}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: rankColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                ranking.nameAr[0],
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.nameAr,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  ranking.badge,
                  style: TextStyle(
                    fontSize: 11,
                    color: rankColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Score
          Text(
            ranking.score.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          // Change
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.xs,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: ranking.changeFromLastWeek >= 0
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  ranking.changeFromLastWeek >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 12,
                  color: ranking.changeFromLastWeek >= 0
                      ? AppColors.success
                      : AppColors.error,
                ),
                const SizedBox(width: AlhaiSpacing.xxxs),
                Text(
                  ranking.changeFromLastWeek.abs().toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ranking.changeFromLastWeek >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualTab(bool isDark, bool isWideScreen) {
    final staffAsync = ref.watch(staffPerformanceProvider);

    return staffAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          AppLocalizations.of(context).aiErrorWithMessage(e.toString()),
        ),
      ),
      data: (staff) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: staff.asMap().entries.map((entry) {
                  return SizedBox(
                    width: isWideScreen
                        ? constraints.maxWidth / 2 - 28
                        : double.infinity,
                    child: StaffPerformanceCard(
                      staff: entry.value,
                      rank: entry.key + 1,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShiftOptimizationTab(bool isDark, bool isWideScreen) {
    final heatmap = ref.watch(shiftHeatmapProvider);
    final optimizations = ref.watch(shiftOptimizationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      child: Column(
        children: [
          ShiftOptimizationChart(
            data: heatmap,
            height: isWideScreen ? 350 : 280,
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Optimization suggestions
          ...optimizations.map((opt) => _buildOptimizationCard(opt, isDark)),
        ],
      ),
    );
  }

  Widget _buildOptimizationCard(ShiftOptimization opt, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      opt.dayAr,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.xs,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppLocalizations.of(context).aiStaffCurrentSuggested(
                          opt.currentStaff,
                          opt.suggestedStaff,
                        ),
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  opt.suggestion,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem(this.icon, this.label, this.value, this.color);
}
