import '../../../models/user.dart';
import '../../../dto/shared/enum_parsers.dart';

/// Entity for storing user data locally
class UserEntity {
  final String id;
  final String phone;
  final String name;
  final String role; // Stored as String
  final String? storeId;
  final String createdAt; // ISO8601 string

  const UserEntity({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    this.storeId,
    required this.createdAt,
  });

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'role': role,
        'store_id': storeId,
        'created_at': createdAt,
      };

  /// Creates from JSON storage
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      storeId: json['store_id'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  /// Creates from Domain User model
  factory UserEntity.fromDomain(User user) {
    return UserEntity(
      id: user.id,
      phone: user.phone,
      name: user.name,
      role: user.role.name,
      storeId: user.storeId,
      createdAt: user.createdAt.toIso8601String(),
    );
  }

  /// Converts to Domain User model
  User toDomain() {
    return User(
      id: id,
      phone: phone,
      name: name,
      role: UserRoleX.fromApi(role),
      storeId: storeId,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
