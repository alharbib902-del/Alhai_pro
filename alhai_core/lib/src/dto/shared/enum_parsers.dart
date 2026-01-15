import '../../models/enums/order_status.dart';
import '../../models/enums/payment_method.dart';
import '../../models/enums/user_role.dart';

/// Robust enum parsers for API responses
/// Handles: camelCase, snake_case, UPPERCASE variations

/// Extension for parsing OrderStatus from API string
extension OrderStatusX on OrderStatus {
  /// Converts API string to OrderStatus enum with normalization
  /// Handles: created, CREATED, out_for_delivery, outForDelivery
  static OrderStatus fromApi(String value) {
    final v = value.trim().toLowerCase();
    switch (v) {
      case 'created':
        return OrderStatus.created;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'outfordelivery':
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.created;
    }
  }
}

/// Extension for parsing PaymentMethod from API string
extension PaymentMethodX on PaymentMethod {
  /// Converts API string to PaymentMethod enum with normalization
  /// Handles: cash, CASH, bank_transfer, bankTransfer
  static PaymentMethod fromApi(String value) {
    final v = value.trim().toLowerCase();
    switch (v) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'wallet':
        return PaymentMethod.wallet;
      case 'banktransfer':
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      default:
        return PaymentMethod.cash;
    }
  }
}

/// Extension for parsing UserRole from API string
extension UserRoleX on UserRole {
  /// Converts API string to UserRole enum with normalization
  /// Handles: superAdmin, super_admin, SUPER_ADMIN, storeOwner, store_owner
  static UserRole fromApi(String value) {
    final v = value.trim().toLowerCase();
    switch (v) {
      case 'superadmin':
      case 'super_admin':
        return UserRole.superAdmin;
      case 'storeowner':
      case 'store_owner':
        return UserRole.storeOwner;
      case 'employee':
      case 'cashier':
        return UserRole.employee;
      case 'delivery':
      case 'driver':
        return UserRole.delivery;
      case 'customer':
        return UserRole.customer;
      default:
        return UserRole.customer;
    }
  }
}
