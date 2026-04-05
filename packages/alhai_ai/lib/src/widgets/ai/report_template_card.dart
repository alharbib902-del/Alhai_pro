/// بطاقة قالب التقرير - Report Template Card Widget
///
/// بطاقة تعرض اسم القالب ووصفه وآخر تشغيل وزر التشغيل
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_smart_reports_service.dart';

/// بطاقة قالب التقرير
class ReportTemplateCard extends StatefulWidget {
  final ReportTemplate template;
  final VoidCallback onRun;

  const ReportTemplateCard({
    super.key,
    required this.template,
    required this.onRun,
  });

  @override
  State<ReportTemplateCard> createState() => _ReportTemplateCardState();
}

class _ReportTemplateCardState extends State<ReportTemplateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    IconData chartIcon;
    Color chartColor;
    switch (widget.template.chartType) {
      case ChartType.barChart:
        chartIcon = Icons.bar_chart_rounded;
        chartColor = const Color(0xFF8B5CF6);
      case ChartType.lineChart:
        chartIcon = Icons.show_chart_rounded;
        chartColor = const Color(0xFF3B82F6);
      case ChartType.pieChart:
        chartIcon = Icons.pie_chart_rounded;
        chartColor = const Color(0xFF10B981);
      case ChartType.table:
        chartIcon = Icons.table_chart_rounded;
        chartColor = const Color(0xFFF97316);
      case ChartType.number:
        chartIcon = Icons.pin_rounded;
        chartColor = const Color(0xFFEF4444);
      case ChartType.heatmap:
        chartIcon = Icons.grid_on_rounded;
        chartColor = const Color(0xFF14B8A6);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? chartColor.withValues(alpha: 0.4)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.border),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? chartColor.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: _isHovered ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: chartColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(chartIcon, color: chartColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.template.nameAr,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.template.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: chartColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              widget.template.descriptionAr,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textMuted,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AlhaiSpacing.sm),

            // Footer
            Row(
              children: [
                // Last run
                if (widget.template.lastRun != null) ...[
                  Icon(Icons.schedule_rounded,
                      size: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : AppColors.textMuted),
                  const SizedBox(width: AlhaiSpacing.xxs),
                  Text(
                    _formatLastRun(widget.template.lastRun!),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                // Run count
                Icon(Icons.replay_rounded,
                    size: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.textMuted),
                const SizedBox(width: AlhaiSpacing.xxs),
                Text(
                  '${widget.template.runCount} مرة',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                // Run button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onRun,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.sm, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            chartColor,
                            chartColor.withValues(alpha: 0.8)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: chartColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: AlhaiSpacing.xxs),
                          Text(
                            l10n.run,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastRun(DateTime lastRun) {
    final diff = DateTime.now().difference(lastRun);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
