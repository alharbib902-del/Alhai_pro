import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../di/injection.dart';
import '../data/addresses_datasource.dart';

/// All addresses for the current user.
final addressesListProvider = FutureProvider<List<Address>>((ref) async {
  final datasource = locator<AddressesDatasource>();
  return datasource.getAddresses();
});

/// Selected address for checkout.
final selectedAddressProvider = StateProvider<Address?>((ref) {
  // Auto-select default address
  final addresses = ref.watch(addressesListProvider).valueOrNull;
  if (addresses != null && addresses.isNotEmpty) {
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }
  return null;
});
