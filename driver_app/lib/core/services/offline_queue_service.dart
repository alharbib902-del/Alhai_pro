import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import '../../features/deliveries/data/delivery_datasource.dart';

/// Queues delivery status updates when offline, replays when back online.
class OfflineQueueService {
  OfflineQueueService._();

  static final OfflineQueueService instance = OfflineQueueService._();

  static const _queueKey = 'offline_delivery_queue';

  /// Add a status update to the offline queue.
  Future<void> enqueue({
    required String deliveryId,
    required String status,
    String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];

    queue.add(jsonEncode({
      'delivery_id': deliveryId,
      'status': status,
      'notes': notes,
      'queued_at': DateTime.now().toIso8601String(),
    }));

    await prefs.setStringList(_queueKey, queue);
    if (kDebugMode) debugPrint('Offline queue: added status=$status for $deliveryId');
  }

  /// Replay all queued actions. Call when connectivity is restored.
  Future<int> flush() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];

    if (queue.isEmpty) return 0;

    final ds = GetIt.instance<DeliveryDatasource>();
    int processed = 0;
    final failed = <String>[];

    for (final item in queue) {
      try {
        final data = jsonDecode(item) as Map<String, dynamic>;
        final result = await ds.updateStatus(
          data['delivery_id'] as String,
          data['status'] as String,
          notes: data['notes'] as String?,
        );

        if (result['success'] == true) {
          processed++;
        } else {
          // Server rejected (e.g., invalid transition) - discard
          if (kDebugMode) {
            debugPrint('Offline queue: server rejected ${data['delivery_id']}: ${result['error']}');
          }
          processed++;
        }
      } catch (e) {
        // Network still failing - keep in queue
        failed.add(item);
        if (kDebugMode) debugPrint('Offline queue: still failing: $e');
      }
    }

    // Save failed items back
    await prefs.setStringList(_queueKey, failed);
    if (kDebugMode) {
      debugPrint('Offline queue: processed $processed, remaining ${failed.length}');
    }

    return processed;
  }

  /// Get number of pending items.
  Future<int> pendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_queueKey) ?? []).length;
  }

  /// Clear the queue.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }
}
