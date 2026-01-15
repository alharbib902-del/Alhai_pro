import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../datasources/local/auth_local_datasource.dart';
import '../../datasources/remote/auth_remote_datasource.dart';
import '../../datasources/remote/orders_remote_datasource.dart';
import '../../datasources/remote/products_remote_datasource.dart';
import '../../dto/products/create_product_request.dart';
import '../../dto/products/product_response.dart';
import '../../dto/products/update_product_request.dart';

/// DataSources module for local and remote data sources
@module
abstract class DataSourcesModule {
  /// AuthLocalDataSource implementation
  @lazySingleton
  AuthLocalDataSource authLocalDataSource(
    FlutterSecureStorage secureStorage,
    SharedPreferences prefs,
  ) =>
      AuthLocalDataSourceImpl(
        secureStorage: secureStorage,
        prefs: prefs,
      );

  /// AuthRemoteDataSource implementation
  @lazySingleton
  AuthRemoteDataSource authRemoteDataSource(
    @Named('apiDio') Dio dio,
  ) =>
      AuthRemoteDataSourceImpl(dio: dio);

  /// OrdersRemoteDataSource implementation
  @lazySingleton
  OrdersRemoteDataSource ordersRemoteDataSource(
    @Named('apiDio') Dio dio,
  ) =>
      OrdersRemoteDataSourceImpl(dio: dio);

  /// ProductsRemoteDataSource implementation
  /// TODO: Replace with real implementation when API is ready
  @lazySingleton
  ProductsRemoteDataSource productsRemoteDataSource(
    @Named('apiDio') Dio dio,
  ) =>
      _ProductsRemoteDataSourceStub(dio: dio);
}

/// Stub implementation for ProductsRemoteDataSource
/// TODO: Replace with real implementation when API is ready
class _ProductsRemoteDataSourceStub implements ProductsRemoteDataSource {
  // ignore: unused_field
  final Dio _dio;

  _ProductsRemoteDataSourceStub({required Dio dio}) : _dio = dio;

  @override
  Future<List<ProductResponse>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
  }) {
    throw UnimplementedError('ProductsRemoteDataSource.getProducts not implemented');
  }

  @override
  Future<ProductResponse> getProduct(String id) {
    throw UnimplementedError('ProductsRemoteDataSource.getProduct not implemented');
  }

  @override
  Future<ProductResponse?> getByBarcode(String barcode) {
    throw UnimplementedError('ProductsRemoteDataSource.getByBarcode not implemented');
  }

  @override
  Future<ProductResponse> createProduct(CreateProductRequest request) {
    throw UnimplementedError('ProductsRemoteDataSource.createProduct not implemented');
  }

  @override
  Future<ProductResponse> updateProduct(String id, UpdateProductRequest request) {
    throw UnimplementedError('ProductsRemoteDataSource.updateProduct not implemented');
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _dio.delete('/products/$id');
  }
}

