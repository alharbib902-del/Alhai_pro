/// Barrel export for domain models
library models;

// Enums
export 'enums/user_role.dart';
export 'enums/order_status.dart';
export 'enums/payment_method.dart';
export 'enums/delivery_status.dart';

// Models
export 'user.dart';

// v3.4 - Customer App Support
export 'customer_account.dart';
export 'loyalty_points.dart';
export 'chat_message.dart';
export 'store.dart';
export 'product.dart';
export 'order.dart';
export 'order_item.dart';
export 'auth_tokens.dart';
export 'auth_result.dart';
export 'category.dart';
export 'address.dart';
export 'cart.dart';
export 'delivery.dart';
export 'stock_adjustment.dart';
export 'supplier.dart';
export 'purchase_order.dart';
export 'debt.dart';
export 'sales_report.dart';
export 'analytics.dart';

// Params
export 'create_order_params.dart';
export 'create_product_params.dart';
export 'update_product_params.dart';

// Pagination (v3.2)
export 'paginated.dart';

// v2.4.0 - Additional Tables
export 'notification.dart';
export 'promotion.dart';
export 'order_payment.dart';
export 'store_settings.dart';
export 'activity_log.dart';
export 'shift.dart';

// v2.5.0 - POS_BACKLOG Compatibility
export 'cash_movement.dart';
export 'refund.dart';

// v2.6.0 - Distributor Portal Compatibility
export 'distributor.dart';
export 'wholesale_order.dart';
export 'pricing_tier.dart';
