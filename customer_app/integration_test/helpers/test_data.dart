/// Test data for customer app integration tests.
///
/// Provides sample products, addresses, orders, and customer data
/// used across all customer app integration tests.
library;

import 'package:alhai_core/alhai_core.dart';

// ============================================================================
// STORE
// ============================================================================

/// Test store ID.
const kTestStoreId = 'test-store-001';

/// Test store name.
const kTestStoreName = 'بقالة الحي - فرع الرئيسي';

// ============================================================================
// CUSTOMER
// ============================================================================

/// Test customer ID.
const kTestCustomerId = 'cust-001';

/// Test customer name.
const kTestCustomerName = 'محمد العميل';

/// Test customer phone.
const kTestCustomerPhone = '0559876543';

/// Test OTP code.
const kTestOtp = '1234';

// ============================================================================
// PRODUCTS
// ============================================================================

/// Sample products for catalog browsing and cart operations.
final testProducts = [
  Product(
    id: 'prod-001',
    storeId: kTestStoreId,
    name: 'حليب السعودية كامل الدسم 1 لتر',
    sku: 'MILK-001',
    barcode: '6281000000001',
    price: 6.50,
    costPrice: 5.00,
    stockQty: 100,
    minQty: 10,
    unit: 'حبة',
    categoryId: 'cat-dairy',
    isActive: true,
    trackInventory: true,
    createdAt: DateTime(2024, 1, 1),
  ),
  Product(
    id: 'prod-002',
    storeId: kTestStoreId,
    name: 'خبز توست لوزين أبيض',
    sku: 'BREAD-001',
    barcode: '6281000000002',
    price: 4.75,
    costPrice: 3.50,
    stockQty: 50,
    minQty: 5,
    unit: 'حبة',
    categoryId: 'cat-bakery',
    isActive: true,
    trackInventory: true,
    createdAt: DateTime(2024, 1, 1),
  ),
  Product(
    id: 'prod-003',
    storeId: kTestStoreId,
    name: 'أرز بسمتي أبو كأس 5 كيلو',
    sku: 'RICE-001',
    barcode: '6281000000003',
    price: 32.00,
    costPrice: 25.00,
    stockQty: 30,
    minQty: 5,
    unit: 'حبة',
    categoryId: 'cat-grains',
    isActive: true,
    trackInventory: true,
    createdAt: DateTime(2024, 1, 1),
  ),
];

// ============================================================================
// ADDRESSES
// ============================================================================

/// Test delivery address.
final testAddress = Address(
  id: 'addr-001',
  label: 'المنزل',
  fullAddress: 'حي النزهة، شارع الأمير سلطان، الرياض 12345',
  city: 'الرياض',
  district: 'النزهة',
  street: 'شارع الأمير سلطان',
  buildingNumber: '42',
  lat: 24.7136,
  lng: 46.6753,
  isDefault: true,
);

/// Secondary test address.
final testAddress2 = Address(
  id: 'addr-002',
  label: 'العمل',
  fullAddress: 'حي العليا، طريق الملك فهد، الرياض 11564',
  city: 'الرياض',
  district: 'العليا',
  street: 'طريق الملك فهد',
  buildingNumber: '100',
  lat: 24.6900,
  lng: 46.6850,
  isDefault: false,
);

// ============================================================================
// ORDERS
// ============================================================================

/// Test order ID for tracking tests.
const kTestOrderId = 'order-001';

/// Test order number.
const kTestOrderNumber = '#ALH-00001';

/// Order status flow for the online order lifecycle.
const kOrderStatusFlow = [
  OrderStatus.created,
  OrderStatus.confirmed,
  OrderStatus.preparing,
  OrderStatus.ready,
  OrderStatus.outForDelivery,
  OrderStatus.delivered,
  OrderStatus.completed,
];

// ============================================================================
// DRIVER
// ============================================================================

/// Test driver ID.
const kTestDriverId = 'driver-001';

/// Test driver name.
const kTestDriverName = 'عبدالله السائق';

/// Test driver phone.
const kTestDriverPhone = '0501112222';
