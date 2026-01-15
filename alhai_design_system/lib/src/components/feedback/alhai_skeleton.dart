import 'package:flutter/material.dart';

import '../../tokens/alhai_durations.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// AlhaiSkeleton - Loading placeholder shapes
/// 
/// Features:
/// - Multiple shape variants
/// - Pre-built component skeletons
/// - RTL-safe
/// - Dark mode colors
class AlhaiSkeleton extends StatelessWidget {
  /// Width of the skeleton
  final double? width;

  /// Height of the skeleton
  final double? height;

  /// Border radius
  final BorderRadius? borderRadius;

  const AlhaiSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  /// Rectangle skeleton
  const AlhaiSkeleton.rectangle({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  /// Circle skeleton
  factory AlhaiSkeleton.circle({
    Key? key,
    required double size,
  }) {
    return _CircleSkeleton(key: key, size: size);
  }

  /// Text skeleton (single or multiple lines)
  factory AlhaiSkeleton.text({
    Key? key,
    double? width,
    int lines = 1,
    double lineHeight = 14,
    double lineSpacing = 8,
  }) {
    return _TextSkeleton(
      key: key,
      width: width,
      lines: lines,
      lineHeight: lineHeight,
      lineSpacing: lineSpacing,
    );
  }

  /// Avatar skeleton
  factory AlhaiSkeleton.avatar({
    Key? key,
    double size = AlhaiSpacing.avatarMd,
  }) {
    return _CircleSkeleton(key: key, size: size);
  }

  /// Card skeleton
  factory AlhaiSkeleton.card({
    Key? key,
    double? width,
    double height = 120,
  }) {
    return _CardSkeleton(key: key, width: width, height: height);
  }

  /// ListTile skeleton
  factory AlhaiSkeleton.listTile({Key? key}) {
    return _ListTileSkeleton(key: key);
  }

  /// ProductCard skeleton
  factory AlhaiSkeleton.productCard({Key? key}) {
    return _ProductCardSkeleton(key: key);
  }

  /// CartItem skeleton
  factory AlhaiSkeleton.cartItem({Key? key}) {
    return _CartItemSkeleton(key: key);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AlhaiRadius.sm);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: effectiveRadius,
      ),
    );
  }
}

/// Circle skeleton
class _CircleSkeleton extends AlhaiSkeleton {
  final double size;

  const _CircleSkeleton({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Text skeleton with multiple lines
class _TextSkeleton extends AlhaiSkeleton {
  final int lines;
  final double lineHeight;
  final double lineSpacing;

  const _TextSkeleton({
    super.key,
    super.width,
    required this.lines,
    required this.lineHeight,
    required this.lineSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < lines; i++) ...[
          if (i > 0) SizedBox(height: lineSpacing),
          _buildLine(i, colorScheme),
        ],
      ],
    );
  }

  Widget _buildLine(int index, ColorScheme colorScheme) {
    final isLast = index == lines - 1 && lines > 1;
    final line = Container(
      width: isLast ? null : width,
      height: lineHeight,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AlhaiRadius.xs),
      ),
    );

    if (isLast) {
      return FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: 0.7,
        child: line,
      );
    }
    return line;
  }
}

/// Card skeleton
class _CardSkeleton extends AlhaiSkeleton {
  const _CardSkeleton({
    super.key,
    super.width,
    super.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
      ),
    );
  }
}

/// ListTile skeleton
class _ListTileSkeleton extends AlhaiSkeleton {
  const _ListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      child: Row(
        children: [
          // Leading avatar
          Container(
            width: AlhaiSpacing.avatarMd,
            height: AlhaiSpacing.avatarMd,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AlhaiRadius.xs),
                    ),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AlhaiRadius.xs),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ProductCard skeleton
class _ProductCardSkeleton extends AlhaiSkeleton {
  const _ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AlhaiRadius.card),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AlhaiRadius.xs),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                // Price
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AlhaiRadius.xs),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                // Button
                Container(
                  width: double.infinity,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AlhaiRadius.full),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CartItem skeleton
class _CartItemSkeleton extends AlhaiSkeleton {
  const _CartItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading image
          Container(
            width: AlhaiSpacing.huge,
            height: AlhaiSpacing.huge,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AlhaiRadius.sm),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AlhaiRadius.xs),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                // Price
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AlhaiRadius.xs),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                // Quantity control
                Container(
                  width: 100,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AlhaiRadius.full),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// AlhaiShimmer - Animated shimmer effect wrapper
/// 
/// Features:
/// - Gradient animation
/// - RTL-safe direction
/// - Token-based duration
/// - Dark mode support
class AlhaiShimmer extends StatefulWidget {
  /// Child widget to apply shimmer effect
  final Widget child;

  /// Whether shimmer is enabled
  final bool enabled;

  /// Animation duration
  final Duration duration;

  const AlhaiShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = AlhaiDurations.shimmer,
  });

  @override
  State<AlhaiShimmer> createState() => _AlhaiShimmerState();
}

class _AlhaiShimmerState extends State<AlhaiShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AlhaiShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      if (widget.enabled) {
        _controller
          ..stop()
          ..repeat();
      }
    }
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller
          ..stop()
          ..reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final baseColor = colorScheme.surfaceContainerHighest;
    final highlightColor = colorScheme.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final v = _animation.value;
            
            // RTL: reverse gradient direction
            final begin = isRtl 
                ? Alignment(1.0 + v, 0.0)
                : Alignment(-1.0 + v, 0.0);
            final end = isRtl
                ? Alignment(-1.0 + v, 0.0)
                : Alignment(1.0 + v, 0.0);

            return LinearGradient(
              begin: begin,
              end: end,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
