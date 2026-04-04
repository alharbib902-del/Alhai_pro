/// Barrel export for datasources
/// Note: Datasources are INTERNAL by default.
/// Export only contracts if you need them for integration tests.
library datasources;

// Remote contracts (no impl exports)
export 'remote/auth_remote_datasource.dart';
export 'remote/orders_remote_datasource.dart';
export 'remote/products_remote_datasource.dart';
export 'remote/categories_remote_datasource.dart';
export 'remote/stores_remote_datasource.dart';
export 'remote/addresses_remote_datasource.dart';
export 'remote/delivery_remote_datasource.dart';
export 'remote/inventory_remote_datasource.dart';
export 'remote/suppliers_remote_datasource.dart';
export 'remote/purchases_remote_datasource.dart';
export 'remote/debts_remote_datasource.dart';
export 'remote/reports_remote_datasource.dart';
export 'remote/analytics_remote_datasource.dart';

// Local contracts + entities (no impl exports)
export 'local/auth_local_datasource.dart';
export 'local/entities/auth_tokens_entity.dart';
export 'local/entities/user_entity.dart';
