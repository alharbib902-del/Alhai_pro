/// Mock Riverpod providers for Admin Lite tests
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ============================================================================
// MOCK SERVICE CLASSES
// ============================================================================

class MockSyncService extends Mock implements SyncService {}

// ============================================================================
// DEFAULT PROVIDER OVERRIDES
// ============================================================================

List<Override> defaultProviderOverrides({
  String? storeId = 'test-store-1',
  String? userId = 'test-user-1',
}) {
  final mockSyncService = MockSyncService();

  when(
    () => mockSyncService.enqueueCreate(
      tableName: any(named: 'tableName'),
      recordId: any(named: 'recordId'),
      data: any(named: 'data'),
    ),
  ).thenAnswer((_) async => 'mock-sync-id');
  when(
    () => mockSyncService.enqueueUpdate(
      tableName: any(named: 'tableName'),
      recordId: any(named: 'recordId'),
      changes: any(named: 'changes'),
    ),
  ).thenAnswer((_) async => 'mock-sync-id');
  when(
    () => mockSyncService.enqueueDelete(
      tableName: any(named: 'tableName'),
      recordId: any(named: 'recordId'),
    ),
  ).thenAnswer((_) async => 'mock-sync-id');

  return [
    currentStoreIdProvider.overrideWith((ref) => storeId),
    syncServiceProvider.overrideWithValue(mockSyncService),
  ];
}
