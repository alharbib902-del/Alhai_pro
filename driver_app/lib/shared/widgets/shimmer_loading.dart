import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// A single shimmering placeholder bar.
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surfaceContainerHighest,
      highlightColor: isDark
          ? theme.colorScheme.surfaceContainerLow
          : theme.colorScheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A card-shaped shimmer placeholder for list items.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerLoading(width: 120, height: 14),
            SizedBox(height: AlhaiSpacing.sm),
            ShimmerLoading(height: 20),
            SizedBox(height: AlhaiSpacing.sm),
            ShimmerLoading(width: 200, height: 14),
          ],
        ),
      ),
    );
  }
}

/// A stats-row shimmer placeholder (3 equal columns).
class ShimmerStatsCard extends StatelessWidget {
  const ShimmerStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    ShimmerLoading(width: 48, height: 28),
                    SizedBox(height: AlhaiSpacing.xs),
                    ShimmerLoading(width: 64, height: 12),
                  ],
                ),
              ),
              if (i < 2)
                VerticalDivider(
                  width: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A shimmer list of [count] ShimmerCards, useful for loading states.
class ShimmerList extends StatelessWidget {
  final int count;

  const ShimmerList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
        child: const ShimmerCard(),
      ),
    );
  }
}
