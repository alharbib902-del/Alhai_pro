import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../services/sentry_service.dart';
import 'offline_queue_service.dart';

/// Listens to connectivity state and triggers [OfflineQueueService.processQueue]
/// whenever the device transitions from offline to online.
///
/// Also processes the queue once on startup so that any orders queued in a
/// prior session are flushed as soon as possible.
class OfflineQueueAutoRetry {
  final OfflineQueueService _queue;
  final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _sub;
  bool _wasOnline = true;

  OfflineQueueAutoRetry({
    required OfflineQueueService queue,
    Connectivity? connectivity,
  }) : _queue = queue,
       _connectivity = connectivity ?? Connectivity();

  Future<void> start() async {
    // Process any work left over from a previous session.
    unawaited(_safeProcess('startup'));

    // Seed the online/offline state.
    try {
      final initial = await _connectivity.checkConnectivity();
      _wasOnline = initial != ConnectivityResult.none;
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'offline_queue: initial check');
    }

    _sub = _connectivity.onConnectivityChanged.listen((result) {
      final online = result != ConnectivityResult.none;
      if (online && !_wasOnline) {
        unawaited(_safeProcess('connectivity_restored'));
      }
      _wasOnline = online;
    });
  }

  Future<void> _safeProcess(String trigger) async {
    try {
      await _queue.processQueue();
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('offline_queue: processQueue failed ($trigger): $e');
      }
      reportError(
        e,
        stackTrace: stack,
        hint: 'offline_queue auto-retry: $trigger',
      );
    }
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
