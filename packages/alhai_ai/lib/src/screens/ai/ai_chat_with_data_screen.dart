/// شاشة المحادثة مع البيانات بالذكاء الاصطناعي
///
/// واجهة محادثة تتيح استعلام البيانات باللغة الطبيعية
/// مع عرض النتائج كأرقام أو جداول أو رسوم بيانية
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../providers/ai_chat_with_data_providers.dart';
import '../../widgets/ai/data_query_input.dart';
import '../../widgets/ai/query_result_view.dart';
import '../../widgets/ai/query_history_panel.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// شاشة المحادثة مع البيانات
class AiChatWithDataScreen extends ConsumerStatefulWidget {
  const AiChatWithDataScreen({super.key});

  @override
  ConsumerState<AiChatWithDataScreen> createState() => _AiChatWithDataScreenState();
}

class _AiChatWithDataScreenState extends ConsumerState<AiChatWithDataScreen> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.aiChatWithData,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.defaultUserName,
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: _buildContent(isDark, isWideScreen),
                ),
              ],
            );
  }

  Widget _buildContent(bool isDark, bool isWideScreen) {
    final currentResult = ref.watch(currentQueryResultProvider);
    final isLoading = ref.watch(isQueryLoadingProvider);
    final history = ref.watch(queryHistoryProvider);
    final suggestions = ref.watch(suggestedQueriesProvider);

    if (isWideScreen) {
      return Row(
        children: [
          // القسم الرئيسي
          Expanded(
            flex: 3,
            child: _buildMainArea(isDark, currentResult, isLoading, suggestions, isWideScreen),
          ),
          // لوحة السجل الجانبية
          SizedBox(
            width: 350,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.zero, AlhaiSpacing.md, AlhaiSpacing.md, AlhaiSpacing.md),
              child: QueryHistoryPanel(
                history: history,
                onRerun: _executeQuery,
                onClearAll: () {
                  ref.read(clearHistoryActionProvider)();
                },
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        _buildMainArea(isDark, currentResult, isLoading, suggestions, isWideScreen),
        if (_showHistory)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showHistory = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox(
                    width: 320,
                    child: QueryHistoryPanel(
                      history: history,
                      onRerun: (query) {
                        setState(() => _showHistory = false);
                        _executeQuery(query);
                      },
                      onClearAll: () {
                        ref.read(clearHistoryActionProvider)();
                      },
                      onClose: () => setState(() => _showHistory = false),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainArea(
    bool isDark,
    dynamic currentResult,
    bool isLoading,
    List<String> suggestions,
    bool isWideScreen,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isWideScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان AI
          _buildAiBanner(isDark),
          const SizedBox(height: AlhaiSpacing.mdl),

          // حقل الإدخال
          DataQueryInput(
            suggestions: suggestions,
            onSubmit: _executeQuery,
            onHistoryTap: isWideScreen
                ? null
                : () => setState(() => _showHistory = true),
            isLoading: isLoading,
          ),

          const SizedBox(height: AlhaiSpacing.lg),

          // النتيجة أو الاقتراحات
          if (currentResult != null) ...[
            QueryResultView(result: currentResult),
          ] else ...[
            _buildWelcomeArea(isDark, suggestions, isWideScreen),
          ],
        ],
      ),
    );
  }

  Widget _buildAiBanner(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
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
              Icons.chat,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiChatWithYourData,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  l10n.aiAskAboutDataInArabic,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AlhaiSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeArea(bool isDark, List<String> suggestions, bool isWideScreen) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان الاقتراحات
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
            const SizedBox(width: AlhaiSpacing.xs),
            Text(
              l10n.aiTrySampleQuestions,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.md),

        // شبكة الاقتراحات
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: suggestions.asMap().entries.map((entry) {
            final idx = entry.key;
            final query = entry.value;
            final colors = [
              const Color(0xFF10B981),
              const Color(0xFF3B82F6),
              const Color(0xFF8B5CF6),
              const Color(0xFFF59E0B),
              const Color(0xFFEF4444),
              const Color(0xFFEC4899),
              const Color(0xFF06B6D4),
              const Color(0xFF14B8A6),
              const Color(0xFFF97316),
              const Color(0xFF6366F1),
            ];
            final color = colors[idx % colors.length];
            final icons = [
              Icons.monetization_on_outlined,
              Icons.emoji_events,
              Icons.calendar_view_week,
              Icons.payment,
              Icons.compare_arrows,
              Icons.people_outline,
              Icons.receipt_long,
              Icons.inventory_2_outlined,
              Icons.date_range,
              Icons.access_time,
            ];
            final icon = icons[idx % icons.length];

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _executeQuery(query),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: isWideScreen ? 280 : double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Expanded(
                        child: Text(
                          query,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: subtextColor,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AlhaiSpacing.xl),

        // نصيحة
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.info.withValues(alpha: 0.1)
                : AppColors.infoSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiTip,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      l10n.aiTipDescription,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _executeQuery(String query) async {
    final executeQuery = ref.read(executeQueryActionProvider);
    await executeQuery(query);
  }
}
