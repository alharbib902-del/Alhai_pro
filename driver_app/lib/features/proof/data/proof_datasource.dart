import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Maximum allowed photo size in bytes (10 MB).
const _maxPhotoSizeBytes = 10 * 1024 * 1024;

/// Allowed JPEG magic bytes (SOI marker).
const _jpegMagicBytes = [0xFF, 0xD8];

/// Allowed PNG magic bytes.
const _pngMagicBytes = [0x89, 0x50, 0x4E, 0x47];

/// Datasource for delivery proof (photo + signature).
class ProofDatasource {
  final SupabaseClient _client;

  ProofDatasource(this._client);

  /// Upload proof photo and save proof record.
  ///
  /// Validates:
  /// - [photoBytes] size does not exceed [_maxPhotoSizeBytes] (10 MB).
  /// - [photoBytes] starts with JPEG or PNG magic bytes.
  /// - [lat] and [lng] are within valid geographic ranges when provided.
  ///
  /// Throws [ArgumentError] if any validation fails.
  Future<void> submitProof({
    required String deliveryId,
    Uint8List? photoBytes,
    String? signatureData,
    String? recipientName,
    String? notes,
    double? lat,
    double? lng,
  }) async {
    // ── Input validation ──────────────────────────────────────────────────

    if (photoBytes != null) {
      if (photoBytes.length > _maxPhotoSizeBytes) {
        throw ArgumentError(
          'حجم الصورة يتجاوز الحد المسموح (${(_maxPhotoSizeBytes / 1024 / 1024).toStringAsFixed(0)} ميجابايت)',
        );
      }
      if (!_isValidImageType(photoBytes)) {
        throw ArgumentError('نوع الصورة غير مدعوم. يُسمح فقط بصور JPEG و PNG');
      }
    }

    if (lat != null && (lat < -90 || lat > 90)) {
      throw ArgumentError('خط العرض غير صالح: $lat (يجب أن يكون بين -90 و 90)');
    }
    if (lng != null && (lng < -180 || lng > 180)) {
      throw ArgumentError(
        'خط الطول غير صالح: $lng (يجب أن يكون بين -180 و 180)',
      );
    }

    // ── Upload & persist ──────────────────────────────────────────────────

    String? photoUrl;

    // Upload photo to Supabase Storage
    if (photoBytes != null) {
      final fileName =
          '${deliveryId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage
          .from('delivery-proofs')
          .uploadBinary(
            fileName,
            photoBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      photoUrl = await _client.storage
          .from('delivery-proofs')
          .createSignedUrl(fileName, 60 * 60 * 24 * 365);
    }

    // Save proof record
    await _client.from('delivery_proofs').insert({
      'delivery_id': deliveryId,
      'photo_url': photoUrl,
      'signature_data': signatureData,
      'recipient_name': recipientName,
      'notes': notes,
      'lat': lat,
      'lng': lng,
    });

    // Update delivery with proof URLs
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (photoUrl != null) updates['proof_photo_url'] = photoUrl;
    if (signatureData != null) updates['proof_signature_url'] = signatureData;

    await _client.from('deliveries').update(updates).eq('id', deliveryId);
  }

  /// Returns `true` if [bytes] starts with known JPEG or PNG magic bytes.
  static bool _isValidImageType(Uint8List bytes) {
    if (bytes.length < 4) return false;
    // JPEG: starts with FF D8
    if (bytes[0] == _jpegMagicBytes[0] && bytes[1] == _jpegMagicBytes[1]) {
      return true;
    }
    // PNG: starts with 89 50 4E 47
    if (bytes[0] == _pngMagicBytes[0] &&
        bytes[1] == _pngMagicBytes[1] &&
        bytes[2] == _pngMagicBytes[2] &&
        bytes[3] == _pngMagicBytes[3]) {
      return true;
    }
    return false;
  }
}
