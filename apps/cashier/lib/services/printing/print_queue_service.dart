/// Print queue service with retry logic and local persistence
///
/// Manages a queue of print jobs, automatically retrying failed prints
/// with exponential backoff. Failed receipts are stored locally in
/// SharedPreferences for manual reprint even after app restart.
///
/// Usage:
/// ```dart
/// final queue = PrintQueueService(printService);
/// await queue.enqueue(receiptData);
/// // The queue will automatically print and retry on failure
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import 'print_service.dart';
import 'receipt_data.dart';

/// Status of a print job in the queue
enum PrintJobStatus {
  pending,
  printing,
  failed,
  success,
}

/// A single print job in the queue
class PrintJob {
  final String id;
  final ReceiptData receipt;
  PrintJobStatus status;
  int attempts;
  DateTime createdAt;
  DateTime? lastAttemptAt;
  String? lastError;

  PrintJob({
    required this.id,
    required this.receipt,
    this.status = PrintJobStatus.pending,
    this.attempts = 0,
    DateTime? createdAt,
    this.lastAttemptAt,
    this.lastError,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON-serializable map for persistence
  Map<String, dynamic> toJson() => {
        'id': id,
        'receiptNumber': receipt.receiptNumber,
        'status': status.name,
        'attempts': attempts,
        'createdAt': createdAt.toIso8601String(),
        'lastAttemptAt': lastAttemptAt?.toIso8601String(),
        'lastError': lastError,
        // Store receipt data for reprint
        'receipt': _receiptToJson(receipt),
      };

  /// Reconstruct from stored JSON
  factory PrintJob.fromJson(Map<String, dynamic> json) {
    final receiptJson = json['receipt'] as Map<String, dynamic>;
    return PrintJob(
      id: json['id'] as String,
      receipt: _receiptFromJson(receiptJson),
      status: PrintJobStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PrintJobStatus.failed,
      ),
      attempts: json['attempts'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.tryParse(json['lastAttemptAt'] as String)
          : null,
      lastError: json['lastError'] as String?,
    );
  }
}

/// Print queue service with automatic retry and persistence
class PrintQueueService {
  final ThermalPrintService _printService;

  /// Maximum number of retry attempts per job
  static const int maxRetries = 3;

  /// Base delay for exponential backoff (multiplied by attempt number)
  static const Duration _baseRetryDelay = Duration(seconds: 3);

  /// SharedPreferences key for failed jobs
  static const String _failedJobsKey = 'print_queue_failed_jobs';

  /// Active queue of pending/in-progress jobs
  final List<PrintJob> _queue = [];

  /// History of failed jobs (persisted for manual reprint)
  final List<PrintJob> _failedJobs = [];

  /// Whether the queue processor is currently running
  bool _processing = false;

  /// Stream controller for job status updates
  final _statusController = StreamController<PrintJob>.broadcast();

  /// Stream of job status changes
  Stream<PrintJob> get jobStatusStream => _statusController.stream;

  /// Current jobs in the queue (pending + printing)
  List<PrintJob> get pendingJobs => List.unmodifiable(_queue.where((j) =>
      j.status == PrintJobStatus.pending ||
      j.status == PrintJobStatus.printing));

  /// Failed jobs available for manual reprint
  List<PrintJob> get failedJobs => List.unmodifiable(_failedJobs);

  /// Total number of jobs in queue + failed
  int get totalJobs => _queue.length + _failedJobs.length;

  /// Whether any jobs are currently pending or printing
  bool get hasActiveJobs => _queue.any((j) =>
      j.status == PrintJobStatus.pending ||
      j.status == PrintJobStatus.printing);

  PrintQueueService(this._printService);

  /// Initialize the queue and load any persisted failed jobs
  Future<void> initialize() async {
    await _loadFailedJobs();
  }

  /// Add a receipt to the print queue
  ///
  /// Returns the job ID. The receipt will be printed automatically
  /// when the printer is available. If printing fails, the job will
  /// be retried up to [maxRetries] times with exponential backoff.
  Future<String> enqueue(ReceiptData receipt) async {
    final job = PrintJob(
      id: '${receipt.receiptNumber}_${DateTime.now().millisecondsSinceEpoch}',
      receipt: receipt,
    );

    _queue.add(job);
    _statusController.add(job);

    if (kDebugMode) {
      debugPrint(
          'PrintQueue: enqueued job ${job.id} (queue: ${_queue.length})');
    }

    // Start processing if not already running
    _processQueue();

    return job.id;
  }

  /// Manually retry a failed job
  ///
  /// Moves the job from the failed list back to the active queue
  /// and resets its retry counter.
  Future<bool> retryFailedJob(String jobId) async {
    final jobIndex = _failedJobs.indexWhere((j) => j.id == jobId);
    if (jobIndex < 0) return false;

    final job = _failedJobs.removeAt(jobIndex);
    job
      ..status = PrintJobStatus.pending
      ..attempts = 0
      ..lastError = null;

    _queue.add(job);
    _statusController.add(job);
    await _persistFailedJobs();

    _processQueue();
    return true;
  }

  /// Retry all failed jobs
  Future<int> retryAllFailed() async {
    final count = _failedJobs.length;
    final jobs = List<PrintJob>.from(_failedJobs);
    _failedJobs.clear();

    for (final job in jobs) {
      job
        ..status = PrintJobStatus.pending
        ..attempts = 0
        ..lastError = null;
      _queue.add(job);
      _statusController.add(job);
    }

    await _persistFailedJobs();
    _processQueue();
    return count;
  }

  /// Remove a failed job from the history
  Future<void> removeFailedJob(String jobId) async {
    _failedJobs.removeWhere((j) => j.id == jobId);
    await _persistFailedJobs();
  }

  /// Clear all failed jobs
  Future<void> clearFailedJobs() async {
    _failedJobs.clear();
    await _persistFailedJobs();
  }

  /// Cancel a pending job in the queue
  bool cancelJob(String jobId) {
    final removed = _queue
        .where((j) => j.id == jobId && j.status == PrintJobStatus.pending)
        .toList();
    for (final job in removed) {
      _queue.remove(job);
      job.status = PrintJobStatus.failed;
      job.lastError = 'تم الإلغاء';
      _statusController.add(job);
    }
    return removed.isNotEmpty;
  }

  /// Dispose of resources
  void dispose() {
    _statusController.close();
  }

  // ─── Queue Processing ──────────────────────────────────

  /// Process the queue sequentially
  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;

    try {
      while (_queue.isNotEmpty) {
        // Find the next pending job
        final job = _queue.firstWhere(
          (j) => j.status == PrintJobStatus.pending,
          orElse: () => _queue.first, // Shouldn't happen, but safety
        );

        if (job.status != PrintJobStatus.pending) {
          // No more pending jobs
          break;
        }

        await _processJob(job);
      }
    } finally {
      _processing = false;
    }
  }

  /// Process a single job with retry logic
  Future<void> _processJob(PrintJob job) async {
    // Check printer readiness
    if (_printService.status != PrinterStatus.connected) {
      if (kDebugMode) {
        debugPrint(
            'PrintQueue: printer not connected, job ${job.id} stays pending');
      }
      // Move to failed immediately - the caller should reconnect and retry
      job
        ..status = PrintJobStatus.failed
        ..lastError = 'الطابعة غير متصلة';
      _queue.remove(job);
      _failedJobs.add(job);
      _statusController.add(job);
      await _persistFailedJobs();
      return;
    }

    job.status = PrintJobStatus.printing;
    job.attempts++;
    job.lastAttemptAt = DateTime.now();
    _statusController.add(job);

    if (kDebugMode) {
      debugPrint(
          'PrintQueue: printing job ${job.id} (attempt ${job.attempts}/$maxRetries)');
    }

    final result = await _printService.printReceipt(job.receipt);

    if (result.success) {
      // Success - remove from queue
      job.status = PrintJobStatus.success;
      _queue.remove(job);
      _statusController.add(job);

      if (kDebugMode) {
        debugPrint('PrintQueue: job ${job.id} printed successfully');
      }
    } else {
      // Failed
      job.lastError = result.error;

      if (job.attempts >= maxRetries) {
        // Max retries exceeded - move to failed list
        job.status = PrintJobStatus.failed;
        _queue.remove(job);
        _failedJobs.add(job);
        _statusController.add(job);
        await _persistFailedJobs();

        if (kDebugMode) {
          debugPrint(
            'PrintQueue: job ${job.id} failed after $maxRetries attempts: ${result.error}',
          );
        }
      } else {
        // Retry with exponential backoff
        job.status = PrintJobStatus.pending;
        _statusController.add(job);

        final delay = _baseRetryDelay * job.attempts;
        if (kDebugMode) {
          debugPrint(
            'PrintQueue: job ${job.id} failed, retrying in ${delay.inSeconds}s '
            '(attempt ${job.attempts}/$maxRetries)',
          );
        }

        await Future<void>.delayed(delay);
      }
    }
  }

  // ─── Persistence ───────────────────────────────────────

  /// Load failed jobs from SharedPreferences
  Future<void> _loadFailedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_failedJobsKey);
      if (jsonStr == null || jsonStr.isEmpty) return;

      final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
      _failedJobs.clear();
      for (final item in jsonList) {
        try {
          _failedJobs.add(PrintJob.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          if (kDebugMode) debugPrint('PrintQueue: failed to parse job: $e');
        }
      }

      if (kDebugMode) {
        debugPrint('PrintQueue: loaded ${_failedJobs.length} failed jobs');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PrintQueue: failed to load jobs: $e');
    }
  }

  /// Persist failed jobs to SharedPreferences
  Future<void> _persistFailedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_failedJobs.isEmpty) {
        await prefs.remove(_failedJobsKey);
      } else {
        final jsonStr =
            json.encode(_failedJobs.map((j) => j.toJson()).toList());
        await prefs.setString(_failedJobsKey, jsonStr);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PrintQueue: failed to persist jobs: $e');
    }
  }
}

// ─── Receipt Serialization Helpers ─────────────────────────

Map<String, dynamic> _receiptToJson(ReceiptData r) => {
      'receiptNumber': r.receiptNumber,
      'dateTime': r.dateTime.toIso8601String(),
      'cashierName': r.cashierName,
      'customerName': r.customerName,
      'customerId': r.customerId,
      'items': r.items
          .map((i) => {
                'name': i.name,
                'quantity': i.quantity,
                'unitPrice': i.unitPrice,
                'total': i.total,
                'barcode': i.barcode,
              })
          .toList(),
      'subtotal': r.subtotal,
      'discount': r.discount,
      'tax': r.tax,
      'total': r.total,
      'paymentMethod': r.paymentMethod,
      'amountReceived': r.amountReceived,
      'changeAmount': r.changeAmount,
      'storeName': r.store.name,
      'storeAddress': r.store.address,
      'storePhone': r.store.phone,
      'storeVat': r.store.vatNumber,
      'storeCr': r.store.crNumber,
      'zatcaQrData': r.zatcaQrData,
      'note': r.note,
    };

ReceiptData _receiptFromJson(Map<String, dynamic> j) => ReceiptData(
      receiptNumber: j['receiptNumber'] as String? ?? '',
      dateTime:
          DateTime.tryParse(j['dateTime'] as String? ?? '') ?? DateTime.now(),
      cashierName: j['cashierName'] as String? ?? 'كاشير',
      customerName: j['customerName'] as String?,
      customerId: j['customerId'] as String?,
      items: (j['items'] as List<dynamic>? ?? []).map((item) {
        final m = item as Map<String, dynamic>;
        return ReceiptItem(
          name: m['name'] as String? ?? '',
          quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
          unitPrice: (m['unitPrice'] as num?)?.toDouble() ?? 0,
          total: (m['total'] as num?)?.toDouble() ?? 0,
          barcode: m['barcode'] as String?,
        );
      }).toList(),
      subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (j['discount'] as num?)?.toDouble() ?? 0,
      tax: (j['tax'] as num?)?.toDouble() ?? 0,
      total: (j['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: j['paymentMethod'] as String? ?? 'cash',
      amountReceived: (j['amountReceived'] as num?)?.toDouble(),
      changeAmount: (j['changeAmount'] as num?)?.toDouble(),
      store: ReceiptStoreInfo(
        name: j['storeName'] as String? ?? 'Al-HAI Store',
        address: j['storeAddress'] as String? ?? '',
        phone: j['storePhone'] as String? ?? '',
        vatNumber: j['storeVat'] as String? ?? '',
        crNumber: j['storeCr'] as String?,
      ),
      zatcaQrData: j['zatcaQrData'] as String?,
      note: j['note'] as String?,
    );
