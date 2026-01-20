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
}
