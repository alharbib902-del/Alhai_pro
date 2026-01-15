import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

/// Address domain model for delivery
@freezed
class Address with _$Address {
  const factory Address({
    required String id,
    required String label,
    required String fullAddress,
    required String city,
    String? district,
    String? street,
    String? buildingNumber,
    String? apartmentNumber,
    String? landmark,
    required double lat,
    required double lng,
    @Default(false) bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}
