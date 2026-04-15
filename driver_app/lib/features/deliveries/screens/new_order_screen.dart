import 'dart:async';

import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/driver_constants.dart';
import '../../../core/widgets/driving_mode_scale.dart';
import '../providers/delivery_providers.dart';
import '../providers/driving_mode_provider.dart';

/// Full-screen alert for new delivery assignment.
///
/// Starts a 30-second countdown timer when an assigned delivery is shown.
/// Auto-rejects the order if the driver does not act before the timer expires.
class NewOrderScreen extends ConsumerStatefulWidget {
  /// Acceptance window in seconds. Exposed for testing.
  final int timeoutSeconds;

  const NewOrderScreen({super.key, this.timeoutSeconds = 30});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late int _remainingSeconds;
  Timer? _countdownTimer;
  String? _assignedDeliveryId;

  /// Tracks the last time an action button was tapped to prevent double-tap.
  DateTime? _lastTapTime;
  static const _debounceInterval = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeoutSeconds;
    // Alert the driver immediately.
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }

  /// Starts the countdown when the first assigned delivery is rendered.
  /// Idempotent — only the first call has effect.
  void _ensureCountdownStarted(String deliveryId) {
    if (_countdownTimer != null) return;
    _assignedDeliveryId = deliveryId;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _autoReject();
      } else {
        setState(() => _remainingSeconds--);
        // Extra haptic nudge in the last 10 seconds.
        if (_remainingSeconds <= 10) {
          HapticFeedback.lightImpact();
        }
      }
    });
  }

  Future<void> _autoReject() async {
    if (_assignedDeliveryId == null || _isLoading) return;
    setState(() {
      _remainingSeconds = 0;
      _isLoading = true;
    });
    try {
      await ref.read(
        updateDeliveryStatusProvider((
          id: _assignedDeliveryId!,
          status: DeliveryStatus.cancelled,
          notes: 'timeout',
        )).future,
      );
    } catch (_) {
      // Even if the server call fails, close the screen — the order should
      // not hang in the UI.
    }
    if (mounted && context.canPop()) context.pop();
  }

  Future<void> _accept(String deliveryId) async {
    // Debounce: ignore rapid taps within the interval.
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < _debounceInterval) {
      return;
    }
    _lastTapTime = now;

    _countdownTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(
        updateDeliveryStatusProvider((
          id: deliveryId,
          status: DeliveryStatus.accepted,
          notes: null,
        )).future,
      );
      if (mounted) context.go('/orders/$deliveryId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ. حاول مرة أخرى')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _reject(String deliveryId) async {
    // Debounce: ignore rapid taps within the interval.
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < _debounceInterval) {
      return;
    }
    _lastTapTime = now;

    _countdownTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(
        updateDeliveryStatusProvider((
          id: deliveryId,
          status: DeliveryStatus.cancelled,
          notes: 'manual_rejection',
        )).future,
      );
      if (mounted && context.canPop()) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ. حاول مرة أخرى')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeDeliveries = ref.watch(activeDeliveriesProvider);

    return Scaffold(
      body: activeDeliveries.when(
        data: (deliveries) {
          final assigned = deliveries
              .where((d) => d['status'] == DeliveryStatus.assigned)
              .toList();

          if (assigned.isEmpty) {
            _countdownTimer?.cancel();
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  const Text('لا توجد طلبات جديدة'),
                  const SizedBox(height: AlhaiSpacing.md),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('رجوع'),
                  ),
                ],
              ),
            );
          }

          final delivery = assigned.first;
          final order = delivery['orders'] as Map<String, dynamic>?;
          final orderNumber = order?['order_number'] ?? '';
          final address = delivery['delivery_address'] ?? '';
          final fee = delivery['delivery_fee'];
          final distance = delivery['distance_km'];
          final estimatedTime = delivery['estimated_time_minutes'];
          final deliveryId = delivery['id'] as String;

          // Start the countdown once we have a delivery to show.
          _ensureCountdownStarted(deliveryId);

          final isUrgent = _remainingSeconds <= 10;
          final progressColor = isUrgent ? Colors.red : Colors.orange;

          return DrivingModeScale(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Column(
                children: [
                  // Countdown progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _remainingSeconds / widget.timeoutSeconds,
                      minHeight: 6,
                      valueColor: AlwaysStoppedAnimation(progressColor),
                      backgroundColor: progressColor.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    '$_remainingSeconds ثانية للقبول',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUrgent
                          ? Colors.red
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),

                  // Alert icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notification_important_rounded,
                      size: 52,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),
                  Text(
                    'طلب توصيل جديد',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (orderNumber.toString().isNotEmpty)
                    Text(
                      '#$orderNumber',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  const SizedBox(height: AlhaiSpacing.xl),

                  // Details card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AlhaiSpacing.md),
                      child: Column(
                        children: [
                          if (address.toString().isNotEmpty)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.location_on_outlined),
                              title: Text(address.toString()),
                              dense: true,
                            ),
                          if (distance != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.straighten),
                              title: Text(
                                '${(distance as num).toStringAsFixed(1)} كم',
                              ),
                              dense: true,
                            ),
                          if (estimatedTime != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.schedule),
                              title: Text('$estimatedTime دقيقة تقريباً'),
                              dense: true,
                            ),
                          if (fee != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.payments),
                              title: Text(
                                '${(fee as num).toStringAsFixed(0)} ر.س',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: 18,
                                ),
                              ),
                              dense: true,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Action buttons
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    Builder(builder: (context) {
                      final isDriving = ref.watch(drivingModeProvider);
                      final acceptHeight = isDriving ? 80.0 : 56.0;
                      final rejectHeight = isDriving ? 80.0 : 48.0;
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: acceptHeight,
                            child: Semantics(
                              label: 'قبول طلب التوصيل',
                              button: true,
                              child: FilledButton.icon(
                                onPressed: () => _accept(deliveryId),
                                icon: const Icon(Icons.check_circle),
                                label: Text(
                                  'قبول الطلب',
                                  style: isDriving
                                      ? theme.textTheme.headlineSmall
                                      : const TextStyle(fontSize: 18),
                                ),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AlhaiSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AlhaiRadius.button,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.sm),
                          SizedBox(
                            width: double.infinity,
                            height: rejectHeight,
                            child: Semantics(
                              label: 'رفض طلب التوصيل',
                              button: true,
                              child: OutlinedButton.icon(
                                onPressed: () => _reject(deliveryId),
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text(
                                  'رفض',
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AlhaiRadius.button,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  const SizedBox(height: AlhaiSpacing.lg),
                ],
              ),
            ),
          ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('حدث خطأ. حاول مرة أخرى')),
      ),
    );
  }
}
