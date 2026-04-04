import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';

/// نتيجة رفع صورة
class ImageUploadResult {
  final String thumbnailUrl;
  final String mediumUrl;
  final String largeUrl;
  final String imageHash;

  const ImageUploadResult({
    required this.thumbnailUrl,
    required this.mediumUrl,
    required this.largeUrl,
    required this.imageHash,
  });
}

/// خدمة رفع الصور إلى Supabase Storage
///
/// تدعم:
/// - رفع صور المنتجات (فرع أو منظمة)
/// - رفع شعار المتجر
/// - حفظ فواتير PDF
/// - حذف الصور القديمة
class ImageUploadService {
  final SupabaseClient _client;
  final AppDatabase _db;
  static const _uuid = Uuid();

  /// أسماء البكتات في Supabase Storage
  static const String productImagesBucket = 'product-images';
  static const String storeLogosBucket = 'store-logos';
  static const String receiptsBucket = 'receipts';
  static const String invoiceAttachmentsBucket = 'invoice-attachments';

  ImageUploadService({
    required SupabaseClient client,
    required AppDatabase db,
  })  : _client = client,
        _db = db;

  /// رفع صورة منتج (لفرع محدد)
  ///
  /// المسار: store/{storeId}/products/{productId}/{size}_{hash}.webp
  /// يرفع 3 نسخ: thumbnail (300px), medium (600px), large (1200px)
  Future<ImageUploadResult?> uploadProductImage({
    required String storeId,
    required String productId,
    required Uint8List imageBytes,
    String contentType = 'image/webp',
  }) async {
    try {
      final hash = _generateHash(imageBytes);
      final basePath = 'store/$storeId/products/$productId';

      // رفع النسخ الثلاث (نفس الصورة - التصغير يتم عبر CDN أو Edge Function)
      final thumbPath = '$basePath/thumb_$hash.webp';
      final mediumPath = '$basePath/medium_$hash.webp';
      final largePath = '$basePath/large_$hash.webp';

      // رفع الصورة الأصلية لكل المقاسات
      await Future.wait([
        _uploadFile(productImagesBucket, thumbPath, imageBytes, contentType),
        _uploadFile(productImagesBucket, mediumPath, imageBytes, contentType),
        _uploadFile(productImagesBucket, largePath, imageBytes, contentType),
      ]);

      // الحصول على الروابط العامة
      final thumbUrl = _getPublicUrl(productImagesBucket, thumbPath);
      final mediumUrl = _getPublicUrl(productImagesBucket, mediumPath);
      final largeUrl = _getPublicUrl(productImagesBucket, largePath);

      // تحديث المنتج في القاعدة المحلية
      await _db.productsDao.updateProductImages(
        productId,
        imageThumbnail: thumbUrl,
        imageMedium: mediumUrl,
        imageLarge: largeUrl,
        imageHash: hash,
      );

      return ImageUploadResult(
        thumbnailUrl: thumbUrl,
        mediumUrl: mediumUrl,
        largeUrl: largeUrl,
        imageHash: hash,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageUploadService: upload product image failed: $e');
      }
      return null;
    }
  }

  /// رفع صورة منتج مركزي (للمنظمة - تظهر في كل الفروع)
  ///
  /// المسار: org/{orgId}/products/{sku}/{size}_{hash}.webp
  Future<ImageUploadResult?> uploadOrgProductImage({
    required String orgId,
    required String orgProductId,
    required String sku,
    required Uint8List imageBytes,
    String contentType = 'image/webp',
  }) async {
    try {
      final hash = _generateHash(imageBytes);
      final basePath =
          'org/$orgId/products/${sku.isNotEmpty ? sku : orgProductId}';

      final thumbPath = '$basePath/thumb_$hash.webp';
      final mediumPath = '$basePath/medium_$hash.webp';
      final largePath = '$basePath/large_$hash.webp';

      await Future.wait([
        _uploadFile(productImagesBucket, thumbPath, imageBytes, contentType),
        _uploadFile(productImagesBucket, mediumPath, imageBytes, contentType),
        _uploadFile(productImagesBucket, largePath, imageBytes, contentType),
      ]);

      final thumbUrl = _getPublicUrl(productImagesBucket, thumbPath);
      final mediumUrl = _getPublicUrl(productImagesBucket, mediumPath);
      final largeUrl = _getPublicUrl(productImagesBucket, largePath);

      // تحديث org_product
      await _db.orgProductsDao.updateOrgProduct(
        orgProductId,
        orgImageThumbnail: thumbUrl,
        orgImageMedium: mediumUrl,
        orgImageLarge: largeUrl,
        orgImageHash: hash,
      );

      // مزامنة الصورة لكل فروع المنظمة عبر RPC
      try {
        await _client.rpc('sync_org_product_to_stores', params: {
          'p_org_product_id': orgProductId,
        });
      } catch (_) {
        // المزامنة ستتم في الدورة التالية
      }

      return ImageUploadResult(
        thumbnailUrl: thumbUrl,
        mediumUrl: mediumUrl,
        largeUrl: largeUrl,
        imageHash: hash,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageUploadService: upload org product image failed: $e');
      }
      return null;
    }
  }

  /// رفع شعار المتجر
  ///
  /// المسار: store/{storeId}/logo/logo_{hash}.webp
  Future<String?> uploadStoreLogo({
    required String storeId,
    required Uint8List imageBytes,
    String contentType = 'image/webp',
  }) async {
    try {
      final hash = _generateHash(imageBytes);
      final path = 'store/$storeId/logo/logo_$hash.webp';

      await _uploadFile(storeLogosBucket, path, imageBytes, contentType);
      return _getPublicUrl(storeLogosBucket, path);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageUploadService: upload store logo failed: $e');
      }
      return null;
    }
  }

  /// حفظ فاتورة PDF في Supabase Storage
  ///
  /// المسار: store/{storeId}/invoices/{year}/{month}/{invoiceNumber}.pdf
  Future<String?> archiveInvoicePdf({
    required String storeId,
    required String invoiceNumber,
    required Uint8List pdfBytes,
  }) async {
    try {
      final now = DateTime.now();
      final path = 'store/$storeId/invoices/'
          '${now.year}/${now.month.toString().padLeft(2, '0')}/'
          '$invoiceNumber.pdf';

      await _uploadFile(
          invoiceAttachmentsBucket, path, pdfBytes, 'application/pdf');
      return _getPublicUrl(invoiceAttachmentsBucket, path);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageUploadService: archive invoice failed: $e');
      }
      return null;
    }
  }

  /// حذف صور منتج (عند حذف المنتج أو تغيير الصورة)
  Future<void> deleteProductImages({
    required String storeId,
    required String productId,
  }) async {
    try {
      final files = await _client.storage
          .from(productImagesBucket)
          .list(path: 'store/$storeId/products/$productId');

      if (files.isNotEmpty) {
        final paths = files
            .map((f) => 'store/$storeId/products/$productId/${f.name}')
            .toList();
        await _client.storage.from(productImagesBucket).remove(paths);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageUploadService: delete images failed: $e');
      }
    }
  }

  // ─── Private Helpers ────────────────────────────────

  /// رفع ملف إلى Supabase Storage
  Future<void> _uploadFile(
    String bucket,
    String path,
    Uint8List bytes,
    String contentType,
  ) async {
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true, // استبدال إذا موجود
          ),
        );
  }

  /// الحصول على الرابط العام
  String _getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// توليد hash بسيط من البايتات (أول 16 بايت → hex)
  String _generateHash(Uint8List bytes) {
    // hash بسيط: UUID + طول الملف (لضمان التفرد)
    return '${_uuid.v4().substring(0, 8)}${bytes.length.toRadixString(16)}';
  }
}
