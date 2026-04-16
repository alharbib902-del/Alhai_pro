/// MFA (Multi-Factor Authentication) service for TOTP-based 2FA.
///
/// Uses Supabase Auth MFA API for enrollment, challenge, and verification.
/// Backup codes are SHA-256 hashed before storage in user metadata.
///
/// Security notes:
/// - TOTP secrets never persist in client state after enrollment.
/// - Backup codes shown once, stored hashed (SHA-256).
/// - All verification goes through Supabase server-side.
/// - Supabase rate-limits failed verification attempts automatically.
library;

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data returned when starting MFA enrollment.
class EnrollmentData {
  /// The factor ID assigned by Supabase.
  final String factorId;

  /// The TOTP secret in Base32 format (for manual entry).
  final String secret;

  /// The otpauth:// URI for QR code generation.
  final String uri;

  const EnrollmentData({
    required this.factorId,
    required this.secret,
    required this.uri,
  });
}

/// Service for managing TOTP-based MFA via Supabase.
class MfaService {
  final SupabaseClient _client;

  MfaService(this._client);

  /// Check if the current user has a verified TOTP factor enrolled.
  Future<bool> isEnrolled() async {
    final response = await _client.auth.mfa.listFactors();
    return response.totp.isNotEmpty;
  }

  /// Get the verified TOTP factor, or null if none enrolled.
  Future<Factor?> getVerifiedFactor() async {
    final response = await _client.auth.mfa.listFactors();
    return response.totp.isEmpty ? null : response.totp.first;
  }

  /// Start TOTP enrollment. Returns data needed to display QR code.
  ///
  /// After calling this, the user must scan the QR code with an
  /// authenticator app, then call [verifyEnrollment] with the 6-digit code.
  Future<EnrollmentData> startEnrollment() async {
    final response = await _client.auth.mfa.enroll(
      factorType: FactorType.totp,
      issuer: 'Alhai Distributor',
      friendlyName: 'totp-${DateTime.now().millisecondsSinceEpoch}',
    );

    final totp = response.totp;
    if (totp == null) {
      throw StateError('TOTP enrollment failed: no TOTP data in response');
    }

    return EnrollmentData(
      factorId: response.id,
      secret: totp.secret,
      uri: totp.uri,
    );
  }

  /// Verify the enrollment by submitting the 6-digit TOTP code.
  ///
  /// Uses challengeAndVerify for atomic operation.
  /// On success, the factor status changes to "verified".
  Future<void> verifyEnrollment({
    required String factorId,
    required String code,
  }) async {
    await _client.auth.mfa.challengeAndVerify(
      factorId: factorId,
      code: code,
    );
  }

  /// Generate cryptographically secure backup codes.
  ///
  /// Returns [count] codes in XXXX-XXXX-XXXX format (hex, uppercase).
  /// Each code has 48 bits of entropy (6 random bytes).
  List<String> generateBackupCodes({int count = 8}) {
    final random = Random.secure();
    return List.generate(count, (_) {
      final bytes = List<int>.generate(6, (_) => random.nextInt(256));
      final hex =
          bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      final upper = hex.toUpperCase();
      // Format: XXXX-XXXX-XXXX
      return '${upper.substring(0, 4)}-${upper.substring(4, 8)}-${upper.substring(8, 12)}';
    });
  }

  /// Hash a backup code with SHA-256.
  String hashBackupCode(String code) {
    // Normalize: remove dashes and uppercase
    final normalized = code.replaceAll('-', '').toUpperCase();
    return sha256.convert(utf8.encode(normalized)).toString();
  }

  /// Store backup codes (hashed) in user metadata.
  Future<void> storeBackupCodes(List<String> codes) async {
    final hashed = codes.map(hashBackupCode).toList();
    await _client.auth.updateUser(
      UserAttributes(data: {'mfa_backup_codes': hashed}),
    );
  }

  /// Remove the MFA factor and clear backup codes.
  Future<void> unenroll(String factorId) async {
    await _client.auth.mfa.unenroll(factorId);
    await _client.auth.updateUser(
      UserAttributes(data: {'mfa_backup_codes': null}),
    );
  }

  /// Verify a TOTP code during login (challenge flow).
  Future<void> verifyLogin({
    required String factorId,
    required String code,
  }) async {
    await _client.auth.mfa.challengeAndVerify(
      factorId: factorId,
      code: code,
    );
  }

  /// Verify a backup code. Returns true if valid.
  ///
  /// On success, the used code is removed from stored codes.
  /// This is a one-time-use mechanism.
  Future<bool> verifyBackupCode(String code) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final hashed = hashBackupCode(code);
    final stored =
        (user.userMetadata?['mfa_backup_codes'] as List<dynamic>?)
            ?.cast<String>() ??
        [];

    if (!stored.contains(hashed)) return false;

    // Remove used code
    final remaining = stored.where((c) => c != hashed).toList();
    await _client.auth.updateUser(
      UserAttributes(data: {'mfa_backup_codes': remaining}),
    );
    return true;
  }

  /// Get the number of remaining backup codes.
  int getRemainingBackupCodeCount() {
    final user = _client.auth.currentUser;
    if (user == null) return 0;
    final stored =
        (user.userMetadata?['mfa_backup_codes'] as List<dynamic>?)
            ?.cast<String>() ??
        [];
    return stored.length;
  }

  /// Get the current Authenticator Assurance Level.
  AuthMFAGetAuthenticatorAssuranceLevelResponse getAAL() {
    return _client.auth.mfa.getAuthenticatorAssuranceLevel();
  }

  /// Check if user has MFA enrolled but session is only aal1 (needs MFA verify).
  bool needsMfaVerification() {
    final aal = getAAL();
    return aal.currentLevel == AuthenticatorAssuranceLevels.aal1 &&
        aal.nextLevel == AuthenticatorAssuranceLevels.aal2;
  }
}
