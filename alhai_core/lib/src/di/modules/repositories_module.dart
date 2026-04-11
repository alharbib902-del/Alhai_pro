import 'package:injectable/injectable.dart';

import '../../datasources/local/auth_local_datasource.dart';
import '../../datasources/remote/addresses_remote_datasource.dart';
import '../../datasources/remote/analytics_remote_datasource.dart';
import '../../datasources/remote/auth_remote_datasource.dart';
import '../../datasources/remote/categories_remote_datasource.dart';
import '../../datasources/remote/debts_remote_datasource.dart';
import '../../datasources/remote/delivery_remote_datasource.dart';
import '../../datasources/remote/inventory_remote_datasource.dart';
import '../../datasources/remote/orders_remote_datasource.dart';
import '../../datasources/remote/products_remote_datasource.dart';
import '../../datasources/remote/purchases_remote_datasource.dart';
import '../../datasources/remote/reports_remote_datasource.dart';
import '../../datasources/remote/stores_remote_datasource.dart';
import '../../datasources/remote/suppliers_remote_datasource.dart';
import '../../repositories/addresses_repository.dart';
import '../../repositories/analytics_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/categories_repository.dart';
import '../../repositories/debts_repository.dart';
import '../../repositories/delivery_repository.dart';
import '../../repositories/impl/addresses_repository_impl.dart';
import '../../repositories/impl/analytics_repository_impl.dart';
import '../../repositories/impl/auth_repository_impl.dart';
import '../../repositories/impl/categories_repository_impl.dart';
import '../../repositories/impl/debts_repository_impl.dart';
import '../../repositories/impl/delivery_repository_impl.dart';
import '../../repositories/impl/inventory_repository_impl.dart';
import '../../repositories/impl/orders_repository_impl.dart';
import '../../repositories/impl/products_repository_impl.dart';
import '../../repositories/impl/purchases_repository_impl.dart';
import '../../repositories/impl/reports_repository_impl.dart';
import '../../repositories/impl/stores_repository_impl.dart';
import '../../repositories/impl/suppliers_repository_impl.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/orders_repository.dart';
import '../../repositories/products_repository.dart';
import '../../repositories/purchases_repository.dart';
import '../../repositories/reports_repository.dart';
import '../../repositories/stores_repository.dart';
import '../../repositories/suppliers_repository.dart';

/// Repositories module - registers all repository implementations
@module
abstract class RepositoriesModule {
  // ============================================
  // Auth & Core
  // ============================================

  /// AuthRepository implementation
  @lazySingleton
  AuthRepository authRepository(
    AuthRemoteDataSource remoteDataSource,
    AuthLocalDataSource localDataSource,
  ) => AuthRepositoryImpl(remote: remoteDataSource, local: localDataSource);

  // ============================================
  // Products & Categories
  // ============================================

  /// ProductsRepository implementation
  @lazySingleton
  ProductsRepository productsRepository(
    ProductsRemoteDataSource remoteDataSource,
  ) => ProductsRepositoryImpl(remote: remoteDataSource);

  /// CategoriesRepository implementation
  @lazySingleton
  CategoriesRepository categoriesRepository(
    CategoriesRemoteDataSource remoteDataSource,
  ) => CategoriesRepositoryImpl(remote: remoteDataSource);

  // ============================================
  // Orders & Delivery
  // ============================================

  /// OrdersRepository implementation
  @lazySingleton
  OrdersRepository ordersRepository(OrdersRemoteDataSource remoteDataSource) =>
      OrdersRepositoryImpl(remote: remoteDataSource);

  /// DeliveryRepository implementation
  @lazySingleton
  DeliveryRepository deliveryRepository(
    DeliveryRemoteDataSource remoteDataSource,
  ) => DeliveryRepositoryImpl(remote: remoteDataSource);

  /// AddressesRepository implementation
  @lazySingleton
  AddressesRepository addressesRepository(
    AddressesRemoteDataSource remoteDataSource,
  ) => AddressesRepositoryImpl(remote: remoteDataSource);

  // ============================================
  // Stores
  // ============================================

  /// StoresRepository implementation
  @lazySingleton
  StoresRepository storesRepository(StoresRemoteDataSource remoteDataSource) =>
      StoresRepositoryImpl(remote: remoteDataSource);

  // ============================================
  // Inventory & Suppliers
  // ============================================

  /// InventoryRepository implementation
  @lazySingleton
  InventoryRepository inventoryRepository(
    InventoryRemoteDataSource remoteDataSource,
  ) => InventoryRepositoryImpl(remote: remoteDataSource);

  /// SuppliersRepository implementation
  @lazySingleton
  SuppliersRepository suppliersRepository(
    SuppliersRemoteDataSource remoteDataSource,
  ) => SuppliersRepositoryImpl(remote: remoteDataSource);

  /// PurchasesRepository implementation
  @lazySingleton
  PurchasesRepository purchasesRepository(
    PurchasesRemoteDataSource remoteDataSource,
  ) => PurchasesRepositoryImpl(remote: remoteDataSource);

  // ============================================
  // Financial
  // ============================================

  /// DebtsRepository implementation
  @lazySingleton
  DebtsRepository debtsRepository(DebtsRemoteDataSource remoteDataSource) =>
      DebtsRepositoryImpl(remote: remoteDataSource);

  // ============================================
  // Reports & Analytics
  // ============================================

  /// ReportsRepository implementation
  @lazySingleton
  ReportsRepository reportsRepository(
    ReportsRemoteDataSource remoteDataSource,
  ) => ReportsRepositoryImpl(remote: remoteDataSource);

  /// AnalyticsRepository implementation
  @lazySingleton
  AnalyticsRepository analyticsRepository(
    AnalyticsRemoteDataSource remoteDataSource,
  ) => AnalyticsRepositoryImpl(remote: remoteDataSource);
}
