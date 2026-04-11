import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../stores/providers/stores_providers.dart';
import '../widgets/store_card.dart';
import '../../../core/services/location_service.dart';

/// User location provider.
final _userLocationProvider = FutureProvider<({double lat, double lng})?>((
  ref,
) async {
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_userLocationProvider);
            ref.invalidate(allStoresProvider);
          },
          child: locationAsync.when(
            loading: () => _buildShimmerList(),
            error: (_, __) => _buildStoreList(ref, context, null),
            data: (location) => _buildStoreList(ref, context, location),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return AlhaiShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
          child: AlhaiSkeleton.card(height: 90),
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
      loading: () => _buildShimmerList(),
      error: (error, _) => Center(
        child: AlhaiEmptyState.error(
          title: 'فشل تحميل المتاجر',
          description: 'تحقق من اتصالك بالإنترنت',
          actionText: 'إعادة المحاولة',
          onAction: () {
            ref.invalidate(allStoresProvider);
            if (location != null) {
              ref.invalidate(nearbyStoresProvider(location));
            }
          },
        ),
      ),
      data: (stores) {
        if (stores.isEmpty) {
          return Center(
            child: AlhaiEmptyState(
              icon: Icons.storefront_outlined,
              title: 'لا توجد متاجر قريبة',
              description: 'حاول توسيع نطاق البحث',
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = ResponsiveHelper.isTablet(context);
            final padding = isTablet
                ? const EdgeInsets.all(AlhaiSpacing.lg)
                : const EdgeInsets.all(AlhaiSpacing.md);

            final header = Padding(
              padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
              child: Text(
                location != null ? 'المتاجر القريبة' : 'جميع المتاجر',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );

            List<Widget> storeWidgets = stores.map((store) {
              final distance = location != null
                  ? LocationService.distanceKm(
                      location.lat,
                      location.lng,
                      store.lat,
                      store.lng,
                    )
                  : null;
              return StoreCard(
                store: store,
                distanceKm: distance,
                onTap: () {
                  ref.read(selectedStoreProvider.notifier).state = store;
                  context.push('/catalog');
                },
              );
            }).toList();

            if (isTablet) {
              // Tablet: 2-column grid
              final columns = ResponsiveHelper.isLargeTablet(context) ? 3 : 2;
              return SingleChildScrollView(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AlhaiSpacing.sm,
                      mainAxisSpacing: AlhaiSpacing.sm,
                      childAspectRatio: 2.2,
                      children: storeWidgets,
                    ),
                  ],
                ),
              );
            }

            // Phone: list layout (unchanged)
            return ListView.builder(
              padding: padding,
              itemCount: stores.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return header;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                  child: storeWidgets[index - 1],
                );
              },
            );
          },
        );
      },
    );
  }
}
