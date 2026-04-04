import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:uuid/uuid.dart';

import '../../../di/injection.dart';
import '../data/orders_datasource.dart';
import '../../addresses/providers/address_providers.dart';
import '../../../core/providers/app_providers.dart';

/// Selected payment method for checkout.
final selectedPaymentMethodProvider =
    StateProvider<PaymentMethod>((ref) => PaymentMethod.cash);

/// Delivery notes.
final deliveryNotesProvider = StateProvider<String>((ref) => '');

/// Computed delivery fee from selected store.
final deliveryFeeProvider = Provider<double>((ref) {
  final store = ref.watch(selectedStoreProvider);
  return store?.deliveryFee ?? 0;
});

/// Minimum order amount from selected store.
final minOrderAmountProvider = Provider<double>((ref) {
  final store = ref.watch(selectedStoreProvider);
  return store?.minOrderAmount ?? 0;
});

/// Place order action.
final placeOrderProvider =
    FutureProvider.family<Order, Cart>((ref, cart) async {
  final address = ref.read(selectedAddressProvider);
  final paymentMethod = ref.read(selectedPaymentMethodProvider);
  final deliveryFee = ref.read(deliveryFeeProvider);

  if (cart.storeId == null || cart.isEmpty) {
    throw Exception('السلة فارغة');
  }

  if (address == null) {
    throw Exception('يرجى اختيار عنوان التوصيل');
  }

  final minOrder = ref.read(minOrderAmountProvider);
  if (minOrder > 0 && cart.total < minOrder) {
    throw Exception('الحد الأدنى للطلب ${minOrder.toStringAsFixed(0)} ر.س');
  }

  final params = CreateOrderParams(
    clientOrderId: const Uuid().v4(),
    storeId: cart.storeId!,
    items: cart.items.map((item) => item.toOrderItem()).toList(),
    addressId: address.id,
    deliveryAddress: address.fullAddress,
    paymentMethod: paymentMethod,
    deliveryFee: deliveryFee,
  );

  final datasource = locator<OrdersDatasource>();
  return datasource.createOrder(params);
});
