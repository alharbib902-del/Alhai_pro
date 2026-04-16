/// Barrel export for all public APIs
library src;

// Config
export 'config/app_endpoints.dart';
export 'config/app_flavor.dart';
export 'config/app_limits.dart';
export 'config/environment.dart';
export 'config/feature_flags.dart';
export 'config/whatsapp_config.dart';
export 'config/supabase_config.dart';

// Models (Domain)
export 'models/models.dart';

// DTOs
export 'dto/dto.dart';

// Repositories (Interfaces only)
export 'repositories/repositories.dart';

// Exceptions
export 'exceptions/exceptions.dart';

// DI
export 'di/di.dart';

// Services (v2.5.0)
export 'services/services.dart';

// Networking (public types only)
export 'networking/networking.dart';

// Monitoring
export 'monitoring/production_logger.dart';
