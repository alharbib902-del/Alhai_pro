import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/strategies/stock_delta_sync.dart';

import '../../helpers/sync_test_helpers.dart';

void main() {
  late MockSupabaseClient mockClient;
  late MockAppDatabase mockDb;
  late MockStockDeltasDao mockDeltasDao;
  late MockSyncMetadataDao mockMetadataDao;
  late StockDeltaSync stockDeltaSync;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockDb = MockAppDatabase();
    mockDeltasDao = MockStockDeltasDao();
    mockMetadataDao = MockSyncMetadataDao();

    stockDeltaSync = StockDeltaSync(
      client: mockClient,
      db: mockDb,
      deltasDao: mockDeltasDao,
      metadataDao: mockMetadataDao,
    );
  });

  group('StockDeltaSync', () {
    group('sync', () {
      test('returns empty result when no pending deltas', () async {
        when(() => mockDeltasDao.getPendingDeltasForStore(any(),
            limit: any(named: 'limit'))).thenAnswer((_) async => []);

        final result = await stockDeltaSync.sync(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        expect(result.deltasSent, 0);
        expect(result.productsUpdated, 0);
        expect(result.hasErrors, isFalse);
        expect(result.hasOversoldProducts, isFalse);
      });

      test('sends deltas via RPC and updates local stock', () async {
        final deltas = [
          createStockDelta(
            id: 'd-1',
            productId: 'p-1',
            quantityChange: -3,
          ),
          createStockDelta(
            id: 'd-2',
            productId: 'p-2',
            quantityChange: -1,
          ),
        ];

        when(() => mockDeltasDao.getPendingDeltasForStore(any(),
            limit: any(named: 'limit'))).thenAnswer((_) async => deltas);

        // RPC returns builder; mock .then() to resolve with results
        setupRpcCall(mockClient, result: [
          {
            'product_id': 'p-1',
            'new_stock': 97,
            'is_oversold': false,
          },
          {
            'product_id': 'p-2',
            'new_stock': 49,
            'is_oversold': false,
          },
        ]);

        when(() => mockDb.customStatement(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockDeltasDao.markSynced(any())).thenAnswer((_) async {});
        when(() => mockMetadataDao.updateLastPushAt(any(), any(),
            syncCount: any(named: 'syncCount'))).thenAnswer((_) async {});
        when(() => mockMetadataDao.clearError(any())).thenAnswer((_) async {});
        when(() => mockMetadataDao.setError(any(), any()))
            .thenAnswer((_) async {});

        final result = await stockDeltaSync.sync(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        expect(result.deltasSent, 2);
        expect(result.productsUpdated, 2);
        expect(result.hasErrors, isFalse);
        expect(result.oversoldProducts, isEmpty);

        verify(() => mockClient.rpc('apply_stock_deltas',
            params: any(named: 'params'))).called(1);
        verify(() => mockDeltasDao.markSynced(['d-1', 'd-2'])).called(1);
      });

      test('detects oversold products', () async {
        final deltas = [
          createStockDelta(
            id: 'd-1',
            productId: 'p-1',
            quantityChange: -100,
          ),
        ];

        when(() => mockDeltasDao.getPendingDeltasForStore(any(),
            limit: any(named: 'limit'))).thenAnswer((_) async => deltas);

        setupRpcCall(mockClient, result: [
          {
            'product_id': 'p-1',
            'new_stock': -5,
            'is_oversold': true,
          },
        ]);

        when(() => mockDb.customStatement(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockDeltasDao.markSynced(any())).thenAnswer((_) async {});
        when(() => mockMetadataDao.updateLastPushAt(any(), any(),
            syncCount: any(named: 'syncCount'))).thenAnswer((_) async {});
        when(() => mockMetadataDao.clearError(any())).thenAnswer((_) async {});
        when(() => mockMetadataDao.setError(any(), any()))
            .thenAnswer((_) async {});

        final result = await stockDeltaSync.sync(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        expect(result.hasOversoldProducts, isTrue);
        expect(result.oversoldProducts, contains('p-1'));
      });

      test('handles RPC error', () async {
        final deltas = [
          createStockDelta(id: 'd-1'),
        ];

        when(() => mockDeltasDao.getPendingDeltasForStore(any(),
            limit: any(named: 'limit'))).thenAnswer((_) async => deltas);

        // Mock RPC to throw synchronously
        when(() => mockClient.rpc(any(), params: any(named: 'params')))
            .thenThrow(Exception('RPC not available'));

        when(() => mockMetadataDao.setError(any(), any()))
            .thenAnswer((_) async {});

        final result = await stockDeltaSync.sync(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        expect(result.hasErrors, isTrue);
        verify(() => mockMetadataDao.setError('stock_deltas', any())).called(1);
      });

      test('handles RPC non-list response gracefully', () async {
        final deltas = [
          createStockDelta(id: 'd-1'),
        ];

        when(() => mockDeltasDao.getPendingDeltasForStore(any(),
            limit: any(named: 'limit'))).thenAnswer((_) async => deltas);

        // RPC returns non-list (e.g., a string)
        setupRpcCall(mockClient, result: 'ok');

        when(() => mockDb.customStatement(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockDeltasDao.markSynced(any())).thenAnswer((_) async {});
        when(() => mockMetadataDao.updateLastPushAt(any(), any(),
            syncCount: any(named: 'syncCount'))).thenAnswer((_) async {});
        when(() => mockMetadataDao.clearError(any())).thenAnswer((_) async {});
        when(() => mockMetadataDao.setError(any(), any()))
            .thenAnswer((_) async {});

        final result = await stockDeltaSync.sync(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        expect(result.deltasSent, 1);
        expect(result.productsUpdated, 0);
      });
    });
  });

  group('StockDeltaResult', () {
    test('hasErrors returns true when errors exist', () {
      final result = StockDeltaResult(
        deltasSent: 0,
        productsUpdated: 0,
        errors: ['error'],
        oversoldProducts: [],
      );
      expect(result.hasErrors, isTrue);
    });

    test('hasErrors returns false when no errors', () {
      final result = StockDeltaResult(
        deltasSent: 2,
        productsUpdated: 2,
        errors: [],
        oversoldProducts: [],
      );
      expect(result.hasErrors, isFalse);
    });

    test('hasOversoldProducts returns true when products are oversold', () {
      final result = StockDeltaResult(
        deltasSent: 1,
        productsUpdated: 1,
        errors: [],
        oversoldProducts: ['p-1'],
      );
      expect(result.hasOversoldProducts, isTrue);
    });

    test('hasOversoldProducts returns false when no products are oversold', () {
      final result = StockDeltaResult(
        deltasSent: 1,
        productsUpdated: 1,
        errors: [],
        oversoldProducts: [],
      );
      expect(result.hasOversoldProducts, isFalse);
    });
  });
}
