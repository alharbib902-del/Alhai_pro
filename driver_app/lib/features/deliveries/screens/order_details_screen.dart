import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/delivery_providers.dart';
import '../widgets/delivery_status_badge.dart';
import '../widgets/delivery_action_buttons.dart';
import '../widgets/customer_info_card.dart';
import '../widgets/order_items_list.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String deliveryId;

  const OrderDetailsScreen({super.key, required this.deliveryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delivery = ref.watch(deliveryByIdProvider(deliveryId));
    final theme = Theme.of(context);

    return delivery.when(
      data: (data) {
        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل الطلب')),
            body: const Center(child: Text('لم يتم العثور على الطلب')),
          );
        }

        final status = data['status'] as String? ?? '';
        final order = data['orders'] as Map<String, dynamic>?;
        final orderNumber = order?['order_number'] as String? ?? '';
        final notes = order?['notes'] as String?;
        final items = (order?['order_items'] as List?) ?? [];
        final address = data['delivery_address'] as String? ?? '';
        final fee = data['delivery_fee'];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              orderNumber.isNotEmpty ? '#$orderNumber' : 'تفاصيل الطلب',
            ),
            actions: [
              // Navigate button
              if (_isActiveStatus(status))
                IconButton(
                  icon: const Icon(Icons.navigation_rounded),
                  onPressed: () => context.push('/orders/$deliveryId/navigate'),
                  tooltip: 'الملاحة',
                ),
              // Chat button
              if (_isActiveStatus(status) && order != null)
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {
                    final orderId = order['id'] as String;
                    context.push('/chat/$orderId');
                  },
                  tooltip: 'المحادثة',
                ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(AlhaiSpacing.md),
                        children: [
                          // Status + Fee header
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AlhaiSpacing.md),
                              child: Row(
                                children: [
                                  DeliveryStatusBadge(status: status),
                                  const Spacer(),
                                  if (fee != null)
                                    Text(
                                      '${(fee as num).toStringAsFixed(0)} ر.س',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xs),

                          // Delivery address
                          if (address.isNotEmpty)
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.location_on_outlined),
                                title: const Text('عنوان التوصيل'),
                                subtitle: Text(address),
                              ),
                            ),
                          const SizedBox(height: AlhaiSpacing.xs),

                          // Customer info
                          CustomerInfoCard(
                            name: order?['customer_name'] as String?,
                            phone: order?['customer_phone'] as String?,
                            address: address,
                          ),
                          const SizedBox(height: AlhaiSpacing.xs),

                          // Order items
                          OrderItemsList(items: items),

                          // Notes
                          if (notes != null && notes.isNotEmpty) ...[
                            const SizedBox(height: AlhaiSpacing.xs),
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.note_outlined),
                                title: const Text('ملاحظات'),
                                subtitle: Text(notes),
                              ),
                            ),
                          ],

                          // Spacer for action buttons
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),

                    // Action buttons at the bottom
                    DeliveryActionButtons(
                      deliveryId: deliveryId,
                      currentStatus: status,
                      onProofRequired: () =>
                          context.push('/orders/$deliveryId/proof'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: ListView(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          children: const [
            ShimmerCard(),
            SizedBox(height: AlhaiSpacing.xs),
            ShimmerCard(),
            SizedBox(height: AlhaiSpacing.xs),
            ShimmerCard(),
            SizedBox(height: AlhaiSpacing.xs),
            ShimmerCard(),
          ],
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: const Center(child: Text('حدث خطأ في تحميل البيانات')),
      ),
    );
  }

  bool _isActiveStatus(String status) {
    return !['delivered', 'failed', 'cancelled'].contains(status);
  }
}
