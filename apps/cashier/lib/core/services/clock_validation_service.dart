import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة التحقق من دقة ساعة الجهاز
///
/// ZATCA requires accurate timestamps on invoices. This service compares the
/// device clock against the Supabase server clock and exposes:
/// - [isClockValid]: whether the device clock is within the acceptable threshold
/// - [clockOffset]: the difference (device - server) so other services can
///   compute a corrected timestamp via `DateTime.now().subtract(clockOffset)`
/// - [onClockValidityChanged]: stream that fires when validity status changes
///
/// Threshold: 5 minutes. Beyond that, ZATCA timestamps are unreliable.
class ClockValidationService {
  ClockValidationService._();

  static final ClockValidationService instance = ClockValidationService._();

  /// Maximum allowed difference between device clock and server clock.
  static const Duration maxAllowedDrift = Duration(minutes: 5);

  /// Broadcast controller for validity changes.
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  /// Current clock offset: device time minus server time.
  /// Positive means device is ahead; negative means device is behind.
  Duration _clockOffset = Duration.zero;

  /// Whether the device clock is within the acceptable threshold.
  bool _isClockValid = true;

  /// Whether the service has completed at least one check.
  bool _initialized = false;

  // -- Public API ------------------------------------------------------------

  /// Whether the device clock is accurate (within [maxAllowedDrift]).
  bool get isClockValid => _isClockValid;

  /// The measured offset: `deviceTime - serverTime`.
  /// Use `DateTime.now().subtract(clockOffset)` to get a corrected timestamp.
  Duration get clockOffset => _clockOffset;

  /// Whether the service has completed initial validation.
  bool get isInitialized => _initialized;

  /// Stream that emits when clock validity status changes.
  Stream<bool> get onClockValidityChanged => _controller.stream;

  /// Compute a corrected timestamp using the measured offset.
  /// Returns `DateTime.now()` adjusted by the server offset.
  DateTime get correctedNow => DateTime.now().subtract(_clockOffset);

  /// Validate the device clock against the Supabase server.
  ///
  /// Uses the `Date` header from a lightweight Supabase REST call
  /// (faster and more reliable than `SELECT NOW()` which requires
  /// PostgREST RPC setup).
  ///
  /// Safe to call multiple times; each call refreshes the offset.
  Future<void> validate() async {
    try {
      final client = Supabase.instance.client;

      // Record device time immediately before and after the request
      // to account for network latency (use midpoint).
      final beforeRequest = DateTime.now();

      // Use a lightweight RPC call to get server time.
      // `SELECT NOW()` via rpc is the most reliable method.
      final response = await client.rpc('now').select();

      final afterRequest = DateTime.now();

      // Parse server time from the response.
      // Supabase rpc('now').select() returns List<Map<String, dynamic>> like:
      // [{"now": "2026-04-04T12:00:00.000000+00:00"}]
      DateTime? serverTime;
      if (response.isNotEmpty) {
        final nowStr = response.first['now'];
        if (nowStr is String) {
          serverTime = DateTime.tryParse(nowStr);
        }
      }

      if (serverTime == null) {
        if (kDebugMode) {
          debugPrint('[ClockValidation] Could not parse server time from rpc response');
        }
        // Cannot validate -- assume valid to avoid false positives
        _setValidity(true, Duration.zero);
        return;
      }

      // Use the midpoint of before/after to estimate actual device time
      // at the moment the server generated its timestamp.
      final deviceMidpoint = beforeRequest.add(
        Duration(
          milliseconds:
              afterRequest.difference(beforeRequest).inMilliseconds ~/ 2,
        ),
      );

      // Offset = device - server (positive = device ahead)
      _clockOffset = deviceMidpoint.difference(serverTime.toLocal());
      final absDrift = _clockOffset.abs();
      final valid = absDrift < maxAllowedDrift;

      if (kDebugMode) {
        debugPrint(
          '[ClockValidation] offset=${_clockOffset.inSeconds}s, '
          'valid=$valid (threshold=${maxAllowedDrift.inMinutes}min)',
        );
      }

      _setValidity(valid, _clockOffset);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ClockValidation] Validation failed: $e');
      }
      // On error (e.g. offline), keep previous state or assume valid
      if (!_initialized) {
        _setValidity(true, Duration.zero);
      }
    }
  }

  /// Release resources.
  void dispose() {
    _controller.close();
  }

  // -- Internal --------------------------------------------------------------

  void _setValidity(bool valid, Duration offset) {
    final changed = _isClockValid != valid || !_initialized;
    _isClockValid = valid;
    _clockOffset = offset;
    _initialized = true;

    if (changed) {
      _controller.add(valid);
    }
  }
}
