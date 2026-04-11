/// Shimmer skeleton loader for content placeholders
///
/// Lightweight skeleton shapes with a built-in shimmer animation.
/// Use [SkeletonListItem], [SkeletonCard], and [SkeletonTable]
/// for common loading patterns across admin screens.
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Shimmer skeleton loader for content placeholders
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: AlhaiMotion.standard),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final effectiveDuration = context.prefersReducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 1500);
    if (_controller.duration != effectiveDuration) {
      _controller
        ..stop()
        ..duration = effectiveDuration;
      if (effectiveDuration != Duration.zero) {
        _controller.repeat();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for a list item row
class SkeletonListItem extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;

  const SkeletonListItem({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      child: Row(
        children: [
          if (hasLeading) ...[
            const SkeletonLoader(width: 48, height: 48, borderRadius: 24),
            const SizedBox(width: AlhaiSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(width: 180, height: 14),
                SizedBox(height: AlhaiSpacing.xs),
                SkeletonLoader(width: 120, height: 12),
              ],
            ),
          ),
          if (hasTrailing) const SkeletonLoader(width: 60, height: 14),
        ],
      ),
    );
  }
}

/// Skeleton for a stat card (matches _StatTile layout)
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SkeletonLoader(height: 28, width: 28, borderRadius: 8),
          SizedBox(height: AlhaiSpacing.md),
          SkeletonLoader(height: 20, width: 100),
          SizedBox(height: AlhaiSpacing.xs),
          SkeletonLoader(height: 12, width: 60),
        ],
      ),
    );
  }
}

/// Skeleton for a DataTable
class SkeletonTable extends StatelessWidget {
  final int rows;
  final int columns;

  const SkeletonTable({super.key, this.rows = 5, this.columns = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md,
            vertical: AlhaiSpacing.sm,
          ),
          child: Row(
            children: List.generate(
              columns,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: AlhaiSpacing.xs,
                  ),
                  child: const SkeletonLoader(
                    height: 14,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        // Rows
        ...List.generate(
          rows,
          (r) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md,
              vertical: AlhaiSpacing.sm + 2,
            ),
            child: Row(
              children: List.generate(
                columns,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AlhaiSpacing.xs,
                    ),
                    child: const SkeletonLoader(
                      height: 12,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
