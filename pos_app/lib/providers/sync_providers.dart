/// مزودات المزامنة والاتصال
///
/// توفر حالة المزامنة والاتصال بالإنترنت
/// تشمل: محرك المزامنة، المستمع الفوري، متتبع الحالة
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local/app_database.dart';
import '../di/injection.dart';
import '../services/connectivity_service.dart';
import '../services/sync/sync_service.dart';
import '../services/sync/sync_manager.dart';
import '../services/sync/sync_api_service.dart';
import '../services/sync/org_sync_service.dart';
import '../services/sync/sync_engine.dart';
import '../services/sync/realtime_listener.dart';
import '../services/sync/sync_status_tracker.dart';
import '../services/sync/initial_sync.dart';
import '../services/sync/strategies/pull_strategy.dart';
import '../services/sync/strategies/push_strategy.dart';
import '../services/sync/strategies/bidirectional_strategy.dart';
import '../services/sync/strategies/stock_delta_sync.dart';

/// مزود قاعدة البيانات - يستخدم singleton من getIt
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return getIt<AppDatabase>();
});

/// مزود خدمة الاتصال
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// مزود حالة الاتصال
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

/// مزود خدمة المزامنة
final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SyncService(db.syncQueueDao);
});

/// مزود خدمة API المزامنة
final syncApiServiceProvider = Provider<SyncApiService?>((ref) {
  try {
    final client = getIt<SupabaseClient>();
    return SyncApiService(client: client);
  } catch (e) {
    // SupabaseClient not registered - offline mode, sync unavailable
    if (kDebugMode) {
      debugPrint('SyncApiService unavailable: SupabaseClient not registered. $e');
    }
    return null;
  }
});

/// مزود خدمة مزامنة المؤسسة
final orgSyncServiceProvider = Provider<OrgSyncService?>((ref) {
  try {
    final client = getIt<SupabaseClient>();
    return OrgSyncService(client: client);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('OrgSyncService unavailable: SupabaseClient not registered. $e');
    }
    return null;
  }
});

/// مزود مدير المزامنة (القديم - للتوافق)
final syncManagerProvider = Provider<SyncManager>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final syncApi = ref.watch(syncApiServiceProvider);
  final orgSync = ref.watch(orgSyncServiceProvider);

  final manager = SyncManager(
    syncService: syncService,
    connectivityService: connectivity,
    onSync: syncApi != null
        ? (tableName, operation, payload) async {
            await syncApi.syncOperation(
              tableName: tableName,
              operation: operation,
              payload: payload,
            );
          }
        : null,
    orgSyncService: orgSync,
  );

  manager.initialize();
  ref.onDispose(() => manager.dispose());
  return manager;
});

// ─── مزودات محرك المزامنة الجديد ───

/// مزود متتبع حالة المزامنة
final syncStatusTrackerProvider = Provider<SyncStatusTracker>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final tracker = SyncStatusTracker(
    db: db,
    metadataDao: db.syncMetadataDao,
    deltasDao: db.stockDeltasDao,
  );
  tracker.startTracking();
  ref.onDispose(() => tracker.dispose());
  return tracker;
});

/// مزود محرك المزامنة
final syncEngineProvider = Provider<SyncEngine?>((ref) {
  try {
    final client = getIt<SupabaseClient>();
    final db = ref.watch(appDatabaseProvider);
    final connectivity = ref.watch(connectivityServiceProvider);
    final statusTracker = ref.watch(syncStatusTrackerProvider);

    final engine = SyncEngine(
      pullStrategy: PullStrategy(
        client: client,
        db: db,
        metadataDao: db.syncMetadataDao,
      ),
      pushStrategy: PushStrategy(
        client: client,
        db: db,
        metadataDao: db.syncMetadataDao,
      ),
      bidirectionalStrategy: BidirectionalStrategy(
        client: client,
        db: db,
        metadataDao: db.syncMetadataDao,
      ),
      stockDeltaSync: StockDeltaSync(
        client: client,
        db: db,
        deltasDao: db.stockDeltasDao,
        metadataDao: db.syncMetadataDao,
      ),
      connectivity: connectivity,
      statusTracker: statusTracker,
    );

    ref.onDispose(() => engine.dispose());
    return engine;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('SyncEngine unavailable: $e');
    }
    return null;
  }
});

/// مزود المستمع الفوري (Realtime)
final realtimeListenerProvider = Provider<RealtimeListener?>((ref) {
  try {
    final client = getIt<SupabaseClient>();
    final db = ref.watch(appDatabaseProvider);

    final listener = RealtimeListener(client: client, db: db);
    ref.onDispose(() => listener.dispose());
    return listener;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('RealtimeListener unavailable: $e');
    }
    return null;
  }
});

/// مزود المزامنة الأولية
final initialSyncProvider = Provider<InitialSync?>((ref) {
  try {
    final client = getIt<SupabaseClient>();
    final db = ref.watch(appDatabaseProvider);

    final initialSync = InitialSync(
      client: client,
      db: db,
      metadataDao: db.syncMetadataDao,
    );
    ref.onDispose(() => initialSync.dispose());
    return initialSync;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('InitialSync unavailable: $e');
    }
    return null;
  }
});

/// مزود حالة تقدم محرك المزامنة (Stream)
final syncEngineProgressProvider = StreamProvider<SyncProgress>((ref) {
  final engine = ref.watch(syncEngineProvider);
  if (engine == null) {
    return Stream.value(const SyncProgress());
  }
  return engine.progressStream;
});

/// مزود حالة المزامنة الشاملة (Stream)
final syncOverviewProvider = StreamProvider<SyncOverview>((ref) {
  final tracker = ref.watch(syncStatusTrackerProvider);
  return tracker.overviewStream;
});

/// مزود عدد العناصر المعلقة
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.watchPendingCount();
});

/// مزود حالة المزامنة (القديم - للتوافق)
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final manager = ref.watch(syncManagerProvider);
  return manager.statusStream;
});

/// مزود لتنفيذ المزامنة يدوياً
final syncNowProvider = FutureProvider.autoDispose<SyncResult>((ref) async {
  final manager = ref.watch(syncManagerProvider);
  return manager.syncPending();
});

/// مزود قائمة العناصر المعلقة (Stream)
final pendingSyncItemsProvider = StreamProvider<List<SyncQueueTableData>>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.watchPendingItems();
});

/// مزود قائمة العناصر المتعارضة (Stream)
final conflictSyncItemsProvider = StreamProvider<List<SyncQueueTableData>>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.watchConflictItems();
});

/// مزود عدد التعارضات
final conflictSyncCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.watchConflictCount();
});
