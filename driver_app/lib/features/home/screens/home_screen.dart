import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/home_providers.dart';
import '../widgets/active_delivery_card.dart';
import '../widgets/daily_stats_card.dart';
import '../widgets/shift_toggle.dart';
import '../../deliveries/providers/new_assignment_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final newAssignment = ref.watch(newAssignmentProvider);

    // Show new assignment alert if available
    newAssignment.whenData((assignment) {
      if (assignment != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.push('/orders/new');
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        actions: const [ShiftToggle()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          children: [
            // Daily stats
            stats.when(
              data: (data) => DailyStatsCard(stats: data),
              loading: () => const DailyStatsCard(stats: {}),
              error: (_, __) => const DailyStatsCard(stats: {}),
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // Active delivery card
            stats.when(
              data: (data) {
                final activeId = data['active_delivery_id'] as String?;
                final activeStatus =
                    data['active_delivery_status'] as String?;
                if (activeId != null) {
                  return ActiveDeliveryCard(
                    deliveryId: activeId,
                    status: activeStatus ?? '',
                    onTap: () => context.push('/orders/$activeId'),
                  );
                }
                return _NoActiveDeliveryCard();
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(AlhaiSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => _NoActiveDeliveryCard(),
            ),

            const SizedBox(height: AlhaiSpacing.md),

            // Pending assignments count
            stats.when(
              data: (data) {
                final pending = data['pending_count'] as int? ?? 0;
                if (pending > 0) {
                  return Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: ListTile(
                      leading: Badge(
                        label: Text('$pending'),
                        child: const Icon(Icons.notification_important_rounded),
                      ),
                      title: Text('$pending طلبات بانتظار القبول'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.go('/deliveries'),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoActiveDeliveryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Text(
              'لا يوجد توصيل نشط',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xxs),
            Text(
              'سيظهر الطلب الجديد هنا عند تعيينه',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
