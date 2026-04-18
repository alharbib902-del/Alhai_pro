import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../services/sentry_service.dart';
import 'pending_mutation.dart';

/// Result returned by a handler registered with [OfflineQueueService].
enum MutationOutcome {
  /// Mutation was applied successfully; drop from the queue.
  success,

  /// Transient failure (network/5xx). Keep in the queue and increment retry.
  retry,

  /// Permanent failure (4xx/validation). Drop from the queue — retrying
  /// would never succeed.
  drop,
}

typedef MutationHandler =
    Future<MutationOutcome> Function(Map<String, dynamic> payload);

/// Persistent queue for mutations that failed to reach the backend because
/// of a transient network error.
///
/// Currently MVP-scoped to order submission but the dispatcher is keyed on
/// mutation [type] so other flows (addresses, profile) can register their
/// own handlers without changes to this class.
///
/// Storage: [SharedPreferences] under [_storageKey] — a JSON array of
/// [PendingMutation] records. The entire array is rewritten on every
/// change; acceptable given the small expected size (< a few dozen).
class OfflineQueueService {
  static const String _storageKey = 'offline_queue.pending_orders_v1';
  static const int _maxRetries = 5;

  final Map<String, MutationHandler> _handlers = {};
  final StreamController<int> _pendingCountController =
      StreamController<int>.broadcast();
  final Uuid _uuid;
  bool _processing = false;

  OfflineQueueService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Register a handler for a mutation [type]. The handler receives the
  /// stored payload and returns a [MutationOutcome] indicating whether to
  /// drop, retry, or keep the mutation.
  void registerHandler(String type, MutationHandler handler) {
    _handlers[type] = handler;
  }

  /// Enqueue a new pending mutation and emit the updated pending count.
  Future<void> enqueue(String type, Map<String, dynamic> payload) async {
    final mutations = await _load();
    mutations.add(
      PendingMutation(
        id: _uuid.v4(),
        type: type,
        payload: payload,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    await _save(mutations);
    _pendingCountController.add(mutations.length);
    addBreadcrumb(
      message: 'offline_queue.enqueue type=$type size=${mutations.length}',
      category: 'offline_queue',
    );
  }

  /// Number of mutations currently pending.
  Future<int> pendingCount() async {
    final mutations = await _load();
    return mutations.length;
  }

  /// Emits the current pending count whenever it changes.
  ///
  /// The first subscriber also receives the current value so UI badges
  /// reflect the disk state on cold start.
  Stream<int> watchPendingCount() async* {
    yield await pendingCount();
    yield* _pendingCountController.stream;
  }

  /// Walk the queue, dispatching each mutation to its registered handler.
  ///
  /// Runs at most once at a time — concurrent calls are coalesced. Entries
  /// are removed on [MutationOutcome.success] or [MutationOutcome.drop],
  /// and their retry counter is incremented on [MutationOutcome.retry]
  /// (dropped outright after [_maxRetries]).
  Future<void> processQueue() async {
    if (_processing) return;
    _processing = true;
    try {
      final mutations = await _load();
      if (mutations.isEmpty) return;

      final remaining = <PendingMutation>[];
      for (final mutation in mutations) {
        final handler = _handlers[mutation.type];
        if (handler == null) {
          // No handler registered for this type yet — keep it for later.
          remaining.add(mutation);
          continue;
        }

        try {
          final outcome = await handler(mutation.payload);
          switch (outcome) {
            case MutationOutcome.success:
              // Drop from queue.
              break;
            case MutationOutcome.drop:
              // Permanent failure — drop, but log for diagnostics.
              reportError(
                StateError('offline_queue: dropping ${mutation.type}'),
                hint: 'offline_queue drop id=${mutation.id}',
              );
              break;
            case MutationOutcome.retry:
              final nextCount = mutation.retryCount + 1;
              if (nextCount >= _maxRetries) {
                if (kDebugMode) {
                  debugPrint(
                    'offline_queue: max retries reached for ${mutation.id}',
                  );
                }
                reportError(
                  StateError(
                    'offline_queue: max retries exhausted for ${mutation.type}',
                  ),
                  hint: 'offline_queue exhausted id=${mutation.id}',
                );
              } else {
                remaining.add(
                  mutation.copyWith(retryCount: nextCount),
                );
              }
              break;
          }
        } catch (e, stack) {
          // Handler threw unexpectedly — treat as retry but track the error.
          final nextCount = mutation.retryCount + 1;
          reportError(
            e,
            stackTrace: stack,
            hint: 'offline_queue handler threw id=${mutation.id}',
          );
          if (nextCount < _maxRetries) {
            remaining.add(
              mutation.copyWith(
                retryCount: nextCount,
                lastError: e.toString(),
              ),
            );
          }
        }
      }

      await _save(remaining);
      _pendingCountController.add(remaining.length);
    } finally {
      _processing = false;
    }
  }

  /// Remove every pending mutation. Exposed for diagnostic/test use.
  @visibleForTesting
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _pendingCountController.add(0);
  }

  /// Dispose any held resources. Call from app shutdown paths (not required
  /// for the common lazy-singleton use).
  void dispose() {
    _pendingCountController.close();
  }

  Future<List<PendingMutation>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return <PendingMutation>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <PendingMutation>[];
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (m) => PendingMutation.fromJson(
              Map<String, dynamic>.from(m),
            ),
          )
          .toList();
    } catch (e, stack) {
      reportError(
        e,
        stackTrace: stack,
        hint: 'offline_queue: corrupt queue payload dropped',
      );
      await prefs.remove(_storageKey);
      return <PendingMutation>[];
    }
  }

  Future<void> _save(List<PendingMutation> mutations) async {
    final prefs = await SharedPreferences.getInstance();
    if (mutations.isEmpty) {
      await prefs.remove(_storageKey);
      return;
    }
    final encoded = jsonEncode(mutations.map((m) => m.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}

/// Backoff delay for the Nth retry (1-indexed): 1s, 2s, 4s, 8s, 16s.
///
/// [OfflineQueueService.processQueue] itself does not sleep — callers that
/// schedule deferred retries (e.g. a connectivity listener) can use this to
/// decide when to re-invoke the service.
Duration offlineQueueBackoff(int retryCount) {
  if (retryCount <= 0) return Duration.zero;
  final clamped = retryCount > 5 ? 5 : retryCount;
  final seconds = 1 << (clamped - 1);
  return Duration(seconds: seconds);
}
