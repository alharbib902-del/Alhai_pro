import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/src/org_catalog_service.dart';

import '../helpers/sync_test_helpers.dart';

class MockProductsDao extends Mock implements ProductsDao {}

class MockOrgProductsDao extends Mock implements OrgProductsDao {}

void main() {
  late MockSupabaseClient mockClient;
  late MockAppDatabase mockDb;
  late MockProductsDao mockProductsDao;
  late MockOrgProductsDao mockOrgProductsDao;
  late OrgCatalogService service;

  setUpAll(() {
    registerSyncFallbackValues();
    registerFallbackValue(
      ProductsTableCompanion.insert(
        id: '',
        storeId: '',
        name: '',
        price: 0,
        createdAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockDb = MockAppDatabase();
    mockProductsDao = MockProductsDao();
    mockOrgProductsDao = MockOrgProductsDao();

    when(() => mockDb.productsDao).thenReturn(mockProductsDao);
    when(() => mockDb.orgProductsDao).thenReturn(mockOrgProductsDao);

    service = OrgCatalogService(client: mockClient, db: mockDb);
  });

  OrgProductsTableData makeOrgProductData({
    String id = 'op-1',
    String orgId = 'org-1',
    String name = 'Test Product',
    // C-4 Stage A: prices in INTEGER cents. Default 25.00 → 2500.
    int defaultPrice = 2500,
  }) {
    return OrgProductsTableData(
      id: id,
      orgId: orgId,
      name: name,
      nameEn: null,
      sku: 'SKU-001',
      barcode: '1234567890',
      description: null,
      defaultPrice: defaultPrice,
      costPrice: 1000,
      categoryId: null,
      unit: null,
      orgImageThumbnail: null,
      orgImageMedium: null,
      orgImageLarge: null,
      orgImageHash: null,
      onlineAvailable: false,
      onlineMaxQty: null,
      minAlertQty: null,
      autoReorder: false,
      reorderQty: null,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: null,
      syncedAt: null,
      deletedAt: null,
    );
  }

  group('OrgCatalogService', () {
    group('cloneOrgProductsToStore', () {
      test('clones all active org products to store', () async {
        when(() => mockOrgProductsDao.getByOrgId('org-1')).thenAnswer(
          (_) async => [
            makeOrgProductData(id: 'op-1', name: 'Product A'),
            makeOrgProductData(id: 'op-2', name: 'Product B'),
          ],
        );

        when(
          () => mockProductsDao.upsertProduct(any()),
        ).thenAnswer((_) async => 1);

        final count = await service.cloneOrgProductsToStore(
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(count, 2);
        verify(() => mockProductsDao.upsertProduct(any())).called(2);
      });

      test('returns 0 when no org products exist', () async {
        when(
          () => mockOrgProductsDao.getByOrgId('org-1'),
        ).thenAnswer((_) async => []);

        final count = await service.cloneOrgProductsToStore(
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(count, 0);
        verifyNever(() => mockProductsDao.upsertProduct(any()));
      });
    });

    group('syncOrgProductToStores', () {
      test('calls RPC and returns count', () async {
        setupRpcCall(mockClient, result: 5);

        final count = await service.syncOrgProductToStores('op-1');

        expect(count, 5);
      });

      test('returns 0 on RPC failure', () async {
        final rpcBuilder = MockPostgrestFilterBuilderDynamic();
        when(
          () => mockClient.rpc(any(), params: any(named: 'params')),
        ).thenAnswer((_) => rpcBuilder);
        when(
          () => rpcBuilder.then<dynamic>(any(), onError: any(named: 'onError')),
        ).thenThrow(Exception('RPC failed'));
        when(
          () => rpcBuilder.timeout(any(), onTimeout: any(named: 'onTimeout')),
        ).thenThrow(Exception('RPC failed'));

        final count = await service.syncOrgProductToStores('op-1');

        expect(count, 0);
      });
    });

    group('getOnlineAvailableQty (static)', () {
      ProductsTableData makeProductData({
        double stockQty = 100,
        double onlineReservedQty = 10,
        double? onlineMaxQty,
        bool onlineAvailable = true,
      }) {
        return ProductsTableData(
          id: 'p-1',
          storeId: 'store-1',
          name: 'Test',
          // C-4 Stage B: SAR × 100 = cents
          price: 1000,
          stockQty: stockQty,
          minQty: 0,
          onlineAvailable: onlineAvailable,
          onlineReservedQty: onlineReservedQty,
          onlineMaxQty: onlineMaxQty,
          isActive: true,
          trackInventory: true,
          autoReorder: false,
          createdAt: DateTime(2026),
        );
      }

      test('returns 0 when not online available', () {
        final product = makeProductData(onlineAvailable: false);
        expect(OrgCatalogService.getOnlineAvailableQty(product), 0);
      });

      test('returns stock minus reserved', () {
        final product = makeProductData(stockQty: 100, onlineReservedQty: 20);
        expect(OrgCatalogService.getOnlineAvailableQty(product), 80.0);
      });

      test('respects max online quantity', () {
        final product = makeProductData(
          stockQty: 100,
          onlineReservedQty: 0,
          onlineMaxQty: 50,
        );
        expect(OrgCatalogService.getOnlineAvailableQty(product), 50.0);
      });

      test('returns available when less than max', () {
        final product = makeProductData(
          stockQty: 30,
          onlineReservedQty: 0,
          onlineMaxQty: 50,
        );
        expect(OrgCatalogService.getOnlineAvailableQty(product), 30.0);
      });
    });

    group('getProductImageUrl (static)', () {
      ProductsTableData makeProductWithImages({
        String? imageThumbnail,
        String? imageMedium,
        String? imageLarge,
        String? orgImageThumbnail,
        String? orgImageMedium,
        String? orgImageLarge,
      }) {
        return ProductsTableData(
          id: 'p-1',
          storeId: 'store-1',
          name: 'Test',
          price: 1000,
          stockQty: 0,
          minQty: 0,
          onlineAvailable: false,
          onlineReservedQty: 0,
          isActive: true,
          trackInventory: true,
          autoReorder: false,
          createdAt: DateTime(2026),
          imageThumbnail: imageThumbnail,
          imageMedium: imageMedium,
          imageLarge: imageLarge,
          orgImageThumbnail: orgImageThumbnail,
          orgImageMedium: orgImageMedium,
          orgImageLarge: orgImageLarge,
        );
      }

      test('prefers store image over org image', () {
        final product = makeProductWithImages(
          imageThumbnail: 'store-thumb',
          orgImageThumbnail: 'org-thumb',
        );
        final url = OrgCatalogService.getProductImageUrl(product);
        expect(url, 'store-thumb');
      });

      test('falls back to org image when store has none', () {
        final product = makeProductWithImages(orgImageThumbnail: 'org-thumb');
        final url = OrgCatalogService.getProductImageUrl(product);
        expect(url, 'org-thumb');
      });

      test('returns correct size', () {
        final product = makeProductWithImages(imageMedium: 'store-medium');
        final url = OrgCatalogService.getProductImageUrl(
          product,
          size: 'medium',
        );
        expect(url, 'store-medium');
      });

      test('returns null when no images available', () {
        final product = makeProductWithImages();
        final url = OrgCatalogService.getProductImageUrl(product);
        expect(url, isNull);
      });
    });
  });
}
