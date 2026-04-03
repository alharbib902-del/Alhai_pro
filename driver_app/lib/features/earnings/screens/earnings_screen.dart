import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/earnings_providers.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(earningsPeriodProvider);
    final summary = ref.watch(earningsSummaryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأرباح'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: SegmentedButton<EarningsPeriod>(
              selected: {period},
              onSelectionChanged: (s) =>
                  ref.read(earningsPeriodProvider.notifier).state = s.first,
              segments: const [
                ButtonSegment(
                  value: EarningsPeriod.daily,
                  label: Text('اليوم'),
                ),
                ButtonSegment(
                  value: EarningsPeriod.weekly,
                  label: Text('الأسبوع'),
                ),
                ButtonSegment(
                  value: EarningsPeriod.monthly,
                  label: Text('الشهر'),
                ),
              ],
            ),
          ),

          // Summary
          Expanded(
            child: summary.when(
              data: (data) {
                final total = (data['total_earnings'] as num).toDouble();
                final count = data['total_deliveries'] as int;
                final avg = (data['avg_per_delivery'] as num).toDouble();
                final distance =
                    (data['total_distance_km'] as num).toDouble();
                final deliveries =
                    data['deliveries'] as List<Map<String, dynamic>>;

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(earningsSummaryProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
                    children: [
                      // Total earnings card
                      Card(
                        color: theme.colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(AlhaiSpacing.lg),
                          child: Column(
                            children: [
                              Text(
                                'إجمالي الأرباح',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: AlhaiSpacing.xs),
                              Text(
                                '${total.toStringAsFixed(0)} ر.س',
                                style:
                                    theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AlhaiSpacing.sm),

                      // Stats row
                      Row(
                        children: [
                          _StatCard(
                            label: 'التوصيلات',
                            value: '$count',
                            icon: Icons.local_shipping,
                          ),
                          const SizedBox(width: AlhaiSpacing.xs),
                          _StatCard(
                            label: 'المتوسط',
                            value: '${avg.toStringAsFixed(0)} ر.س',
                            icon: Icons.trending_up,
                          ),
                          const SizedBox(width: AlhaiSpacing.xs),
                          _StatCard(
                            label: 'المسافة',
                            value: '${distance.toStringAsFixed(1)} كم',
                            icon: Icons.straighten,
                          ),
                        ],
                      ),
                      const SizedBox(height: AlhaiSpacing.md),

                      // Deliveries list
                      if (deliveries.isNotEmpty) ...[
                        Text(
                          'التوصيلات',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.xs),
                        for (final d in deliveries)
                          _EarningsDeliveryTile(delivery: d),
                      ] else
                        Padding(
                          padding: const EdgeInsets.all(AlhaiSpacing.xl),
                          child: Center(
                            child: Text(
                              'لا توجد توصيلات في هذه الفترة',
                              style: TextStyle(
                                  color: theme.colorScheme.outline),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          child: Column(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: AlhaiSpacing.xxs),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarningsDeliveryTile extends StatelessWidget {
  final Map<String, dynamic> delivery;

  const _EarningsDeliveryTile({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fee = (delivery['delivery_fee'] as num?)?.toDouble() ?? 0;
    final deliveredAt =
        DateTime.tryParse(delivery['delivered_at'] as String? ?? '');
    final order = delivery['orders'] as Map<String, dynamic>?;
    final orderNum = order?['order_number'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(
          orderNum.toString().isNotEmpty ? '#$orderNum' : 'توصيل',
        ),
        subtitle: deliveredAt != null
            ? Text(
                '${deliveredAt.hour}:${deliveredAt.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodySmall,
              )
            : null,
        trailing: Text(
          '${fee.toStringAsFixed(0)} ر.س',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        dense: true,
      ),
    );
  }
}
