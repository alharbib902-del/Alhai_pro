import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/src/image_upload_service.dart';

import '../helpers/sync_test_helpers.dart';

class MockStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

class MockProductsDao extends Mock implements ProductsDao {}

class MockOrgProductsDao extends Mock implements OrgProductsDao {}

void main() {
  late MockSupabaseClient mockClient;
  late MockStorageClient mockStorage;
  late MockStorageFileApi mockFileApi;
  late MockAppDatabase mockDb;
  late MockProductsDao mockProductsDao;
  late MockOrgProductsDao mockOrgProductsDao;
  late ImageUploadService service;

  setUpAll(() {
    registerSyncFallbackValues();
    registerFallbackValue(const FileOptions());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockStorage = MockStorageClient();
    mockFileApi = MockStorageFileApi();
    mockDb = MockAppDatabase();
    mockProductsDao = MockProductsDao();
    mockOrgProductsDao = MockOrgProductsDao();

    when(() => mockClient.storage).thenReturn(mockStorage);
    when(() => mockStorage.from(any())).thenReturn(mockFileApi);
    when(() => mockDb.productsDao).thenReturn(mockProductsDao);
    when(() => mockDb.orgProductsDao).thenReturn(mockOrgProductsDao);

    service = ImageUploadService(client: mockClient, db: mockDb);
  });

  group('ImageUploadService', () {
    group('uploadProductImage', () {
      test('uploads three image sizes and updates local DB', () async {
        final imageBytes = Uint8List.fromList(List.filled(100, 0xFF));

        when(() => mockFileApi.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenAnswer((_) async => '');

        when(() => mockFileApi.getPublicUrl(any())).thenReturn(
            'https://storage.example.com/test.webp');

        when(() => mockProductsDao.updateProductImages(
              any(),
              imageThumbnail: any(named: 'imageThumbnail'),
              imageMedium: any(named: 'imageMedium'),
              imageLarge: any(named: 'imageLarge'),
              imageHash: any(named: 'imageHash'),
            )).thenAnswer((_) async => 1);

        final result = await service.uploadProductImage(
          storeId: 'store-1',
          productId: 'prod-1',
          imageBytes: imageBytes,
        );

        expect(result, isNotNull);
        expect(result!.thumbnailUrl, contains('https://'));
        expect(result.mediumUrl, contains('https://'));
        expect(result.largeUrl, contains('https://'));
        expect(result.imageHash, isNotEmpty);

        // Three uploads: thumb, medium, large
        verify(() => mockFileApi.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).called(3);

        verify(() => mockProductsDao.updateProductImages(
              'prod-1',
              imageThumbnail: any(named: 'imageThumbnail'),
              imageMedium: any(named: 'imageMedium'),
              imageLarge: any(named: 'imageLarge'),
              imageHash: any(named: 'imageHash'),
            )).called(1);
      });

      test('returns null on upload failure', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3]);

        when(() => mockFileApi.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenThrow(Exception('Storage error'));

        final result = await service.uploadProductImage(
          storeId: 'store-1',
          productId: 'prod-1',
          imageBytes: imageBytes,
        );

        expect(result, isNull);
      });
    });

    group('uploadOrgProductImage', () {
      test('uploads and updates org product images', () async {
        final imageBytes = Uint8List.fromList(List.filled(50, 0xAB));

        when(() => mockFileApi.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenAnswer((_) async => '');

        when(() => mockFileApi.getPublicUrl(any())).thenReturn(
            'https://storage.example.com/org.webp');

        when(() => mockOrgProductsDao.updateOrgProduct(
              any(),
              orgImageThumbnail: any(named: 'orgImageThumbnail'),
              orgImageMedium: any(named: 'orgImageMedium'),
              orgImageLarge: any(named: 'orgImageLarge'),
              orgImageHash: any(named: 'orgImageHash'),
            )).thenAnswer((_) async => 1);

        // RPC call for sync
        setupRpcCall(mockClient, result: 0);

        final result = await service.uploadOrgProductImage(
          orgId: 'org-1',
          orgProductId: 'op-1',
          sku: 'SKU-001',
          imageBytes: imageBytes,
        );

        expect(result, isNotNull);
        verify(() => mockOrgProductsDao.updateOrgProduct(
              'op-1',
              orgImageThumbnail: any(named: 'orgImageThumbnail'),
              orgImageMedium: any(named: 'orgImageMedium'),
              orgImageLarge: any(named: 'orgImageLarge'),
              orgImageHash: any(named: 'orgImageHash'),
            )).called(1);
      });

      test('returns null on failure', () async {
        final imageBytes = Uint8List.fromList([1]);

        when(() => mockFileApi.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenThrow(Exception('Upload failed'));

        final result = await service.uploadOrgProductImage(
          orgId: 'org-1',
          orgProductId: 'op-1',
          sku: 'SKU-001',
          imageBytes: imageBytes,
        );

        expect(result, isNull);
      });
    });

    group('uploadStoreLogo', () {
      test('uploads logo and returns public URL', () async {
        final imageBytes = Uint8List.fromList(List.filled(20, 0xCC));

        when(() => mockFileApi.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenAnswer((_) async => '');

        when(() => mockFileApi.getPublicUrl(any())).thenReturn(
            'https://storage.example.com/logo.webp');

        final url = await service.uploadStoreLogo(
          storeId: 'store-1',
          imageBytes: imageBytes,
        );

        expect(url, isNotNull);
        expect(url, contains('https://'));
      });

      test('returns null on failure', () async {
        when(() => mockFileApi.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenThrow(Exception('Failed'));

        final url = await service.uploadStoreLogo(
          storeId: 'store-1',
          imageBytes: Uint8List(1),
        );

        expect(url, isNull);
      });
    });

    group('archiveInvoicePdf', () {
      test('uploads PDF and returns public URL', () async {
        final pdfBytes = Uint8List.fromList(List.filled(50, 0x25));

        when(() => mockFileApi.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenAnswer((_) async => '');

        when(() => mockFileApi.getPublicUrl(any())).thenReturn(
            'https://storage.example.com/invoice.pdf');

        final url = await service.archiveInvoicePdf(
          storeId: 'store-1',
          invoiceNumber: 'INV-2026-00001',
          pdfBytes: pdfBytes,
        );

        expect(url, isNotNull);
        expect(url, contains('https://'));
      });

      test('returns null on failure', () async {
        when(() => mockFileApi.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenThrow(Exception('Failed'));

        final url = await service.archiveInvoicePdf(
          storeId: 'store-1',
          invoiceNumber: 'INV-001',
          pdfBytes: Uint8List(1),
        );

        expect(url, isNull);
      });
    });

    group('deleteProductImages', () {
      test('lists and removes files', () async {
        when(() => mockFileApi.list(path: any(named: 'path')))
            .thenAnswer((_) async => [
                  FileObject(
                    name: 'thumb_abc.webp',
                    id: '1',
                    owner: null,
                    updatedAt: '',
                    createdAt: '',
                    lastAccessedAt: '',
                    metadata: {},
                    bucketId: 'product-images',
                    buckets: null,
                  ),
                ]);

        when(() => mockFileApi.remove(any()))
            .thenAnswer((_) async => []);

        await service.deleteProductImages(
          storeId: 'store-1',
          productId: 'prod-1',
        );

        verify(() => mockFileApi.remove(any())).called(1);
      });

      test('does nothing when no files exist', () async {
        when(() => mockFileApi.list(path: any(named: 'path')))
            .thenAnswer((_) async => []);

        await service.deleteProductImages(
          storeId: 'store-1',
          productId: 'prod-1',
        );

        verifyNever(() => mockFileApi.remove(any()));
      });
    });
  });

  group('ImageUploadResult', () {
    test('holds all URL fields', () {
      const result = ImageUploadResult(
        thumbnailUrl: 'https://example.com/thumb.webp',
        mediumUrl: 'https://example.com/medium.webp',
        largeUrl: 'https://example.com/large.webp',
        imageHash: 'abc123',
      );

      expect(result.thumbnailUrl, contains('thumb'));
      expect(result.mediumUrl, contains('medium'));
      expect(result.largeUrl, contains('large'));
      expect(result.imageHash, 'abc123');
    });
  });
}
