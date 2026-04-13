import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/sa_dashboard_providers.dart'
    show saSupabaseClientProvider;
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
/// Failed inserts are kept in an in-memory queue ([_pendingRetries]) and
/// retried on the next successful [log] call. The queue is capped at
/// [_maxRetryQueueSize] entries to prevent unbounded memory growth.
class AuditLogService {
  /// Supabase client for inserting audit rows.
  ///
  /// Tests may pass a duck-typed fake via [AuditLogService.test].
  final dynamic _client;

  /// Resolves the current actor (id + optional email).
  ///
  /// Default wiring reads from `client.auth.currentSession`. Unit tests
  /// override this to supply a fixed actor without a real Supabase session.
  final AuditActor? Function() _resolveActor;

  /// Production constructor -- accepts a typed [SupabaseClient].
  AuditLogService(SupabaseClient client, {AuditActor? Function()? resolveActor})
    : _client = client,
      _resolveActor = resolveActor ?? (() => _defaultActorFromClient(client));

  /// Test constructor -- accepts a fake client.
  AuditLogService.test(this._client, {AuditActor? Function()? resolveActor})
    : _resolveActor = resolveActor ?? (() => _defaultActorFromClient(_client));

  /// In-memory queue for audit entries that failed to persist.
  /// Retried on the next successful [log] call.
  final List<Map<String, dynamic>> _pendingRetries = [];

  /// Maximum entries held in the retry queue to prevent unbounded growth.
  static const _maxRetryQueueSize = 50;

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
    final actor = _resolveActor();
    if (actor == null) {
      // No session means we cannot attribute the action. Don't silently
      // fabricate an actor_id -- report and bail.
      await reportError(
        StateError('AuditLogService.log called with no current actor'),
        hint: 'action=$action target=$targetType/$targetId',
      );
      return;
    }

    final row = {
      'actor_id': actor.id,
      if (actor.email != null) 'actor_email': actor.email,
      'action': action,
      'target_type': targetType,
      'target_id': targetId,
      if (before != null) 'before': before,
      if (after != null) 'after': after,
      if (metadata != null) 'metadata': metadata,
    };

    try {
      await _client.from('audit_log').insert(row);

      // Current insert succeeded -- flush any previously queued retries.
      await _flushRetryQueue();
    } catch (e, st) {
      // Swallow: the parent mutation has already succeeded and we don't want
      // to surface an audit glitch to the user. Report for ops visibility.
      await reportError(
        e,
        stackTrace: st,
        hint:
            'audit_log insert failed action=$action '
            'target=$targetType/$targetId',
      );

      // Enqueue for retry on the next successful call.
      _enqueueForRetry(row);
    }
  }

  /// Adds a failed audit row to the retry queue, dropping the oldest entry
  /// if the queue is full.
  void _enqueueForRetry(Map<String, dynamic> row) {
    if (_pendingRetries.length >= _maxRetryQueueSize) {
      _pendingRetries.removeAt(0); // drop oldest
    }
    _pendingRetries.add(row);
  }

  /// Attempts to insert all queued retry entries. Entries that still fail
  /// are silently dropped (already reported to Sentry on first failure).
  Future<void> _flushRetryQueue() async {
    if (_pendingRetries.isEmpty) return;
    final batch = List<Map<String, dynamic>>.from(_pendingRetries);
    _pendingRetries.clear();
    for (final row in batch) {
      try {
        await _client.from('audit_log').insert(row);
      } catch (e, st) {
        // Already reported on first failure; just log retry failure.
        await reportError(
          e,
          stackTrace: st,
          hint: 'audit_log retry flush failed',
        );
      }
    }
  }

  /// Default actor resolver: pulls id + email from the Supabase session.
  static AuditActor? _defaultActorFromClient(dynamic client) {
    try {
      // ignore: avoid_dynamic_calls
      final session = client.auth.currentSession;
      if (session == null) return null;
      // ignore: avoid_dynamic_calls
      final user = session.user;
      final id = user.id as String?;
      if (id == null || id.isEmpty) return null;
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
