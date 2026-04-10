import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sa_dashboard_providers.dart' show saSupabaseClientProvider;
import 'sentry_service.dart';

/// Resolved actor for a single audit_log insert.
///
/// Kept separate from Supabase types so unit tests can provide their own
/// session info without constructing a real [SupabaseClient].
class AuditActor {
  final String id;
  final String? email;

  const AuditActor({required this.id, this.email});
}

/// Appends rows to the `audit_log` table for every privileged Super Admin
/// mutation.
///
/// The Super Admin app bypasses normal RLS, so an audit trail is the primary
/// accountability mechanism. Call [log] **after** the parent mutation has
/// succeeded. Failures here are swallowed (and reported to Sentry) so we
/// never block the user-visible action just because auditing hit a hiccup.
///
/// TODO(production): consider a local retry queue for audit entries that
/// fail to persist — today we report and drop them, which is acceptable for
/// an initial P0 rollout but not ideal for long-term forensics.
class AuditLogService {
  // Typed as dynamic so the service can accept the real [SupabaseClient]
  // in production and the lightweight fake from test/helpers in unit tests.
  // ignore: strict_raw_type
  final dynamic _client;

  /// Resolves the current actor (id + optional email).
  ///
  /// Default wiring reads from `client.auth.currentSession`. Unit tests
  /// override this to supply a fixed actor without a real Supabase session.
  final AuditActor? Function() _resolveActor;

  AuditLogService(
    // ignore: strict_raw_type
    this._client, {
    AuditActor? Function()? resolveActor,
  }) : _resolveActor = resolveActor ?? (() => _defaultActorFromClient(_client));

  /// Insert a single audit entry.
  ///
  /// - [action] — short verb like `store.create`, `subscription.update`.
  /// - [targetType] — entity kind: `store`, `user`, `subscription`, etc.
  /// - [targetId] — stable id of the target row.
  /// - [before]/[after] — optional JSON snapshots for change tracking.
  /// - [metadata] — free-form extra context (reason, diff summary, etc.).
  ///
  /// Never throws: on failure, the error is reported to Sentry and the
  /// method returns normally so the caller's mutation is not affected.
  Future<void> log({
    required String action,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final actor = _resolveActor();
      if (actor == null) {
        // No session means we cannot attribute the action. Don't silently
        // fabricate an actor_id — report and bail.
        await reportError(
          StateError('AuditLogService.log called with no current actor'),
          hint: 'action=$action target=$targetType/$targetId',
        );
        return;
      }

      await _client.from('audit_log').insert({
        'actor_id': actor.id,
        if (actor.email != null) 'actor_email': actor.email,
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
        if (before != null) 'before': before,
        if (after != null) 'after': after,
        if (metadata != null) 'metadata': metadata,
      });
    } catch (e, st) {
      // Swallow: the parent mutation has already succeeded and we don't want
      // to surface an audit glitch to the user. Report for ops visibility.
      await reportError(
        e,
        stackTrace: st,
        hint: 'audit_log insert failed action=$action '
            'target=$targetType/$targetId',
      );
      // TODO(production): enqueue this entry in a local retry queue so
      // transient network blips don't drop audit rows permanently.
    }
  }

  /// Default actor resolver: pulls id + email from the Supabase session.
  // ignore: strict_raw_type
  static AuditActor? _defaultActorFromClient(dynamic client) {
    try {
      final session = client.auth.currentSession;
      if (session == null) return null;
      final user = session.user;
      // ignore: avoid_dynamic_calls
      final id = user.id as String?;
      if (id == null || id.isEmpty) return null;
      // ignore: avoid_dynamic_calls
      final email = user.email as String?;
      return AuditActor(id: id, email: email);
    } catch (_) {
      return null;
    }
  }
}

/// Riverpod singleton for the [AuditLogService].
///
/// Shares the same [SupabaseClient] as the rest of the super_admin app via
/// [saSupabaseClientProvider] so all mutations and audit writes go through
/// one session.
final auditLogServiceProvider = Provider<AuditLogService>((ref) {
  final client = ref.watch(saSupabaseClientProvider);
  return AuditLogService(client);
});
