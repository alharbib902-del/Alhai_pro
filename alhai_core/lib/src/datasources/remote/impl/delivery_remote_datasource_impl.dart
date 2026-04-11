import 'package:dio/dio.dart';

import '../../../dto/addresses/address_response.dart';
import '../../../models/enums/delivery_status.dart';
import '../delivery_remote_datasource.dart';

/// Implementation of DeliveryRemoteDataSource
class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final Dio _dio;

  DeliveryRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<DeliveryResponse>> getMyDeliveries() async {
    final response = await _dio.get('/deliveries/mine');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => _parseDeliveryResponse(json)).toList();
  }

  @override
  Future<DeliveryResponse> getDelivery(String id) async {
    final response = await _dio.get('/deliveries/$id');
    return _parseDeliveryResponse(response.data);
  }

  @override
  Future<DeliveryResponse?> getDeliveryByOrderId(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId/delivery');
      return _parseDeliveryResponse(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<DeliveryResponse> updateStatus(
    String id,
    DeliveryStatus status,
  ) async {
    final response = await _dio.patch(
      '/deliveries/$id/status',
      data: {'status': status.name},
    );
    return _parseDeliveryResponse(response.data);
  }

  @override
  Future<void> updateLocation({
    required String deliveryId,
    required double lat,
    required double lng,
  }) async {
    await _dio.post(
      '/deliveries/$deliveryId/location',
      data: {'lat': lat, 'lng': lng},
    );
  }

  @override
  Future<DeliveryResponse> acceptDelivery(String id) async {
    final response = await _dio.post('/deliveries/$id/accept');
    return _parseDeliveryResponse(response.data);
  }

  @override
  Future<void> rejectDelivery(String id, {String? reason}) async {
    await _dio.post(
      '/deliveries/$id/reject',
      data: {if (reason != null) 'reason': reason},
    );
  }

  @override
  Future<DeliveryResponse> markPickedUp(String id) async {
    final response = await _dio.post('/deliveries/$id/pickup');
    return _parseDeliveryResponse(response.data);
  }

  @override
  Future<DeliveryResponse> markDelivered(String id, {String? notes}) async {
    final response = await _dio.post(
      '/deliveries/$id/deliver',
      data: {if (notes != null) 'notes': notes},
    );
    return _parseDeliveryResponse(response.data);
  }

  @override
  Future<void> reportIssue(String id, String issue) async {
    await _dio.post('/deliveries/$id/issue', data: {'issue': issue});
  }

  DeliveryResponse _parseDeliveryResponse(Map<String, dynamic> json) {
    return DeliveryResponse(
      id: json['id'],
      orderId: json['order_id'],
      driverId: json['driver_id'],
      status: json['status'],
      pickupAddress: AddressResponse.fromJson(json['pickup_address']),
      deliveryAddress: AddressResponse.fromJson(json['delivery_address']),
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      driverLat: json['driver_lat']?.toDouble(),
      driverLng: json['driver_lng']?.toDouble(),
      estimatedArrival: json['estimated_arrival'],
      pickedUpAt: json['picked_up_at'],
      deliveredAt: json['delivered_at'],
      notes: json['notes'],
      createdAt: json['created_at'],
    );
  }
}
