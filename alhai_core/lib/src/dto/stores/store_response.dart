import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/store.dart';

part 'store_response.freezed.dart';
part 'store_response.g.dart';

/// DTO for store response from API (snake_case) - Complete v3.2
@freezed
class StoreResponse with _$StoreResponse {
  const StoreResponse._();

  const factory StoreResponse({
    required String id,
    required String name,
    required String address,
    String? phone,
    String? email,
    required double lat,
    required double lng,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'logo_url') String? logoUrl,
    String? description,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'delivery_radius') double? deliveryRadius,
    @JsonKey(name: 'min_order_amount') double? minOrderAmount,
    @JsonKey(name: 'delivery_fee') double? deliveryFee,
    @JsonKey(name: 'accepts_delivery') @Default(true) bool acceptsDelivery,
    @JsonKey(name: 'accepts_pickup') @Default(true) bool acceptsPickup,
    @JsonKey(name: 'working_hours') Map<String, dynamic>? workingHoursJson,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _StoreResponse;

  factory StoreResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreResponseFromJson(json);

  /// Maps DTO to Domain model
  Store toDomain() {
    return Store(
      id: id,
      name: name,
      address: address,
      phone: phone,
      email: email,
      lat: lat,
      lng: lng,
      imageUrl: imageUrl,
      logoUrl: logoUrl,
      description: description,
      isActive: isActive,
      ownerId: ownerId,
      deliveryRadius: deliveryRadius,
      minOrderAmount: minOrderAmount,
      deliveryFee: deliveryFee,
      acceptsDelivery: acceptsDelivery,
      acceptsPickup: acceptsPickup,
      workingHours: workingHoursJson != null 
          ? WorkingHours.fromJson(workingHoursJson!) 
          : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}
