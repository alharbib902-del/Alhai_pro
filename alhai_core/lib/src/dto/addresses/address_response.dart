import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/address.dart';

part 'address_response.freezed.dart';
part 'address_response.g.dart';

/// DTO for address response from API (snake_case)
@freezed
class AddressResponse with _$AddressResponse {
  const AddressResponse._();

  const factory AddressResponse({
    required String id,
    required String label,
    @JsonKey(name: 'full_address') required String fullAddress,
    required String city,
    String? district,
    String? street,
    @JsonKey(name: 'building_number') String? buildingNumber,
    @JsonKey(name: 'apartment_number') String? apartmentNumber,
    String? landmark,
    required double lat,
    required double lng,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _AddressResponse;

  factory AddressResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressResponseFromJson(json);

  /// Maps DTO to Domain model
  Address toDomain() {
    return Address(
      id: id,
      label: label,
      fullAddress: fullAddress,
      city: city,
      district: district,
      street: street,
      buildingNumber: buildingNumber,
      apartmentNumber: apartmentNumber,
      landmark: landmark,
      lat: lat,
      lng: lng,
      isDefault: isDefault,
    );
  }
}
