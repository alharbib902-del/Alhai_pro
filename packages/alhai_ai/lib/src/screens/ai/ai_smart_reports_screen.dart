/// شاشة التقارير الذكية - AI Smart Reports Screen
///
/// استعلام بلغة طبيعية في الأعلى، منطقة التقرير المولد، شريط القوالب الجانبي
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../providers/ai_smart_reports_providers.dart';
import '../../widgets/ai/report_query_input.dart';
import '../../widgets/ai/generated_report_view.dart';
import '../../widgets/ai/report_template_card.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

class AiSmartReportsScreen extends ConsumerStatefulWidget {
  const AiSmartReportsScreen({super.key});

  @override
  ConsumerState<AiSmartReportsScreen> createState() => _AiSmartReportsScreenState();
}

class _AiSmartReportsScreenState extends ConsumerState<AiSmartReportsScreen> {
  bool _showTemplates = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
              children: [
                AppHeader(
                  title: AppLocalizations.of(context)!.aiSmartReportsTitle,
                  onMenuTap: !isWideScreen ? () => Scaffold.of(context).openDrawer() : null,
                ),
                Expanded(child: _buildContent(isDark, isWideScreen)),
              ],
            );
  }

  Widget _buildContent(bool isDark, bool isWideScreen) {
    final suggestions = ref.watch(querySuggestionsProvider);
    final generatedReport = ref.watch(generatedReportProvider);
    final templates = ref.watch(reportTemplatesProvider);
    final categoryFilter = ref.watch(templateCategoryFilterProvider);

    final l10n = AppLocalizations.of(context)!;
    final categories = [kAllCategoryFilter, ...templates.map((t) => t.category).toSet()];
    final filteredTemplates = categoryFilter == kAllCategoryFilter
        ? templates
        : templates.where((t) => t.category == categoryFilter).toList();

    return Column(
      children: [
        // Query input
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.md, AlhaiSpacing.mdl, AlhaiSpacing.zero),
          child: ReportQueryInput(
            suggestions: suggestions,
            onSubmit: (query) {
              ref.read(generatedReportProvider.notifier).generateFromQuery(query);
            },
          ),
        ),

        // Main content area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            child: isWideScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Generated report area
                      Expanded(
                        flex: 3,
                        child: _buildReportArea(generatedReport, isDark),
                      ),
                      const SizedBox(width: AlhaiSpacing.mdl),
                      // Templates sidebar
                      if (_showTemplates)
                        SizedBox(
                          width: 320,
                          child: _buildTemplatesSidebar(
                            filteredTemplates, categories, categoryFilter, isDark,
                          ),
                        ),
                    ],
                  )
                : Column(
                    children: [
                      // Toggle templates button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => setState(() => _showTemplates = !_showTemplates),
                            icon: Icon(
                              _showTemplates ? Icons.close_rounded : Icons.dashboard_customize_rounded,
                              size: 18,
                            ),
                            label: Text(_showTemplates ? l10n.hideTemplates : l10n.showTemplates),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                      if (_showTemplates) ...[
                        SizedBox(
                          height: 200,
                          child: _buildTemplatesSidebar(
                            filteredTemplates, categories, categoryFilter, isDark,
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                      ],
                      Expanded(
                        child: _buildReportArea(generatedReport, isDark),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportArea(AsyncValue generatedReport, bool isDark) {
    return generatedReport.when(
      loading: () => _buildLoadingState(isDark),
      error: (e, _) => _buildErrorState(isDark, e.toString()),
      data: (report) {
        if (report == null) {
          return _buildEmptyState(isDark);
        }
        return GeneratedReportView(report: report);
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.mdl),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 48,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.mdl),
            Text(
              AppLocalizations.of(context)!.askAboutStore,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              AppLocalizations.of(context)!.writeQuestionHint,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickAction(AppLocalizations.of(context)!.quickActionTodaySales, Icons.receipt_long_rounded, isDark),
                _buildQuickAction(AppLocalizations.of(context)!.quickActionTop10, Icons.star_rounded, isDark),
                _buildQuickAction(AppLocalizations.of(context)!.quickActionMonthlyCompare, Icons.compare_arrows_rounded, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String text, IconData icon, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(generatedReportProvider.notifier).generateFromQuery(text),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AlhaiSpacing.xs),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                : const Color(0xFF8B5CF6).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              AppLocalizations.of(context)!.analyzingData,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String error) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: AlhaiSpacing.sm),
            Text(AppLocalizations.of(context)!.errorOccurredShort(error),
              style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesSidebar(
    List templates, List<String> categories, String categoryFilter, bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.dashboard_customize_rounded, size: 18, color: Color(0xFF8B5CF6)),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  AppLocalizations.of(context)!.readyTemplates,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Category filter
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == categoryFilter;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat == kAllCategoryFilter ? AppLocalizations.of(context)!.filterAllLabel : cat),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    selectedColor: const Color(0xFF8B5CF6),
                    backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.grey50,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    onSelected: (_) => ref.read(templateCategoryFilterProvider.notifier).state = cat,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsetsDirectional.fromSTEB(14, AlhaiSpacing.xxs, 14, 14),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ReportTemplateCard(
                    template: templates[index],
                    onRun: () {
                      ref.read(generatedReportProvider.notifier)
                          .generateFromTemplate(templates[index].id);
                    },
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
