import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/constants/app_constants.dart';

class AddressesDatasource {
  final SupabaseClient _client;

  AddressesDatasource(this._client);

  String get _userId => _client.auth.currentUser!.id;

  Future<List<Address>> getAddresses() async {
    final data = await _client
        .from('addresses')
        .select()
        .eq('user_id', _userId)
        .order('is_default', ascending: false)
        .timeout(AppConstants.networkTimeout);

    return (data as List)
        .map((row) => _addressFromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<Address?> getDefaultAddress() async {
    try {
      final data = await _client
          .from('addresses')
          .select()
          .eq('user_id', _userId)
          .eq('is_default', true)
          .limit(1)
          .single()
          .timeout(AppConstants.networkTimeout);
      return _addressFromRow(data);
    } catch (_) {
      return null;
    }
  }

  Future<Address> createAddress(CreateAddressParams params) async {
    // If this is default, unset other defaults
    if (params.isDefault) {
      await _client
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', _userId);
    }

    final data = await _client.from('addresses').insert({
      'user_id': _userId,
      'label': params.label,
      'full_address': params.fullAddress,
      'city': params.city,
      'district': params.district,
      'street': params.street,
      'building': params.buildingNumber,
      'apartment': params.apartmentNumber,
      'latitude': params.lat,
      'longitude': params.lng,
      'is_default': params.isDefault,
    }).select().single().timeout(AppConstants.networkTimeout);

    return _addressFromRow(data);
  }

  Future<void> deleteAddress(String id) async {
    await _client
        .from('addresses')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId)
        .timeout(AppConstants.networkTimeout);
  }

  Future<void> setDefaultAddress(String id) async {
    // Unset all defaults then set new — single RPC would be better but this works
    await _client
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', _userId)
        .timeout(AppConstants.networkTimeout);

    await _client
        .from('addresses')
        .update({'is_default': true})
        .eq('id', id)
        .timeout(AppConstants.networkTimeout);
  }

  Address _addressFromRow(Map<String, dynamic> row) {
    return Address(
      id: row['id'] as String,
      label: row['label'] as String? ?? '',
      fullAddress: row['full_address'] as String? ?? '',
      city: row['city'] as String? ?? '',
      district: row['district'] as String?,
      street: row['street'] as String?,
      buildingNumber: row['building'] as String?,
      apartmentNumber: row['apartment'] as String?,
      lat: (row['latitude'] as num?)?.toDouble() ?? 0,
      lng: (row['longitude'] as num?)?.toDouble() ?? 0,
      isDefault: row['is_default'] as bool? ?? false,
    );
  }
}
