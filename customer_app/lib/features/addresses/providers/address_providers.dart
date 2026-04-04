import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../di/injection.dart';
import '../data/addresses_datasource.dart';

/// All addresses for the current user.
final addressesListProvider = FutureProvider<List<Address>>((ref) async {
  final datasource = locator<AddressesDatasource>();
  return datasource.getAddresses();
});

/// Auto-selected default address (derived from addressesListProvider).
final _defaultAddressProvider = Provider<Address?>((ref) {
  final addresses = ref.watch(addressesListProvider).valueOrNull;
  if (addresses != null && addresses.isNotEmpty) {
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }
  return null;
});

/// Selected address for checkout.
/// Starts with the default address but can be overridden by user selection.
final selectedAddressProvider = StateProvider<Address?>((ref) {
  return ref.watch(_defaultAddressProvider);
});
