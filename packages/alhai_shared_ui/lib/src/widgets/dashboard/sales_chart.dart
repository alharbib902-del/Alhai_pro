/// Sales Chart Widget - رسم بياني للمبيعات
///
/// رسم بياني يعرض المبيعات بأنماط مختلفة
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/utils/currency_formatter.dart';

/// نقطة بيانات
class ChartDataPoint {
  final String label;
  final double value;
  final DateTime? date;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.date,
  });
}

/// نوع الفترة الزمنية
enum ChartPeriod {
  /// أسبوعي
  weekly,

  /// شهري
  monthly,

  /// سنوي
  yearly,
}

/// رسم بياني شريطي محسّن
class SimpleBarChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final Color? barColor;
  final double height;
  final bool showLabels;

  const SimpleBarChart({
    super.key,
    required this.data,
    this.barColor,
    this.height = 250,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            AppLocalizations.of(context)?.noData ?? 'No data',
            style: TextStyle(
              color:
                  isDark ? Colors.white.withAlpha(128) : AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final maxValue = data.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final effectiveColor = barColor ?? AppColors.primary;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barAreaHeight = height - (showLabels ? 32 : 0);
          final barWidth = (constraints.maxWidth / data.length) * 0.5;
          final gridColor = isDark ? AppColors.borderDark : AppColors.border;
          final textColor =
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

          return Column(
            children: [
              // منطقة الرسم مع الشبكة
              Expanded(
                child: Stack(
                  children: [
                    // خطوط الشبكة الأفقية
                    ...List.generate(5, (i) {
                      final y = (barAreaHeight / 4) * i;
                      return Positioned(
                        top: y,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1,
                          color: gridColor,
                        ),
                      );
                    }),
                    // الأعمدة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: data.map((point) {
                        final percentage =
                            maxValue > 0 ? point.value / maxValue : 0.0;
                        return Tooltip(
                          message:
                              '${point.label}: ${_formatValue(point.value)}',
                          child: AnimatedContainer(
                            duration: context.prefersReducedMotion
                                ? Duration.zero
                                : const Duration(milliseconds: 400),
                            curve: AlhaiMotion.standardDecelerate,
                            width: barWidth.clamp(20.0, 48.0),
                            height: (barAreaHeight - 8) * percentage,
                            decoration: BoxDecoration(
                              color: effectiveColor.withValues(alpha: 0.8),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // التسميات
              if (showLabels)
                SizedBox(
                  height: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: data.map((point) {
                      return Text(
                        point.label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

/// كارت الرسم البياني مع العنوان وأزرار الفترة
class SalesChartCard extends StatefulWidget {
  final Map<ChartPeriod, List<ChartDataPoint>> data;
  final ChartPeriod initialPeriod;
  final String title;
  final String? subtitle;
  final ValueChanged<ChartPeriod>? onPeriodChanged;

  const SalesChartCard({
    super.key,
    required this.data,
    this.initialPeriod = ChartPeriod.weekly,
    this.title = '',
    this.subtitle,
    this.onPeriodChanged,
  });

  @override
  State<SalesChartCard> createState() => _SalesChartCardState();
}

class _SalesChartCardState extends State<SalesChartCard> {
  late ChartPeriod _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
  }

  String _getPeriodLabel(ChartPeriod period, AppLocalizations l10n) {
    switch (period) {
      case ChartPeriod.weekly:
        return l10n.weekly;
      case ChartPeriod.monthly:
        return l10n.monthly;
      case ChartPeriod.yearly:
        return l10n.yearly;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currentData = widget.data[_selectedPeriod] ?? [];
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            BorderRadius.circular(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(13)
              : AppColors.border.withAlpha(128),
        ),
        boxShadow: AppShadows.of(context, size: ShadowSize.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الهيدر
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title.isNotEmpty ? widget.title : l10n.salesAnalysis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withAlpha(128)
                            : AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),

              // أزرار الفترة - pill style
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xxs),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ChartPeriod.values.map((period) {
                    final isSelected = period == _selectedPeriod;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedPeriod = period);
                        widget.onPeriodChanged?.call(period);
                      },
                      child: AnimatedContainer(
                        duration: context.prefersReducedMotion
                            ? Duration.zero
                            : AlhaiDurations.standard,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.sm,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (Theme.of(context).colorScheme.surface)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected
                              ? AppShadows.of(context, size: ShadowSize.sm)
                              : null,
                        ),
                        child: Text(
                          _getPeriodLabel(period, l10n),
                          style: TextStyle(
                            color: isSelected
                                ? (Theme.of(context).colorScheme.onSurface)
                                : (isDark
                                    ? Colors.white.withAlpha(102)
                                    : AppColors.textSecondary),
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),

          // الرسم البياني الشريطي
          SimpleBarChart(
            data: currentData,
            height: isMobile ? 200 : 280,
          ),
        ],
      ),
    );
  }
}

/// قائمة الأكثر مبيعاً
class TopProductsList extends StatelessWidget {
  final List<TopProductItem> products;
  final String title;
  final int maxItems;
  final void Function(String productId)? onProductTap;

  const TopProductsList({
    super.key,
    required this.products,
    this.title = '',
    this.maxItems = 3,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final displayProducts = products.take(maxItems).toList();

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(13)
              : AppColors.border.withAlpha(128),
        ),
        boxShadow: AppShadows.of(context, size: ShadowSize.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isNotEmpty ? title : l10n.topSelling,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: AlhaiSpacing.md),

          // القائمة بدون ترتيب
          ...displayProducts.asMap().entries.map((entry) {
            return _TopProductRow(
              product: entry.value,
              isLast: entry.key == displayProducts.length - 1,
              onTap: entry.value.id != null && onProductTap != null
                  ? () => onProductTap!(entry.value.id!)
                  : null,
            );
          }),
        ],
      ),
    );
  }
}

/// عنصر منتج في القائمة
class TopProductItem {
  final String? id;
  final String name;
  final String? imageUrl;
  final IconData? icon;
  final int quantity;
  final double revenue;
  final String? quantityLabel;

  const TopProductItem({
    this.id,
    required this.name,
    this.imageUrl,
    this.icon,
    required this.quantity,
    required this.revenue,
    this.quantityLabel,
  });
}

class _TopProductRow extends StatelessWidget {
  final TopProductItem product;
  final bool isLast;
  final VoidCallback? onTap;

  const _TopProductRow({
    required this.product,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color:
                        isDark ? Colors.white.withAlpha(26) : AppColors.border,
                  ),
                ),
        ),
        child: Row(
          children: [
            // أيقونة المنتج
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.icon != null
                  ? Icon(
                      product.icon,
                      color: isDark
                          ? Colors.white.withAlpha(128)
                          : AppColors.textTertiary,
                      size: 20,
                    )
                  : Icon(
                      Icons.inventory_2_outlined,
                      color: isDark
                          ? Colors.white.withAlpha(128)
                          : AppColors.textTertiary,
                      size: 20,
                    ),
            ),

            SizedBox(width: AlhaiSpacing.sm),

            // الاسم والكمية
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    product.quantityLabel ??
                        '${product.quantity} ${l10n.ordersText}',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withAlpha(102)
                          : AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // الإيرادات
            Text(
              CurrencyFormatter.formatCompactWithContext(
                  context, product.revenue),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
