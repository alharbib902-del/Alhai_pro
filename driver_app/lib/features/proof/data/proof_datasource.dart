import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource for delivery proof (photo + signature).
class ProofDatasource {
  final SupabaseClient _client;

  ProofDatasource(this._client);

  /// Upload proof photo and save proof record.
  Future<void> submitProof({
    required String deliveryId,
    Uint8List? photoBytes,
    String? signatureData,
    String? recipientName,
    String? notes,
    double? lat,
    double? lng,
  }) async {
    String? photoUrl;

    // Upload photo to Supabase Storage
    if (photoBytes != null) {
      final fileName =
          '${deliveryId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('delivery-proofs').uploadBinary(
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
}
