import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entities/auth_tokens_entity.dart';
import 'entities/user_entity.dart';

/// Local data source contract for auth storage
abstract class AuthLocalDataSource {
  /// Saves auth tokens to secure storage
  Future<void> saveTokens(AuthTokensEntity tokens);

  /// Gets stored auth tokens (null if not saved)
  Future<AuthTokensEntity?> getTokens();

  /// Clears stored auth tokens
  Future<void> clearTokens();

  /// Saves user data to local storage
  Future<void> saveUser(UserEntity user);

  /// Gets stored user data (null if not saved)
  Future<UserEntity?> getUser();

  /// Clears stored user data
  Future<void> clearUser();
}

/// Implementation of AuthLocalDataSource
/// Uses FlutterSecureStorage for tokens, SharedPreferences for user
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _tokensKey = 'auth_tokens';
  static const String _userKey = 'auth_user';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  }) : _secureStorage = secureStorage,
       _prefs = prefs;

  // ==================== Tokens (SecureStorage) ====================

  @override
  Future<void> saveTokens(AuthTokensEntity tokens) async {
    final jsonString = jsonEncode(tokens.toJson());
    await _secureStorage.write(key: _tokensKey, value: jsonString);
  }

  @override
  Future<AuthTokensEntity?> getTokens() async {
    final jsonString = await _secureStorage.read(key: _tokensKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthTokensEntity.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _tokensKey);
  }

  // ==================== User (SharedPreferences) ====================

  @override
  Future<void> saveUser(UserEntity user) async {
    final jsonString = jsonEncode(user.toJson());
    await _prefs.setString(_userKey, jsonString);
  }

  @override
  Future<UserEntity?> getUser() async {
    final jsonString = _prefs.getString(_userKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserEntity.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }
}
