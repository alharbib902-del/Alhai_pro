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
      body: storesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('فشل تحميل المتاجر')),
        data: (stores) {
          if (stores.isEmpty) {
            return const Center(child: Text('لا توجد متاجر'));
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
    );
  }
}
