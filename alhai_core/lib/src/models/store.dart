import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

/// Store domain model (v3.2 - Complete)
@freezed
class Store with _$Store {
  const Store._();

  const factory Store({
    required String id,
    required String name,
    required String address,
    String? phone,
    String? email,
    required double lat,
    required double lng,
    String? imageUrl,
    String? logoUrl,
    String? description,
    required bool isActive,
    required String ownerId,
    double? deliveryRadius,
    double? minOrderAmount,
    double? deliveryFee,
    @Default(true) bool acceptsDelivery,
    @Default(true) bool acceptsPickup,
    WorkingHours? workingHours,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) =>
      _$StoreFromJson(json);

  /// Check if store is currently open
  bool isOpenNow() {
    if (workingHours == null) return true;
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final hours = workingHours!.toJson()[dayName] as Map<String, dynamic>?;
    if (hours == null || hours['isClosed'] == true) return false;
    
    final openTime = _parseTime(hours['open'] as String?);
    final closeTime = _parseTime(hours['close'] as String?);
    if (openTime == null || closeTime == null) return false;
    
    final nowMinutes = now.hour * 60 + now.minute;
    return nowMinutes >= openTime && nowMinutes <= closeTime;
  }

  String _getDayName(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }

  int? _parseTime(String? time) {
    if (time == null) return null;
    final parts = time.split(':');
    if (parts.length != 2) return null;
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

/// Working hours for each day
@freezed
class WorkingHours with _$WorkingHours {
  const factory WorkingHours({
    DayHours? monday,
    DayHours? tuesday,
    DayHours? wednesday,
    DayHours? thursday,
    DayHours? friday,
    DayHours? saturday,
    DayHours? sunday,
  }) = _WorkingHours;

  factory WorkingHours.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursFromJson(json);
}

/// Hours for a specific day
@freezed
class DayHours with _$DayHours {
  const factory DayHours({
    required String open,
    required String close,
    @Default(false) bool isClosed,
  }) = _DayHours;

  factory DayHours.fromJson(Map<String, dynamic> json) =>
      _$DayHoursFromJson(json);
}
