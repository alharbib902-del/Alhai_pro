/// Shared Drift database for all Alhai apps.
///
/// Contains 40+ tables, 28+ DAOs, FTS search, migrations (v1-v11),
/// and database seeder for development.
library alhai_database;

// Core
export 'src/app_database.dart';
export 'src/connection.dart';

// Re-export commonly used Drift types
export 'package:drift/drift.dart' show Value;

// Tables (barrel)
export 'src/tables/tables.dart';

// DAOs (barrel)
export 'src/daos/daos.dart';

// FTS
export 'src/fts/products_fts.dart';

// Seeders
export 'src/seeders/database_seeder.dart';

// Enums (M30: type-safe status column validation)
export 'src/enums/status_enums.dart';

// Utils (M29: JSON column validation)
export 'src/utils/json_validators.dart';

// Constants
export 'src/constants/retention_policy.dart';

// Services
export 'src/services/database_backup_service.dart';
export 'src/services/data_validator.dart';
export 'src/services/db_health_service.dart';
export 'src/services/storage_monitor.dart';
export 'src/services/data_retention_service.dart';

// Repositories (shared local implementations)
export 'src/repositories/local_products_repository.dart';
export 'src/repositories/local_categories_repository.dart';
