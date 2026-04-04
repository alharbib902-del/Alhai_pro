import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_account.freezed.dart';
part 'customer_account.g.dart';

/// Customer Account model for multi-store support (v3.4)
/// Links a global customer to a specific store with separate balance/loyalty
@freezed
class CustomerAccount with _$CustomerAccount {
  const CustomerAccount._();

  const factory CustomerAccount({
    required String id,
    required String customerId, // global_customers.id
    required String storeId,
    @Default(0.0) double balance, // negative = debt, positive = credit
    @Default(500.0) double creditLimit,
    @Default(true) bool isActive,
    @Default(0) int totalOrders,
    @Default(0) int completedOrders,
    @Default(0) int cancelledOrders,
    DateTime? lastOrderAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _CustomerAccount;

  factory CustomerAccount.fromJson(Map<String, dynamic> json) =>
      _$CustomerAccountFromJson(json);

  /// Calculate available credit
  double get availableCredit {
    if (balance >= 0) return creditLimit; // No debt
    return creditLimit + balance; // balance is negative
  }

  /// Check if customer can order with credit
  bool canOrderWithCredit(double orderAmount) {
    if (!isActive) return false;
    return (balance.abs() + orderAmount) <= creditLimit;
  }

  /// Check if account is restricted
  bool get isRestricted => !isActive || balance.abs() > creditLimit;
}
