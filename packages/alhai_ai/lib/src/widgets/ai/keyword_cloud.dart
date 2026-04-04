/// سحابة الكلمات المفتاحية - Keyword Cloud Widget
///
/// Wrap of keyword chips with size/color based on frequency/sentiment
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_sentiment_analysis_service.dart';

/// سحابة الكلمات المفتاحية
class KeywordCloud extends StatelessWidget {
  final List<KeywordData> keywords;

  const KeywordCloud({super.key, required this.keywords});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final maxCount = keywords.map((k) => k.count).reduce(max);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cloud_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الكلمات الأكثر ذكراً',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${keywords.length} كلمة مفتاحية',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Legend
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(
                      color: AppColors.success,
                      label: l10n.positive,
                      isDark: isDark),
                  const SizedBox(width: AlhaiSpacing.sm),
                  _LegendDot(
                      color: AppColors.warning,
                      label: l10n.neutral,
                      isDark: isDark),
                  const SizedBox(width: AlhaiSpacing.sm),
                  _LegendDot(
                      color: AppColors.error,
                      label: l10n.negative,
                      isDark: isDark),
                ],
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.md),

          // Keywords cloud
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: keywords.map((keyword) {
              return _KeywordChip(
                keyword: keyword,
                maxCount: maxCount,
                isDark: isDark,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// شارة نقطة التوضيح
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendDot(
      {required this.color, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AlhaiSpacing.xxs),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// شريحة كلمة مفتاحية
class _KeywordChip extends StatefulWidget {
  final KeywordData keyword;
  final int maxCount;
  final bool isDark;

  const _KeywordChip({
    required this.keyword,
    required this.maxCount,
    required this.isDark,
  });

  @override
  State<_KeywordChip> createState() => _KeywordChipState();
}

class _KeywordChipState extends State<_KeywordChip> {
  bool _isHovered = false;

  Color get _sentimentColor {
    switch (widget.keyword.sentiment) {
      case SentimentScore.veryPositive:
      case SentimentScore.positive:
        return AppColors.success;
      case SentimentScore.neutral:
        return AppColors.warning;
      case SentimentScore.negative:
      case SentimentScore.veryNegative:
        return AppColors.error;
    }
  }

  double get _sizeFactor {
    if (widget.maxCount == 0) return 1;
    return 0.7 + (widget.keyword.count / widget.maxCount) * 0.8;
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = 12.0 * _sizeFactor;
    final paddingH = 10.0 * _sizeFactor;
    final paddingV = 6.0 * _sizeFactor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          color: _isHovered
              ? _sentimentColor.withValues(alpha: 0.2)
              : _sentimentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? _sentimentColor.withValues(alpha: 0.5)
                : _sentimentColor.withValues(alpha: 0.2),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: _sentimentColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.keyword.word,
              style: TextStyle(
                color: _sentimentColor,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
            if (_isHovered) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: _sentimentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.keyword.count}',
                  style: TextStyle(
                    color: _sentimentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
