/// شاشة تصميم العروض بالذكاء الاصطناعي
///
/// تعرض عروض ترويجية مولّدة تلقائياً مع تفاصيل ROI
/// واختبارات A/B لمقارنة العروض
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../providers/ai_promotion_designer_providers.dart';
import '../../services/ai_promotion_designer_service.dart';
import '../../widgets/ai/generated_promotion_card.dart';
import '../../widgets/ai/roi_forecast_chart.dart';
import '../../widgets/ai/ab_test_config_panel.dart';

/// شاشة تصميم العروض الذكية
class AiPromotionDesignerScreen extends ConsumerStatefulWidget {
  const AiPromotionDesignerScreen({super.key});

  @override
  ConsumerState<AiPromotionDesignerScreen> createState() => _AiPromotionDesignerScreenState();
}

class _AiPromotionDesignerScreenState extends ConsumerState<AiPromotionDesignerScreen>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.aiPromotionDesigner,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.defaultUserName,
                  userRole: l10n.branchManager,
                ),
                Container(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark ? Colors.white60 : AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(icon: const Icon(Icons.auto_awesome), text: l10n.aiSuggestedPromotions),
                      Tab(icon: const Icon(Icons.trending_up), text: l10n.aiRoiAnalysis),
                      Tab(icon: const Icon(Icons.science), text: l10n.aiAbTest),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPromotionsTab(isDark, isWideScreen),
                      _buildRoiTab(isDark, isWideScreen),
                      _buildAbTestTab(isDark, isWideScreen),
                    ],
                  ),
                ),
              ],
            );
  }

  // ============================================================================
  // TAB 1: العروض المقترحة
  // ============================================================================

  Widget _buildPromotionsTab(bool isDark, bool isWideScreen) {
    final promotions = ref.watch(filteredPromotionsProvider);
    final totalRevenue = ref.watch(totalProjectedRevenueProvider);
    final avgConfidence = ref.watch(averageConfidenceProvider);
    final selectedFilter = ref.watch(promotionTypeFilterProvider);

    return promotions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final l10n = AppLocalizations.of(context)!;
        return Center(child: Text(l10n.aiErrorOccurred(e.toString())));
      },
      data: (promos) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(isWideScreen ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة AI Header
              _buildAiHeader(isDark, totalRevenue, avgConfidence, promos.length),
              const SizedBox(height: 20),

              // فلتر الأنواع
              _buildTypeFilter(isDark, selectedFilter),
              const SizedBox(height: 16),

              // شبكة العروض
              if (isWideScreen)
                _buildPromotionsGrid(promos, isDark)
              else
                _buildPromotionsList(promos, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiHeader(bool isDark, AsyncValue<double> totalRevenue, AsyncValue<double> avgConfidence, int count) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiSmartPromotionDesigner,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.aiPromotionsGeneratedCount(count),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeaderStat(
                l10n.aiProjectedRevenue,
                totalRevenue.when(
                  data: (v) => '${(v / 1000).toStringAsFixed(0)}K ر.س',
                  loading: () => '...',
                  error: (_, __) => '--',
                ),
                Icons.monetization_on_outlined,
              ),
              const SizedBox(width: 16),
              _buildHeaderStat(
                l10n.aiAiConfidence,
                avgConfidence.when(
                  data: (v) => '${(v * 100).toStringAsFixed(0)}%',
                  loading: () => '...',
                  error: (_, __) => '--',
                ),
                Icons.psychology,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(bool isDark, PromotionType? selected) {
    const types = PromotionType.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(isDark, AppLocalizations.of(context)!.all, null, selected == null),
          ...types.map((type) => _buildFilterChip(
                isDark,
                AiPromotionDesignerService.getPromotionTypeLabel(type),
                type,
                selected == type,
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(bool isDark, String label, PromotionType? type, bool isSelected) {
    final color = type != null
        ? Color(AiPromotionDesignerService.getPromotionTypeColorValue(type))
        : AppColors.primary;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref.read(promotionTypeFilterProvider.notifier).state = type;
        },
        selectedColor: color.withValues(alpha: 0.15),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? color : (isDark ? Colors.white70 : AppColors.textSecondary),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected
              ? color
              : (isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.border),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildPromotionsGrid(List<GeneratedPromotion> promos, bool isDark) {
    final selected = ref.watch(selectedPromotionProvider);
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: promos.map((p) {
        return SizedBox(
          width: 380,
          child: GeneratedPromotionCard(
            promotion: p,
            isSelected: selected?.id == p.id,
            onTap: () {
              ref.read(selectedPromotionProvider.notifier).state = p;
              _tabController.animateTo(1);
            },
            onApply: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.aiPromotionApplied(p.title)),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPromotionsList(List<GeneratedPromotion> promos, bool isDark) {
    final selected = ref.watch(selectedPromotionProvider);
    return Column(
      children: promos.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GeneratedPromotionCard(
            promotion: p,
            isSelected: selected?.id == p.id,
            onTap: () {
              ref.read(selectedPromotionProvider.notifier).state = p;
              _tabController.animateTo(1);
            },
            onApply: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.aiPromotionApplied(p.title)),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  // ============================================================================
  // TAB 2: تحليل ROI
  // ============================================================================

  Widget _buildRoiTab(bool isDark, bool isWideScreen) {
    final l10n = AppLocalizations.of(context)!;
    final selectedPromotion = ref.watch(selectedPromotionProvider);
    final roiForecast = ref.watch(roiForecastProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWideScreen ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تفاصيل العرض المحدد
          if (selectedPromotion != null) ...[
            _buildSelectedPromotionDetail(isDark, selectedPromotion),
            const SizedBox(height: 20),
          ],

          // رسم بياني ROI
          roiForecast.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.aiErrorOccurred(e.toString()))),
            data: (forecasts) => RoiForecastChart(forecasts: forecasts),
          ),

          if (selectedPromotion == null) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.touch_app,
                    color: isDark ? Colors.white38 : AppColors.textMuted,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.aiSelectPromotionForRoi,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedPromotionDetail(bool isDark, GeneratedPromotion promo) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final typeColor = Color(AiPromotionDesignerService.getPromotionTypeColorValue(promo.type));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AiPromotionDesignerService.getPromotionTypeLabel(promo.type),
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.aiConfidencePercent((promo.confidence * 100).toStringAsFixed(0)),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            promo.title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            promo.description,
            style: TextStyle(
              color: subtextColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDetailStat(l10n.aiRevenueLabel, '${promo.projectedRevenue.toStringAsFixed(0)} ر.س', AppColors.success, isDark),
              const SizedBox(width: 12),
              _buildDetailStat(l10n.aiCostLabel, '${promo.projectedCost.toStringAsFixed(0)} ر.س', AppColors.error, isDark),
              const SizedBox(width: 12),
              _buildDetailStat('ROI', '${promo.roi.toStringAsFixed(0)}%', const Color(0xFF8B5CF6), isDark),
              if (promo.discountAmount > 0) ...[
                const SizedBox(width: 12),
                _buildDetailStat(l10n.aiDiscountLabel, '${promo.discountAmount.toStringAsFixed(0)}%', typeColor, isDark),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textMuted,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // TAB 3: اختبار A/B
  // ============================================================================

  Widget _buildAbTestTab(bool isDark, bool isWideScreen) {
    final l10n = AppLocalizations.of(context)!;
    final promoA = ref.watch(abTestPromotionAProvider);
    final promoB = ref.watch(abTestPromotionBProvider);
    final duration = ref.watch(abTestDurationProvider);
    final controlPercent = ref.watch(abTestControlPercentProvider);
    final allPromotions = ref.watch(generatedPromotionsProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWideScreen ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات عن اختبار A/B
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                  : const Color(0xFF8B5CF6).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.aiAbTestDescription,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // لوحة التكوين
          allPromotions.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (promos) => AbTestConfigPanel(
              promotionA: promoA,
              promotionB: promoB,
              testDurationDays: duration,
              controlGroupPercent: controlPercent,
              onDurationChanged: (v) {
                ref.read(abTestDurationProvider.notifier).state = v;
              },
              onControlPercentChanged: (v) {
                ref.read(abTestControlPercentProvider.notifier).state = v;
              },
              availablePromotions: promos,
              onSelectA: (p) {
                ref.read(abTestPromotionAProvider.notifier).state = p;
              },
              onSelectB: (p) {
                ref.read(abTestPromotionBProvider.notifier).state = p;
              },
              onLaunch: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.aiAbTestLaunched),
                    backgroundColor: const Color(0xFF8B5CF6),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
