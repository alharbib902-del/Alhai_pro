/// حقل استعلام التقارير - Report Query Input Widget
///
/// حقل إدخال مع اقتراحات منسدلة واستعلامات نموذجية
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_smart_reports_service.dart';

/// حقل استعلام التقارير الذكية
class ReportQueryInput extends StatefulWidget {
  final List<QuerySuggestion> suggestions;
  final ValueChanged<String> onSubmit;
  final String? initialQuery;

  const ReportQueryInput({
    super.key,
    required this.suggestions,
    required this.onSubmit,
    this.initialQuery,
  });

  @override
  State<ReportQueryInput> createState() => _ReportQueryInputState();
}

class _ReportQueryInputState extends State<ReportQueryInput> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<QuerySuggestion> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _filteredSuggestions = widget.suggestions;
    _focusNode.addListener(() {
      setState(() => _showSuggestions =
          _focusNode.hasFocus && _filteredSuggestions.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = widget.suggestions;
      } else {
        _filteredSuggestions = widget.suggestions.where((s) {
          return s.text.contains(query) || s.category.contains(query);
        }).toList();
      }
      _showSuggestions = _focusNode.hasFocus && _filteredSuggestions.isNotEmpty;
    });
  }

  void _submit(String query) {
    if (query.trim().isNotEmpty) {
      widget.onSubmit(query.trim());
      _focusNode.unfocus();
      setState(() => _showSuggestions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input field
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? const Color(0xFF8B5CF6)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.border),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: [
              if (_focusNode.hasFocus)
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 14, start: 8),
                child: Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _filterSuggestions,
                  onSubmitted: _submit,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اسأل عن أي تقرير... مثل "كم مبيعات اليوم؟"',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : AppColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _submit(_controller.text),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          l10n.analysis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Suggestions dropdown
        if (_showSuggestions) ...[
          const SizedBox(height: AlhaiSpacing.xxs),
          Container(
            constraints: const BoxConstraints(maxHeight: 260),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: _filteredSuggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.grey100,
              ),
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return _SuggestionItem(
                  suggestion: suggestion,
                  isDark: isDark,
                  onTap: () {
                    _controller.text = suggestion.text;
                    _submit(suggestion.text);
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// عنصر اقتراح
class _SuggestionItem extends StatefulWidget {
  final QuerySuggestion suggestion;
  final bool isDark;
  final VoidCallback onTap;

  const _SuggestionItem({
    required this.suggestion,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SuggestionItem> createState() => _SuggestionItemState();
}

class _SuggestionItemState extends State<_SuggestionItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    IconData chartIcon;
    switch (widget.suggestion.expectedChart) {
      case ChartType.barChart:
        chartIcon = Icons.bar_chart_rounded;
      case ChartType.lineChart:
        chartIcon = Icons.show_chart_rounded;
      case ChartType.pieChart:
        chartIcon = Icons.pie_chart_rounded;
      case ChartType.table:
        chartIcon = Icons.table_chart_rounded;
      case ChartType.number:
        chartIcon = Icons.pin_rounded;
      case ChartType.heatmap:
        chartIcon = Icons.grid_on_rounded;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: _hovered
            ? (widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.grey50)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    size: 16,
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.suggestion.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: AlhaiSpacing.xxxs),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(chartIcon, size: 12, color: const Color(0xFF8B5CF6)),
                      const SizedBox(width: AlhaiSpacing.xxs),
                      Text(
                        widget.suggestion.category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
