import 'package:supabase_flutter/supabase_flutter.dart';

/// Append-only audit trail for privileged distributor-portal actions.
///
/// Writes to the shared `audit_log` table. This is a best-effort logger:
/// failures are swallowed so a transient audit problem never blocks the
/// parent mutation. Uses `print` only for local diagnostics — real error
/// reporting should plug into Sentry once the service is wired here.
///
/// Prioritize logging these event families:
/// - distributor.{create,update,suspend}
/// - organization.{update,approve,reject}
/// - document.{approve,reject}
/// - invoice.{create,update,void}
/// - inventory.adjustment (include before/after quantity)
class DistributorAuditService {
  DistributorAuditService._();

  static final DistributorAuditService instance = DistributorAuditService._();

  /// Insert a single audit row. Never throws.
  ///
  /// [action] — stable verb, e.g. `distributor.create`, `organization.approve`.
  /// [targetType] — entity kind: `distributor`, `organization`, `document`.
  /// [targetId] — stable id of the target row.
  /// [before] / [after] — optional JSON snapshots for change tracking.
  /// [metadata] — free-form JSON (reason, stakeholder id, etc.).
  Future<void> log({
    required String action,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      final user = session?.user;
      if (user == null) {
        // No session — can't attribute the action.
        return;
      }

      final row = <String, dynamic>{
        'actor_id': user.id,
        if (user.email != null) 'actor_email': user.email,
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
        if (before != null) 'before': before,
        if (after != null) 'after': after,
        if (metadata != null) 'metadata': metadata,
      };

      // sa_audit_log is the platform-wide shared audit trail (v40).
      // Distinct from public.audit_log which belongs to the POS pipeline.
      await client.from('sa_audit_log').insert(row);
    } catch (_) {
      // Swallow: audit is best-effort. Parent mutation already succeeded.
      // TODO(observability): wire reportError() once Sentry is centralized
      // for distributor_portal.
    }
  }
}
