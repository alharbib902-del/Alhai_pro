/// مزودات المزامنة والاتصال
///
/// توفر حالة المزامنة والاتصال بالإنترنت
/// تشمل: محرك المزامنة، المستمع الفوري، متتبع الحالة
library;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alhai_auth/alhai_auth.dart'
    show authStateProvider, currentStoreIdProvider;
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_sync/alhai_sync.dart';

/// مزود قاعدة البيانات - يستخدم singleton من GetIt.I
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return GetIt.I<AppDatabase>();
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
    final client = GetIt.I<SupabaseClient>();
    return SyncApiService(client: client);
  } catch (e) {
    // SupabaseClient not registered - offline mode, sync unavailable
    if (kDebugMode) {
      debugPrint(
        'SyncApiService unavailable: SupabaseClient not registered. $e',
      );
    }
    return null;
  }
});

/// مزود خدمة مزامنة المؤسسة
final orgSyncServiceProvider = Provider<OrgSyncService?>((ref) {
  try {
    final client = GetIt.I<SupabaseClient>();
    return OrgSyncService(client: client);
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        'OrgSyncService unavailable: SupabaseClient not registered. $e',
      );
    }
    return null;
  }
});

/// مزود خدمة السحب الدوري
final pullSyncServiceProvider = Provider<PullSyncService?>((ref) {
  final syncApi = ref.watch(syncApiServiceProvider);
  if (syncApi == null) return null;

  final db = ref.watch(appDatabaseProvider);
  return PullSyncService(
    syncApi: syncApi,
    db: db,
    metadataDao: db.syncMetadataDao,
    syncQueueDao: db.syncQueueDao,
  );
});

/// مزود مدير المزامنة (القديم - للتوافق)
final syncManagerProvider = Provider<SyncManager>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final syncApi = ref.watch(syncApiServiceProvider);
  final orgSync = ref.watch(orgSyncServiceProvider);
  final pullSync = ref.watch(pullSyncServiceProvider);
  final storeId = ref.watch(currentStoreIdProvider);

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
    pullSyncService: pullSync,
    storeId: storeId,
  );

  manager.initialize();
  ref.onDispose(() => manager.dispose());
  return manager;
});

// ─── مزامنة العملاء الموجودين لمرة واحدة ───

/// يُفعّل مرة واحدة عند التشغيل لمزامنة العملاء الذين أُنشئوا محليًا
/// قبل إضافة كود المزامنة. يتحقق عبر syncedAt == null
final syncExistingCustomersProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final syncService = ref.watch(syncServiceProvider);
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return 0;

  try {
    // جلب العملاء الذين لم تتم مزامنتهم (syncedAt == null)
    final unsyncedCustomers = await db.customersDao.getActiveCustomers(storeId);

    // جلب org_id
    String? orgId;
    try {
      final store = await db.storesDao.getStoreById(storeId);
      orgId = store?.orgId;
    } catch (e) {
      if (kDebugMode) debugPrint('[SyncCustomers] Error resolving orgId: $e');
    }

    int count = 0;
    for (final customer in unsyncedCustomers) {
      // التحقق: هل يوجد بالفعل في sync_queue؟
      final existing = await db.syncQueueDao.findByIdempotencyKey(
        'customers_${customer.id}_CREATE',
      );
      if (existing != null) continue; // تخطي - موجود في الطابور بالفعل

      await syncService.enqueueCreate(
        tableName: 'customers',
        recordId: customer.id,
        data: {
          'id': customer.id,
          'orgId': orgId,
          'storeId': customer.storeId,
          'name': customer.name,
          'phone': customer.phone,
          'email': customer.email,
          'address': customer.address,
          'city': customer.city,
          'taxNumber': customer.taxNumber,
          'type': customer.type,
          'notes': customer.notes,
          'isActive': customer.isActive,
          'createdAt': customer.createdAt.toIso8601String(),
          'updatedAt': customer.updatedAt?.toIso8601String(),
        },
        priority: SyncPriority.high,
      );
      count++;
    }

    if (count > 0 && kDebugMode) {
      debugPrint(
        '[SyncCustomers] ✅ Enqueued $count existing customers for sync',
      );
    }
    return count;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[SyncCustomers] ❌ Error: $e');
    }
    return 0;
  }
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
    final client = GetIt.I<SupabaseClient>();
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
      syncQueueDao: db.syncQueueDao,
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
    final client = GetIt.I<SupabaseClient>();
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

/// مزود تفعيل المستمع الفوري (Realtime)
///
/// يُراقب حالة المصادقة ومعرّف المتجر.
/// عند تسجيل الدخول واختيار المتجر: يبدأ الاستماع للتحديثات الفورية.
/// عند تسجيل الخروج: يوقف الاستماع تلقائياً.
///
/// يُقرأ مرة واحدة من PosScreen عند التحميل لتفعيل الاشتراك.
final realtimeActivationProvider = FutureProvider<void>((ref) async {
  final authState = ref.watch(authStateProvider);
  final storeId = ref.watch(currentStoreIdProvider);
  final listener = ref.watch(realtimeListenerProvider);

  // إيقاف المستمع عند تسجيل الخروج أو عدم توفر المتطلبات
  if (!authState.isAuthenticated || storeId == null || listener == null) {
    if (listener != null && listener.isActive) {
      await listener.stop();
      if (kDebugMode) {
        debugPrint('[RealtimeActivation] Stopped (logged out or no store)');
      }
    }
    return;
  }

  // لا تبدأ مرتين
  if (listener.isActive) return;

  // جلب org_id من بيانات المتجر في القاعدة المحلية
  String orgId = '';
  try {
    final db = ref.read(appDatabaseProvider);
    final store = await db.storesDao.getStoreById(storeId);
    orgId = store?.orgId ?? '';
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[RealtimeActivation] Failed to get store orgId: $e');
    }
  }

  // بدء الاستماع
  await listener.start(orgId: orgId, storeId: storeId);

  if (kDebugMode) {
    debugPrint('[RealtimeActivation] Started for store=$storeId, org=$orgId');
  }

  // إيقاف عند إلغاء الـ provider (تسجيل خروج / تغيير متجر)
  ref.onDispose(() {
    if (listener.isActive) {
      listener.stop();
    }
  });
});

/// مزود المزامنة الأولية
final initialSyncProvider = Provider<InitialSync?>((ref) {
  try {
    final client = GetIt.I<SupabaseClient>();
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

/// مزود التزامن العام - يفعّل InitialSync + Realtime تلقائياً
///
/// يعمل عند وجود جلسة مصادقة + storeId.
/// يُقرأ من CashierShell لضمان التشغيل بغض النظر عن الشاشة الأولى.
final globalSyncActivationProvider = FutureProvider<void>((ref) async {
  final authState = ref.watch(authStateProvider);
  final storeId = ref.watch(currentStoreIdProvider);

  // ليس مسجل دخول أو لا يوجد متجر
  if (!authState.isAuthenticated || storeId == null) return;

  // ─── 1. InitialSync ───
  final initialSync = ref.watch(initialSyncProvider);
  if (initialSync != null) {
    final isComplete = await initialSync.isComplete();
    if (!isComplete) {
      // جلب org_id من بيانات المتجر
      String orgId = '';
      try {
        final db = ref.read(appDatabaseProvider);
        final store = await db.storesDao.getStoreById(storeId);
        orgId = store?.orgId ?? '';
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[GlobalSync] Failed to get store orgId: $e');
        }
      }

      if (kDebugMode) {
        debugPrint(
          '[GlobalSync] Running InitialSync for store=$storeId, org=$orgId',
        );
      }

      final result = await initialSync.execute(orgId: orgId, storeId: storeId);
      if (kDebugMode) {
        debugPrint(
          '[GlobalSync] InitialSync done: ${result.totalRecords} records, '
          '${result.errors.length} errors',
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint('[GlobalSync] InitialSync already complete');
      }
    }
  }

  // ─── 2. Realtime Listener ───
  // تفعيل المستمع الفوري (سيتجاهل إذا كان يعمل بالفعل)
  await ref.read(realtimeActivationProvider.future);
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

/// مزود معلومات المبيعات غير المُزامنة (العدد + وقت أقدم عنصر)
/// يُستخدم لعرض بانر التحذير عند وجود عناصر معلقة لأكثر من 5 دقائق
final unsyncedSalesInfoProvider =
    StreamProvider<({int count, DateTime? oldestAt})>((ref) {
      final syncService = ref.watch(syncServiceProvider);
      return syncService.watchPendingCountWithOldest();
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
final pendingSyncItemsProvider = StreamProvider<List<SyncQueueTableData>>((
  ref,
) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.watchPendingItems();
});

/// مزود قائمة العناصر المتعارضة (Stream)
final conflictSyncItemsProvider = StreamProvider<List<SyncQueueTableData>>((
  ref,
) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.watchConflictItems();
});

/// مزود عدد التعارضات
final conflictSyncCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.watchConflictCount();
});

/// مزود عدد العناصر الميتة (Dead Letter) - فشلت نهائياً بعد استنفاد المحاولات
final deadLetterCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.watchDeadLetterCount();
});
