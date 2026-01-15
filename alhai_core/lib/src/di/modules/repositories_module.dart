import 'package:injectable/injectable.dart';

import '../../datasources/local/auth_local_datasource.dart';
import '../../datasources/remote/auth_remote_datasource.dart';
import '../../datasources/remote/orders_remote_datasource.dart';
import '../../datasources/remote/products_remote_datasource.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/impl/auth_repository_impl.dart';
import '../../repositories/impl/orders_repository_impl.dart';
import '../../repositories/impl/products_repository_impl.dart';
import '../../repositories/orders_repository.dart';
import '../../repositories/products_repository.dart';

/// Repositories module
@module
abstract class RepositoriesModule {
  /// AuthRepository implementation
  @lazySingleton
  AuthRepository authRepository(
    AuthRemoteDataSource remoteDataSource,
    AuthLocalDataSource localDataSource,
  ) =>
      AuthRepositoryImpl(
        remote: remoteDataSource,
        local: localDataSource,
      );

  /// OrdersRepository implementation
  @lazySingleton
  OrdersRepository ordersRepository(
    OrdersRemoteDataSource remoteDataSource,
  ) =>
      OrdersRepositoryImpl(
        remote: remoteDataSource,
      );

  /// ProductsRepository implementation
  @lazySingleton
  ProductsRepository productsRepository(
    ProductsRemoteDataSource remoteDataSource,
  ) =>
      ProductsRepositoryImpl(
        remote: remoteDataSource,
      );
}
