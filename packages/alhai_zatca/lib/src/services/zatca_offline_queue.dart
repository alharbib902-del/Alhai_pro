import 'dart:convert';

import 'package:alhai_zatca/src/api/clearance_api.dart';
import 'package:alhai_zatca/src/api/reporting_api.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages a queue of ZATCA invoices that failed to submit
///
/// When the device is offline or ZATCA API is unavailable,
/// invoices are queued for later retry.
class ZatcaOfflineQueue {
  final List<QueuedInvoice> _queue = [];

  /// SharedPreferences key used for default fallback persistence
  static const String _prefsKey = 'zatca_offline_queue';

  /// Optional persistence callback -- set by DI to persist queue to DB
  Future<void> Function(List<QueuedInvoice> queue)? onQueueChanged;

  /// Optional load callback -- set by DI to restore queue from DB
  Future<List<QueuedInvoice>> Function()? onLoadQueue;

  /// Whether the queue has been loaded from persistence
  bool _loaded = false;

  /// Add an invoice to the offline queue
  Future<void> enqueue({
    required String invoiceNumber,
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
    required bool isStandard,
    String? storeId,
  }) async {
    await _ensureLoaded();

    // Avoid duplicate entries for the same invoice
    final existingIdx =
        _queue.indexWhere((item) => item.invoiceNumber == invoiceNumber);
    if (existingIdx >= 0) {
      // Update existing entry
      _queue[existingIdx] = _queue[existingIdx].copyWith(
        signedXmlBase64: signedXmlBase64,
        invoiceHash: invoiceHash,
        retryCount: _queue[existingIdx].retryCount,
      );
    } else {
      _queue.add(QueuedInvoice(
        invoiceNumber: invoiceNumber,
        signedXmlBase64: signedXmlBase64,
        invoiceHash: invoiceHash,
        uuid: uuid,
        isStandard: isStandard,
        storeId: storeId ?? '',
        queuedAt: DateTime.now(),
        retryCount: 0,
      ));
    }

    await _persistQueue();
  }

  /// Get all queued invoices
  Future<List<QueuedInvoice>> getAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_queue);
  }

  /// Get the count of queued invoices
  Future<int> get pendingCount async {
    await _ensureLoaded();
    return _queue.length;
  }

  /// Get count of invoices that can still be retried
  Future<int> get retryableCount async {
    await _ensureLoaded();
    return _queue.where((item) => !item.isMaxRetriesExceeded).length;
  }

  /// Get invoices that have exceeded max retries
  Future<List<QueuedInvoice>> getFailedInvoices() async {
    await _ensureLoaded();
    return _queue.where((item) => item.isMaxRetriesExceeded).toList();
  }

  /// Remove an invoice from the queue after successful submission
  Future<void> dequeue({required String invoiceNumber}) async {
    await _ensureLoaded();
    _queue.removeWhere((item) => item.invoiceNumber == invoiceNumber);
    await _persistQueue();
  }

  /// Increment the retry count for a queued invoice
  Future<void> incrementRetry({required String invoiceNumber}) async {
    await _ensureLoaded();
    final index =
        _queue.indexWhere((item) => item.invoiceNumber == invoiceNumber);
    if (index >= 0) {
      _queue[index] = _queue[index].copyWith(
        retryCount: _queue[index].retryCount + 1,
        lastRetryAt: DateTime.now(),
      );
      await _persistQueue();
    }
  }

  /// Process all retryable invoices in the queue
  ///
  /// Attempts to resubmit each queued invoice. On success, removes from queue.
  /// On failure, increments retry count.
  ///
  /// Returns a list of results for each attempt.
  Future<List<QueueProcessResult>> processQueue({
    required ReportingApi reportingApi,
    required ClearanceApi clearanceApi,
    required CertificateStorage certStorage,
    required String storeId,
  }) async {
    await _ensureLoaded();
    final results = <QueueProcessResult>[];

    // Get the certificate for this store
    final certificate = await certStorage.getCertificate(storeId: storeId);
    if (certificate == null) {
      return [
        const QueueProcessResult(
          invoiceNumber: '*',
          success: false,
          message: 'No certificate found for store',
        ),
      ];
    }

    // Process retryable invoices in queue order
    final retryable =
        _queue.where((item) => !item.isMaxRetriesExceeded).toList();

    for (final item in retryable) {
      try {
        final ZatcaResponse response;

        if (item.isStandard) {
          // Standard invoices go through clearance
          response = await clearanceApi.clearInvoice(
            signedXmlBase64: item.signedXmlBase64,
            invoiceHash: item.invoiceHash,
            uuid: item.uuid,
            certificate: certificate,
          );
        } else {
          // Simplified invoices go through reporting
          response = await reportingApi.reportInvoice(
            signedXmlBase64: item.signedXmlBase64,
            invoiceHash: item.invoiceHash,
            uuid: item.uuid,
            certificate: certificate,
          );
        }

        if (response.isSuccess) {
          await dequeue(invoiceNumber: item.invoiceNumber);
          results.add(QueueProcessResult(
            invoiceNumber: item.invoiceNumber,
            success: true,
            message: 'Successfully submitted',
            response: response,
          ));
        } else {
          await incrementRetry(invoiceNumber: item.invoiceNumber);
          results.add(QueueProcessResult(
            invoiceNumber: item.invoiceNumber,
            success: false,
            message: response.errors.isNotEmpty
                ? response.errors.first.message
                : 'Submission rejected by ZATCA',
            response: response,
          ));
        }
      } catch (e) {
        await incrementRetry(invoiceNumber: item.invoiceNumber);
        results.add(QueueProcessResult(
          invoiceNumber: item.invoiceNumber,
          success: false,
          message: 'Network error: $e',
        ));
      }
    }

    return results;
  }

  /// Clear all queued invoices
  Future<void> clearAll() async {
    _queue.clear();
    await _persistQueue();
  }

  /// Clear only invoices that have exceeded max retries
  Future<int> clearFailed() async {
    await _ensureLoaded();
    final before = _queue.length;
    _queue.removeWhere((item) => item.isMaxRetriesExceeded);
    await _persistQueue();
    return before - _queue.length;
  }

  /// Ensure queue has been loaded from persistence
  ///
  /// Uses [onLoadQueue] callback if provided (DI-wired DB persistence).
  /// Falls back to SharedPreferences so queued invoices are never lost
  /// on app restart, even without external wiring.
  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;

    if (onLoadQueue != null) {
      try {
        final persisted = await onLoadQueue!();
        _queue
          ..clear()
          ..addAll(persisted);
        return;
      } catch (_) {
        // Fall through to SharedPreferences fallback
      }
    }

    // Default fallback: load from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        _queue
          ..clear()
          ..addAll(decoded
              .map((e) => QueuedInvoice.fromJson(e as Map<String, dynamic>)));
      }
    } catch (_) {
      // If loading fails, start with empty queue
    }
  }

  /// Persist the current queue state
  ///
  /// Uses [onQueueChanged] callback if provided (DI-wired DB persistence).
  /// Falls back to SharedPreferences so queued invoices survive app restart
  /// even without external wiring.
  Future<void> _persistQueue() async {
    if (onQueueChanged != null) {
      try {
        await onQueueChanged!(_queue.toList());
        return;
      } catch (_) {
        // Fall through to SharedPreferences fallback
      }
    }

    // Default fallback: persist to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_queue.map((e) => e.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
    } catch (_) {
      // Persistence failure should not block operations
    }
  }
}

/// A ZATCA invoice queued for retry
class QueuedInvoice {
  final String invoiceNumber;
  final String signedXmlBase64;
  final String invoiceHash;
  final String uuid;
  final bool isStandard;
  final String storeId;
  final DateTime queuedAt;
  final DateTime? lastRetryAt;
  final int retryCount;

  /// Maximum number of retries before giving up
  static const int maxRetries = 10;

  const QueuedInvoice({
    required this.invoiceNumber,
    required this.signedXmlBase64,
    required this.invoiceHash,
    required this.uuid,
    required this.isStandard,
    this.storeId = '',
    required this.queuedAt,
    this.lastRetryAt,
    this.retryCount = 0,
  });

  /// Whether this invoice has exceeded max retries
  bool get isMaxRetriesExceeded => retryCount >= maxRetries;

  /// How long this invoice has been queued
  Duration get timeInQueue => DateTime.now().difference(queuedAt);

  QueuedInvoice copyWith({
    String? invoiceNumber,
    String? signedXmlBase64,
    String? invoiceHash,
    String? uuid,
    bool? isStandard,
    String? storeId,
    DateTime? queuedAt,
    DateTime? lastRetryAt,
    int? retryCount,
  }) {
    return QueuedInvoice(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      signedXmlBase64: signedXmlBase64 ?? this.signedXmlBase64,
      invoiceHash: invoiceHash ?? this.invoiceHash,
      uuid: uuid ?? this.uuid,
      isStandard: isStandard ?? this.isStandard,
      storeId: storeId ?? this.storeId,
      queuedAt: queuedAt ?? this.queuedAt,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'invoiceNumber': invoiceNumber,
        'signedXmlBase64': signedXmlBase64,
        'invoiceHash': invoiceHash,
        'uuid': uuid,
        'isStandard': isStandard,
        'storeId': storeId,
        'queuedAt': queuedAt.toIso8601String(),
        if (lastRetryAt != null) 'lastRetryAt': lastRetryAt!.toIso8601String(),
        'retryCount': retryCount,
      };

  factory QueuedInvoice.fromJson(Map<String, dynamic> json) => QueuedInvoice(
        invoiceNumber: json['invoiceNumber'] as String,
        signedXmlBase64: json['signedXmlBase64'] as String,
        invoiceHash: json['invoiceHash'] as String,
        uuid: json['uuid'] as String,
        isStandard: json['isStandard'] as bool,
        storeId: json['storeId'] as String? ?? '',
        queuedAt: DateTime.parse(json['queuedAt'] as String),
        lastRetryAt: json['lastRetryAt'] != null
            ? DateTime.parse(json['lastRetryAt'] as String)
            : null,
        retryCount: json['retryCount'] as int? ?? 0,
      );
}

/// Result of processing a single queued invoice
class QueueProcessResult {
  final String invoiceNumber;
  final bool success;
  final String message;
  final ZatcaResponse? response;

  const QueueProcessResult({
    required this.invoiceNumber,
    required this.success,
    required this.message,
    this.response,
  });
}
