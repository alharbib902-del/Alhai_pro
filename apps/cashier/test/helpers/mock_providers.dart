/// Mock Riverpod providers for Cashier tests
///
/// Provides default overrides for all Riverpod providers used across
/// cashier screens: auth state, sync service, theme, etc.
///
/// Usage:
/// ```dart
/// testWidgets('screen renders', (tester) async {
///   await tester.pumpWidget(createTestWidget(
///     const MyScreen(),
///     overrides: defaultProviderOverrides(storeId: 'custom-store'),
///   ));
/// });
/// ```
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

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSyncService extends Mock implements SyncService {}

// ============================================================================
// DEFAULT PROVIDER OVERRIDES
// ============================================================================

/// Default provider overrides for all widget tests.
///
/// These provide sensible defaults so tests don't crash on missing providers.
/// Every screen that reads [currentStoreIdProvider] or [syncServiceProvider]
/// will get a working mock value.
///
/// Pass [storeId] and [userId] to customise the identity used in the test.
List<Override> defaultProviderOverrides({
  String? storeId = 'test-store-1',
  String? userId = 'test-user-1',
}) {
  // Ensure SyncPriority fallback is registered before any() matchers
  registerFallbackValue(SyncPriority.normal);
  final mockSyncService = MockSyncService();

  // Make sync queue methods return silently by default
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

  // Create a test user for auth providers
  final testUser = User(
    id: userId ?? 'test-user-1',
    phone: '+966500000000',
    name: 'Test Cashier',
    role: UserRole.employee,
    storeId: storeId,
    createdAt: DateTime(2026, 1, 1),
  );

  return [
    currentStoreIdProvider.overrideWith((ref) => storeId),
    syncServiceProvider.overrideWithValue(mockSyncService),
    currentUserProvider.overrideWithValue(testUser),
    isAuthenticatedProvider.overrideWithValue(true),
    userRoleProvider.overrideWithValue(UserRole.employee),
  ];
}

/// Create a [MockSyncService] with default stubs already configured.
///
/// Useful when you need direct access to the mock for verification:
/// ```dart
/// final sync = createMockSyncService();
/// // ... run test ...
/// verify(() => sync.enqueueCreate(...)).called(1);
/// ```
MockSyncService createMockSyncService() {
  registerFallbackValue(SyncPriority.normal);
  final mockSyncService = MockSyncService();

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

  return mockSyncService;
}
