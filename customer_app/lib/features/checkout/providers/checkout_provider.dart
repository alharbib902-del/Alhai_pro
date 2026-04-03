import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:uuid/uuid.dart';

import '../../../di/injection.dart';
import '../data/orders_datasource.dart';
import '../../addresses/providers/address_providers.dart';

/// Selected payment method for checkout.
final selectedPaymentMethodProvider =
    StateProvider<PaymentMethod>((ref) => PaymentMethod.cash);

/// Delivery notes.
final deliveryNotesProvider = StateProvider<String>((ref) => '');

/// Place order action.
final placeOrderProvider = FutureProvider.family<Order, Cart>((ref, cart) async {
  final address = ref.read(selectedAddressProvider);
  final paymentMethod = ref.read(selectedPaymentMethodProvider);

  if (cart.storeId == null || cart.isEmpty) {
    throw Exception('السلة فارغة');
  }

  final params = CreateOrderParams(
    clientOrderId: const Uuid().v4(),
    storeId: cart.storeId!,
    items: cart.items.map((item) => item.toOrderItem()).toList(),
    addressId: address?.id,
    deliveryAddress: address?.fullAddress,
    paymentMethod: paymentMethod,
  );

  final datasource = locator<OrdersDatasource>();
  return datasource.createOrder(params);
});
