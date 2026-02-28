import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/auth_tokens.dart';

part 'auth_tokens_response.freezed.dart';
part 'auth_tokens_response.g.dart';

/// DTO for auth tokens response from API (snake_case)
@freezed
class AuthTokensResponse with _$AuthTokensResponse {
  const AuthTokensResponse._();

  const factory AuthTokensResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_at') required String expiresAt,
  }) = _AuthTokensResponse;

  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensResponseFromJson(json);

  /// Maps DTO to Domain model
  AuthTokens toDomain() {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.tryParse(expiresAt) ?? DateTime.now(),
    );
  }
}
