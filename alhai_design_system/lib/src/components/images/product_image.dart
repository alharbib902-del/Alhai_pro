import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Size options for product images
enum ImageSize {
  /// 300×300 - For Grid, List, Search
  thumbnail,
  
  /// 600×600 - For Quick View, Drawer
  medium,
  
  /// 1200×1200 - For Product Detail, Zoom
  large,
}

/// Widget to display product images with automatic caching and fallbacks
/// 
/// Usage:
/// ```dart
/// // In Grid
/// ProductImage(
///   thumbnail: product.imageThumbnail,
///   medium: product.imageMedium,
///   large: product.imageLarge,
///   size: ImageSize.thumbnail,
/// )
/// 
/// // In Detail Screen
/// ProductImage(
///   thumbnail: product.imageThumbnail,
///   medium: product.imageMedium,
///   large: product.imageLarge,
///   size: ImageSize.large,
/// )
/// ```
class ProductImage extends StatelessWidget {
  final String? thumbnail;
  final String? medium;
  final String? large;
  final ImageSize size;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ProductImage({
    super.key,
    this.thumbnail,
    this.medium,
    this.large,
    this.size = ImageSize.thumbnail,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  /// Pre-cache a list of product image URLs for offline availability.
  ///
  /// Call during app initialization (e.g., after store selection) to ensure
  /// top-selling product images are available instantly when offline.
  ///
  /// ```dart
  /// // In initState or after loading products:
  /// final topProducts = products.take(50);
  /// await ProductImage.precacheProducts(
  ///   context,
  ///   topProducts.map((p) => p.imageThumbnail).whereType<String>().toList(),
  /// );
  /// ```
  static Future<void> precacheProducts(
    BuildContext context,
    List<String> imageUrls, {
    int maxConcurrent = 5,
  }) async {
    // Process in batches to avoid overwhelming the network
    for (var i = 0; i < imageUrls.length; i += maxConcurrent) {
      final batch = imageUrls.skip(i).take(maxConcurrent);
      await Future.wait(
        batch.map((url) {
          if (url.isEmpty) return Future<void>.value();
          return precacheImage(
            CachedNetworkImageProvider(url),
            context,
          ).catchError((_) {
            // Silently ignore - precaching is best-effort
          });
        }),
      );
    }
  }

  /// Pre-cache a single image URL for offline availability.
  static Future<void> precacheSingle(BuildContext context, String url) async {
    if (url.isEmpty) return;
    try {
      await precacheImage(CachedNetworkImageProvider(url), context);
    } catch (_) {
      // Silently ignore - precaching is best-effort
    }
  }

  /// Select the appropriate image URL based on size with fallbacks
  String? get _imageUrl {
    return switch (size) {
      ImageSize.thumbnail => thumbnail ?? medium ?? large,
      ImageSize.medium => medium ?? thumbnail ?? large,
      ImageSize.large => large ?? medium ?? thumbnail,
    };
  }

  @override
  Widget build(BuildContext context) {
    final url = _imageUrl;

    if (url == null || url.isEmpty) {
      return _buildPlaceholder(context);
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: _getMemCacheSize(),
      memCacheHeight: _getMemCacheSize(),
      placeholder: (context, url) => _buildPlaceholder(context),
      errorWidget: (context, url, error) => _buildError(context),
      cacheManager: CacheManager(
        Config(
          'alhai_product_images',
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 2000,
        ),
      ),
      fadeInDuration: AlhaiMotion.durationFast,
      fadeOutDuration: AlhaiMotion.durationFast,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: _getIconSize(),
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: _getIconSize(),
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  double _getIconSize() {
    return switch (size) {
      ImageSize.thumbnail => 32.0,
      ImageSize.medium => 48.0,
      ImageSize.large => 64.0,
    };
  }

  /// Returns the memory cache size in pixels (2x display size for retina).
  int _getMemCacheSize() {
    return switch (size) {
      ImageSize.thumbnail => 200,
      ImageSize.medium => 400,
      ImageSize.large => 800,
    };
  }
}
