/// بطاقة نتيجة التعرف - Recognition Result Card Widget
///
/// عرض المنتج المطابق مع شريط الثقة وصورة المنتج وأزرار قبول/رفض
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../services/ai_product_recognition_service.dart';

/// بطاقة نتيجة التعرف
class RecognitionResultCard extends StatefulWidget {
  final RecognizedProduct product;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const RecognitionResultCard({
    super.key,
    required this.product,
    this.onAccept,
    this.onReject,
    this.onTap,
  });

  @override
  State<RecognitionResultCard> createState() => _RecognitionResultCardState();
}

class _RecognitionResultCardState extends State<RecognitionResultCard> {
  bool _isHovered = false;

  Color get _statusColor {
    switch (widget.product.status) {
      case RecognitionStatus.matched:
        return AppColors.success;
      case RecognitionStatus.partialMatch:
        return AppColors.warning;
      case RecognitionStatus.unrecognized:
        return AppColors.error;
      case RecognitionStatus.newProduct:
        return AppColors.info;
    }
  }

  String get _statusLabel =>
      AiProductRecognitionService.getStatusLabel(widget.product.status);

  IconData get _statusIcon {
    switch (widget.product.status) {
      case RecognitionStatus.matched:
        return Icons.check_circle_rounded;
      case RecognitionStatus.partialMatch:
        return Icons.help_rounded;
      case RecognitionStatus.unrecognized:
        return Icons.error_rounded;
      case RecognitionStatus.newProduct:
        return Icons.add_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confidence = (widget.product.confidence * 100).toInt();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? _statusColor.withValues(alpha: 0.4)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.border),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? _statusColor.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: _isHovered ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: [
              // Product image placeholder
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_rounded,
                      color: _statusColor.withValues(alpha: 0.5),
                      size: 24,
                    ),
                    const SizedBox(height: AlhaiSpacing.xxxs),
                    Text(
                      '$confidence%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.nameAr,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.xs,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon, size: 12, color: _statusColor),
                              const SizedBox(width: AlhaiSpacing.xxs),
                              Text(
                                _statusLabel,
                                style: TextStyle(
                                  color: _statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Details row
                    Row(
                      children: [
                        if (widget.product.barcode != null) ...[
                          Icon(
                            Icons.qr_code_rounded,
                            size: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: AlhaiSpacing.xxs),
                          Text(
                            widget.product.barcode!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: AlhaiSpacing.sm),
                        ],
                        if (widget.product.category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: AlhaiSpacing.xxxs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.product.category!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AlhaiSpacing.xs),

                    // Confidence bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: widget.product.confidence,
                              minHeight: 5,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : AppColors.grey200,
                              valueColor: AlwaysStoppedAnimation(_statusColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: AlhaiSpacing.xs),
                        if (widget.product.suggestedPrice != null)
                          Text(
                            '${widget.product.suggestedPrice!.toStringAsFixed(2)} ر.س',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Accept/Reject buttons
              Column(
                children: [
                  _ActionButton(
                    icon: Icons.check_rounded,
                    color: AppColors.success,
                    onTap: widget.onAccept,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _ActionButton(
                    icon: Icons.close_rounded,
                    color: AppColors.error,
                    onTap: widget.onReject,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر إجراء صغير
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.xs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
