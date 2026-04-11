import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:alhai_core/alhai_core.dart';

/// Implementation of PinValidationService for supervisor PIN validation
/// Supports both online and offline (TOTP) validation
/// Referenced by: US-7.3 (TOTP Offline PIN)
class PinValidationServiceImpl implements PinValidationService {
  final StoreMembersRepository _membersRepository;

  // In-memory cache for TOTP secrets (in production, use secure storage)
  final List<TotpSecret> _cachedSecrets = [];

  // Failed attempts tracking
  final Map<String, int> _failedAttempts = {};
  final Map<String, DateTime> _lockouts = {};

  // Emergency codes storage
  final Map<String, EmergencyCode> _emergencyCodes = {};

  // Local audit log for PIN validation attempts
  final List<PinAuditLogEntry> _auditLog = [];

  // Configuration
  static const int _maxAttempts = 3;
  static const Duration _lockoutDuration = Duration(minutes: 15);
  static const Duration _emergencyCodeValidity = Duration(hours: 24);

  PinValidationServiceImpl({required StoreMembersRepository membersRepository})
    : _membersRepository = membersRepository;

  @override
  Future<PinValidationResult> validatePin(PinValidationRequest request) async {
    try {
      final userId = request.supervisorId;

      // Check if locked out
      if (userId != null && _isLockedOut(userId)) {
        return PinValidationResult.failure(
          errorMessage: 'الحساب مقفل. حاول مرة أخرى لاحقًا',
          remainingAttempts: 0,
          lockedUntil: _lockouts[userId],
        );
      }

      // In production, this would call the server to validate PIN
      // For now, we'll use a mock validation based on PIN hash
      final isValid = await _validatePinOnline(request.pin, userId);

      if (isValid) {
        // Clear failed attempts on success
        if (userId != null) {
          _failedAttempts.remove(userId);
        }

        // Get user details (mock)
        return PinValidationResult.success(
          userId: userId ?? 'supervisor_1',
          userName: 'المشرف',
          role: request.action.requiredRole,
          permissions: _getPermissionsForAction(request.action),
        );
      } else {
        // Increment failed attempts
        if (userId != null) {
          _failedAttempts[userId] = (_failedAttempts[userId] ?? 0) + 1;

          if (_failedAttempts[userId]! >= _maxAttempts) {
            _lockouts[userId] = DateTime.now().add(_lockoutDuration);
            return PinValidationResult.failure(
              errorMessage: 'تم تجاوز عدد المحاولات المسموحة',
              remainingAttempts: 0,
              lockedUntil: _lockouts[userId],
            );
          }
        }

        return PinValidationResult.failure(
          errorMessage: 'رمز PIN غير صحيح',
          remainingAttempts: _maxAttempts - (_failedAttempts[userId] ?? 0),
        );
      }
    } catch (e) {
      return PinValidationResult.failure(errorMessage: 'فشل التحقق من PIN: $e');
    }
  }

  @override
  Future<PinValidationResult> validatePinOffline(
    PinValidationRequest request,
  ) async {
    try {
      // Check if offline validation is available
      if (!await isOfflineValidationAvailable()) {
        return PinValidationResult.failure(
          errorMessage: 'التحقق غير المتصل غير متاح. يرجى المزامنة أولاً',
        );
      }

      // Find TOTP secret for the supervisor
      final secret = _cachedSecrets.firstWhere(
        (s) => s.userId == request.supervisorId,
        orElse: () => throw Exception('لم يتم العثور على بيانات المستخدم'),
      );

      // Generate current TOTP code
      final currentCode = _generateTotpCode(secret.secret);

      // Validate PIN against TOTP
      if (request.pin == currentCode) {
        return PinValidationResult.success(
          userId: secret.userId,
          userName: 'المشرف (غير متصل)',
          role: request.action.requiredRole,
          permissions: _getPermissionsForAction(request.action),
        );
      }

      // Also check previous and next codes for clock drift tolerance
      final previousCode = _generateTotpCode(secret.secret, offset: -1);
      final nextCode = _generateTotpCode(secret.secret, offset: 1);

      if (request.pin == previousCode || request.pin == nextCode) {
        return PinValidationResult.success(
          userId: secret.userId,
          userName: 'المشرف (غير متصل)',
          role: request.action.requiredRole,
          permissions: _getPermissionsForAction(request.action),
        );
      }

      return PinValidationResult.failure(errorMessage: 'رمز PIN غير صحيح');
    } catch (e) {
      return PinValidationResult.failure(
        errorMessage: 'فشل التحقق غير المتصل: $e',
      );
    }
  }

  @override
  Future<EmergencyCode> generateEmergencyCode(String supervisorId) async {
    // Generate a random 6-digit code
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = ((random % 900000) + 100000).toString();

    final emergencyCode = EmergencyCode(
      code: code,
      supervisorId: supervisorId,
      expiresAt: DateTime.now().add(_emergencyCodeValidity),
    );

    _emergencyCodes[code] = emergencyCode;

    return emergencyCode;
  }

  @override
  Future<PinValidationResult> validateEmergencyCode(String code) async {
    final emergencyCode = _emergencyCodes[code];

    if (emergencyCode == null) {
      return PinValidationResult.failure(errorMessage: 'رمز الطوارئ غير صحيح');
    }

    if (emergencyCode.isUsed) {
      return PinValidationResult.failure(
        errorMessage: 'رمز الطوارئ مستخدم مسبقًا',
      );
    }

    if (emergencyCode.expiresAt.isBefore(DateTime.now())) {
      return PinValidationResult.failure(
        errorMessage: 'رمز الطوارئ منتهي الصلاحية',
      );
    }

    // Mark as used
    _emergencyCodes[code] = EmergencyCode(
      code: emergencyCode.code,
      supervisorId: emergencyCode.supervisorId,
      expiresAt: emergencyCode.expiresAt,
      isUsed: true,
    );

    return PinValidationResult.success(
      userId: emergencyCode.supervisorId,
      userName: 'المشرف (طوارئ)',
      role: 'SUPERVISOR',
    );
  }

  @override
  Future<void> syncTotpSecrets(String storeId) async {
    try {
      // In production, fetch TOTP secrets from server
      // For now, generate mock secrets
      final membersResult = await _membersRepository.getStoreMembers(storeId);
      final members = membersResult.items;

      _cachedSecrets.clear();

      for (final member in members) {
        // Only sync secrets for supervisors and managers
        final roleName = member.role.name.toUpperCase();
        if (roleName == 'SUPERVISOR' || roleName == 'MANAGER') {
          _cachedSecrets.add(
            TotpSecret(
              userId: member.id,
              secret: _generateSecretForUser(member.id),
              syncedAt: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      throw Exception('فشل مزامنة بيانات التحقق: $e');
    }
  }

  @override
  Future<List<TotpSecret>> getCachedSecrets() async {
    return List.unmodifiable(_cachedSecrets);
  }

  @override
  Future<bool> isOfflineValidationAvailable() async {
    if (_cachedSecrets.isEmpty) return false;

    // Check if secrets are recent (within 24 hours)
    final oldestSecret = _cachedSecrets.reduce(
      (a, b) => a.syncedAt.isBefore(b.syncedAt) ? a : b,
    );

    return DateTime.now().difference(oldestSecret.syncedAt).inHours < 24;
  }

  @override
  Future<void> logValidationAttempt({
    required String userId,
    required PinActionType action,
    required bool success,
    String? ipAddress,
  }) async {
    final entry = PinAuditLogEntry(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      action: action,
      success: success,
      ipAddress: ipAddress,
      timestamp: DateTime.now(),
      failedAttemptCount: _failedAttempts[userId] ?? 0,
      isLockedOut: _isLockedOut(userId),
    );

    _auditLog.add(entry);

    // Keep only the last 1000 entries in memory to prevent unbounded growth
    if (_auditLog.length > 1000) {
      _auditLog.removeRange(0, _auditLog.length - 1000);
    }
  }

  /// Returns a read-only copy of the local audit log.
  /// Entries are ordered chronologically (oldest first).
  List<PinAuditLogEntry> getAuditLog() {
    return List.unmodifiable(_auditLog);
  }

  /// Returns audit log entries filtered by [userId].
  List<PinAuditLogEntry> getAuditLogForUser(String userId) {
    return List.unmodifiable(
      _auditLog.where((entry) => entry.userId == userId),
    );
  }

  /// Returns only failed audit log entries, optionally filtered by date range.
  List<PinAuditLogEntry> getFailedAttempts({DateTime? since, DateTime? until}) {
    return List.unmodifiable(
      _auditLog.where((entry) {
        if (entry.success) return false;
        if (since != null && entry.timestamp.isBefore(since)) return false;
        if (until != null && entry.timestamp.isAfter(until)) return false;
        return true;
      }),
    );
  }

  /// Exports the audit log as a list of JSON-serializable maps.
  List<Map<String, dynamic>> exportAuditLog() {
    return _auditLog.map((entry) => entry.toJson()).toList();
  }

  @override
  Future<void> clearFailedAttempts(String userId) async {
    _failedAttempts.remove(userId);
    _lockouts.remove(userId);
  }

  @override
  Future<int> getRemainingAttempts(String userId) async {
    final attempts = _failedAttempts[userId] ?? 0;
    return _maxAttempts - attempts;
  }

  // Helper methods

  bool _isLockedOut(String userId) {
    final lockoutTime = _lockouts[userId];
    if (lockoutTime == null) return false;

    if (lockoutTime.isAfter(DateTime.now())) {
      return true;
    } else {
      // Lockout expired, clear it
      _lockouts.remove(userId);
      _failedAttempts.remove(userId);
      return false;
    }
  }

  Future<bool> _validatePinOnline(String pin, String? userId) async {
    // In production, this would make an API call
    // For now, accept any 4+ digit PIN
    return pin.length >= 4;
  }

  String _generateTotpCode(String secret, {int offset = 0}) {
    // Simple time-based code generation
    // In production, use a proper TOTP library (otp package)
    final timeStep =
        (DateTime.now().millisecondsSinceEpoch / 30000).floor() + offset;
    final data = '$secret$timeStep';
    final hash = sha256.convert(utf8.encode(data));
    final code =
        (hash.bytes.last * 100000 +
            hash.bytes.first * 1000 +
            hash.bytes[1] * 10 +
            hash.bytes[2]) %
        1000000;
    return code.toString().padLeft(6, '0');
  }

  String _generateSecretForUser(String userId) {
    // Generate a deterministic secret based on user ID
    // In production, this would come from the server
    final hash = sha256.convert(utf8.encode('alhai_totp_$userId'));
    return base64Encode(hash.bytes.take(16).toList());
  }

  List<String> _getPermissionsForAction(PinActionType action) {
    switch (action) {
      case PinActionType.refund:
        return ['refund.create', 'refund.approve'];
      case PinActionType.discount:
        return ['discount.apply', 'discount.override'];
      case PinActionType.voidSale:
        return ['sale.void'];
      case PinActionType.cashOut:
        return ['cash.withdraw'];
      case PinActionType.priceOverride:
        return ['product.price_override'];
      case PinActionType.shiftClose:
        return ['shift.close'];
    }
  }
}

/// Structured audit log entry for PIN validation attempts.
/// Stores all relevant context for security auditing and compliance.
class PinAuditLogEntry {
  final String id;
  final String userId;
  final PinActionType action;
  final bool success;
  final String? ipAddress;
  final DateTime timestamp;
  final int failedAttemptCount;
  final bool isLockedOut;

  const PinAuditLogEntry({
    required this.id,
    required this.userId,
    required this.action,
    required this.success,
    this.ipAddress,
    required this.timestamp,
    required this.failedAttemptCount,
    required this.isLockedOut,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'action': action.name,
    'success': success,
    'ipAddress': ipAddress,
    'timestamp': timestamp.toIso8601String(),
    'failedAttemptCount': failedAttemptCount,
    'isLockedOut': isLockedOut,
  };

  factory PinAuditLogEntry.fromJson(
    Map<String, dynamic> json,
  ) => PinAuditLogEntry(
    id: json['id'] as String,
    userId: json['userId'] as String,
    action: PinActionType.values.firstWhere((a) => a.name == json['action']),
    success: json['success'] as bool,
    ipAddress: json['ipAddress'] as String?,
    timestamp: DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now(),
    failedAttemptCount: json['failedAttemptCount'] as int,
    isLockedOut: json['isLockedOut'] as bool,
  );

  @override
  String toString() =>
      'PinAuditLogEntry(userId: $userId, action: ${action.name}, '
      'success: $success, timestamp: ${timestamp.toIso8601String()})';
}
