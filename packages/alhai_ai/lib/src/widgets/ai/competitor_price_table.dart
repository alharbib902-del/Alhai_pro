/// جدول مقارنة أسعار المنافسين - Competitor Price Table Widget
///
/// يعرض جدول مقارنة الأسعار بين متجرنا والمنافسين
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_competitor_analysis_service.dart';

/// جدول مقارنة الأسعار
class CompetitorPriceTable extends StatelessWidget {
  final List<PriceComparison> comparisons;
  final ScrollController? scrollController;

  const CompetitorPriceTable({
    super.key,
    required this.comparisons,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (comparisons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows_rounded,
              size: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppColors.textMuted,
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Text(
              'لا توجد بيانات مقارنة',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final competitorNames = comparisons.first.competitorPrices.keys.toList();

    return Container(
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
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              isDark ? const Color(0xFF0F172A) : AppColors.grey50,
            ),
            dataRowColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.primarySurface;
              }
              return null;
            }),
            columnSpacing: 20,
            horizontalMargin: 16,
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            dataTextStyle: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : AppColors.textPrimary,
            ),
            columns: [
              DataColumn(label: Text(l10n.product)),
              DataColumn(label: Text(l10n.productCategory)),
              DataColumn(label: Text(l10n.ourPrice), numeric: true),
              ...competitorNames.map(
                (name) => DataColumn(label: Text(name), numeric: true),
              ),
              const DataColumn(label: Text('متوسط السوق'), numeric: true),
              const DataColumn(label: Text('الفرق %'), numeric: true),
              DataColumn(label: Text(l10n.position)),
            ],
            rows: comparisons.map((comparison) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 160,
                      child: Text(
                        comparison.productName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    _CategoryChip(
                      category: comparison.category,
                      isDark: isDark,
                    ),
                  ),
                  DataCell(
                    Text(
                      '${comparison.ourPrice.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  ...competitorNames.map((name) {
                    final price = comparison.competitorPrices[name] ?? 0;
                    final isHigher = price > comparison.ourPrice;
                    final isLower = price < comparison.ourPrice;
                    return DataCell(
                      Text(
                        price.toStringAsFixed(2),
                        style: TextStyle(
                          color: isLower
                              ? AppColors.error
                              : isHigher
                              ? AppColors.success
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : AppColors.textSecondary),
                          fontWeight: (isLower || isHigher)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                  DataCell(
                    Text(
                      comparison.avgMarketPrice.toStringAsFixed(2),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                  DataCell(
                    _PriceDiffBadge(
                      percent: comparison.priceDifferencePercent,
                      isDark: isDark,
                    ),
                  ),
                  DataCell(
                    _PositionIndicator(
                      position: comparison.position,
                      isDark: isDark,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// شارة التصنيف
class _CategoryChip extends StatelessWidget {
  final String category;
  final bool isDark;

  const _CategoryChip({required this.category, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.info.withValues(alpha: 0.15)
            : AppColors.infoSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.info : const Color(0xFF1D4ED8),
        ),
      ),
    );
  }
}

/// شارة فرق السعر
class _PriceDiffBadge extends StatelessWidget {
  final double percent;
  final bool isDark;

  const _PriceDiffBadge({required this.percent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isNegative = percent < 0;
    final color = isNegative ? AppColors.success : AppColors.error;
    final icon = isNegative
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AlhaiSpacing.xxxs),
          Text(
            '${percent.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// مؤشر الموقف السعري
class _PositionIndicator extends StatelessWidget {
  final PricePosition position;
  final bool isDark;

  const _PositionIndicator({required this.position, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String label;
    Color color;
    IconData icon;

    switch (position) {
      case PricePosition.cheapest:
        label = l10n.cheapest;
        color = AppColors.success;
        icon = Icons.emoji_events_rounded;
      case PricePosition.belowAverage:
        label = 'أقل من المتوسط';
        color = AppColors.primaryLight;
        icon = Icons.thumb_up_rounded;
      case PricePosition.average:
        label = l10n.medium;
        color = AppColors.warning;
        icon = Icons.horizontal_rule_rounded;
      case PricePosition.aboveAverage:
        label = 'أعلى من المتوسط';
        color = AppColors.secondary;
        icon = Icons.trending_up_rounded;
      case PricePosition.mostExpensive:
        label = l10n.mostExpensive;
        color = AppColors.error;
        icon = Icons.warning_rounded;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AlhaiSpacing.xxs),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
