import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/delivery_providers.dart';
import '../widgets/delivery_card.dart';

class DeliveriesListScreen extends ConsumerWidget {
  const DeliveriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(deliveryFilterProvider);
    final deliveries = ref.watch(filteredDeliveriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التوصيلات'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
            child: SegmentedButton<DeliveryFilter>(
              selected: {filter},
              onSelectionChanged: (s) =>
                  ref.read(deliveryFilterProvider.notifier).state = s.first,
              segments: const [
                ButtonSegment(
                  value: DeliveryFilter.active,
                  label: Text('نشط'),
                  icon: Icon(Icons.local_shipping, size: 16),
                ),
                ButtonSegment(
                  value: DeliveryFilter.completed,
                  label: Text('مكتمل'),
                  icon: Icon(Icons.check_circle, size: 16),
                ),
                ButtonSegment(
                  value: DeliveryFilter.all,
                  label: Text('الكل'),
                  icon: Icon(Icons.list, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      body: deliveries.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  Text(
                    'لا توجد توصيلات',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myDeliveriesStreamProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final delivery = list[index];
                return DeliveryCard(
                  delivery: delivery,
                  onTap: () {
                    final id = delivery['id'] as String;
                    context.push('/orders/$id');
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}
