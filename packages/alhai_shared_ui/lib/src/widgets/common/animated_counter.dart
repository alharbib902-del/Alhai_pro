/// Animated Counter Widget - عداد متحرك
///
/// يعرض رقماً بتأثير عد تصاعدي/تنازلي متحرك
/// مثالي لعرض الإحصائيات والأرقام الكبيرة
library;

import 'package:flutter/material.dart';
import 'package:alhai_core/alhai_core.dart' show StoreSettings;
import 'package:alhai_design_system/alhai_design_system.dart';

/// عداد متحرك
class AnimatedCounter extends StatefulWidget {
  /// القيمة النهائية
  final double value;

  /// مدة الحركة
  final Duration duration;

  /// منحنى الحركة
  final Curve curve;

  /// نمط النص
  final TextStyle? style;

  /// البادئة (مثل: ر.س)
  final String? prefix;

  /// اللاحقة
  final String? suffix;

  /// عدد الأرقام العشرية
  final int decimalPlaces;

  /// فاصل الآلاف
  final bool useThousandSeparator;

  /// لون التغيير الإيجابي
  final Color? positiveColor;

  /// لون التغيير السلبي
  final Color? negativeColor;

  /// إظهار تأثير التغيير
  final bool showChangeEffect;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 800),
    this.curve = AlhaiMotion.standardDecelerate,
    this.style,
    this.prefix,
    this.suffix,
    this.decimalPlaces = 0,
    this.useThousandSeparator = true,
    this.positiveColor,
    this.negativeColor,
    this.showChangeEffect = false,
  });

  /// عداد للعملة السعودية
  factory AnimatedCounter.currency({
    Key? key,
    required double value,
    Duration duration = const Duration(milliseconds: 800),
    TextStyle? style,
    bool showChangeEffect = false,
  }) {
    return AnimatedCounter(
      key: key,
      value: value,
      duration: duration,
      style: style,
      suffix: ' ${StoreSettings.defaultCurrencySymbol}',
      decimalPlaces: 2,
      showChangeEffect: showChangeEffect,
    );
  }

  /// عداد بسيط للأرقام الصحيحة
  factory AnimatedCounter.integer({
    Key? key,
    required int value,
    Duration duration = const Duration(milliseconds: 600),
    TextStyle? style,
    String? suffix,
    bool showChangeEffect = false,
  }) {
    return AnimatedCounter(
      key: key,
      value: value.toDouble(),
      duration: duration,
      style: style,
      suffix: suffix,
      decimalPlaces: 0,
      showChangeEffect: showChangeEffect,
    );
  }

  /// عداد للنسبة المئوية
  factory AnimatedCounter.percentage({
    Key? key,
    required double value,
    Duration duration = const Duration(milliseconds: 600),
    TextStyle? style,
    bool showChangeEffect = true,
  }) {
    return AnimatedCounter(
      key: key,
      value: value,
      duration: duration,
      style: style,
      suffix: '%',
      decimalPlaces: 1,
      showChangeEffect: showChangeEffect,
    );
  }

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  static final _thousandSeparatorRegExp =
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;
  bool _isIncreasing = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _setupAnimation();
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration =
        context.prefersReducedMotion ? Duration.zero : widget.duration;
  }

  void _setupAnimation() {
    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _isIncreasing = widget.value > _previousValue;
      _setupAnimation();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double number) {
    String formatted;
    if (widget.decimalPlaces == 0) {
      formatted = number.round().toString();
    } else {
      formatted = number.toStringAsFixed(widget.decimalPlaces);
    }

    if (widget.useThousandSeparator) {
      final parts = formatted.split('.');
      final intPart = parts[0].replaceAllMapped(
        _thousandSeparatorRegExp,
        (Match m) => '${m[1]},',
      );
      formatted = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    }

    return '${widget.prefix ?? ''}$formatted${widget.suffix ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final displayValue = _animation.value;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: context.prefersReducedMotion
              ? Duration.zero
              : AlhaiDurations.standard,
          builder: (context, scaleValue, _) {
            Color? textColor;
            if (widget.showChangeEffect && _controller.isAnimating) {
              textColor = _isIncreasing
                  ? (widget.positiveColor ?? AppColors.success)
                  : (widget.negativeColor ?? AppColors.error);
            }

            return Transform.scale(
              scale: widget.showChangeEffect && _controller.isAnimating
                  ? 1.0 + (0.05 * (1 - _controller.value))
                  : 1.0,
              child: Text(
                _formatNumber(displayValue),
                style: (widget.style ?? const TextStyle()).copyWith(
                  color: textColor ?? widget.style?.color,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// عداد دائري متحرك
class AnimatedCircularCounter extends StatefulWidget {
  /// القيمة الحالية (0-100)
  final double value;

  /// القيمة القصوى
  final double maxValue;

  /// لون التقدم
  final Color? progressColor;

  /// لون الخلفية
  final Color? backgroundColor;

  /// سمك الخط
  final double strokeWidth;

  /// حجم الدائرة
  final double size;

  /// النص المركزي
  final Widget? center;

  /// مدة الحركة
  final Duration duration;

  const AnimatedCircularCounter({
    super.key,
    required this.value,
    this.maxValue = 100,
    this.progressColor,
    this.backgroundColor,
    this.strokeWidth = 8,
    this.size = 100,
    this.center,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCircularCounter> createState() =>
      _AnimatedCircularCounterState();
}

class _AnimatedCircularCounterState extends State<AnimatedCircularCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value / widget.maxValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AlhaiMotion.standardDecelerate,
    ));

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration =
        context.prefersReducedMotion ? Duration.zero : widget.duration;
  }

  @override
  void didUpdateWidget(AnimatedCircularCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: oldWidget.value / widget.maxValue,
        end: widget.value / widget.maxValue,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AlhaiMotion.standardDecelerate,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = widget.progressColor ?? AppColors.primary;
    final backgroundColor = widget.backgroundColor ?? AppColors.grey200;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // خلفية
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: backgroundColor,
                  valueColor: AlwaysStoppedAnimation(backgroundColor),
                ),
              ),
              // التقدم
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // المحتوى المركزي
              if (widget.center != null)
                widget.center!
              else
                Text(
                  '${(widget.value).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: widget.size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// شريط تقدم متحرك
class AnimatedProgressBar extends StatefulWidget {
  /// القيمة الحالية (0-1)
  final double value;

  /// لون الشريط
  final Color? color;

  /// لون الخلفية
  final Color? backgroundColor;

  /// ارتفاع الشريط
  final double height;

  /// نصف قطر الحواف
  final double borderRadius;

  /// مدة الحركة
  final Duration duration;

  /// إظهار النسبة
  final bool showPercentage;

  /// Gradient للون
  final Gradient? gradient;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius = 4,
    this.duration = const Duration(milliseconds: 600),
    this.showPercentage = false,
    this.gradient,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AlhaiMotion.standardDecelerate,
    ));

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration =
        context.prefersReducedMotion ? Duration.zero : widget.duration;
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: oldWidget.value.clamp(0.0, 1.0),
        end: widget.value.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AlhaiMotion.standardDecelerate,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = widget.color ?? AppColors.primary;
    final backgroundColor = widget.backgroundColor ?? AppColors.grey200;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showPercentage) ...[
              Text(
                '${(_animation.value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.end,
              ),
              SizedBox(height: AlhaiSpacing.xxs),
            ],
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.gradient == null ? progressColor : null,
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
