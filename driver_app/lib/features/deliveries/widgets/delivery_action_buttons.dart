import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/delivery_providers.dart';

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

class _DeliveryActionButtonsState
    extends ConsumerState<DeliveryActionButtons> {
  bool _isLoading = false;

  Future<void> _updateStatus(String newStatus, {String? notes}) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(
        updateDeliveryStatusProvider(
          (id: widget.deliveryId, status: newStatus, notes: notes),
        ).future,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary action
          FilledButton.icon(
            onPressed: () => actions.first.onPressed(),
            icon: Icon(actions.first.icon),
            label: Text(actions.first.label),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Secondary actions
          if (actions.length > 1) ...[
            const SizedBox(height: AlhaiSpacing.xs),
            for (final action in actions.skip(1))
              Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                child: OutlinedButton.icon(
                  onPressed: () => action.onPressed(),
                  icon: Icon(action.icon),
                  label: Text(action.label),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: action.isDestructive ? Colors.red : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
      case 'assigned':
        return [
          _ActionItem(
            label: 'قبول الطلب',
            icon: Icons.check_circle_outline,
            onPressed: () => _updateStatus('accepted'),
          ),
          _ActionItem(
            label: 'رفض الطلب',
            icon: Icons.cancel_outlined,
            onPressed: () => _showRejectDialog(),
            isDestructive: true,
          ),
        ];
      case 'accepted':
        return [
          _ActionItem(
            label: 'بدأت التوجه للمتجر',
            icon: Icons.directions_car_rounded,
            onPressed: () => _updateStatus('heading_to_pickup'),
          ),
        ];
      case 'heading_to_pickup':
        return [
          _ActionItem(
            label: 'وصلت المتجر',
            icon: Icons.store_rounded,
            onPressed: () => _updateStatus('arrived_at_pickup'),
          ),
        ];
      case 'arrived_at_pickup':
        return [
          _ActionItem(
            label: 'استلمت الطلب',
            icon: Icons.inventory_2_rounded,
            onPressed: () => _updateStatus('picked_up'),
          ),
        ];
      case 'picked_up':
        return [
          _ActionItem(
            label: 'بدأت التوصيل',
            icon: Icons.local_shipping_rounded,
            onPressed: () => _updateStatus('heading_to_customer'),
          ),
        ];
      case 'heading_to_customer':
        return [
          _ActionItem(
            label: 'وصلت العميل',
            icon: Icons.location_on_rounded,
            onPressed: () => _updateStatus('arrived_at_customer'),
          ),
        ];
      case 'arrived_at_customer':
        return [
          _ActionItem(
            label: 'تأكيد التسليم',
            icon: Icons.check_circle_rounded,
            onPressed: () {
              if (widget.onProofRequired != null) {
                widget.onProofRequired!();
              } else {
                _updateStatus('delivered');
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
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('رفض الطلب'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'سبب الرفض (اختياري)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus('cancelled', notes: controller.text);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('رفض'),
            ),
          ],
        );
      },
    );
  }

  void _showFailDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('فشل التوصيل'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'سبب الفشل',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus('failed', notes: controller.text);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
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
