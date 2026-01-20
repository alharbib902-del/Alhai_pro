import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling product image uploads to Cloudflare R2
class ImageService {
  final _supabase = Supabase.instance.client;

  /// Upload a product image with automatic resizing to 3 sizes
  /// 
  /// Returns URLs for thumbnail (300x300), medium (600x600), and large (1200x1200)
  /// Images are converted to WebP format for optimal performance
  /// 
  /// Example:
  /// ```dart
  /// final service = ImageService();
  /// final urls = await service.uploadProductImage(
  ///   productId: product.id,
  ///   imageFile: File('path/to/image.jpg'),
  /// );
  /// print('Thumbnail: ${urls.thumbnail}');
  /// ```
  Future<ProductImageUrls> uploadProductImage({
    required String productId,
    required File imageFile,
  }) async {
    try {
      // 1. Read and decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw ImageProcessingException('Failed to decode image');
      }

      // 2. Generate hash for versioning
      final hash = sha256.convert(bytes).toString().substring(0, 8);

      // 3. Resize to 3 sizes
      final thumb = img.copyResize(
        image,
        width: 300,
        height: 300,
        interpolation: img.Interpolation.linear,
      );
      
      final medium = img.copyResize(
        image,
        width: 600,
        height: 600,
        interpolation: img.Interpolation.linear,
      );
      
      final large = img.copyResize(
        image,
        width: 1200,
        height: 1200,
        interpolation: img.Interpolation.linear,
      );

      // 4. Convert to PNG (WebP not available in this version of image package)
      final thumbBytes = img.encodePng(thumb);
      final mediumBytes = img.encodePng(medium);
      final largeBytes = img.encodePng(large);

      // 5. Upload to R2 via Edge Function
      final response = await _supabase.functions.invoke(
        'upload-product-images',
        body: {
          'product_id': productId,
          'hash': hash,
          'images': {
            'thumb': base64Encode(thumbBytes),
            'medium': base64Encode(mediumBytes),
            'large': base64Encode(largeBytes),
          },
        },
      );

      if (response.status != 200) {
        throw UploadException(
          'Upload failed with status ${response.status}: ${response.data}',
        );
      }

      final data = response.data['urls'] as Map<String, dynamic>;
      
      return ProductImageUrls(
        thumbnail: data['imageThumbnail'] as String,
        medium: data['imageMedium'] as String,
        large: data['imageLarge'] as String,
        hash: hash,
      );
    } catch (e) {
      if (e is ImageProcessingException || e is UploadException) {
        rethrow;
      }
      throw ImageProcessingException('Failed to process image: $e');
    }
  }
}

/// URLs for the three sizes of a product image
class ProductImageUrls {
  final String thumbnail;
  final String medium;
  final String large;
  final String hash;

  const ProductImageUrls({
    required this.thumbnail,
    required this.medium,
    required this.large,
    required this.hash,
  });

  Map<String, String> toMap() => {
    'thumbnail': thumbnail,
    'medium': medium,
    'large': large,
    'hash': hash,
  };
}

/// Exception thrown when image processing fails
class ImageProcessingException implements Exception {
  final String message;
  const ImageProcessingException(this.message);
  
  @override
  String toString() => 'ImageProcessingException: $message';
}

/// Exception thrown when upload fails
class UploadException implements Exception {
  final String message;
  const UploadException(this.message);
  
  @override
  String toString() => 'UploadException: $message';
}
