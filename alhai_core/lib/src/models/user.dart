import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums/user_role.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User domain model (v3.2 - Complete)
@freezed
class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String phone,
    String? email,
    required String name,
    String? imageUrl,
    required UserRole role,
    String? storeId,
    @Default(true) bool isActive,
    @Default(false) bool isVerified,
    String? fcmToken,
    DateTime? lastLoginAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Check if user is admin
  bool get isAdmin => role == UserRole.superAdmin;

  /// Check if user is store owner
  bool get isStoreOwner => role == UserRole.storeOwner;

  /// Check if user is employee
  bool get isEmployee => role == UserRole.employee;

  /// Check if user is delivery driver
  bool get isDelivery => role == UserRole.delivery;

  /// Check if user is customer
  bool get isCustomer => role == UserRole.customer;

  /// Check if user can access store management
  bool get canManageStore =>
      role == UserRole.superAdmin || role == UserRole.storeOwner;

  /// Get initials for avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
