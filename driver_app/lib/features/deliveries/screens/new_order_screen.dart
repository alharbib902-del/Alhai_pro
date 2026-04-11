import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/delivery_providers.dart';

/// Full-screen alert for new delivery assignment.
class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  Future<void> _accept(String deliveryId) async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(
        updateDeliveryStatusProvider((
          id: deliveryId,
          status: 'accepted',
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
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(
        updateDeliveryStatusProvider((
          id: deliveryId,
          status: 'cancelled',
          notes: 'رفض السائق',
        )).future,
      );
      if (mounted) context.pop();
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeDeliveries = ref.watch(activeDeliveriesProvider);

    return Scaffold(
      body: activeDeliveries.when(
        data: (deliveries) {
          final assigned = deliveries
              .where((d) => d['status'] == 'assigned')
              .toList();

          if (assigned.isEmpty) {
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

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Column(
                children: [
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
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _accept(deliveryId),
                        icon: const Icon(Icons.check_circle),
                        label: const Text(
                          'قبول الطلب',
                          style: TextStyle(fontSize: 18),
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
                    const SizedBox(height: AlhaiSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _reject(deliveryId),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text(
                          'رفض',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AlhaiRadius.button,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AlhaiSpacing.lg),
                ],
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
