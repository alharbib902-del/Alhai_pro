import 'package:dio/dio.dart';

import '../../datasources/remote/delivery_remote_datasource.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/address.dart';
import '../../models/delivery.dart';
import '../../models/enums/delivery_status.dart';
import '../delivery_repository.dart';

/// Implementation of DeliveryRepository
class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryRemoteDataSource _remote;

  DeliveryRepositoryImpl({
    required DeliveryRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<List<Delivery>> getMyDeliveries() async {
    try {
      final responses = await _remote.getMyDeliveries();
      return responses.map((r) => _toDomain(r)).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Delivery> getDelivery(String id) async {
    try {
      final response = await _remote.getDelivery(id);
      return _toDomain(response);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Delivery?> getDeliveryByOrderId(String orderId) async {
    try {
      final response = await _remote.getDeliveryByOrderId(orderId);
      return response != null ? _toDomain(response) : null;
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Delivery> updateStatus(String id, DeliveryStatus status) async {
    try {
      final response = await _remote.updateStatus(id, status);
      return _toDomain(response);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> updateLocation({
    required String deliveryId,
    required double lat,
    required double lng,
  }) async {
    try {
      await _remote.updateLocation(
        deliveryId: deliveryId,
        lat: lat,
        lng: lng,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Delivery> acceptDelivery(String id) async {
    try {
      final response = await _remote.acceptDelivery(id);
      return _toDomain(response);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> rejectDelivery(String id, {String? reason}) async {
    try {
      await _remote.rejectDelivery(id, reason: reason);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Delivery> markPickedUp(String id) async {
    try {
      final response = await _remote.markPickedUp(id);
      return _toDomain(response);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Delivery> markDelivered(String id, {String? notes}) async {
    try {
      final response = await _remote.markDelivered(id, notes: notes);
      return _toDomain(response);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> reportIssue(String id, String issue) async {
    try {
      await _remote.reportIssue(id, issue);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  /// Convert DeliveryResponse to Delivery domain model
  Delivery _toDomain(DeliveryResponse response) {
    return Delivery(
      id: response.id,
      orderId: response.orderId,
      driverId: response.driverId,
      status: DeliveryStatusX.fromApi(response.status),
      pickupAddress: Address(
        id: response.pickupAddress.id,
        label: response.pickupAddress.label,
        fullAddress: response.pickupAddress.fullAddress,
        city: response.pickupAddress.city,
        lat: response.pickupAddress.lat,
        lng: response.pickupAddress.lng,
      ),
      deliveryAddress: Address(
        id: response.deliveryAddress.id,
        label: response.deliveryAddress.label,
        fullAddress: response.deliveryAddress.fullAddress,
        city: response.deliveryAddress.city,
        lat: response.deliveryAddress.lat,
        lng: response.deliveryAddress.lng,
      ),
      driverName: response.driverName,
      driverPhone: response.driverPhone,
      driverLat: response.driverLat,
      driverLng: response.driverLng,
      estimatedArrival: response.estimatedArrival != null
          ? DateTime.parse(response.estimatedArrival!)
          : null,
      pickedUpAt: response.pickedUpAt != null
          ? DateTime.parse(response.pickedUpAt!)
          : null,
      deliveredAt: response.deliveredAt != null
          ? DateTime.parse(response.deliveredAt!)
          : null,
      notes: response.notes,
      createdAt: DateTime.parse(response.createdAt),
    );
  }
}
