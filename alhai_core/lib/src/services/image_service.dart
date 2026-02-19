import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling product image uploads to Supabase Storage
class ImageService {
  final _supabase = Supabase.instance.client;

  static const String _bucket = 'product-images';

  /// Upload a product image with automatic resizing to 3 sizes
  ///
  /// Images are stored in: {storeId}/{productId}/thumb.png, medium.png, large.png
  /// Returns URLs for thumbnail (300x300), medium (600x600), and large (1200x1200)
  Future<ProductImageUrls> uploadProductImage({
    required String storeId,
    required String productId,
    required File imageFile,
  }) async {
    try {
      // 1. Read and decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw const ImageProcessingException('Failed to decode image');
      }

      // 2. Generate hash for versioning
      final hash = sha256.convert(bytes).toString().substring(0, 8);

      // 3. Resize to 3 sizes (maintain aspect ratio)
      final thumb = img.copyResize(image, width: 300);
      final medium = img.copyResize(image, width: 600);
      final large = img.copyResize(image, width: 1200);

      // 4. Encode to JPEG (smaller size than PNG)
      final thumbBytes = Uint8List.fromList(img.encodeJpg(thumb, quality: 80));
      final mediumBytes = Uint8List.fromList(img.encodeJpg(medium, quality: 85));
      final largeBytes = Uint8List.fromList(img.encodeJpg(large, quality: 90));

      // 5. Upload to Supabase Storage
      final basePath = '$storeId/$productId';

      await Future.wait([
        _uploadFile('$basePath/thumb_$hash.jpg', thumbBytes),
        _uploadFile('$basePath/medium_$hash.jpg', mediumBytes),
        _uploadFile('$basePath/large_$hash.jpg', largeBytes),
      ]);

      // 6. Get public URLs
      final thumbUrl = _supabase.storage
          .from(_bucket)
          .getPublicUrl('$basePath/thumb_$hash.jpg');
      final mediumUrl = _supabase.storage
          .from(_bucket)
          .getPublicUrl('$basePath/medium_$hash.jpg');
      final largeUrl = _supabase.storage
          .from(_bucket)
          .getPublicUrl('$basePath/large_$hash.jpg');

      return ProductImageUrls(
        thumbnail: thumbUrl,
        medium: mediumUrl,
        large: largeUrl,
        hash: hash,
      );
    } catch (e) {
      if (e is ImageProcessingException || e is UploadException) {
        rethrow;
      }
      throw ImageProcessingException('Failed to process image: $e');
    }
  }

  /// Upload from bytes (for web platform)
  Future<ProductImageUrls> uploadProductImageFromBytes({
    required String storeId,
    required String productId,
    required Uint8List imageBytes,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ImageProcessingException('Failed to decode image');
      }

      final hash = sha256.convert(imageBytes).toString().substring(0, 8);

      final thumb = img.copyResize(image, width: 300);
      final medium = img.copyResize(image, width: 600);
      final large = img.copyResize(image, width: 1200);

      final thumbBytes = Uint8List.fromList(img.encodeJpg(thumb, quality: 80));
      final mediumBytes = Uint8List.fromList(img.encodeJpg(medium, quality: 85));
      final largeBytes = Uint8List.fromList(img.encodeJpg(large, quality: 90));

      final basePath = '$storeId/$productId';

      await Future.wait([
        _uploadFile('$basePath/thumb_$hash.jpg', thumbBytes),
        _uploadFile('$basePath/medium_$hash.jpg', mediumBytes),
        _uploadFile('$basePath/large_$hash.jpg', largeBytes),
      ]);

      final thumbUrl = _supabase.storage
          .from(_bucket)
          .getPublicUrl('$basePath/thumb_$hash.jpg');
      final mediumUrl = _supabase.storage
          .from(_bucket)
          .getPublicUrl('$basePath/medium_$hash.jpg');
      final largeUrl = _supabase.storage
          .from(_bucket)
          .getPublicUrl('$basePath/large_$hash.jpg');

      return ProductImageUrls(
        thumbnail: thumbUrl,
        medium: mediumUrl,
        large: largeUrl,
        hash: hash,
      );
    } catch (e) {
      if (e is ImageProcessingException || e is UploadException) {
        rethrow;
      }
      throw ImageProcessingException('Failed to process image: $e');
    }
  }

  /// Delete all images for a product
  Future<void> deleteProductImages({
    required String storeId,
    required String productId,
  }) async {
    try {
      final list = await _supabase.storage
          .from(_bucket)
          .list(path: '$storeId/$productId');

      if (list.isNotEmpty) {
        final paths = list
            .map((f) => '$storeId/$productId/${f.name}')
            .toList();
        await _supabase.storage.from(_bucket).remove(paths);
      }
    } catch (e) {
      throw UploadException('Failed to delete images: $e');
    }
  }

  Future<void> _uploadFile(String path, Uint8List bytes) async {
    try {
      await _supabase.storage.from(_bucket).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );
    } catch (e) {
      throw UploadException('Failed to upload $path: $e');
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
