/// حقل إدخال الاستعلام
///
/// حقل نصي مع اقتراحات تلقائية وزر تنفيذ وأيقونة السجل
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// حقل إدخال الاستعلام
class DataQueryInput extends StatefulWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onHistoryTap;
  final bool isLoading;

  const DataQueryInput({
    super.key,
    required this.suggestions,
    required this.onSubmit,
    this.onHistoryTap,
    this.isLoading = false,
  });

  @override
  State<DataQueryInput> createState() => _DataQueryInputState();
}

class _DataQueryInputState extends State<DataQueryInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = widget.suggestions;
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && _controller.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {
      if (text.isEmpty) {
        _filteredSuggestions = widget.suggestions;
        _showSuggestions = _focusNode.hasFocus;
      } else {
        _filteredSuggestions =
            widget.suggestions.where((s) => s.contains(text)).toList();
        _showSuggestions = _filteredSuggestions.isNotEmpty;
      }
    });
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
    setState(() => _showSuggestions = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // حقل الإدخال
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.border),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: [
              if (_focusNode.hasFocus)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // أيقونة AI
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 14, start: 8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

              // الحقل النصي
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onTextChanged,
                  onSubmitted: (_) => _submit(),
                  textInputAction: TextInputAction.search,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اسأل عن بياناتك... مثال: كم مبيعات اليوم؟',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppColors.textMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                  ),
                ),
              ),

              // زر السجل
              if (widget.onHistoryTap != null)
                IconButton(
                  onPressed: widget.onHistoryTap,
                  icon: Icon(
                    Icons.history,
                    color: isDark ? Colors.white54 : AppColors.textMuted,
                    size: 20,
                  ),
                  tooltip: 'سجل الاستعلامات',
                ),

              // زر التنفيذ
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(start: AlhaiSpacing.xs),
                child: widget.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AlhaiSpacing.sm),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: _submit,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),

        // الاقتراحات
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _controller.text = suggestion;
                      setState(() => _showSuggestions = false);
                      widget.onSubmit(suggestion);
                      _controller.clear();
                      _focusNode.unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color:
                                isDark ? Colors.white38 : AppColors.textMuted,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.north_west,
                            color: isDark ? Colors.white24 : AppColors.grey300,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
