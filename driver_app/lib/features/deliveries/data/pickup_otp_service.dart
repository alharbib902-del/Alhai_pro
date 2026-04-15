import 'package:supabase_flutter/supabase_flutter.dart';

/// Client-side service for the pickup OTP verification flow.
///
/// Communicates with the backend via Supabase RPCs:
/// - `request_pickup_otp` — generates a new 4-digit OTP
/// - `verify_pickup_otp` — validates the driver's input
///
/// If the backend RPCs are not deployed yet, methods throw a user-friendly
/// [OtpNotAvailableException] instead of a cryptic Postgres error.
class PickupOtpService {
  final SupabaseClient _client;

  PickupOtpService(this._client);

  /// Request a new OTP for the given order.
  ///
  /// Returns the OTP ID and expiration time.
  /// Throws [OtpNotAvailableException] if the backend RPC is not deployed.
  Future<({String otpId, DateTime expiresAt})> requestOtp(
    String orderId,
  ) async {
    try {
      final response = await _client.rpc(
        'request_pickup_otp',
        params: {'order_id': orderId},
      );
      final data = response as Map<String, dynamic>;
      return (
        otpId: data['otp_id'] as String,
        expiresAt: DateTime.parse(data['expires_at'] as String),
      );
    } on PostgrestException catch (e) {
      if (e.code == '42883') {
        throw OtpNotAvailableException();
      }
      rethrow;
    }
  }

  /// Verify the OTP entered by the driver.
  ///
  /// On success, the backend transitions the order to `picked_up`.
  /// Throws [OtpVerificationException] with a user-friendly message on failure.
  /// Throws [OtpNotAvailableException] if the backend RPC is not deployed.
  Future<void> verifyOtp({
    required String orderId,
    required String otpCode,
  }) async {
    try {
      final response = await _client.rpc(
        'verify_pickup_otp',
        params: {'order_id': orderId, 'otp_code': otpCode},
      );
      final data = response as Map<String, dynamic>;
      if (data['success'] != true) {
        throw OtpVerificationException(
          data['error'] as String? ?? 'فشل التحقق',
          attemptsRemaining: data['attempts_remaining'] as int?,
        );
      }
    } on PostgrestException catch (e) {
      if (e.code == '42883') {
        throw OtpNotAvailableException();
      }
      // Map known error messages to user-friendly exceptions.
      final msg = e.message;
      if (msg.contains('expired') || msg.contains('انتهت')) {
        throw OtpVerificationException('انتهت صلاحية الرمز. اطلب رمزاً جديداً.');
      }
      if (msg.contains('max_attempts') || msg.contains('محاولات')) {
        throw OtpVerificationException(
          'تم تجاوز الحد الأقصى للمحاولات. تواصل مع الدعم.',
          isLocked: true,
        );
      }
      if (msg.contains('already_verified') || msg.contains('مسبقاً')) {
        throw OtpVerificationException('تم التحقق من هذا الطلب مسبقاً.');
      }
      throw OtpVerificationException(
        'رمز غير صحيح. حاول مرة أخرى.',
      );
    }
  }
}

/// Thrown when the backend OTP RPCs are not deployed yet.
class OtpNotAvailableException implements Exception {
  final String message = 'خاصية التحقق غير مفعّلة بعد. يرجى التواصل مع الدعم.';

  @override
  String toString() => message;
}

/// Thrown when OTP verification fails (wrong code, expired, locked, etc.).
class OtpVerificationException implements Exception {
  final String message;
  final int? attemptsRemaining;
  final bool isLocked;

  OtpVerificationException(
    this.message, {
    this.attemptsRemaining,
    this.isLocked = false,
  });

  @override
  String toString() => message;
}
