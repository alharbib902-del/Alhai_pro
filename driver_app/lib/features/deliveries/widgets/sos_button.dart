import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/location_service.dart';

/// Emergency SOS button shown during active deliveries.
///
/// When tapped, shows a confirmation dialog. On confirmation:
/// 1. Logs the SOS event to the `audit_log` table with location + order context.
/// 2. Opens the phone dialer with Saudi emergency number 999.
class SosButton extends ConsumerWidget {
  /// The ID of the currently active delivery.
  final String activeDeliveryId;

  const SosButton({super.key, required this.activeDeliveryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      heroTag: 'sos_button',
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('إشارة استغاثة'),
            content: const Text(
              'هل تريد إرسال إشارة استغاثة والاتصال بالطوارئ (999)؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('تأكيد الاستغاثة'),
              ),
            ],
          ),
        );

        if (confirmed != true || !context.mounted) return;

        // 1. Best-effort audit log with location
        _logSosEvent(ref);

        // 2. Open dialer to Saudi emergency number
        try {
          await launchUrl(Uri.parse('tel:999'));
        } catch (_) {
          // Dialer may not be available on all devices.
        }

        // 3. Show confirmation
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال إشارة الاستغاثة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      tooltip: 'طوارئ SOS',
      child: const Icon(Icons.sos, size: 28),
    );
  }

  /// Best-effort audit log — fire-and-forget.
  void _logSosEvent(WidgetRef ref) {
    Future<void>(() async {
      try {
        final client = ref.read(supabaseClientProvider);
        final userId = client.auth.currentUser?.id;

        double? lat;
        double? lng;
        try {
          final position = await LocationService.instance.getCurrentPosition();
          lat = position?.latitude;
          lng = position?.longitude;
        } catch (_) {
          // Location unavailable — log without coordinates.
        }

        await client.from('audit_log').insert({
          'user_id': userId,
          'action': 'sos_triggered',
          'details': {
            'lat': lat,
            'lng': lng,
            'order_id': activeDeliveryId,
            'timestamp': DateTime.now().toIso8601String(),
          },
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Best-effort — SOS must not be blocked by audit failure.
      }
    });
  }
}
