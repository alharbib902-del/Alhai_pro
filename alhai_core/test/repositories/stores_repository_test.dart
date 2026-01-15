import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/stores_remote_datasource.dart';
import 'package:alhai_core/src/dto/stores/store_response.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/repositories/stores_repository.dart';
import 'package:alhai_core/src/repositories/impl/stores_repository_impl.dart';

// Mock class
class MockStoresRemoteDataSource extends Mock implements StoresRemoteDataSource {}

void main() {
  late StoresRepositoryImpl repository;
  late MockStoresRemoteDataSource mockRemote;

  // Test data
  final testStoreResponse = StoreResponse(
    id: 'store-1',
    name: 'Test Store',
    address: '123 Main St',
    phone: '+966500000000',
    lat: 24.7136,
    lng: 46.6753,
    imageUrl: 'https://example.com/store.jpg',
    isActive: true,
    ownerId: 'owner-1',
    createdAt: '2026-01-10T10:00:00Z',
  );

  setUp(() {
    mockRemote = MockStoresRemoteDataSource();
    repository = StoresRepositoryImpl(remote: mockRemote);
  });

  group('StoresRepositoryImpl', () {
    group('getStore', () {
      test('returns Store on success', () async {
        // Arrange
        when(() => mockRemote.getStore(any()))
            .thenAnswer((_) async => testStoreResponse);

        // Act
        final result = await repository.getStore('store-1');

        // Assert
        expect(result.id, equals('store-1'));
        expect(result.name, equals('Test Store'));
        verify(() => mockRemote.getStore('store-1')).called(1);
      });

      test('throws NotFoundException on 404', () async {
        // Arrange
        when(() => mockRemote.getStore(any())).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/stores/invalid'),
          ),
          requestOptions: RequestOptions(path: '/stores/invalid'),
        ));

        // Act & Assert
        expect(
          () => repository.getStore('invalid'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('getCurrentStore', () {
      test('returns current Store when exists', () async {
        // Arrange
        when(() => mockRemote.getCurrentStore())
            .thenAnswer((_) async => testStoreResponse);

        // Act
        final result = await repository.getCurrentStore();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('store-1'));
      });

      test('returns null when no current store', () async {
        // Arrange
        when(() => mockRemote.getCurrentStore()).thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentStore();

        // Assert
        expect(result, isNull);
      });
    });

    group('getStores', () {
      test('returns list of stores', () async {
        // Arrange
        when(() => mockRemote.getStores())
            .thenAnswer((_) async => [testStoreResponse]);

        // Act
        final result = await repository.getStores();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.name, equals('Test Store'));
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(() => mockRemote.getStores()).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/stores'),
        ));

        // Act & Assert
        expect(
          () => repository.getStores(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getNearbyStores', () {
      test('returns nearby stores with location params', () async {
        // Arrange
        when(() => mockRemote.getNearbyStores(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radiusKm: any(named: 'radiusKm'),
            )).thenAnswer((_) async => [testStoreResponse]);

        // Act
        final result = await repository.getNearbyStores(
          lat: 24.7136,
          lng: 46.6753,
          radiusKm: 5,
        );

        // Assert
        expect(result, hasLength(1));
        verify(() => mockRemote.getNearbyStores(
              lat: 24.7136,
              lng: 46.6753,
              radiusKm: 5,
            )).called(1);
      });
    });

    group('updateStore', () {
      test('updates store with params', () async {
        // Arrange
        final params = UpdateStoreParams(name: 'Updated Store');
        when(() => mockRemote.updateStore(any(), any()))
            .thenAnswer((_) async => testStoreResponse);

        // Act
        final result = await repository.updateStore('store-1', params);

        // Assert
        expect(result.id, equals('store-1'));
        verify(() => mockRemote.updateStore('store-1', any())).called(1);
      });
    });

    group('isStoreOpen', () {
      test('returns true when store is open', () async {
        // Arrange
        when(() => mockRemote.isStoreOpen(any())).thenAnswer((_) async => true);

        // Act
        final result = await repository.isStoreOpen('store-1');

        // Assert
        expect(result, isTrue);
      });

      test('returns false when store is closed', () async {
        // Arrange
        when(() => mockRemote.isStoreOpen(any())).thenAnswer((_) async => false);

        // Act
        final result = await repository.isStoreOpen('store-1');

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
