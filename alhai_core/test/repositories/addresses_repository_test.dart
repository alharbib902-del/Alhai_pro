import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/addresses_remote_datasource.dart';
import 'package:alhai_core/src/dto/addresses/address_response.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/repositories/addresses_repository.dart';
import 'package:alhai_core/src/repositories/impl/addresses_repository_impl.dart';

// Mock class
class MockAddressesRemoteDataSource extends Mock
    implements AddressesRemoteDataSource {}

void main() {
  late AddressesRepositoryImpl repository;
  late MockAddressesRemoteDataSource mockRemote;

  // Test data
  const testAddressResponse = AddressResponse(
    id: 'addr-1',
    label: 'Home',
    fullAddress: '123 Main St, Riyadh',
    city: 'Riyadh',
    district: 'Al Olaya',
    street: 'Main St',
    buildingNumber: '123',
    lat: 24.7136,
    lng: 46.6753,
    isDefault: true,
  );

  const testSecondAddressResponse = AddressResponse(
    id: 'addr-2',
    label: 'Work',
    fullAddress: '456 Office St, Riyadh',
    city: 'Riyadh',
    district: 'King Fahd',
    street: 'Office St',
    buildingNumber: '456',
    lat: 24.7200,
    lng: 46.6800,
    isDefault: false,
  );

  setUp(() {
    mockRemote = MockAddressesRemoteDataSource();
    repository = AddressesRepositoryImpl(remote: mockRemote);
  });

  group('AddressesRepositoryImpl', () {
    group('getAddresses', () {
      test('returns list of addresses on success', () async {
        // Arrange
        when(() => mockRemote.getAddresses()).thenAnswer(
          (_) async => [testAddressResponse, testSecondAddressResponse],
        );

        // Act
        final result = await repository.getAddresses();

        // Assert
        expect(result, hasLength(2));
        expect(result.first.label, equals('Home'));
        verify(() => mockRemote.getAddresses()).called(1);
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(() => mockRemote.getAddresses()).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/addresses'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getAddresses(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getDefaultAddress', () {
      test('returns default address when exists', () async {
        // Arrange
        when(() => mockRemote.getAddresses()).thenAnswer(
          (_) async => [testAddressResponse, testSecondAddressResponse],
        );

        // Act
        final result = await repository.getDefaultAddress();

        // Assert
        expect(result, isNotNull);
        expect(result!.isDefault, isTrue);
        expect(result.label, equals('Home'));
      });

      test('returns null when no addresses exist', () async {
        // Arrange
        when(() => mockRemote.getAddresses()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getDefaultAddress();

        // Assert
        expect(result, isNull);
      });
    });

    group('getAddress', () {
      test('returns single address on success', () async {
        // Arrange
        when(
          () => mockRemote.getAddress(any()),
        ).thenAnswer((_) async => testAddressResponse);

        // Act
        final result = await repository.getAddress('addr-1');

        // Assert
        expect(result.id, equals('addr-1'));
        expect(result.city, equals('Riyadh'));
        verify(() => mockRemote.getAddress('addr-1')).called(1);
      });
    });

    group('createAddress', () {
      test('creates address with correct params', () async {
        // Arrange
        const params = CreateAddressParams(
          label: 'New Address',
          fullAddress: '789 New St',
          city: 'Jeddah',
          lat: 21.5433,
          lng: 39.1728,
        );
        when(
          () => mockRemote.createAddress(any()),
        ).thenAnswer((_) async => testAddressResponse);

        // Act
        final result = await repository.createAddress(params);

        // Assert
        expect(result.id, isNotNull);
        verify(() => mockRemote.createAddress(any())).called(1);
      });
    });

    group('updateAddress', () {
      test('updates address with params', () async {
        // Arrange
        const params = UpdateAddressParams(label: 'Updated Label');
        when(
          () => mockRemote.updateAddress(any(), any()),
        ).thenAnswer((_) async => testAddressResponse);

        // Act
        final result = await repository.updateAddress('addr-1', params);

        // Assert
        expect(result.id, equals('addr-1'));
        verify(() => mockRemote.updateAddress('addr-1', any())).called(1);
      });
    });

    group('deleteAddress', () {
      test('deletes address successfully', () async {
        // Arrange
        when(() => mockRemote.deleteAddress(any())).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(repository.deleteAddress('addr-1'), completes);
        verify(() => mockRemote.deleteAddress('addr-1')).called(1);
      });
    });

    group('setDefaultAddress', () {
      test('sets default address successfully', () async {
        // Arrange
        when(
          () => mockRemote.setDefaultAddress(any()),
        ).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(repository.setDefaultAddress('addr-1'), completes);
        verify(() => mockRemote.setDefaultAddress('addr-1')).called(1);
      });
    });
  });
}
