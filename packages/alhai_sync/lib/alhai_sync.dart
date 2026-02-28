/// Sync engine, strategies, offline manager, and connectivity for Alhai apps.
///
/// 4-phase sync: Pull → Push → Bidirectional → Stock Delta.
/// Supports offline mode with queue and exponential backoff retry.
library alhai_sync;

// Core sync services
export 'src/sync_engine.dart';
export 'src/sync_manager.dart';
export 'src/sync_service.dart';
export 'src/sync_api_service.dart';
export 'src/org_sync_service.dart';
export 'src/initial_sync.dart';
export 'src/sync_status_tracker.dart';
export 'src/realtime_listener.dart';
export 'src/json_converter.dart';
export 'src/sync_payload_utils.dart';

// Strategies
export 'src/strategies/strategies.dart';

// Offline & Connectivity
export 'src/offline/offline_manager.dart';
export 'src/connectivity_service.dart';
