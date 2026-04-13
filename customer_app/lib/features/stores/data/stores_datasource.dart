import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/sentry_service.dart';

class StoresDatasource {
  final SupabaseClient _client;

  StoresDatasource(this._client);

  Future<List<Store>> getNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    // Try server-side RPC first (Haversine on Postgres)
    try {
      final data = await _client
          .rpc(
            'get_nearby_stores',
            params: {'p_lat': lat, 'p_lng': lng, 'p_radius_km': radiusKm},
          )
          .timeout(AppConstants.networkTimeout);

      return (data as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(_storeFromRow)
          .toList();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'getNearbyStores: RPC fallback to client-side');
      // Fallback: client-side filtering if RPC is unavailable
      return _getNearbyStoresClientSide(lat: lat, lng: lng, radiusKm: radiusKm);
    }
  }

  /// Client-side fallback for nearby stores (fetches all, filters locally)
  Future<List<Store>> _getNearbyStoresClientSide({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    final data = await _client
        .from('stores')
        .select()
        .eq('is_active', true)
        .not('lat', 'is', null)
        .order('created_at', ascending: false)
        .timeout(AppConstants.networkTimeout);

    final stores = (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_storeFromRow)
        .where((store) {
          final dist = _distanceKm(lat, lng, store.lat, store.lng);
          return dist <= radiusKm;
        })
        .toList();

    // Sort by distance
    stores.sort((a, b) {
      final distA = _distanceKm(lat, lng, a.lat, a.lng);
      final distB = _distanceKm(lat, lng, b.lat, b.lng);
      return distA.compareTo(distB);
    });

    return stores;
  }

  Future<Store> getStore(String id) async {
    final data = await _client
        .from('stores')
        .select()
        .eq('id', id)
        .single()
        .timeout(AppConstants.networkTimeout);
    return _storeFromRow(data);
  }

  Future<List<Store>> getAllStores({int limit = 100, int offset = 0}) async {
    final data = await _client
        .from('stores')
        .select()
        .eq('is_active', true)
        .order('name')
        .range(offset, offset + limit - 1)
        .timeout(AppConstants.networkTimeout);
    return (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_storeFromRow)
        .toList();
  }

  Store _storeFromRow(Map<String, dynamic> row) {
    return Store(
      id: row['id'] as String,
      name: row['name'] as String,
      address: row['address'] as String? ?? '',
      phone: row['phone'] as String?,
      email: row['email'] as String?,
      lat: (row['lat'] as num?)?.toDouble() ?? 0,
      lng: (row['lng'] as num?)?.toDouble() ?? 0,
      imageUrl: row['image_url'] as String?,
      logoUrl: row['logo'] as String?,
      description: row['description'] as String?,
      isActive: row['is_active'] as bool? ?? true,
      ownerId: row['owner_id'] as String? ?? '',
      deliveryRadius: (row['delivery_radius'] as num?)?.toDouble(),
      minOrderAmount: (row['min_order_amount'] as num?)?.toDouble(),
      deliveryFee: (row['delivery_fee'] as num?)?.toDouble(),
      acceptsDelivery: row['accepts_delivery'] as bool? ?? true,
      acceptsPickup: row['accepts_pickup'] as bool? ?? true,
      createdAt: DateTime.parse(
        row['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Haversine distance in km
  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;
}
