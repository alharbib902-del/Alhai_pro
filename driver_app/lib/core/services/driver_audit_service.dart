import 'package:supabase_flutter/supabase_flutter.dart';

import 'sentry_service.dart';

/// Append-only audit trail for driver actions.
///
/// Writes to the shared `audit_log` table so operations can reconstruct
/// what a driver did on a sensitive event (delivery status change, proof
/// capture, shift start/end). Location pings are NOT logged per-sample —
/// the caller is expected to batch or only audit meaningful transitions
/// (status changes, proximity triggers).
///
/// The service is intentionally best-effort: every failure is reported to
/// Sentry and swallowed, so a transient audit failure never blocks the
/// parent action.
class DriverAuditService {
  DriverAuditService._();

  static final DriverAuditService instance = DriverAuditService._();

  /// Insert a single audit row. Never throws.
  ///
  /// [action] — stable verb: `delivery.status.change`, `delivery.proof.capture`,
  ///   `shift.start`, `shift.end`, `location.tracking.toggle`.
  /// [targetType] — entity kind: `delivery`, `shift`, `driver`.
  /// [targetId] — stable id of the target row.
  /// [metadata] — free-form JSON (lat/lng, notes, previous status, etc.).
  Future<void> log({
    required String action,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      final user = session?.user;
      if (user == null) {
        // No active session — cannot attribute. Report and bail.
        await reportError(
          StateError('DriverAuditService.log called without active session'),
          hint: 'action=$action target=$targetType/$targetId',
        );
        return;
      }

      final row = <String, dynamic>{
        'actor_id': user.id,
        if (user.email != null) 'actor_email': user.email,
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
        if (metadata != null) 'metadata': metadata,
      };

      // sa_audit_log is the platform-wide shared audit trail (v40).
      // Distinct from public.audit_log which belongs to the POS pipeline.
      await client.from('sa_audit_log').insert(row);
    } catch (e, st) {
      // Swallow: audit is best-effort. The parent action has already
      // succeeded and we don't want a transient audit failure to surface.
      await reportError(
        e,
        stackTrace: st,
        hint:
            'DriverAuditService.log failed action=$action '
            'target=$targetType/$targetId',
      );
    }
  }
}
