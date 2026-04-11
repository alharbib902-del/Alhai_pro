/// Shimmer Loading Widget - تأثير التحميل اللامع
///
/// يوفر تأثير shimmer احترافي للتحميل
/// مع دعم كامل للوضع المظلم
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';

/// تأثير Shimmer للتحميل
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: AlhaiMotion.standard),
    );

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final effectiveDuration = context.prefersReducedMotion
        ? Duration.zero
        : widget.duration;
    if (_controller.duration != effectiveDuration) {
      _controller.duration = effectiveDuration;
      if (widget.isLoading) {
        _controller
          ..stop()
          ..repeat();
      }
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        widget.baseColor ?? (isDark ? AppColors.grey700 : AppColors.grey200);
    final highlightColor =
        widget.highlightColor ??
        (isDark ? AppColors.grey600 : AppColors.grey100);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// عنصر نائب للتحميل
class ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
    this.margin,
  });

  /// عنصر نائب دائري
  factory ShimmerPlaceholder.circular({
    Key? key,
    required double size,
    EdgeInsetsGeometry? margin,
  }) {
    return ShimmerPlaceholder(
      key: key,
      width: size,
      height: size,
      borderRadius: size / 2,
      margin: margin,
    );
  }

  /// عنصر نائب للنص
  factory ShimmerPlaceholder.text({
    Key? key,
    double width = double.infinity,
    double height = 14,
    EdgeInsetsGeometry? margin,
  }) {
    return ShimmerPlaceholder(
      key: key,
      width: width,
      height: height,
      borderRadius: 4,
      margin: margin,
    );
  }

  /// عنصر نائب للبطاقة
  factory ShimmerPlaceholder.card({
    Key? key,
    double? width,
    double height = 120,
    EdgeInsetsGeometry? margin,
  }) {
    return ShimmerPlaceholder(
      key: key,
      width: width,
      height: height,
      borderRadius: 12,
      margin: margin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey700 : AppColors.grey200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// بطاقة تحميل Shimmer
class ShimmerCard extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? margin;

  const ShimmerCard({super.key, this.height, this.margin});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: height ?? 120,
        margin: margin ?? const EdgeInsets.only(bottom: AppSizes.md),
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerPlaceholder.circular(size: 44),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerPlaceholder.text(width: 120),
                      const SizedBox(height: AppSizes.xs),
                      ShimmerPlaceholder.text(width: 80, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            ShimmerPlaceholder.text(width: double.infinity),
          ],
        ),
      ),
    );
  }
}

/// قائمة تحميل Shimmer
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 72,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            height: itemHeight,
            margin: const EdgeInsets.only(bottom: AppSizes.sm),
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                ShimmerPlaceholder.circular(size: 44),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerPlaceholder.text(width: 150),
                      const SizedBox(height: AppSizes.xs),
                      ShimmerPlaceholder.text(width: 100, height: 12),
                    ],
                  ),
                ),
                ShimmerPlaceholder.text(width: 60),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// شبكة تحميل Shimmer
class ShimmerGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const ShimmerGrid({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.childAspectRatio = 1,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSizes.md,
          mainAxisSpacing: AppSizes.md,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSizes.radiusLg),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ShimmerPlaceholder.text(width: double.infinity),
                        ShimmerPlaceholder.text(width: 60, height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// إحصائيات تحميل Shimmer
class ShimmerStats extends StatelessWidget {
  final int count;
  final bool isWide;

  const ShimmerStats({super.key, this.count = 4, this.isWide = true});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: AppSizes.lg,
          mainAxisSpacing: AppSizes.lg,
          childAspectRatio: isWide ? 1.8 : 1.5,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerPlaceholder.text(width: 80, height: 12),
                    ShimmerPlaceholder.circular(size: 36),
                  ],
                ),
                ShimmerPlaceholder.text(width: 100, height: 24),
                ShimmerPlaceholder.text(width: 60, height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// شريط تحميل علوي
class ShimmerTopBar extends StatelessWidget {
  const ShimmerTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerPlaceholder.text(width: 180, height: 20),
                  const SizedBox(height: AppSizes.xs),
                  ShimmerPlaceholder.text(width: 120, height: 14),
                ],
              ),
            ),
            Row(
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: AppSizes.sm),
                  child: ShimmerPlaceholder.circular(size: 40),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
