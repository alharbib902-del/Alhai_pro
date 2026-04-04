import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Skeleton layout for dashboard KPI grid
class SADashboardSkeleton extends StatelessWidget {
  const SADashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AlhaiShimmer(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title placeholder
            const AlhaiSkeleton.rectangle(
              width: 180,
              height: 24,
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            // KPI cards grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AlhaiSpacing.md,
              crossAxisSpacing: AlhaiSpacing.md,
              childAspectRatio: 2.2,
              children: List.generate(
                4,
                (_) => AlhaiSkeleton.card(height: 120),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            // Second KPI row
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AlhaiSpacing.md,
              crossAxisSpacing: AlhaiSpacing.md,
              childAspectRatio: 2.2,
              children: List.generate(
                4,
                (_) => AlhaiSkeleton.card(height: 120),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xl),
            // Section title
            const AlhaiSkeleton.rectangle(
              width: 140,
              height: 18,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            // Chart skeleton
            AlhaiSkeleton.card(height: 280),
            const SizedBox(height: AlhaiSpacing.xl),
            // Section title
            const AlhaiSkeleton.rectangle(
              width: 140,
              height: 18,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            // Pie chart skeleton
            AlhaiSkeleton.card(height: 200),
          ],
        ),
      ),
    );
  }
}

/// Skeleton layout for list/table screens
class SATableSkeleton extends StatelessWidget {
  final int rowCount;
  const SATableSkeleton({super.key, this.rowCount = 8});

  @override
  Widget build(BuildContext context) {
    return AlhaiShimmer(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          children: [
            // Search bar skeleton
            const AlhaiSkeleton.rectangle(
              width: double.infinity,
              height: 48,
              borderRadius:
                  BorderRadius.all(Radius.circular(AlhaiRadius.input)),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            // Table header
            const AlhaiSkeleton.rectangle(
              width: double.infinity,
              height: 40,
            ),
            const SizedBox(height: 4),
            // Table rows
            ...List.generate(
              rowCount,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: AlhaiSkeleton.rectangle(
                  width: double.infinity,
                  height: 52,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
