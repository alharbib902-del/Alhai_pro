import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/categories_remote_datasource.dart';
import 'package:alhai_core/src/dto/categories/category_response.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/repositories/impl/categories_repository_impl.dart';

// Mock class
class MockCategoriesRemoteDataSource extends Mock
    implements CategoriesRemoteDataSource {}

void main() {
  late CategoriesRepositoryImpl repository;
  late MockCategoriesRemoteDataSource mockRemote;

  // Test data
  final testCategoryResponse = CategoryResponse(
    id: 'cat-1',
    name: 'Fruits',
    imageUrl: 'https://example.com/fruits.jpg',
    parentId: null,
    sortOrder: 1,
    isActive: true,
  );

  final testChildCategoryResponse = CategoryResponse(
    id: 'cat-2',
    name: 'Apples',
    imageUrl: 'https://example.com/apples.jpg',
    parentId: 'cat-1',
    sortOrder: 1,
    isActive: true,
  );

  setUp(() {
    mockRemote = MockCategoriesRemoteDataSource();
    repository = CategoriesRepositoryImpl(remote: mockRemote);
  });

  group('CategoriesRepositoryImpl', () {
    group('getCategories', () {
      test('returns list of categories on success', () async {
        // Arrange
        when(() => mockRemote.getCategories(any()))
            .thenAnswer((_) async => [testCategoryResponse]);

        // Act
        final result = await repository.getCategories('store-1');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.id, equals('cat-1'));
        expect(result.first.name, equals('Fruits'));
        verify(() => mockRemote.getCategories('store-1')).called(1);
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(() => mockRemote.getCategories(any())).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/categories'),
        ));

        // Act & Assert
        expect(
          () => repository.getCategories('store-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getCategory', () {
      test('returns single category on success', () async {
        // Arrange
        when(() => mockRemote.getCategory(any()))
            .thenAnswer((_) async => testCategoryResponse);

        // Act
        final result = await repository.getCategory('cat-1');

        // Assert
        expect(result.id, equals('cat-1'));
        expect(result.name, equals('Fruits'));
        verify(() => mockRemote.getCategory('cat-1')).called(1);
      });

      test('throws NotFoundException on 404', () async {
        // Arrange
        when(() => mockRemote.getCategory(any())).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/categories/invalid'),
          ),
          requestOptions: RequestOptions(path: '/categories/invalid'),
        ));

        // Act & Assert
        expect(
          () => repository.getCategory('invalid'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('getRootCategories', () {
      test('filters only root categories (parentId == null)', () async {
        // Arrange
        when(() => mockRemote.getCategories(any())).thenAnswer(
            (_) async => [testCategoryResponse, testChildCategoryResponse]);

        // Act
        final result = await repository.getRootCategories('store-1');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.parentId, isNull);
      });
    });

    group('getChildCategories', () {
      test('filters categories by parentId', () async {
        // Arrange
        when(() => mockRemote.getCategories(any())).thenAnswer(
            (_) async => [testCategoryResponse, testChildCategoryResponse]);

        // Act
        final result = await repository.getChildCategories('cat-1');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.parentId, equals('cat-1'));
      });
    });
  });
}
