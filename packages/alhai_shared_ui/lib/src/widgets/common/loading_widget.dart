import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget لعرض حالة التحميل مع تأثير Shimmer
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// Shimmer loading للقوائم
class ShimmerList extends StatelessWidget {
  /// عدد العناصر الوهمية
  final int itemCount;
  
  /// ارتفاع كل عنصر
  final double itemHeight;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outlineVariant,
      highlightColor: isDark ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading للـ Grid
class ShimmerGrid extends StatelessWidget {
  /// عدد العناصر الوهمية
  final int itemCount;
  
  /// عدد الأعمدة
  final int crossAxisCount;
  
  /// نسبة العرض للارتفاع
  final double aspectRatio;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 3,
    this.aspectRatio = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outlineVariant,
      highlightColor: isDark ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.surfaceContainerLow,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading لبطاقة واحدة
class ShimmerCard extends StatelessWidget {
  /// عرض البطاقة
  final double? width;
  
  /// ارتفاع البطاقة
  final double height;
  
  /// نصف قطر الحواف
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 100,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outlineVariant,
      highlightColor: isDark ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.surfaceContainerLow,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
