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
