import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart';

class AddressesDatasource {
  final SupabaseClient _client;

  AddressesDatasource(this._client);

  String get _userId => _client.auth.currentUser!.id;

  Future<List<Address>> getAddresses() async {
    final data = await _client
        .from('addresses')
        .select()
        .eq('user_id', _userId)
        .order('is_default', ascending: false);

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
          .single();
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
      'landmark': params.landmark,
      'latitude': params.lat,
      'longitude': params.lng,
      'is_default': params.isDefault,
    }).select().single();

    return _addressFromRow(data);
  }

  Future<void> deleteAddress(String id) async {
    await _client
        .from('addresses')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  Future<void> setDefaultAddress(String id) async {
    // Unset all defaults
    await _client
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', _userId);

    // Set new default
    await _client
        .from('addresses')
        .update({'is_default': true})
        .eq('id', id);
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
      landmark: row['landmark'] as String?,
      lat: (row['latitude'] as num?)?.toDouble() ?? 0,
      lng: (row['longitude'] as num?)?.toDouble() ?? 0,
      isDefault: row['is_default'] as bool? ?? false,
    );
  }
}
