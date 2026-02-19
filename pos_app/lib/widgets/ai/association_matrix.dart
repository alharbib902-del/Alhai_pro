/// مصفوفة الارتباطات - Association Matrix
///
/// شبكة/خريطة حرارية لقوة ارتباط أزواج المنتجات باستخدام CustomPaint
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/ai_basket_analysis_service.dart';

/// مصفوفة الارتباطات
class AssociationMatrix extends StatelessWidget {
  final List<ProductAssociation> associations;
  final ValueChanged<ProductAssociation>? onPairTap;

  const AssociationMatrix({
    super.key,
    required this.associations,
    this.onPairTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
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
              const Icon(Icons.grid_on_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'خريطة الارتباطات', // Association Heatmap
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Legend
              _buildLegend(isDark, l10n),
            ],
          ),

          const SizedBox(height: 16),

          // Heatmap grid
          SizedBox(
            height: math.min(associations.length * 56.0, 400),
            child: ListView.separated(
              itemCount: associations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final assoc = associations[index];
                return _AssociationRow(
                  association: assoc,
                  isDark: isDark,
                  onTap: () => onPairTap?.call(assoc),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(
          color: AppColors.success,
          label: l10n.strong,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _LegendItem(
          color: AppColors.warning,
          label: l10n.medium,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _LegendItem(
          color: AppColors.error.withValues(alpha: 0.6),
          label: l10n.weak,
          isDark: isDark,
        ),
      ],
    );
  }
}

/// صف ارتباط - Association Row
class _AssociationRow extends StatefulWidget {
  final ProductAssociation association;
  final bool isDark;
  final VoidCallback? onTap;

  const _AssociationRow({
    required this.association,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_AssociationRow> createState() => _AssociationRowState();
}

class _AssociationRowState extends State<_AssociationRow> {
  bool _isHovered = false;

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.75) return AppColors.success;
    if (confidence >= 0.55) return AppColors.warning;
    return AppColors.error.withValues(alpha: 0.7);
  }

  @override
  Widget build(BuildContext context) {
    final assoc = widget.association;
    final confColor = _getConfidenceColor(assoc.confidence);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.grey50)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Product A
              Expanded(
                flex: 3,
                child: Text(
                  assoc.productAName,
                  style: TextStyle(
                    color: widget.isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.sync_alt_rounded,
                  size: 16,
                  color: widget.isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textMuted,
                ),
              ),

              // Product B
              Expanded(
                flex: 3,
                child: Text(
                  assoc.productBName,
                  style: TextStyle(
                    color: widget.isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // Confidence bar
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: assoc.confidence,
                        backgroundColor: widget.isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.grey200,
                        valueColor: AlwaysStoppedAnimation<Color>(confColor),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(assoc.confidence * 100).toInt()}%',
                      style: TextStyle(
                        color: confColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Frequency badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${assoc.frequency}x',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// عنصر المفتاح - Legend Item
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
