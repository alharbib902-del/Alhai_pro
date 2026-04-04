/// Skeleton / Shimmer loading widgets for the Distributor Portal.
///
/// A simple animated placeholder used instead of CircularProgressIndicator
/// while data is being fetched.
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// A single skeleton block with animated opacity (shimmer effect).
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Theme.of(context).colorScheme.surfaceContainerLow;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// A skeleton that mimics a summary card layout.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SkeletonBox(width: 42, height: 42, borderRadius: 10),
          SizedBox(height: 12),
          SkeletonBox(width: 80, height: 22),
          SizedBox(height: 6),
          SkeletonBox(width: 100, height: 14),
        ],
      ),
    );
  }
}

/// A skeleton that mimics a table row.
class SkeletonRow extends StatelessWidget {
  final int columns;
  const SkeletonRow({super.key, this.columns = 5});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(columns, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SkeletonBox(height: 14, width: i == 0 ? 120 : 60),
            ),
          );
        }),
      ),
    );
  }
}

/// A full-page skeleton for dashboard-like screens.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossCount = width >= AlhaiBreakpoints.desktop ? 4 : (width >= AlhaiBreakpoints.tablet ? 2 : 1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 180, height: 28),
          const SizedBox(height: 8),
          const SkeletonBox(width: 260, height: 16),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: crossCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(4, (_) => const SkeletonCard()),
          ),
          const SizedBox(height: 24),
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: SkeletonBox(width: 200, height: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// A skeleton for table/list screens (orders, products, pricing).
class TableSkeleton extends StatelessWidget {
  final int rows;
  final int columns;
  const TableSkeleton({super.key, this.rows = 8, this.columns = 5});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
              child: Row(
                children: List.generate(columns, (_) {
                  return const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: SkeletonBox(height: 14),
                    ),
                  );
                }),
              ),
            ),
            // Data rows
            ...List.generate(rows, (_) => SkeletonRow(columns: columns)),
          ],
        ),
      ),
    );
  }
}

/// A skeleton for report screens.
class ReportSkeleton extends StatelessWidget {
  const ReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMedium = width >= AlhaiBreakpoints.tablet;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Summary cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(4, (_) {
              return SizedBox(
                width: isMedium ? (width - 72) / 2 : double.infinity,
                child: const SkeletonCard(),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Chart placeholder
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
