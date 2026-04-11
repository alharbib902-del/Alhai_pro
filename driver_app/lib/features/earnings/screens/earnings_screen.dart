import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/stat_item.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/earnings_providers.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(earningsPeriodProvider);
    final summary = ref.watch(earningsSummaryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الأرباح'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
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
                    final total =
                        (data['total_earnings'] as num?)?.toDouble() ?? 0;
                    final count =
                        (data['total_deliveries'] as num?)?.toInt() ?? 0;
                    final avg =
                        (data['avg_per_delivery'] as num?)?.toDouble() ?? 0;
                    final distance =
                        (data['total_distance_km'] as num?)?.toDouble() ?? 0;
                    final deliveries =
                        data['deliveries'] as List<Map<String, dynamic>>;

                    // Fixed header items: total card (0), stats row (1),
                    // section label or empty state (2).
                    // Delivery tiles start at index 3 and are built lazily.
                    const headerCount = 3;
                    final hasDeliveries = deliveries.isNotEmpty;

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(earningsSummaryProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.md,
                        ),
                        itemCount:
                            headerCount +
                            (hasDeliveries ? deliveries.length : 1),
                        addAutomaticKeepAlives: false,
                        itemBuilder: (context, index) {
                          // Total earnings card
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AlhaiSpacing.sm,
                              ),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AlhaiRadius.md,
                                  ),
                                ),
                                color: theme.colorScheme.primaryContainer,
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AlhaiSpacing.lg,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'إجمالي الأرباح',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                      ),
                                      const SizedBox(height: AlhaiSpacing.xs),
                                      Text(
                                        '${total.toStringAsFixed(0)} ر.س',
                                        style: theme.textTheme.headlineLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          // Stats row
                          if (index == 1) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AlhaiSpacing.md,
                              ),
                              child: Row(
                                children: [
                                  _StatCardTile(
                                    label: 'التوصيلات',
                                    value: '$count',
                                    icon: Icons.local_shipping,
                                  ),
                                  const SizedBox(width: AlhaiSpacing.xs),
                                  _StatCardTile(
                                    label: 'المتوسط',
                                    value: '${avg.toStringAsFixed(0)} ر.س',
                                    icon: Icons.trending_up,
                                  ),
                                  const SizedBox(width: AlhaiSpacing.xs),
                                  _StatCardTile(
                                    label: 'المسافة',
                                    value: '${distance.toStringAsFixed(1)} كم',
                                    icon: Icons.straighten,
                                  ),
                                ],
                              ),
                            );
                          }

                          // Section label or empty state
                          if (index == 2) {
                            if (!hasDeliveries) {
                              return Padding(
                                padding: const EdgeInsets.all(AlhaiSpacing.xl),
                                child: Center(
                                  child: Text(
                                    'لا توجد توصيلات في هذه الفترة',
                                    style: TextStyle(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AlhaiSpacing.xs,
                              ),
                              child: Text(
                                'التوصيلات',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }

                          // Delivery tiles — built lazily
                          final d = deliveries[index - headerCount];
                          return _EarningsDeliveryTile(
                            key: ValueKey(d['id'] ?? index),
                            delivery: d,
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const _EarningsShimmer(),
                  error: (e, _) =>
                      const Center(child: Text('حدث خطأ في تحميل البيانات')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expanded card tile wrapping shared [StatItem].
class _StatCardTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCardTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlhaiRadius.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            child: StatItem(icon: icon, value: value, label: label),
          ),
        ),
      ),
    );
  }
}

class _EarningsDeliveryTile extends StatelessWidget {
  final Map<String, dynamic> delivery;

  const _EarningsDeliveryTile({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fee = (delivery['delivery_fee'] as num?)?.toDouble() ?? 0;
    final deliveredAt = DateTime.tryParse(
      delivery['delivered_at'] as String? ?? '',
    );
    final order = delivery['orders'] as Map<String, dynamic>?;
    final orderNum = order?['order_number'] ?? '';
    final timeStr = deliveredAt != null
        ? '${deliveredAt.hour}:${deliveredAt.minute.toString().padLeft(2, '0')}'
        : '';
    final label = orderNum.toString().isNotEmpty
        ? 'طلب رقم $orderNum، ${fee.toStringAsFixed(0)} ريال${timeStr.isNotEmpty ? '، الوقت $timeStr' : ''}'
        : 'توصيل، ${fee.toStringAsFixed(0)} ريال';

    return Semantics(
      label: label,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.md),
        ),
        margin: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
        child: ListTile(
          leading: ExcludeSemantics(
            child: Icon(
              Icons.check_circle,
              size: 24,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(orderNum.toString().isNotEmpty ? '#$orderNum' : 'توصيل'),
          subtitle: deliveredAt != null
              ? Text(timeStr, style: theme.textTheme.bodySmall)
              : null,
          trailing: Text(
            '${fee.toStringAsFixed(0)} ر.س',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          dense: true,
        ),
      ),
    );
  }
}

/// Shimmer placeholder for the earnings screen while loading.
class _EarningsShimmer extends StatelessWidget {
  const _EarningsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Total card shimmer
        Padding(
          padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Column(
                children: const [
                  ShimmerLoading(width: 100, height: 14),
                  SizedBox(height: AlhaiSpacing.xs),
                  ShimmerLoading(width: 140, height: 36),
                ],
              ),
            ),
          ),
        ),
        // Stats row shimmer
        Padding(
          padding: const EdgeInsets.only(bottom: AlhaiSpacing.md),
          child: Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                const Expanded(child: ShimmerCard()),
                if (i < 2) const SizedBox(width: AlhaiSpacing.xs),
              ],
            ],
          ),
        ),
        // Delivery tiles shimmer
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
            child: const ShimmerCard(),
          ),
      ],
    );
  }
}
