import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// MOCK CLASSES
// ============================================================================

// --- DAOs ---
class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockSyncMetadataDao extends Mock implements SyncMetadataDao {}

class MockStockDeltasDao extends Mock implements StockDeltasDao {}

// --- Database ---
class MockAppDatabase extends Mock implements AppDatabase {}

// --- Supabase ---
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// Typed mock for select() results: PostgrestFilterBuilder<PostgrestList>
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

/// Mock for delete()/upsert() results: PostgrestFilterBuilder<dynamic>
class MockPostgrestFilterBuilderDynamic extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

/// Typed mock for insert/update/delete transform results
class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<PostgrestList> {}

/// Typed mock for maybeSingle() results
class MockPostgrestTransformBuilderNullableMap extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

// --- Connectivity ---
class MockConnectivity extends Mock implements Connectivity {}

// ============================================================================
// SUPABASE MOCK HELPERS
// ============================================================================
// PostgREST builders implement Future<T>, so they can't use thenReturn.
// Instead, we mock .then() on the builder to resolve the await.

/// Setup a MockPostgrestFilterBuilder select chain to resolve with [data]
/// when awaited. Mocks: select -> eq -> order -> range -> then(resolve)
///
/// Note: PostgREST builders implement Future<T>, so `thenReturn` is rejected
/// by mocktail. We use `thenAnswer((_) => builder)` for chain methods.
void setupSelectChain(
  MockSupabaseQueryBuilder queryBuilder,
  MockPostgrestFilterBuilder filterBuilder, {
  List<Map<String, dynamic>> data = const [],
}) {
  when(() => queryBuilder.select(any())).thenAnswer((_) => filterBuilder);
  when(() => filterBuilder.eq(any(), any())).thenAnswer((_) => filterBuilder);
  when(() => filterBuilder.or(any())).thenAnswer((_) => filterBuilder);
  when(() => filterBuilder.gte(any(), any())).thenAnswer((_) => filterBuilder);
  when(() => filterBuilder.order(any(), ascending: any(named: 'ascending')))
      .thenAnswer((_) => filterBuilder);
  when(() => filterBuilder.range(any(), any())).thenAnswer((_) => filterBuilder);
  // Mock the `then()` method that `await` calls since PostgrestBuilder implements Future
  when(() => filterBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
      .thenAnswer((invocation) {
    final onValue = invocation.positionalArguments[0] as Function;
    return Future.value(onValue(data));
  });
}

/// Setup upsert on queryBuilder to succeed (resolves when awaited)
void setupUpsertChain(MockSupabaseQueryBuilder queryBuilder) {
  final upsertBuilder = MockPostgrestFilterBuilderDynamic();
  when(() => queryBuilder.upsert(any(), onConflict: any(named: 'onConflict')))
      .thenAnswer((_) => upsertBuilder);
  when(() => upsertBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
      .thenAnswer((invocation) {
    final onValue = invocation.positionalArguments[0] as Function;
    return Future.value(onValue(null));
  });
}

/// Setup delete chain: delete() -> eq() -> then(resolve)
void setupDeleteChain(MockSupabaseQueryBuilder queryBuilder) {
  final deleteBuilder = MockPostgrestFilterBuilderDynamic();
  when(() => queryBuilder.delete()).thenAnswer((_) => deleteBuilder);
  when(() => deleteBuilder.eq(any(), any())).thenAnswer((_) => deleteBuilder);
  when(() => deleteBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
      .thenAnswer((invocation) {
    final onValue = invocation.positionalArguments[0] as Function;
    return Future.value(onValue(null));
  });
}

/// Setup RPC call on client that resolves with [result]
void setupRpcCall(MockSupabaseClient client, {dynamic result}) {
  final rpcBuilder = MockPostgrestFilterBuilderDynamic();
  when(() => client.rpc(any(), params: any(named: 'params')))
      .thenAnswer((_) => rpcBuilder);
  when(() => rpcBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
      .thenAnswer((invocation) {
    final onValue = invocation.positionalArguments[0] as Function;
    return Future.value(onValue(result));
  });
}

/// Setup maybeSingle() on a filter builder to resolve with [data]
void setupMaybeSingle(
  MockPostgrestFilterBuilder filterBuilder, {
  Map<String, dynamic>? data,
}) {
  final transformBuilder = MockPostgrestTransformBuilderNullableMap();
  when(() => filterBuilder.maybeSingle()).thenAnswer((_) => transformBuilder);
  when(() => transformBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
      .thenAnswer((invocation) {
    final onValue = invocation.positionalArguments[0] as Function;
    return Future.value(onValue(data));
  });
}

// ============================================================================
// FAKE CLASSES (for registerFallbackValue)
// ============================================================================

class FakeDateTime extends Fake implements DateTime {}

class FakeSyncQueueTableCompanion extends Fake
    implements SyncQueueTableCompanion {}

class FakeSyncMetadataTableCompanion extends Fake
    implements SyncMetadataTableCompanion {}

// ============================================================================
// REGISTER FALLBACK VALUES
// ============================================================================

void registerSyncFallbackValues() {
  registerFallbackValue(FakeDateTime());
  registerFallbackValue(FakeSyncQueueTableCompanion());
  registerFallbackValue(FakeSyncMetadataTableCompanion());
  registerFallbackValue(ConnectivityResult.none);
  registerFallbackValue(Duration.zero);
}

// ============================================================================
// TEST DATA HELPERS
// ============================================================================

/// Create a mock SyncQueueTableData
SyncQueueTableData createSyncQueueItem({
  String id = 'test-id-1',
  String tableName = 'products',
  String recordId = 'record-1',
  String operation = 'CREATE',
  String payload = '{"id":"record-1","name":"Test"}',
  String idempotencyKey = 'products_record-1_create',
  String status = 'pending',
  int retryCount = 0,
  int maxRetries = 3,
  String? lastError,
  int priority = 2,
  DateTime? createdAt,
  DateTime? lastAttemptAt,
  DateTime? syncedAt,
}) {
  return SyncQueueTableData(
    id: id,
    tableName_: tableName,
    recordId: recordId,
    operation: operation,
    payload: payload,
    idempotencyKey: idempotencyKey,
    status: status,
    retryCount: retryCount,
    maxRetries: maxRetries,
    lastError: lastError,
    priority: priority,
    createdAt: createdAt ?? DateTime.now(),
    lastAttemptAt: lastAttemptAt,
    syncedAt: syncedAt,
  );
}

/// Create a mock SyncMetadataTableData
SyncMetadataTableData createSyncMetadata({
  String tableName = 'products',
  DateTime? lastPullAt,
  DateTime? lastPushAt,
  int pendingCount = 0,
  int failedCount = 0,
  bool isInitialSynced = false,
  int lastSyncCount = 0,
  String? lastError,
}) {
  return SyncMetadataTableData(
    tableName_: tableName,
    lastPullAt: lastPullAt,
    lastPushAt: lastPushAt,
    pendingCount: pendingCount,
    failedCount: failedCount,
    isInitialSynced: isInitialSynced,
    lastSyncCount: lastSyncCount,
    lastError: lastError,
  );
}

/// Create a mock StockDeltasTableData
StockDeltasTableData createStockDelta({
  String id = 'delta-1',
  String productId = 'product-1',
  String storeId = 'store-1',
  String? orgId,
  int quantityChange = -3,
  String deviceId = 'device-1',
  String operationType = 'sale',
  String? referenceId,
  String syncStatus = 'pending',
  DateTime? createdAt,
  DateTime? syncedAt,
}) {
  return StockDeltasTableData(
    id: id,
    productId: productId,
    storeId: storeId,
    orgId: orgId,
    quantityChange: quantityChange,
    deviceId: deviceId,
    operationType: operationType,
    referenceId: referenceId,
    syncStatus: syncStatus,
    createdAt: createdAt ?? DateTime.now().toUtc(),
    syncedAt: syncedAt,
  );
}
