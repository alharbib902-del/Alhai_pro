import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../datasources/local/auth_local_datasource.dart';
import '../../datasources/remote/addresses_remote_datasource.dart';
import '../../datasources/remote/analytics_remote_datasource.dart';
import '../../datasources/remote/auth_remote_datasource.dart';
import '../../datasources/remote/categories_remote_datasource.dart';
import '../../datasources/remote/debts_remote_datasource.dart';
import '../../datasources/remote/delivery_remote_datasource.dart';
import '../../datasources/remote/impl/addresses_remote_datasource_impl.dart';
import '../../datasources/remote/impl/analytics_remote_datasource_impl.dart';
import '../../datasources/remote/impl/categories_remote_datasource_impl.dart';
import '../../datasources/remote/impl/debts_remote_datasource_impl.dart';
import '../../datasources/remote/impl/delivery_remote_datasource_impl.dart';
import '../../datasources/remote/impl/inventory_remote_datasource_impl.dart';
import '../../datasources/remote/impl/products_remote_datasource_impl.dart';
import '../../datasources/remote/impl/purchases_remote_datasource_impl.dart';
import '../../datasources/remote/impl/reports_remote_datasource_impl.dart';
import '../../datasources/remote/impl/stores_remote_datasource_impl.dart';
import '../../datasources/remote/impl/suppliers_remote_datasource_impl.dart';
import '../../datasources/remote/inventory_remote_datasource.dart';
import '../../datasources/remote/orders_remote_datasource.dart';
import '../../datasources/remote/products_remote_datasource.dart';
import '../../datasources/remote/purchases_remote_datasource.dart';
import '../../datasources/remote/reports_remote_datasource.dart';
import '../../datasources/remote/stores_remote_datasource.dart';
import '../../datasources/remote/suppliers_remote_datasource.dart';

/// DataSources module for local and remote data sources
@module
abstract class DataSourcesModule {
  // ============================================
  // Local DataSources
  // ============================================

  /// AuthLocalDataSource implementation
  @lazySingleton
  AuthLocalDataSource authLocalDataSource(
    FlutterSecureStorage secureStorage,
    SharedPreferences prefs,
  ) => AuthLocalDataSourceImpl(secureStorage: secureStorage, prefs: prefs);

  // ============================================
  // Auth & Core Remote DataSources
  // ============================================

  /// AuthRemoteDataSource implementation
  @lazySingleton
  AuthRemoteDataSource authRemoteDataSource(@Named('apiDio') Dio dio) =>
      AuthRemoteDataSourceImpl(dio: dio);

  // ============================================
  // Products & Categories
  // ============================================

  /// ProductsRemoteDataSource implementation
  @lazySingleton
  ProductsRemoteDataSource productsRemoteDataSource(@Named('apiDio') Dio dio) =>
      ProductsRemoteDataSourceImpl(dio: dio);

  /// CategoriesRemoteDataSource implementation
  @lazySingleton
  CategoriesRemoteDataSource categoriesRemoteDataSource(
    @Named('apiDio') Dio dio,
  ) => CategoriesRemoteDataSourceImpl(dio: dio);

  // ============================================
  // Orders & Delivery
  // ============================================

  /// OrdersRemoteDataSource implementation
  @lazySingleton
  OrdersRemoteDataSource ordersRemoteDataSource(@Named('apiDio') Dio dio) =>
      OrdersRemoteDataSourceImpl(dio: dio);

  /// DeliveryRemoteDataSource implementation
  @lazySingleton
  DeliveryRemoteDataSource deliveryRemoteDataSource(@Named('apiDio') Dio dio) =>
      DeliveryRemoteDataSourceImpl(dio: dio);

  /// AddressesRemoteDataSource implementation
  @lazySingleton
  AddressesRemoteDataSource addressesRemoteDataSource(
    @Named('apiDio') Dio dio,
  ) => AddressesRemoteDataSourceImpl(dio: dio);

  // ============================================
  // Stores
  // ============================================

  /// StoresRemoteDataSource implementation
  @lazySingleton
  StoresRemoteDataSource storesRemoteDataSource(@Named('apiDio') Dio dio) =>
      StoresRemoteDataSourceImpl(dio: dio);

  // ============================================
  // Inventory & Suppliers
  // ============================================

  /// InventoryRemoteDataSource implementation
  @lazySingleton
  InventoryRemoteDataSource inventoryRemoteDataSource(
    @Named('apiDio') Dio dio,
  ) => InventoryRemoteDataSourceImpl(dio: dio);

  /// SuppliersRemoteDataSource implementation
  @lazySingleton
  SuppliersRemoteDataSource suppliersRemoteDataSource(
    @Named('apiDio') Dio dio,
  ) => SuppliersRemoteDataSourceImpl(dio: dio);

  /// PurchasesRemoteDataSource implementation
  @lazySingleton
  PurchasesRemoteDataSource purchasesRemoteDataSource(
    @Named('apiDio') Dio dio,
  ) => PurchasesRemoteDataSourceImpl(dio: dio);

  // ============================================
  // Financial
  // ============================================

  /// DebtsRemoteDataSource implementation
  @lazySingleton
  DebtsRemoteDataSource debtsRemoteDataSource(@Named('apiDio') Dio dio) =>
      DebtsRemoteDataSourceImpl(dio: dio);

  // ============================================
  // Reports & Analytics
  // ============================================

  /// ReportsRemoteDataSource implementation
  @lazySingleton
  ReportsRemoteDataSource reportsRemoteDataSource(@Named('apiDio') Dio dio) =>
      ReportsRemoteDataSourceImpl(dio: dio);

  /// AnalyticsRemoteDataSource implementation
  @lazySingleton
  AnalyticsRemoteDataSource analyticsRemoteDataSource(
    @Named('apiDio') Dio dio,
  ) => AnalyticsRemoteDataSourceImpl(dio: dio);
}
