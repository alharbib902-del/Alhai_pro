import 'package:freezed_annotation/freezed_annotation.dart';

part 'pin_validation.freezed.dart';
part 'pin_validation.g.dart';

/// PIN action type enum (v2.5.0)
enum PinActionType {
  @JsonValue('REFUND')
  refund,
  @JsonValue('DISCOUNT')
  discount,
  @JsonValue('VOID')
  voidSale,
  @JsonValue('CASH_OUT')
  cashOut,
  @JsonValue('PRICE_OVERRIDE')
  priceOverride,
  @JsonValue('SHIFT_CLOSE')
  shiftClose,
}

/// Extension for PinActionType
extension PinActionTypeExt on PinActionType {
  String get displayNameAr {
    switch (this) {
      case PinActionType.refund:
        return 'مرتجع';
      case PinActionType.discount:
        return 'خصم';
      case PinActionType.voidSale:
        return 'إلغاء فاتورة';
      case PinActionType.cashOut:
        return 'سحب نقدي';
      case PinActionType.priceOverride:
        return 'تعديل سعر';
      case PinActionType.shiftClose:
        return 'إغلاق وردية';
    }
  }

  /// Minimum role required for this action
  String get requiredRole {
    switch (this) {
      case PinActionType.refund:
      case PinActionType.discount:
      case PinActionType.voidSale:
      case PinActionType.cashOut:
        return 'SUPERVISOR';
      case PinActionType.priceOverride:
      case PinActionType.shiftClose:
        return 'MANAGER';
    }
  }
}

/// PIN validation request model
@freezed
class PinValidationRequest with _$PinValidationRequest {
  const factory PinValidationRequest({
    required String pin,
    required PinActionType action,
    String? supervisorId,
  }) = _PinValidationRequest;

  factory PinValidationRequest.fromJson(Map<String, dynamic> json) =>
      _$PinValidationRequestFromJson(json);
}

/// PIN validation result model
@freezed
class PinValidationResult with _$PinValidationResult {
  const PinValidationResult._();

  const factory PinValidationResult({
    required bool isValid,
    String? userId,
    String? userName,
    String? role,
    List<String>? permissions,
    String? errorMessage,
    @Default(0) int remainingAttempts,
    DateTime? lockedUntil,
  }) = _PinValidationResult;

  factory PinValidationResult.fromJson(Map<String, dynamic> json) =>
      _$PinValidationResultFromJson(json);

  /// Check if account is locked
  bool get isLocked =>
      lockedUntil != null && lockedUntil!.isAfter(DateTime.now());

  /// Create success result
  factory PinValidationResult.success({
    required String userId,
    required String userName,
    required String role,
    List<String>? permissions,
  }) =>
      PinValidationResult(
        isValid: true,
        userId: userId,
        userName: userName,
        role: role,
        permissions: permissions ?? [],
      );

  /// Create failure result
  factory PinValidationResult.failure({
    required String errorMessage,
    int remainingAttempts = 3,
    DateTime? lockedUntil,
  }) =>
      PinValidationResult(
        isValid: false,
        errorMessage: errorMessage,
        remainingAttempts: remainingAttempts,
        lockedUntil: lockedUntil,
      );
}

/// Emergency code for offline PIN validation
@freezed
class EmergencyCode with _$EmergencyCode {
  const factory EmergencyCode({
    required String code,
    required String supervisorId,
    required DateTime expiresAt,
    @Default(false) bool isUsed,
  }) = _EmergencyCode;

  factory EmergencyCode.fromJson(Map<String, dynamic> json) =>
      _$EmergencyCodeFromJson(json);
}

/// TOTP secret for offline validation
@freezed
class TotpSecret with _$TotpSecret {
  const factory TotpSecret({
    required String userId,
    required String secret,
    required DateTime syncedAt,
  }) = _TotpSecret;

  factory TotpSecret.fromJson(Map<String, dynamic> json) =>
      _$TotpSecretFromJson(json);
}

/// PIN validation service interface (v2.5.0)
/// Referenced by: US-7.3 (TOTP Offline PIN)
abstract class PinValidationService {
  /// Validates supervisor PIN (online mode)
  Future<PinValidationResult> validatePin(PinValidationRequest request);

  /// Validates PIN offline using TOTP
  Future<PinValidationResult> validatePinOffline(PinValidationRequest request);

  /// Generates emergency code for offline use
  Future<EmergencyCode> generateEmergencyCode(String supervisorId);

  /// Validates emergency code
  Future<PinValidationResult> validateEmergencyCode(String code);

  /// Syncs TOTP secrets from server
  Future<void> syncTotpSecrets(String storeId);

  /// Gets cached TOTP secrets
  Future<List<TotpSecret>> getCachedSecrets();

  /// Checks if offline validation is available
  Future<bool> isOfflineValidationAvailable();

  /// Logs PIN validation attempt for audit
  Future<void> logValidationAttempt({
    required String userId,
    required PinActionType action,
    required bool success,
    String? ipAddress,
  });

  /// Clears failed attempts for a user
  Future<void> clearFailedAttempts(String userId);

  /// Gets remaining attempts before lockout
  Future<int> getRemainingAttempts(String userId);
}
