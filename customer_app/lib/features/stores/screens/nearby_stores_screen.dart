import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../providers/stores_providers.dart';
import '../../home/widgets/store_card.dart';

class NearbyStoresScreen extends ConsumerWidget {
  const NearbyStoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(allStoresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المتاجر القريبة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: storesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: AlhaiEmptyState.error(
              title: 'فشل تحميل المتاجر',
              description: 'تحقق من اتصالك بالإنترنت',
              actionText: 'إعادة المحاولة',
              onAction: () => ref.invalidate(allStoresProvider),
            ),
          ),
          data: (stores) {
            if (stores.isEmpty) {
              return Center(
                child: AlhaiEmptyState(
                  icon: Icons.storefront_outlined,
                  title: 'لا توجد متاجر قريبة',
                  description: 'لم نتمكن من العثور على متاجر في منطقتك',
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final store = stores[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                  child: StoreCard(
                    store: store,
                    onTap: () {
                      ref.read(selectedStoreProvider.notifier).state = store;
                      context.push('/catalog');
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
