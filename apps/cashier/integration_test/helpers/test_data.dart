/// Test data for integration tests.
///
/// Provides sample products, customers, invoices, and return data
/// used across all cashier integration tests to ensure consistency.
library;

import 'package:alhai_core/alhai_core.dart';

// ============================================================================
// STORE
// ============================================================================

/// Test store ID used across all integration tests.
const kTestStoreId = 'test-store-001';

/// Test store name.
const kTestStoreName = 'بقالة الحي - فرع الرئيسي';

// ============================================================================
// CASHIER / USER
// ============================================================================

/// Test cashier user ID.
const kTestCashierId = 'test-cashier-001';

/// Test cashier name.
const kTestCashierName = 'أحمد المحاسب';

/// Test cashier phone (Saudi format).
const kTestCashierPhone = '0501234567';

/// Test OTP code used for login in test environment.
const kTestOtp = '1234';

// ============================================================================
// PRODUCTS
// ============================================================================

/// A sample barcode for scanning tests.
const kTestBarcode = '6281000000001';

/// Sample products for POS cart operations.
final testProducts = [
  Product(
    id: 'prod-001',
    storeId: kTestStoreId,
    name: 'حليب السعودية كامل الدسم 1 لتر',
    sku: 'MILK-001',
    barcode: kTestBarcode,
    // C-4 Stage B: SAR × 100 = cents (int)
    price: 650,
    costPrice: 500,
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
    // C-4 Stage B: SAR × 100 = cents (int)
    price: 475,
    costPrice: 350,
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
    // C-4 Stage B: SAR × 100 = cents (int)
    price: 3200,
    costPrice: 2500,
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
// CUSTOMERS
// ============================================================================

/// Test customer ID for debt/ledger operations.
const kTestCustomerId = 'cust-001';

/// Test customer name.
const kTestCustomerName = 'محمد العميل';

/// Test customer phone.
const kTestCustomerPhone = '0559876543';

// ============================================================================
// INVOICES / SALES
// ============================================================================

/// A completed sale ID for return/refund flow tests.
const kTestSaleId = 'sale-001';

/// A completed sale invoice number for lookup.
const kTestInvoiceNo = 'INV-2024-00001';

/// VAT rate used in Saudi Arabia (15%).
const kVatRate = 0.15;

// ============================================================================
// RETURN DATA
// ============================================================================

/// Common return reasons mapped to their Arabic labels.
const kReturnReasons = {
  'defective': 'منتج معيب',
  'wrong': 'منتج خاطئ',
  'customer_request': 'طلب العميل',
  'other': 'أخرى',
};

// ============================================================================
// COMPUTED HELPERS
// ============================================================================

/// Calculate subtotal for a list of products with quantities.
double calculateSubtotal(Map<Product, int> items) {
  return items.entries.fold(
    0.0,
    (sum, entry) => sum + (entry.key.price * entry.value),
  );
}

/// Calculate VAT amount from a subtotal.
double calculateVat(double subtotal) => subtotal * kVatRate;

/// Calculate total (subtotal + VAT).
double calculateTotal(double subtotal) => subtotal + calculateVat(subtotal);
