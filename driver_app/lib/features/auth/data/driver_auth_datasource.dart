import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:alhai_core/alhai_core.dart';

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
      userData = existing;
    } else {
      // New user - create with delivery role
      userData = await _client
          .from('users')
          .upsert({
            'id': supabaseUser.id,
            'phone': phone,
            'name': phone,
            'role': 'delivery',
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id')
          .select()
          .single();
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
    } catch (_) {
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
      final driverUpdates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (vehicleType != null) driverUpdates['vehicle_type'] = vehicleType;
      if (vehiclePlate != null) driverUpdates['vehicle_plate'] = vehiclePlate;

      await _client
          .from('drivers')
          .upsert({
            'id': userId,
            'name': name ?? '',
            'phone': _client.auth.currentUser?.phone ?? '',
            ...driverUpdates,
          }, onConflict: 'id');
    }
  }

  Future<void> updateFcmToken(String token) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('users')
        .update({'fcm_token': token})
        .eq('id', userId);
  }

  Future<void> logout() async {
    // Clear FCM token on logout
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      await _client
          .from('users')
          .update({'fcm_token': null})
          .eq('id', userId);
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
