/// شاشة التنبؤ بالمرتجعات بالذكاء الاصطناعي
///
/// لوحة متكاملة تعرض تحليل المرتجعات المتوقعة
/// مع مؤشرات الخطر والإجراءات الوقائية المقترحة
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';
import '../../providers/ai_return_prediction_providers.dart';
import '../../services/ai_return_prediction_service.dart';
import '../../widgets/ai/return_risk_card.dart';
import '../../widgets/ai/preventive_action_card.dart';

/// شاشة التنبؤ بالمرتجعات
class AiReturnPredictionScreen extends ConsumerStatefulWidget {
  const AiReturnPredictionScreen({super.key});

  @override
  ConsumerState<AiReturnPredictionScreen> createState() => _AiReturnPredictionScreenState();
}

class _AiReturnPredictionScreenState extends ConsumerState<AiReturnPredictionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: 'التنبؤ بالمرتجعات - AI',
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.defaultUserName,
                  userRole: l10n.branchManager,
                ),
                // التبويبات
                Container(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark ? Colors.white60 : AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(icon: Icon(Icons.warning_amber_rounded), text: 'تحليل المخاطر'),
                      Tab(icon: Icon(Icons.shield_outlined), text: 'إجراءات وقائية'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRiskAnalysisTab(isDark, isWideScreen),
                      _buildPreventiveActionsTab(isDark, isWideScreen),
                    ],
                  ),
                ),
              ],
            );
  }

  // ============================================================================
  // TAB 1: تحليل المخاطر
  // ============================================================================

  Widget _buildRiskAnalysisTab(bool isDark, bool isWideScreen) {
    final probabilities = ref.watch(filteredProbabilitiesProvider);
    final trends = ref.watch(returnTrendsProvider);
    final avgRate = ref.watch(averageReturnRateProvider);
    final atRisk = ref.watch(atRiskAmountProvider);
    final highRiskCount = ref.watch(highRiskCountProvider);
    final selectedFilter = ref.watch(selectedRiskFilterProvider);

    return probabilities.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('حدث خطأ: $e')),
      data: (probs) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(isWideScreen ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقات الملخص
              _buildSummaryCards(isDark, isWideScreen, avgRate, atRisk, highRiskCount),
              const SizedBox(height: 24),

              // رسم بياني للاتجاه
              trends.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (trendData) => _buildTrendChart(isDark, trendData),
              ),
              const SizedBox(height: 24),

              // فلتر مستوى الخطر
              _buildRiskFilter(isDark, selectedFilter),
              const SizedBox(height: 16),

              // قائمة العمليات
              Text(
                'العمليات المعرضة للإرجاع (${probs.length})',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...probs.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReturnRiskCard(probability: p),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(
    bool isDark,
    bool isWideScreen,
    AsyncValue<double> avgRate,
    AsyncValue<double> atRisk,
    AsyncValue<int> highRisk,
  ) {
    final cards = [
      _SummaryCardData(
        title: 'معدل الإرجاع',
        value: avgRate.when(
          data: (v) => '${v.toStringAsFixed(1)}%',
          loading: () => '...',
          error: (_, __) => '--',
        ),
        icon: Icons.trending_down,
        color: const Color(0xFF3B82F6),
        subtitle: 'متوسط آخر 6 أشهر',
      ),
      _SummaryCardData(
        title: 'مبلغ معرض للخطر',
        value: atRisk.when(
          data: (v) => '${v.toStringAsFixed(0)} ر.س',
          loading: () => '...',
          error: (_, __) => '--',
        ),
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFEF4444),
        subtitle: 'عمليات عالية الخطر',
      ),
      _SummaryCardData(
        title: 'عمليات عالية الخطر',
        value: highRisk.when(
          data: (v) => '$v',
          loading: () => '...',
          error: (_, __) => '--',
        ),
        icon: Icons.flag_rounded,
        color: const Color(0xFFF59E0B),
        subtitle: 'تحتاج تدخل فوري',
      ),
    ];

    if (isWideScreen) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildSummaryCard(isDark, c),
                  ),
                ))
            .toList(),
      );
    }

    return Column(
      children: cards
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildSummaryCard(isDark, c),
              ))
          .toList(),
    );
  }

  Widget _buildSummaryCard(bool isDark, _SummaryCardData data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [data.color, data.color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(bool isDark, List<ReturnTrend> trends) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'اتجاه المرتجعات',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _TrendChartPainter(
                trends: trends,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: trends.map((t) {
              final trendIcon = t.trend == TrendDirection.up
                  ? Icons.arrow_upward
                  : t.trend == TrendDirection.down
                      ? Icons.arrow_downward
                      : Icons.remove;
              final trendColor = t.trend == TrendDirection.up
                  ? AppColors.error
                  : t.trend == TrendDirection.down
                      ? AppColors.success
                      : AppColors.warning;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    Text(
                      t.period,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(trendIcon, size: 10, color: trendColor),
                        Text(
                          '${t.returnRate}%',
                          style: TextStyle(
                            color: trendColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFilter(bool isDark, ReturnRiskLevel? selected) {
    final filters = [
      const _FilterOption(label: 'الكل', value: null),
      const _FilterOption(label: 'عالي جداً', value: ReturnRiskLevel.veryHigh),
      const _FilterOption(label: 'عالي', value: ReturnRiskLevel.high),
      const _FilterOption(label: 'متوسط', value: ReturnRiskLevel.medium),
      const _FilterOption(label: 'منخفض', value: ReturnRiskLevel.low),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = f.value == selected;
          final chipColor = f.value != null
              ? Color(AiReturnPredictionService.getRiskColorValue(f.value!))
              : AppColors.primary;

          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: FilterChip(
              label: Text(f.label),
              selected: isSelected,
              onSelected: (_) {
                ref.read(selectedRiskFilterProvider.notifier).state = f.value;
              },
              selectedColor: chipColor.withValues(alpha: 0.15),
              backgroundColor: isDark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              labelStyle: TextStyle(
                color: isSelected
                    ? chipColor
                    : (isDark ? Colors.white70 : AppColors.textSecondary),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected
                    ? chipColor
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppColors.border),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================================
  // TAB 2: الإجراءات الوقائية
  // ============================================================================

  Widget _buildPreventiveActionsTab(bool isDark, bool isWideScreen) {
    final actions = ref.watch(preventiveActionsProvider);

    return actions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('حدث خطأ: $e')),
      data: (actionsList) {
        final totalSavings = actionsList.fold<double>(
          0,
          (sum, a) => sum + a.estimatedSavings,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWideScreen ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ملخص التوفير
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.savings,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجمالي التوفير المتوقع',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${totalSavings.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'من ${actionsList.length} إجراء وقائي',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'AI',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // عنوان القائمة
              Text(
                'الإجراءات الوقائية المقترحة',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'طبّق هذه الإجراءات لتقليل المرتجعات وزيادة رضا العملاء',
                style: TextStyle(
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              // قائمة الإجراءات
              ...actionsList.map((action) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PreventiveActionCard(
                      action: action,
                      onApply: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم تطبيق: ${action.title}'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      onDismiss: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم تجاهل: ${action.title}'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// HELPER MODELS
// ============================================================================

class _SummaryCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}

class _FilterOption {
  final String label;
  final ReturnRiskLevel? value;

  const _FilterOption({required this.label, required this.value});
}

// ============================================================================
// TREND CHART PAINTER
// ============================================================================

class _TrendChartPainter extends CustomPainter {
  final List<ReturnTrend> trends;
  final bool isDark;

  _TrendChartPainter({required this.trends, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final maxRate = trends.map((t) => t.returnRate).reduce(math.max);
    final minRate = trends.map((t) => t.returnRate).reduce(math.min);
    final range = (maxRate - minRate).clamp(1.0, double.infinity);

    const paddingTop = 20.0;
    const paddingBottom = 30.0;
    final chartHeight = size.height - paddingTop - paddingBottom;
    final stepX = size.width / (trends.length - 1).clamp(1, trends.length);

    // رسم خطوط الشبكة
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = paddingTop + (chartHeight * i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // رسم المنطقة المظللة والخط
    final points = <Offset>[];
    for (int i = 0; i < trends.length; i++) {
      final x = i * stepX;
      final normalizedY = (trends[i].returnRate - minRate) / range;
      final y = paddingTop + chartHeight - (normalizedY * chartHeight);
      points.add(Offset(x, y));
    }

    // المنطقة المظللة
    if (points.length >= 2) {
      final areaPath = Path()..moveTo(points.first.dx, size.height - paddingBottom);
      for (final p in points) {
        areaPath.lineTo(p.dx, p.dy);
      }
      areaPath.lineTo(points.last.dx, size.height - paddingBottom);
      areaPath.close();

      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFEF4444).withValues(alpha: 0.2),
            const Color(0xFFEF4444).withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(areaPath, areaPaint);
    }

    // الخط
    final linePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // النقاط
    for (int i = 0; i < points.length; i++) {
      final trendColor = trends[i].trend == TrendDirection.up
          ? const Color(0xFFEF4444)
          : trends[i].trend == TrendDirection.down
              ? const Color(0xFF22C55E)
              : const Color(0xFFF59E0B);

      canvas.drawCircle(
        points[i],
        5,
        Paint()..color = isDark ? const Color(0xFF1E293B) : Colors.white,
      );
      canvas.drawCircle(
        points[i],
        4,
        Paint()..color = trendColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
