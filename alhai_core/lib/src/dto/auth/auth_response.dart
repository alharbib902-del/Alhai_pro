import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/auth_result.dart';
import '../../models/user.dart';
import '../shared/enum_parsers.dart';
import 'auth_tokens_response.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// DTO for user data in auth response (snake_case)
@freezed
class UserResponse with _$UserResponse {
  const UserResponse._();

  const factory UserResponse({
    required String id,
    required String phone,
    required String name,
    required String role,
    @JsonKey(name: 'store_id') String? storeId,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  /// Maps DTO to Domain model (called from Repository only)
  User toDomain() {
    return User(
      id: id,
      phone: phone,
      name: name,
      role: UserRoleX.fromApi(role),
      storeId: storeId,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}

/// DTO for complete auth response from API
@freezed
class AuthResponse with _$AuthResponse {
  const AuthResponse._();

  const factory AuthResponse({
    required UserResponse user,
    required AuthTokensResponse tokens,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  /// Maps DTO to Domain model (called from Repository only)
  AuthResult toDomain() {
    return AuthResult(
      user: user.toDomain(),
      tokens: tokens.toDomain(),
    );
  }
}
