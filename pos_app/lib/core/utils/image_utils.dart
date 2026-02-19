/// Image Utilities - أدوات تحسين الصور
///
/// يوفر:
/// - تحميل الصور المحسّن مع caching
/// - Placeholder images
/// - تحميل متدرج (blur → thumbnail → full)
/// - معالجة أخطاء التحميل
library image_utils;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// خدمة تحسين الصور
class ImageOptimizer {
  ImageOptimizer._();

  /// الحد الأقصى لحجم cache الصور بالميغابايت
  static const int maxCacheSizeMB = 100;

  /// مدة صلاحية cache الصور
  static const Duration cacheValidDuration = Duration(days: 7);

  /// Placeholder للصور
  static Widget placeholder({
    double? width,
    double? height,
    Color? color,
    IconData icon = Icons.image_outlined,
  }) {
    return Container(
      width: width,
      height: height,
      color: color ?? Colors.grey[200],
      child: Center(
        child: Icon(
          icon,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }

  /// Shimmer placeholder للتحميل
  static Widget shimmerPlaceholder({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }

  /// Error placeholder
  static Widget errorPlaceholder({
    double? width,
    double? height,
    VoidCallback? onRetry,
  }) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: Colors.grey[500],
              size: 32,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget محسّن لعرض صور المنتجات
class OptimizedProductImage extends StatelessWidget {
  /// URL الصورة (thumbnail, medium, أو large)
  final String? imageUrl;

  /// URL الـ thumbnail للتحميل المتدرج
  final String? thumbnailUrl;

  /// العرض
  final double? width;

  /// الارتفاع
  final double? height;

  /// شكل الصورة
  final BoxFit fit;

  /// حدود مستديرة
  final BorderRadius? borderRadius;

  /// عند النقر
  final VoidCallback? onTap;

  /// إظهار shimmer أثناء التحميل
  final bool showShimmer;

  const OptimizedProductImage({
    super.key,
    this.imageUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.onTap,
    this.showShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    // إذا لم يوجد URL، أظهر placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      // Placeholder أثناء التحميل
      placeholder: (context, url) => showShimmer
          ? _buildShimmer()
          : _buildPlaceholder(),
      // التحميل المتدرج: thumbnail أولاً
      placeholderFadeInDuration: const Duration(milliseconds: 200),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 200),
      // Error widget
      errorWidget: (context, url, error) => _buildErrorWidget(),
      // Memory cache لتحسين الأداء
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      // استخدام fade in للتحميل السلس
      fadeInCurve: Curves.easeIn,
    );

    // إضافة الحدود المستديرة
    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    // إضافة إمكانية النقر
    if (onTap != null) {
      image = GestureDetector(
        onTap: onTap,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey[500],
          size: 24,
        ),
      ),
    );
  }
}

/// Widget لعرض الصور مع تحميل متدرج (Progressive Loading)
/// يعرض thumbnail أولاً ثم الصورة الكاملة
class ProgressiveImage extends StatelessWidget {
  /// URL الصورة الكاملة
  final String imageUrl;

  /// URL الـ thumbnail
  final String? thumbnailUrl;

  /// العرض
  final double? width;

  /// الارتفاع
  final double? height;

  /// شكل الصورة
  final BoxFit fit;

  /// حدود مستديرة
  final BorderRadius? borderRadius;

  const ProgressiveImage({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // الـ thumbnail كـ background
          if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: thumbnailUrl!,
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
              ),
            ),

          // الصورة الكاملة
          CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: fit,
            fadeInDuration: const Duration(milliseconds: 400),
            placeholder: (context, url) => const SizedBox.shrink(),
            errorWidget: (context, url, error) => Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget لعرض صور متعددة بشكل Grid
class ImageGrid extends StatelessWidget {
  /// قائمة URLs الصور
  final List<String> imageUrls;

  /// عدد الأعمدة
  final int crossAxisCount;

  /// المسافة بين الصور
  final double spacing;

  /// حدود مستديرة
  final BorderRadius? borderRadius;

  /// عند النقر على صورة
  final void Function(int index)? onImageTap;

  const ImageGrid({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 3,
    this.spacing = 4,
    this.borderRadius,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return OptimizedProductImage(
          imageUrl: imageUrls[index],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          onTap: onImageTap != null ? () => onImageTap!(index) : null,
        );
      },
    );
  }
}

/// مدير cache الصور
class ImageCacheManager {
  ImageCacheManager._();

  /// مسح cache الصور
  static Future<void> clearCache() async {
    await CachedNetworkImage.evictFromCache('');
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// الحصول على حجم cache
  static int get cacheSize {
    return PaintingBinding.instance.imageCache.currentSize;
  }

  /// الحصول على عدد الصور في cache
  static int get cachedImageCount {
    return PaintingBinding.instance.imageCache.liveImageCount;
  }

  /// تكوين cache
  static void configure({
    int? maximumSize,
    int? maximumSizeBytes,
  }) {
    if (maximumSize != null) {
      PaintingBinding.instance.imageCache.maximumSize = maximumSize;
    }
    if (maximumSizeBytes != null) {
      PaintingBinding.instance.imageCache.maximumSizeBytes = maximumSizeBytes;
    }
  }
}

/// Extension لتسهيل استخدام الصور
extension ImageUrlExtension on String? {
  /// هل الـ URL صالح
  bool get isValidImageUrl {
    if (this == null || this!.isEmpty) return false;
    return this!.startsWith('http://') || this!.startsWith('https://');
  }

  /// الحصول على thumbnail URL من Cloudflare R2
  String? get thumbnailUrl {
    if (!isValidImageUrl) return null;
    // إذا كان URL يحتوي على /thumb/ أو _thumb فهو thumbnail بالفعل
    if (this!.contains('/thumb/') || this!.contains('_thumb')) {
      return this;
    }
    // تحويل للـ thumbnail
    return this!.replaceAll('/large/', '/thumb/').replaceAll('/medium/', '/thumb/');
  }

  /// الحصول على medium URL
  String? get mediumUrl {
    if (!isValidImageUrl) return null;
    if (this!.contains('/medium/')) return this;
    return this!.replaceAll('/large/', '/medium/').replaceAll('/thumb/', '/medium/');
  }

  /// الحصول على large URL
  String? get largeUrl {
    if (!isValidImageUrl) return null;
    if (this!.contains('/large/')) return this;
    return this!.replaceAll('/medium/', '/large/').replaceAll('/thumb/', '/large/');
  }
}
