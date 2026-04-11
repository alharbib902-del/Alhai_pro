/// Mock Riverpod providers for Admin tests
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:alhai_database/alhai_database.dart' show SyncQueueTableData;
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_core/alhai_core.dart';

// ============================================================================
// MOCK SERVICE CLASSES
// ============================================================================

class MockSyncService extends Mock implements SyncService {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockSyncManager extends Mock implements SyncManager {}

// ============================================================================
// DEFAULT PROVIDER OVERRIDES
// ============================================================================

/// Returns a list of Riverpod overrides suitable for most Admin widget tests.
///
/// Overrides:
/// - [currentStoreIdProvider] with [storeId] (default: 'test-store-1')
/// - [syncServiceProvider] with a no-op MockSyncService
/// - [currentUserProvider] with a test admin user
/// - [isAuthenticatedProvider] with true
/// - [userRoleProvider] with storeOwner
///
/// Pass additional overrides to [createTestWidget] to extend or replace these.
List<Override> defaultProviderOverrides({
  String? storeId = 'test-store-1',
  String? userId = 'test-user-1',
}) {
  registerFallbackValue(SyncPriority.normal);
  // Duration is needed for recoverStuckSyncingItems(stuckThreshold: any(...))
  registerFallbackValue(const Duration(minutes: 5));
  final mockSyncService = MockSyncService();

  // Stub enqueue methods so sync calls don't throw during tests
  when(
    () => mockSyncService.enqueueCreate(
      tableName: any(named: 'tableName'),
      recordId: any(named: 'recordId'),
      data: any(named: 'data'),
      priority: any(named: 'priority'),
    ),
  ).thenAnswer((_) async => 'mock-sync-id');

  when(
    () => mockSyncService.enqueueUpdate(
      tableName: any(named: 'tableName'),
      recordId: any(named: 'recordId'),
      changes: any(named: 'changes'),
      priority: any(named: 'priority'),
    ),
  ).thenAnswer((_) async => 'mock-sync-id');

  when(
    () => mockSyncService.enqueueDelete(
      tableName: any(named: 'tableName'),
      recordId: any(named: 'recordId'),
      priority: any(named: 'priority'),
    ),
  ).thenAnswer((_) async => 'mock-sync-id');

  when(() => mockSyncService.getPendingCount()).thenAnswer((_) async => 0);

  when(
    () => mockSyncService.watchPendingCount(),
  ).thenAnswer((_) => Stream.value(0));

  when(
    () => mockSyncService.watchPendingItems(),
  ).thenAnswer((_) => Stream.value([]));

  when(
    () => mockSyncService.watchConflictItems(),
  ).thenAnswer((_) => Stream.value([]));

  when(
    () => mockSyncService.watchConflictCount(),
  ).thenAnswer((_) => Stream.value(0));

  // SyncManager.initialize() and syncPending() call these methods:
  when(
    () => mockSyncService.getPendingItems(),
  ).thenAnswer((_) async => <SyncQueueTableData>[]);

  when(
    () => mockSyncService.getConflictItems(),
  ).thenAnswer((_) async => <SyncQueueTableData>[]);

  when(
    () => mockSyncService.getStuckSyncingItems(),
  ).thenAnswer((_) async => <SyncQueueTableData>[]);

  when(() => mockSyncService.resetStuckItems()).thenAnswer((_) async => 0);

  when(
    () => mockSyncService.recoverStuckSyncingItems(
      stuckThreshold: any(named: 'stuckThreshold'),
    ),
  ).thenAnswer((_) async => 0);

  when(() => mockSyncService.retryItem(any())).thenAnswer((_) async {});

  when(() => mockSyncService.markAsSyncing(any())).thenAnswer((_) async {});

  when(() => mockSyncService.markAsSynced(any())).thenAnswer((_) async {});

  when(
    () => mockSyncService.markAsFailed(any(), any()),
  ).thenAnswer((_) async {});

  when(
    () => mockSyncService.cleanup(olderThan: any(named: 'olderThan')),
  ).thenAnswer((_) async => 0);

  when(
    () => mockSyncService.getDeadLetterItems(),
  ).thenAnswer((_) async => <SyncQueueTableData>[]);

  when(() => mockSyncService.getDeadLetterCount()).thenAnswer((_) async => 0);

  when(
    () => mockSyncService.watchDeadLetterCount(),
  ).thenAnswer((_) => Stream.value(0));

  when(
    () => mockSyncService.watchPendingCountWithOldest(),
  ).thenAnswer((_) => Stream.value((count: 0, oldestAt: null)));

  // Create a test admin user
  final testUser = User(
    id: userId ?? 'test-user-1',
    phone: '+966500000000',
    name: 'Test Admin',
    role: UserRole.storeOwner,
    storeId: storeId,
    createdAt: DateTime(2026, 1, 1),
  );

  // Create a mock AuthNotifier so screens that use authStateProvider work.
  final mockAuthRepo = MockAuthRepository();
  when(() => mockAuthRepo.getCurrentUser()).thenAnswer((_) async => testUser);
  when(() => mockAuthRepo.isAuthenticated()).thenAnswer((_) async => true);

  // Create a mock ConnectivityService (offline by default - prevents timers)
  final mockConnectivity = MockConnectivityService();
  when(() => mockConnectivity.isOnline).thenReturn(false);
  when(() => mockConnectivity.isOffline).thenReturn(true);
  when(
    () => mockConnectivity.onConnectivityChanged,
  ).thenAnswer((_) => const Stream<bool>.empty());
  when(() => mockConnectivity.dispose()).thenReturn(null);

  // Create a mock SyncManager that doesn't start any timers
  final mockSyncManager = MockSyncManager();
  when(() => mockSyncManager.initialize()).thenAnswer((_) async {});
  when(() => mockSyncManager.dispose()).thenReturn(null);
  when(() => mockSyncManager.isSyncing).thenReturn(false);
  when(
    () => mockSyncManager.statusStream,
  ).thenAnswer((_) => const Stream.empty());

  return [
    currentStoreIdProvider.overrideWith((ref) => storeId),
    syncServiceProvider.overrideWithValue(mockSyncService),
    connectivityServiceProvider.overrideWithValue(mockConnectivity),
    syncManagerProvider.overrideWithValue(mockSyncManager),
    currentUserProvider.overrideWithValue(testUser),
    isAuthenticatedProvider.overrideWithValue(true),
    userRoleProvider.overrideWithValue(UserRole.storeOwner),
    // Override authStateProvider so screens watching it don't hit GetIt
    authStateProvider.overrideWith((ref) {
      return AuthNotifier(mockAuthRepo);
    }),
  ];
}
