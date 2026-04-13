import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:alhai_core/alhai_core.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/sentry_service.dart';

class AuthDatasource {
  final SupabaseClient _client;

  AuthDatasource(this._client);

  Future<void> sendOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResult> verifyOtp(String phone, String otp) async {
    final response = await _client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );

    final supabaseUser = response.user;
    if (supabaseUser == null) {
      throw Exception('OTP verification failed');
    }

    // Upsert user row in public.users table
    final userData = await _client
        .from('users')
        .upsert({
          'id': supabaseUser.id,
          'phone': phone,
          'name': supabaseUser.userMetadata?['name'] ?? phone,
          'role': 'customer',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id')
        .select()
        .single()
        .timeout(AppConstants.networkTimeout);

    final user = User(
      id: userData['id'] as String,
      phone: userData['phone'] as String,
      name: userData['name'] as String? ?? phone,
      email: userData['email'] as String?,
      role: UserRole.customer,
      isActive: userData['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(
        userData['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );

    final session = response.session!;
    final tokens = AuthTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (session.expiresAt ?? 0) * 1000,
      ),
    );

    return AuthResult(user: user, tokens: tokens);
  }

  Future<User?> getCurrentUser() async {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser == null) return null;

    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', supabaseUser.id)
          .single()
          .timeout(AppConstants.networkTimeout);

      return User(
        id: data['id'] as String,
        phone: data['phone'] as String,
        name: data['name'] as String? ?? '',
        email: data['email'] as String?,
        imageUrl: data['image_url'] as String?,
        role: UserRole.customer,
        isActive: data['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(
          data['created_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
      );
    } catch (e, stack) {
      debugPrint('[AuthDatasource] Error fetching current user: $e');
      reportError(e, stackTrace: stack, hint: 'getCurrentUser');
      return null;
    }
  }

  Future<void> updateProfile({String? name, String? email}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    updates['updated_at'] = DateTime.now().toIso8601String();

    await _client
        .from('users')
        .update(updates)
        .eq('id', userId)
        .timeout(AppConstants.networkTimeout);
  }

  Future<void> logout() async {
    await _client.auth.signOut();

    // Clear SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e, stack) {
      debugPrint('[AuthDatasource] Error clearing SharedPreferences: $e');
      reportError(
        e,
        stackTrace: stack,
        hint: 'logout: clear SharedPreferences',
      );
    }

    // Clear secure storage tokens
    try {
      const secureStorage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      await secureStorage.deleteAll();
    } catch (e, stack) {
      debugPrint('[AuthDatasource] Error clearing secure storage: $e');
      reportError(e, stackTrace: stack, hint: 'logout: clear secure storage');
    }

    // Verify session is cleared (assert is stripped in release builds)
    if (_client.auth.currentSession != null) {
      debugPrint('[AuthDatasource] Warning: session not null after logout');
    }
  }

  bool get isAuthenticated => _client.auth.currentSession != null;
}
