/// Barrel export for repository interfaces
/// Note: Only interfaces are exported, implementations are internal
library repositories;

export 'auth_repository.dart';
export 'orders_repository.dart';
export 'products_repository.dart';
export 'categories_repository.dart';
export 'stores_repository.dart';
export 'addresses_repository.dart';
export 'delivery_repository.dart';
export 'inventory_repository.dart';
export 'suppliers_repository.dart';
export 'purchases_repository.dart';
export 'debts_repository.dart';
export 'reports_repository.dart';
export 'analytics_repository.dart';

// v2.4.0 - Additional Repositories
export 'notifications_repository.dart';
export 'promotions_repository.dart';
export 'order_payments_repository.dart';
export 'store_settings_repository.dart';
export 'activity_logs_repository.dart';
export 'shifts_repository.dart';

// v2.5.0 - POS_BACKLOG Compatibility
export 'cash_movements_repository.dart';
export 'refunds_repository.dart';

// v2.6.0 - Distributor Portal Compatibility
export 'distributors_repository.dart';
export 'wholesale_orders_repository.dart';

