/// Pricing tier providers for tier management and store assignments.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import 'distributor_datasource_provider.dart';

// ─── Pricing Tiers ─────────────────────────────────────────────

/// All pricing tiers for the current org.
final pricingTiersProvider = FutureProvider.autoDispose<List<PricingTier>>((
  ref,
) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getPricingTiers();
});

/// Store tier assignments with joined store/tier info.
final storeTierAssignmentsProvider =
    FutureProvider.autoDispose<List<StoreTierAssignment>>((ref) async {
      final ds = ref.watch(distributorDatasourceProvider);
      return ds.getStoreTierAssignments();
    });

/// All stores in the org (for assignment dropdown).
final orgStoresProvider =
    FutureProvider.autoDispose<List<({String id, String name})>>((ref) async {
      final ds = ref.watch(distributorDatasourceProvider);
      return ds.getOrgStores();
    });

/// Discount percentage for a specific store (by store ID).
final storeDiscountProvider = FutureProvider.autoDispose.family<double, String>(
  (ref, storeId) async {
    final ds = ref.watch(distributorDatasourceProvider);
    return ds.getStoreDiscountPercent(storeId);
  },
);
