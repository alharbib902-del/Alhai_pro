import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_tokens.dart';
import 'user.dart';

part 'auth_result.freezed.dart';
part 'auth_result.g.dart';

/// AuthResult domain model - result of successful authentication
@freezed
class AuthResult with _$AuthResult {
  const factory AuthResult({required User user, required AuthTokens tokens}) =
      _AuthResult;

  factory AuthResult.fromJson(Map<String, dynamic> json) =>
      _$AuthResultFromJson(json);
}
