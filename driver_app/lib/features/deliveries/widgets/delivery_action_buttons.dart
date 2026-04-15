import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/driver_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/voice_prompt_service.dart';
import '../data/delivery_datasource.dart';
import '../providers/delivery_providers.dart';
import '../providers/driving_mode_provider.dart';

/// Dynamic action buttons based on current delivery status.
class DeliveryActionButtons extends ConsumerStatefulWidget {
  final String deliveryId;
  final String currentStatus;
  final VoidCallback? onProofRequired;

  const DeliveryActionButtons({
    super.key,
    required this.deliveryId,
    required this.currentStatus,
    this.onProofRequired,
  });

  @override
  ConsumerState<DeliveryActionButtons> createState() =>
      _DeliveryActionButtonsState();
}

class _DeliveryActionButtonsState extends ConsumerState<DeliveryActionButtons> {
  bool _isLoading = false;

  /// Tracks the last time a status update was triggered to prevent double-tap.
  DateTime? _lastTapTime;
  static const _debounceInterval = Duration(seconds: 2);

  /// Statuses where mock GPS must be checked before allowing the transition.
  static const _mockGpsGuardedStatuses = {
    DeliveryStatus.arrivedAtPickup,
    DeliveryStatus.pickedUp,
    DeliveryStatus.arrivedAtCustomer,
    DeliveryStatus.delivered,
  };

  Future<void> _updateStatus(String newStatus, {String? notes}) async {
    // Debounce: ignore rapid taps within the interval.
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < _debounceInterval) {
      return;
    }
    _lastTapTime = now;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    // Block critical status transitions when mock GPS is detected.
    if (_mockGpsGuardedStatuses.contains(newStatus)) {
      try {
        await LocationService.instance.getVerifiedPosition();
      } on MockGpsDetectedException catch (e) {
        // Best-effort audit log — do not let logging failure unblock fraud.
        final ds = GetIt.instance<DeliveryDatasource>();
        await ds.logMockGpsDetected(
          lat: e.position.latitude,
          lng: e.position.longitude,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      } catch (_) {
        // Location fetch failed for non-mock reason — allow the transition.
      }
    }

    try {
      await ref.read(
        updateDeliveryStatusProvider((
          id: widget.deliveryId,
          status: newStatus,
          notes: notes,
        )).future,
      );
      // Voice prompt in driving mode
      if (ref.read(drivingModeProvider)) {
        VoicePromptService.instance.announceStatus(newStatus);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ. حاول مرة أخرى')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AlhaiSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final actions = _getActions(widget.currentStatus);
    if (actions.isEmpty) return const SizedBox.shrink();

    final isDriving = ref.watch(drivingModeProvider);
    final buttonPadding = isDriving ? 28.0 : 14.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary action
          SizedBox(
            height: isDriving ? 80 : null,
            child: Semantics(
              label: actions.first.label,
              button: true,
              child: FilledButton.icon(
                onPressed: actions.first.onPressed,
                icon: Icon(actions.first.icon),
                label: Text(
                  actions.first.label,
                  style: isDriving
                      ? Theme.of(context).textTheme.headlineSmall
                      : null,
                ),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.button),
                  ),
                ),
              ),
            ),
          ),
          // Secondary actions
          if (actions.length > 1) ...[
            const SizedBox(height: AlhaiSpacing.xs),
            for (final action in actions.skip(1))
              Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                child: SizedBox(
                  height: isDriving ? 80 : null,
                  child: Semantics(
                    label: action.label,
                    button: true,
                    child: OutlinedButton.icon(
                      onPressed: action.onPressed,
                      icon: Icon(action.icon),
                      label: Text(action.label),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: buttonPadding),
                        foregroundColor: action.isDestructive
                            ? Theme.of(context).colorScheme.error
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AlhaiRadius.button),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  List<_ActionItem> _getActions(String status) {
    switch (status) {
      case DeliveryStatus.assigned:
        return [
          _ActionItem(
            label: 'قبول الطلب',
            icon: Icons.check_circle_outline,
            onPressed: () => _updateStatus(DeliveryStatus.accepted),
          ),
          _ActionItem(
            label: 'رفض الطلب',
            icon: Icons.cancel_outlined,
            onPressed: () => _showRejectDialog(),
            isDestructive: true,
          ),
        ];
      case DeliveryStatus.accepted:
        return [
          _ActionItem(
            label: 'بدأت التوجه للمتجر',
            icon: Icons.directions_car_rounded,
            onPressed: () => _updateStatus(DeliveryStatus.headingToPickup),
          ),
        ];
      case DeliveryStatus.headingToPickup:
        return [
          _ActionItem(
            label: 'وصلت المتجر',
            icon: Icons.store_rounded,
            onPressed: () => _updateStatus(DeliveryStatus.arrivedAtPickup),
          ),
        ];
      case DeliveryStatus.arrivedAtPickup:
        return [
          _ActionItem(
            label: 'استلمت الطلب',
            icon: Icons.inventory_2_rounded,
            onPressed: () => _updateStatus(DeliveryStatus.pickedUp),
          ),
        ];
      case DeliveryStatus.pickedUp:
        return [
          _ActionItem(
            label: 'بدأت التوصيل',
            icon: Icons.local_shipping_rounded,
            onPressed: () => _updateStatus(DeliveryStatus.headingToCustomer),
          ),
        ];
      case DeliveryStatus.headingToCustomer:
        return [
          _ActionItem(
            label: 'وصلت العميل',
            icon: Icons.location_on_rounded,
            onPressed: () => _updateStatus(DeliveryStatus.arrivedAtCustomer),
          ),
        ];
      case DeliveryStatus.arrivedAtCustomer:
        return [
          _ActionItem(
            label: 'تأكيد التسليم',
            icon: Icons.check_circle_rounded,
            onPressed: () {
              if (widget.onProofRequired != null) {
                widget.onProofRequired!();
              } else {
                // H8: Block delivery completion without proof.
                // onProofRequired must be provided to navigate to the proof
                // screen. Refusing the transition prevents proof-less delivery.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يجب تقديم إثبات التسليم قبل التأكيد'),
                  ),
                );
              }
            },
          ),
          _ActionItem(
            label: 'فشل التوصيل',
            icon: Icons.error_outline,
            onPressed: () => _showFailDialog(),
            isDestructive: true,
          ),
        ];
      default:
        return [];
    }
  }

  void _showRejectDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('رفض الطلب'),
          content: TextField(
            controller: controller,
            maxLength: 200,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'سبب الرفض (اختياري)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(DeliveryStatus.cancelled, notes: controller.text);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: const Text('رفض'),
            ),
          ],
        );
      },
    );
  }

  void _showFailDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('فشل التوصيل'),
          content: TextField(
            controller: controller,
            maxLength: 200,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'سبب الفشل',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(DeliveryStatus.failed, notes: controller.text);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: const Text('تأكيد الفشل'),
            ),
          ],
        );
      },
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;

  _ActionItem({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });
}
