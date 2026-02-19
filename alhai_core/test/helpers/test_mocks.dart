/// المحاكيات المشتركة للاختبارات - Shared Test Mocks
///
/// توفر محاكيات (Mocks) موحدة لجميع الاختبارات باستخدام mocktail
library;

import 'package:mocktail/mocktail.dart';

// DataSources - Local
import 'package:alhai_core/src/datasources/local/auth_local_datasource.dart';

// DataSources - Remote
import 'package:alhai_core/src/datasources/remote/auth_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/products_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/orders_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/categories_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/stores_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/addresses_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/delivery_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/inventory_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/suppliers_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/purchases_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/debts_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/reports_remote_datasource.dart';
import 'package:alhai_core/src/datasources/remote/analytics_remote_datasource.dart';

// Repositories
import 'package:alhai_core/src/repositories/auth_repository.dart';
import 'package:alhai_core/src/repositories/products_repository.dart';
import 'package:alhai_core/src/repositories/orders_repository.dart';
import 'package:alhai_core/src/repositories/categories_repository.dart';
import 'package:alhai_core/src/repositories/stores_repository.dart';
import 'package:alhai_core/src/repositories/addresses_repository.dart';
import 'package:alhai_core/src/repositories/delivery_repository.dart';
import 'package:alhai_core/src/repositories/inventory_repository.dart';
import 'package:alhai_core/src/repositories/suppliers_repository.dart';
import 'package:alhai_core/src/repositories/purchases_repository.dart';
import 'package:alhai_core/src/repositories/debts_repository.dart';
import 'package:alhai_core/src/repositories/reports_repository.dart';
import 'package:alhai_core/src/repositories/analytics_repository.dart';

// Entities (for Fake registration)
import 'package:alhai_core/src/datasources/local/entities/auth_tokens_entity.dart';
import 'package:alhai_core/src/datasources/local/entities/user_entity.dart';

// DTOs (for Fake registration)
import 'package:alhai_core/src/dto/products/create_product_request.dart';
import 'package:alhai_core/src/dto/products/update_product_request.dart';
import 'package:alhai_core/src/dto/orders/create_order_request.dart';

// ============================================================================
// LOCAL DATASOURCE MOCKS
// ============================================================================

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

// ============================================================================
// REMOTE DATASOURCE MOCKS
// ============================================================================

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockProductsRemoteDataSource extends Mock
    implements ProductsRemoteDataSource {}

class MockOrdersRemoteDataSource extends Mock
    implements OrdersRemoteDataSource {}

class MockCategoriesRemoteDataSource extends Mock
    implements CategoriesRemoteDataSource {}

class MockStoresRemoteDataSource extends Mock
    implements StoresRemoteDataSource {}

class MockAddressesRemoteDataSource extends Mock
    implements AddressesRemoteDataSource {}

class MockDeliveryRemoteDataSource extends Mock
    implements DeliveryRemoteDataSource {}

class MockInventoryRemoteDataSource extends Mock
    implements InventoryRemoteDataSource {}

class MockSuppliersRemoteDataSource extends Mock
    implements SuppliersRemoteDataSource {}

class MockPurchasesRemoteDataSource extends Mock
    implements PurchasesRemoteDataSource {}

class MockDebtsRemoteDataSource extends Mock implements DebtsRemoteDataSource {}

class MockReportsRemoteDataSource extends Mock
    implements ReportsRemoteDataSource {}

class MockAnalyticsRemoteDataSource extends Mock
    implements AnalyticsRemoteDataSource {}

// ============================================================================
// REPOSITORY MOCKS
// ============================================================================

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProductsRepository extends Mock implements ProductsRepository {}

class MockOrdersRepository extends Mock implements OrdersRepository {}

class MockCategoriesRepository extends Mock implements CategoriesRepository {}

class MockStoresRepository extends Mock implements StoresRepository {}

class MockAddressesRepository extends Mock implements AddressesRepository {}

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

class MockInventoryRepository extends Mock implements InventoryRepository {}

class MockSuppliersRepository extends Mock implements SuppliersRepository {}

class MockPurchasesRepository extends Mock implements PurchasesRepository {}

class MockDebtsRepository extends Mock implements DebtsRepository {}

class MockReportsRepository extends Mock implements ReportsRepository {}

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

// ============================================================================
// FAKE CLASSES (for mocktail fallbackValue registration)
// ============================================================================

class FakeAuthTokensEntity extends Fake implements AuthTokensEntity {}

class FakeUserEntity extends Fake implements UserEntity {}

class FakeCreateProductRequest extends Fake implements CreateProductRequest {}

class FakeUpdateProductRequest extends Fake implements UpdateProductRequest {}

class FakeCreateOrderRequest extends Fake implements CreateOrderRequest {}

// ============================================================================
// REGISTRATION HELPER
// ============================================================================

/// تسجيل جميع الـ Fakes المطلوبة لـ mocktail
/// يجب استدعاء هذه الدالة في setUpAll
void registerAllFallbackValues() {
  registerFallbackValue(FakeAuthTokensEntity());
  registerFallbackValue(FakeUserEntity());
  registerFallbackValue(FakeCreateProductRequest());
  registerFallbackValue(FakeUpdateProductRequest());
  registerFallbackValue(FakeCreateOrderRequest());
}
