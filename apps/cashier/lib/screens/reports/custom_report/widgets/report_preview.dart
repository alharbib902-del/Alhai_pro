/// عرض نتائج التقرير: بطاقات ملخص + جدول + حالة فارغة
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../providers/report_data_provider.dart';

class ReportPreview extends StatelessWidget {
  final ReportResult result;
  final bool isWideScreen;
  final bool isMediumScreen;
  final bool isDark;

  const ReportPreview({
    super.key,
    required this.result,
    required this.isWideScreen,
    required this.isMediumScreen,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (result.rows.isEmpty) {
      return _EmptyState(isDark: isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isWideScreen)
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: l10n.total,
                  value: '${result.totalValue.toStringAsFixed(0)} ${l10n.sar}',
                  icon: Icons.monetization_on_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: _SummaryCard(
                  label: l10n.count,
                  value: '${result.totalCount}',
                  icon: Icons.format_list_numbered_rounded,
                  color: AppColors.info,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: _SummaryCard(
                  label: l10n.periods,
                  value: '${result.rows.length}',
                  icon: Icons.calendar_view_day_rounded,
                  color: AppColors.purple,
                  isDark: isDark,
                ),
              ),
            ],
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _SummaryCard(
                      label: l10n.total,
                      value:
                          '${result.totalValue.toStringAsFixed(0)} ${l10n.sar}',
                      icon: Icons.monetization_on_rounded,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _SummaryCard(
                      label: l10n.count,
                      value: '${result.totalCount}',
                      icon: Icons.format_list_numbered_rounded,
                      color: AppColors.info,
                      isDark: isDark,
                    ),
                  ),
                ],
              );
            },
          ),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _ResultsTable(
          rows: result.rows,
          totalValue: result.totalValue,
          totalCount: result.totalCount,
          isMediumScreen: isMediumScreen,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextMuted(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final double totalValue;
  final int totalCount;
  final bool isMediumScreen;
  final bool isDark;

  const _ResultsTable({
    required this.rows,
    required this.totalValue,
    required this.totalCount,
    required this.isMediumScreen,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMediumScreen ? 20 : 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.periodLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.count,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.valueLabel,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
                if (isMediumScreen)
                  Expanded(
                    flex: 2,
                    child: Text(
                      l10n.percentage,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Rows
          ...List.generate(rows.length, (index) {
            final row = rows[index];
            final label = row['label'] as String? ?? '';
            final value = row['value'] as double? ?? 0;
            final rawCount = row['count'];
            final count = rawCount is int
                ? rawCount
                : (rawCount is double ? rawCount.toInt() : 0);
            final percentage = totalValue > 0
                ? (value / totalValue * 100).toStringAsFixed(1)
                : '0.0';
            final isEven = index % 2 == 0;

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMediumScreen ? 20 : 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: isEven
                    ? Colors.transparent
                    : AppColors.getSurfaceVariant(
                        isDark,
                      ).withValues(alpha: 0.4),
                border: Border(
                  bottom: index < rows.length - 1
                      ? BorderSide(
                          color: AppColors.getBorder(
                            isDark,
                          ).withValues(alpha: 0.5),
                        )
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${value.toStringAsFixed(0)} ${l10n.sar}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ),
                  if (isMediumScreen)
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AlhaiSpacing.xs,
                              vertical: AlhaiSpacing.xxxs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$percentage%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
          // Total row
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMediumScreen ? 20 : 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.total,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '$totalCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${totalValue.toStringAsFixed(0)} ${l10n.sar}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (isMediumScreen)
                  const Expanded(
                    flex: 2,
                    child: Text(
                      '100%',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.xxxl),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              l10n.noData,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              l10n.tryDifferentFilters,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
