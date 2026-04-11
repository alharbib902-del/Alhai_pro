import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/suppliers_remote_datasource.dart';
import 'package:alhai_core/src/dto/suppliers/supplier_response.dart';
import 'package:alhai_core/src/dto/suppliers/create_supplier_request.dart';
import 'package:alhai_core/src/dto/suppliers/update_supplier_request.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/repositories/suppliers_repository.dart';
import 'package:alhai_core/src/repositories/impl/suppliers_repository_impl.dart';

// Mock class
class MockSuppliersRemoteDataSource extends Mock
    implements SuppliersRemoteDataSource {}

// Fake classes
class FakeCreateSupplierRequest extends Fake implements CreateSupplierRequest {}

class FakeUpdateSupplierRequest extends Fake implements UpdateSupplierRequest {}

void main() {
  late SuppliersRepositoryImpl repository;
  late MockSuppliersRemoteDataSource mockRemote;

  // Test data
  const testSupplierResponse = SupplierResponse(
    id: 'sup-1',
    storeId: 'store-1',
    name: 'Test Supplier',
    phone: '0500000000',
    email: 'supplier@test.com',
    address: 'Test Address',
    isActive: true,
    balance: 1000.0,
    createdAt: '2026-01-19T10:00:00Z',
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateSupplierRequest());
    registerFallbackValue(FakeUpdateSupplierRequest());
  });

  setUp(() {
    mockRemote = MockSuppliersRemoteDataSource();
    repository = SuppliersRepositoryImpl(remote: mockRemote);
  });

  group('SuppliersRepositoryImpl', () {
    group('getSuppliers', () {
      test('returns Paginated<Supplier> on success', () async {
        // Arrange
        when(
          () => mockRemote.getSuppliers(
            any(),
            activeOnly: any(named: 'activeOnly'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => [testSupplierResponse]);

        // Act
        final result = await repository.getSuppliers(
          'store-1',
          page: 1,
          limit: 20,
        );

        // Assert
        expect(result.items, hasLength(1));
        expect(result.items.first.id, equals('sup-1'));
        expect(result.items.first.name, equals('Test Supplier'));
        verify(
          () => mockRemote.getSuppliers('store-1', page: 1, limit: 20),
        ).called(1);
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(
          () => mockRemote.getSuppliers(
            any(),
            activeOnly: any(named: 'activeOnly'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/suppliers'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getSuppliers('store-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getSupplier', () {
      test('returns Supplier on success', () async {
        // Arrange
        when(
          () => mockRemote.getSupplier(any()),
        ).thenAnswer((_) async => testSupplierResponse);

        // Act
        final result = await repository.getSupplier('sup-1');

        // Assert
        expect(result.id, equals('sup-1'));
        expect(result.name, equals('Test Supplier'));
      });

      test('throws NotFoundException on 404', () async {
        // Arrange
        when(() => mockRemote.getSupplier(any())).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: '/suppliers/invalid'),
            ),
            requestOptions: RequestOptions(path: '/suppliers/invalid'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getSupplier('invalid'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('createSupplier', () {
      test('creates supplier successfully', () async {
        // Arrange
        const params = CreateSupplierParams(
          storeId: 'store-1',
          name: 'New Supplier',
          phone: '0500000001',
        );

        when(
          () => mockRemote.createSupplier(any()),
        ).thenAnswer((_) async => testSupplierResponse);

        // Act
        final result = await repository.createSupplier(params);

        // Assert
        expect(result.id, equals('sup-1'));
        verify(() => mockRemote.createSupplier(any())).called(1);
      });
    });

    group('deleteSupplier', () {
      test('deletes supplier successfully', () async {
        // Arrange
        when(() => mockRemote.deleteSupplier(any())).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(repository.deleteSupplier('sup-1'), completes);
        verify(() => mockRemote.deleteSupplier('sup-1')).called(1);
      });
    });
  });
}
