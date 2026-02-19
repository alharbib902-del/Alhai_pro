/// شاشة توصيات العملاء بالذكاء الاصطناعي - AI Customer Recommendations Screen
///
/// قائمة العملاء، فلتر الشرائح، بطاقات التوصيات، جدول إعادة الشراء
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';
import '../../widgets/ai/recommendation_card.dart';
import '../../widgets/ai/repurchase_timeline.dart';
import '../../widgets/ai/whatsapp_recommendation_dialog.dart';
import '../../providers/ai_customer_recommendations_providers.dart';
import '../../services/ai_customer_recommendations_service.dart';

class AiCustomerRecommendationsScreen extends ConsumerStatefulWidget {
  const AiCustomerRecommendationsScreen({super.key});

  @override
  ConsumerState<AiCustomerRecommendationsScreen> createState() =>
      _AiCustomerRecommendationsScreenState();
}

class _AiCustomerRecommendationsScreenState
    extends ConsumerState<AiCustomerRecommendationsScreen>
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

  Color _getSegmentColor(CustomerSegment segment) {
    switch (segment) {
      case CustomerSegment.vip:
        return const Color(0xFFEAB308);
      case CustomerSegment.regular:
        return AppColors.primary;
      case CustomerSegment.atRisk:
        return AppColors.warning;
      case CustomerSegment.lost:
        return AppColors.error;
      case CustomerSegment.newCustomer:
        return AppColors.info;
    }
  }

  String _getSegmentLabel(CustomerSegment segment) {
    final l10n = AppLocalizations.of(context)!;
    switch (segment) {
      case CustomerSegment.vip:
        return l10n.segmentVip;
      case CustomerSegment.regular:
        return l10n.segmentRegular;
      case CustomerSegment.atRisk:
        return l10n.segmentAtRisk;
      case CustomerSegment.lost:
        return l10n.segmentLost;
      case CustomerSegment.newCustomer:
        return l10n.segmentNewCustomer;
    }
  }

  IconData _getSegmentIcon(CustomerSegment segment) {
    switch (segment) {
      case CustomerSegment.vip:
        return Icons.star_rounded;
      case CustomerSegment.regular:
        return Icons.person_rounded;
      case CustomerSegment.atRisk:
        return Icons.warning_rounded;
      case CustomerSegment.lost:
        return Icons.person_off_rounded;
      case CustomerSegment.newCustomer:
        return Icons.person_add_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
              children: [
                AppHeader(
                  title: AppLocalizations.of(context)!.aiCustomerRecommendationsTitle,
                  onMenuTap: !isWideScreen ? () => Scaffold.of(context).openDrawer() : null,
                ),
                Expanded(child: _buildContent(isDark, isWideScreen)),
              ],
            );
  }

  Widget _buildContent(bool isDark, bool isWideScreen) {
    final segmentsAsync = ref.watch(customerSegmentsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segment summary cards
          segmentsAsync.when(
            data: (segments) => _buildSegmentCards(isDark, segments, isWideScreen),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Text('$e'),
          ),

          const SizedBox(height: 20),

          // Segment filter chips
          _buildSegmentFilters(isDark),

          const SizedBox(height: 20),

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
              tabs: [
                Tab(text: AppLocalizations.of(context)!.tabRecommendations),
                Tab(text: AppLocalizations.of(context)!.tabRepurchase),
                Tab(text: AppLocalizations.of(context)!.tabSegments),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: isWideScreen ? 600 : 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecommendationsTab(isDark, isWideScreen),
                _buildRepurchaseTab(isDark),
                _buildSegmentsDetailTab(isDark, isWideScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentCards(bool isDark, List<SegmentResult> segments, bool isWideScreen) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: segments.map((seg) {
        final color = _getSegmentColor(seg.segment);
        return SizedBox(
          width: isWideScreen
              ? (MediaQuery.of(context).size.width - (isWideScreen ? 380 : 80)) / segments.length - 16
              : double.infinity,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getSegmentIcon(seg.segment), color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSegmentLabel(seg.segment),
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.customerCount(seg.count),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.revenueK((seg.totalRevenue / 1000).toStringAsFixed(1)),
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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
  }

  Widget _buildSegmentFilters(bool isDark) {
    final currentFilter = ref.watch(segmentFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All filter
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: FilterChip(
              selected: currentFilter == null,
              label: Text(AppLocalizations.of(context)!.filterAllLabel),
              onSelected: (_) => ref.read(segmentFilterProvider.notifier).state = null,
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: currentFilter == null ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
                fontSize: 12,
              ),
            ),
          ),
          ...CustomerSegment.values.map((segment) {
            final isSelected = currentFilter == segment;
            final color = _getSegmentColor(segment);
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(_getSegmentLabel(segment)),
                onSelected: (_) => ref.read(segmentFilterProvider.notifier).state = isSelected ? null : segment,
                selectedColor: color.withValues(alpha: 0.15),
                checkmarkColor: color,
                avatar: Icon(_getSegmentIcon(segment), size: 16, color: isSelected ? color : null),
                labelStyle: TextStyle(
                  color: isSelected ? color : (isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
                  fontSize: 12,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab(bool isDark, bool isWideScreen) {
    final recsAsync = ref.watch(filteredCustomerRecommendationsProvider);

    return recsAsync.when(
      data: (recs) {
        return ListView.separated(
          itemCount: recs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final rec = recs[index];
            return _CustomerRecommendationCard(
              recommendation: rec,
              isDark: isDark,
              segmentColor: _getSegmentColor(rec.segment),
              segmentLabel: _getSegmentLabel(rec.segment),
              segmentIcon: _getSegmentIcon(rec.segment),
              onWhatsApp: rec.phone != null
                  ? () {
                      WhatsAppRecommendationDialog.show(
                        context,
                        customerName: rec.customerName,
                        productName: rec.products.isNotEmpty ? rec.products.first.name : '',
                        initialPhone: rec.phone,
                        price: rec.products.isNotEmpty ? rec.products.first.price : null,
                      );
                    }
                  : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  Widget _buildRepurchaseTab(bool isDark) {
    final remindersAsync = ref.watch(repurchaseRemindersProvider);

    return remindersAsync.when(
      data: (reminders) => SingleChildScrollView(
        child: RepurchaseTimeline(
          reminders: reminders,
          onSendWhatsApp: (reminder) {
            WhatsAppRecommendationDialog.show(
              context,
              customerName: reminder.customerName,
              productName: reminder.productName,
              initialPhone: reminder.phone,
              offerMessage: reminder.isOverdue
                  ? AppLocalizations.of(context)!.specialOfferMissYou
                  : AppLocalizations.of(context)!.friendlyReminderPurchase(reminder.productName),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  Widget _buildSegmentsDetailTab(bool isDark, bool isWideScreen) {
    final segmentsAsync = ref.watch(customerSegmentsProvider);

    return segmentsAsync.when(
      data: (segments) {
        return ListView.separated(
          itemCount: segments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final seg = segments[index];
            final color = _getSegmentColor(seg.segment);
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getSegmentIcon(seg.segment), color: color, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        _getSegmentLabel(seg.segment),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.customerCount(seg.count),
                          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _SegmentStat(
                        label: AppLocalizations.of(context)!.totalRevenueLabel,
                        value: AppLocalizations.of(context)!.revenueK((seg.totalRevenue / 1000).toStringAsFixed(1)),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 24),
                      _SegmentStat(
                        label: AppLocalizations.of(context)!.avgSpendStat,
                        value: AppLocalizations.of(context)!.amountSar(seg.avgSpend.toStringAsFixed(0)),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Customer names
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: seg.customers.map((c) {
                      return Chip(
                        label: Text(c.customerName, style: const TextStyle(fontSize: 11)),
                        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.grey50,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.grey200,
                        ),
                      );
                    }).toList(),
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

/// بطاقة توصية العميل - Customer Recommendation Card
class _CustomerRecommendationCard extends StatelessWidget {
  final CustomerRecommendation recommendation;
  final bool isDark;
  final Color segmentColor;
  final String segmentLabel;
  final IconData segmentIcon;
  final VoidCallback? onWhatsApp;

  const _CustomerRecommendationCard({
    required this.recommendation,
    required this.isDark,
    required this.segmentColor,
    required this.segmentLabel,
    required this.segmentIcon,
    this.onWhatsApp,
  });

  String _formatTimeAgo(DateTime date, AppLocalizations l10n) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return l10n.timeAgoToday;
    if (diff.inDays == 1) return l10n.timeAgoYesterday;
    return l10n.timeAgoDays(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer info header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: segmentColor.withValues(alpha: 0.15),
                child: Text(
                  recommendation.customerName.isNotEmpty
                      ? recommendation.customerName[0]
                      : '?',
                  style: TextStyle(
                    color: segmentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.customerName,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          l10n.lastVisitLabel(_formatTimeAgo(recommendation.lastVisit, l10n)),
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.visitCountLabel(recommendation.visitCount),
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Segment badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: segmentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(segmentIcon, size: 12, color: segmentColor),
                    const SizedBox(width: 4),
                    Text(
                      segmentLabel,
                      style: TextStyle(color: segmentColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Spend info
          Row(
            children: [
              Text(
                l10n.avgSpendLabel(recommendation.avgSpend.toStringAsFixed(0)),
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                l10n.totalSpentLabel((recommendation.totalSpent / 1000).toStringAsFixed(1)),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (recommendation.products.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.recommendedProducts,
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendation.products.map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: RecommendationCard(product: product, compact: true),
                )),
          ],

          // WhatsApp button
          if (onWhatsApp != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onWhatsApp,
                icon: const Icon(Icons.message_rounded, size: 16),
                label: Text(l10n.sendWhatsAppOffer),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  side: const BorderSide(color: Color(0xFF25D366)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// إحصائية الشريحة - Segment Stat
class _SegmentStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _SegmentStat({
    required this.label,
    required this.value,
    required this.isDark,
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
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
