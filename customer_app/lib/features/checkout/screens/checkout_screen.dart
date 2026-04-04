import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../cart/providers/cart_provider.dart';
import '../../addresses/providers/address_providers.dart';
import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    // Check minimum order amount
    final minOrderAmount = ref.read(minOrderAmountProvider);
    if (minOrderAmount > 0 && cart.total < minOrderAmount) {
      setState(() {
        _error =
            'الحد الأدنى للطلب ${minOrderAmount.toStringAsFixed(2)} ر.س';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final order = await ref.read(placeOrderProvider(cart).future);

      HapticFeedback.heavyImpact();

      // Clear cart
      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        context.go('/orders/${order.id}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);
    final paymentMethod = ref.watch(selectedPaymentMethodProvider);
    final addressesAsync = ref.watch(addressesListProvider);
    final deliveryFee = ref.watch(deliveryFeeProvider);
    final minOrderAmount = ref.watch(minOrderAmountProvider);
    final orderTotal = cart.total + deliveryFee;

    final belowMinOrder = minOrderAmount > 0 && cart.total < minOrderAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address Section
                  Text(
                    'عنوان التوصيل',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  addressesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('فشل تحميل العناوين'),
                    data: (addresses) {
                      if (addresses.isEmpty) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.add_location_alt),
                            title: const Text('أضف عنوان توصيل'),
                            onTap: () => context.push('/profile/addresses'),
                          ),
                        );
                      }

                      return Column(
                        children: addresses.map((address) {
                          final isSelected =
                              selectedAddress?.id == address.id;
                          return Card(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer
                                : null,
                            child: ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                              title: Text(address.label),
                              subtitle: Text(
                                address.fullAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle,
                                      color: theme.colorScheme.primary)
                                  : null,
                              onTap: () {
                                ref
                                    .read(selectedAddressProvider.notifier)
                                    .state = address;
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),

                  // Payment Method
                  Text(
                    'طريقة الدفع',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  ...[
                    (PaymentMethod.cash, 'الدفع عند الاستلام', Icons.money),
                    (PaymentMethod.card, 'بطاقة ائتمان', Icons.credit_card),
                    (PaymentMethod.wallet, 'المحفظة', Icons.account_balance_wallet),
                  ].map((entry) {
                    final (method, label, icon) = entry;
                    final isSelected = paymentMethod == method;
                    return Card(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: Icon(icon,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : null),
                        title: Text(label),
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: theme.colorScheme.primary)
                            : null,
                        onTap: () {
                          ref
                              .read(selectedPaymentMethodProvider.notifier)
                              .state = method;
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: AlhaiSpacing.lg),

                  // Minimum order warning
                  if (belowMinOrder) ...[
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(AlhaiSpacing.sm),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: theme.colorScheme.onErrorContainer),
                            const SizedBox(width: AlhaiSpacing.xs),
                            Expanded(
                              child: Text(
                                'الحد الأدنى للطلب ${minOrderAmount.toStringAsFixed(2)} ر.س',
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                  ],

                  // Order Summary
                  Text(
                    'ملخص الطلب',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AlhaiSpacing.md),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'المنتجات (${cart.itemCount})',
                            value: '${cart.total.toStringAsFixed(2)} ر.س',
                          ),
                          const Divider(),
                          _SummaryRow(
                            label: 'رسوم التوصيل',
                            value: deliveryFee > 0
                                ? '${deliveryFee.toStringAsFixed(2)} ر.س'
                                : 'مجاني',
                          ),
                          const Divider(),
                          _SummaryRow(
                            label: 'الإجمالي',
                            value: '${orderTotal.toStringAsFixed(2)} ر.س',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: AlhaiSpacing.md),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Place order button
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: FilledButton(
                onPressed: _loading || belowMinOrder ? null : _placeOrder,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: AlhaiRadius.borderMd,
                  ),
                ),
                child: _loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        'تأكيد الطلب - ${orderTotal.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
