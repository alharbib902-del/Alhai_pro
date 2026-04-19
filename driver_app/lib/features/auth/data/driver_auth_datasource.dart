import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:alhai_core/alhai_core.dart';

import '../../../core/services/sentry_service.dart';

/// Auth datasource for driver app.
/// Handles OTP login and validates that the user has 'delivery' role.
class DriverAuthDatasource {
  final SupabaseClient _client;

  DriverAuthDatasource(this._client);

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
      throw Exception('فشل التحقق من الرمز');
    }

    // Get or create user row - drivers must have 'delivery' role
    final existing = await _client
        .from('users')
        .select()
        .eq('id', supabaseUser.id)
        .maybeSingle();

    Map<String, dynamic> userData;

    if (existing != null) {
      // Existing user - verify role
      final role = existing['role'] as String?;
      if (role != 'delivery') {
        throw Exception('هذا الحساب ليس حساب سائق');
      }
      // Block inactive drivers — they must wait for admin approval.
      if (existing['is_active'] != true) {
        throw const DriverPendingApprovalException();
      }
      userData = existing;
    } else {
      // New user - create with delivery role, inactive until admin approves.
      userData = await _client
          .from('users')
          .upsert({
            'id': supabaseUser.id,
            'phone': phone,
            'name': phone,
            'role': 'delivery',
            'is_active': false,
            'created_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id')
          .select()
          .single();
    }

    // Block inactive drivers — they must wait for admin approval.
    if (userData['is_active'] != true) {
      throw const DriverPendingApprovalException();
    }

    final user = _mapUser(userData);
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
          .single();

      final role = data['role'] as String?;
      if (role != 'delivery') return null;

      return _mapUser(data);
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'getCurrentUser');
      return null;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? vehicleType,
    String? vehiclePlate,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;

    await _client.from('users').update(updates).eq('id', userId);

    // Update driver record if vehicle info provided
    if (vehicleType != null || vehiclePlate != null) {
      // Fetch the driver's assigned store_id. Admin sets this during approval.
      // The v55 strict RLS policy (has_store_access(store_id)) requires
      // store_id to be present and match the user's accessible stores.
      final me = await _client
          .from('users')
          .select('store_id')
          .eq('id', userId)
          .single();
      final storeId = me['store_id'] as String?;
      if (storeId == null || storeId.isEmpty) {
        throw Exception('السائق غير مرتبط بمتجر — يرجى التواصل مع الإدارة');
      }

      final driverUpdates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (vehicleType != null) driverUpdates['vehicle_type'] = vehicleType;
      if (vehiclePlate != null) driverUpdates['vehicle_plate'] = vehiclePlate;

      await _client.from('drivers').upsert({
        'id': userId,
        'store_id': storeId,
        'name': name ?? '',
        'phone': _client.auth.currentUser?.phone ?? '',
        ...driverUpdates,
      }, onConflict: 'id');
    }
  }

  Future<void> updateFcmToken(String token) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('users').update({'fcm_token': token}).eq('id', userId);
  }

  Future<void> logout() async {
    // Clear FCM token on logout
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      await _client.from('users').update({'fcm_token': null}).eq('id', userId);
    }
    await _client.auth.signOut();
  }

  bool get isAuthenticated => _client.auth.currentSession != null;

  User _mapUser(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String,
      phone: data['phone'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String?,
      imageUrl: data['image_url'] as String?,
      role: UserRole.delivery,
      isActive: data['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(
        data['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

/// Thrown when a driver account exists but has not been approved by admin yet.
class DriverPendingApprovalException implements Exception {
  const DriverPendingApprovalException();

  String get message => 'حسابك قيد المراجعة من قبل الإدارة';

  @override
  String toString() => message;
}
