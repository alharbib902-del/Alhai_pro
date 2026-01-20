/// Barrel export for DTOs
/// Note: DTOs are exported for cases where apps need direct API mapping
library dto;

// Auth DTOs
export 'auth/auth_response.dart';
export 'auth/auth_tokens_response.dart';

// Orders DTOs
export 'orders/order_response.dart';
export 'orders/order_item_response.dart';
export 'orders/create_order_request.dart';
export 'orders/order_item_request.dart';

// Shared
export 'shared/enum_parsers.dart';

// Products DTOs
export 'products/product_response.dart';
export 'products/create_product_request.dart';
export 'products/update_product_request.dart';

// Categories DTOs
export 'categories/category_response.dart';

// Stores DTOs
export 'stores/store_response.dart';

// Addresses DTOs
export 'addresses/address_response.dart';

// Inventory DTOs
export 'inventory/stock_adjustment_response.dart';
export 'inventory/adjust_stock_request.dart';
export 'inventory/low_stock_product_response.dart';

// Suppliers DTOs
export 'suppliers/supplier_response.dart';
export 'suppliers/create_supplier_request.dart';
export 'suppliers/update_supplier_request.dart';

// Purchases DTOs
export 'purchases/purchase_order_response.dart';
export 'purchases/create_purchase_order_request.dart';
export 'purchases/receive_items_request.dart';

// Debts DTOs
export 'debts/debt_response.dart';
export 'debts/create_debt_request.dart';
export 'debts/debt_payment_response.dart';
export 'debts/debt_summary_response.dart';

// Reports DTOs
export 'reports/sales_summary_response.dart';
export 'reports/product_sales_response.dart';
export 'reports/category_sales_response.dart';
export 'reports/inventory_value_response.dart';
export 'reports/monthly_comparison_response.dart';

// Analytics DTOs
export 'analytics/slow_moving_product_response.dart';
export 'analytics/sales_forecast_response.dart';
export 'analytics/smart_alert_response.dart';
export 'analytics/reorder_suggestion_response.dart';
export 'analytics/peak_hours_analysis_response.dart';
export 'analytics/customer_pattern_response.dart';
export 'analytics/dashboard_summary_response.dart';
