import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../stores/providers/stores_providers.dart';
import '../widgets/store_card.dart';
import '../../../core/services/location_service.dart';

/// User location provider.
final _userLocationProvider = FutureProvider<({double lat, double lng})?>((ref) async {
  final pos = await LocationService.getCurrentPosition();
  if (pos == null) return null;
  return (lat: pos.latitude, lng: pos.longitude);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final locationAsync = ref.watch(_userLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً${user != null ? " ${user.name}" : ""}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'اختر متجرك',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_userLocationProvider);
          ref.invalidate(allStoresProvider);
        },
        child: locationAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildStoreList(ref, context, null),
          data: (location) => _buildStoreList(ref, context, location),
        ),
      ),
    );
  }

  Widget _buildStoreList(
    WidgetRef ref,
    BuildContext context,
    ({double lat, double lng})? location,
  ) {
    final theme = Theme.of(context);

    // Use nearby stores if location available, otherwise all stores
    final storesAsync = location != null
        ? ref.watch(nearbyStoresProvider(location))
        : ref.watch(allStoresProvider);

    return storesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AlhaiSpacing.md),
            Text('فشل تحميل المتاجر', style: theme.textTheme.bodyLarge),
            const SizedBox(height: AlhaiSpacing.xs),
            FilledButton(
              onPressed: () {
                ref.invalidate(allStoresProvider);
                if (location != null) {
                  ref.invalidate(nearbyStoresProvider(location));
                }
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
      data: (stores) {
        if (stores.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: AlhaiSpacing.md),
                Text(
                  'لا توجد متاجر قريبة',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  'حاول توسيع نطاق البحث',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          itemCount: stores.length + 1, // +1 for header
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                child: Text(
                  location != null ? 'المتاجر القريبة' : 'جميع المتاجر',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            final store = stores[index - 1];
            final distance = location != null
                ? LocationService.distanceKm(
                    location.lat, location.lng, store.lat, store.lng)
                : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
              child: StoreCard(
                store: store,
                distanceKm: distance,
                onTap: () {
                  ref.read(selectedStoreProvider.notifier).state = store;
                  context.push('/catalog');
                },
              ),
            );
          },
        );
      },
    );
  }
}
