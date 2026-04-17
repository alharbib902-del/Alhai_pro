/// MFA-related Riverpod providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase/supabase_client.dart';
import '../data/services/mfa_service.dart';

/// Provides the MFA service instance.
final mfaServiceProvider = Provider<MfaService>((ref) {
  return MfaService(AppSupabase.client);
});

/// Whether the current user has MFA enrolled (verified factor).
///
/// Auto-disposes so it re-checks on re-read.
final mfaEnrollmentStatusProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final service = ref.read(mfaServiceProvider);
  return service.isEnrolled();
});

/// Whether the current session needs MFA verification (aal1 → aal2).
final mfaNeedsVerificationProvider = Provider<bool>((ref) {
  final service = ref.read(mfaServiceProvider);
  return service.needsMfaVerification();
});
