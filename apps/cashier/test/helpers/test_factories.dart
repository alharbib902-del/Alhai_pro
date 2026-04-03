/// Test data factories for Cashier tests
///
/// Factory functions that produce valid Drift data objects matching the
/// database table schemas. All default values use Arabic text to match the
/// app's Arabic-first UX.
///
/// Each factory uses named optional parameters so callers only need to
/// override the fields relevant to their test.
library;

import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// PRODUCTS
// ============================================================================

/// Create a [ProductsTableData] with sensible defaults.
ProductsTableData createTestProduct({
  String id = 'prod-1',
  String storeId = 'test-store-1',
  String name = '\u0645\u0646\u062a\u062c \u062a\u062c\u0631\u064a\u0628\u064a', // منتج تجريبي
  String? sku,
  String? barcode,
  double price = 25.0,
  double? costPrice = 15.0,
  int stockQty = 100,
  int minQty = 5,
  String? unit,
  String? description,
  String? categoryId,
  bool isActive = true,
  bool trackInventory = true,
  bool autoReorder = false,
  bool onlineAvailable = false,
  double onlineReservedQty = 0.0,
  DateTime? createdAt,
}) {
  return ProductsTableData(
    id: id,
    storeId: storeId,
    name: name,
    sku: sku,
    barcode: barcode,
    price: price,
    costPrice: costPrice,
    stockQty: stockQty,
    minQty: minQty,
    unit: unit,
    description: description,
    categoryId: categoryId,
    isActive: isActive,
    trackInventory: trackInventory,
    autoReorder: autoReorder,
    onlineAvailable: onlineAvailable,
    onlineReservedQty: onlineReservedQty,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

// ============================================================================
// SALES
// ============================================================================

/// Create a [SalesTableData] with sensible defaults.
SalesTableData createTestSale({
  String id = 'sale-1',
  String storeId = 'test-store-1',
  String receiptNo = 'POS-20260115-0001',
  String cashierId = 'test-user-1',
  String? customerId,
  String? customerName,
  String? customerPhone,
  double subtotal = 100.0,
  double discount = 0.0,
  double tax = 15.0,
  double total = 115.0,
  String paymentMethod = 'cash',
  bool isPaid = true,
  double? amountReceived,
  double? changeAmount,
  String? notes,
  String channel = 'POS',
  String status = 'completed',
  DateTime? createdAt,
}) {
  return SalesTableData(
    id: id,
    storeId: storeId,
    receiptNo: receiptNo,
    cashierId: cashierId,
    customerId: customerId,
    customerName: customerName,
    customerPhone: customerPhone,
    subtotal: subtotal,
    discount: discount,
    tax: tax,
    total: total,
    paymentMethod: paymentMethod,
    isPaid: isPaid,
    amountReceived: amountReceived,
    changeAmount: changeAmount,
    notes: notes,
    channel: channel,
    status: status,
    createdAt: createdAt ?? DateTime(2026, 1, 15, 10, 30),
  );
}

// ============================================================================
// SALE ITEMS
// ============================================================================

/// Create a [SaleItemsTableData] with sensible defaults.
SaleItemsTableData createTestSaleItem({
  String id = 'item-1',
  String saleId = 'sale-1',
  String productId = 'prod-1',
  String productName = '\u0645\u0646\u062a\u062c \u062a\u062c\u0631\u064a\u0628\u064a', // منتج تجريبي
  String? productSku,
  String? productBarcode,
  int qty = 2,
  double unitPrice = 25.0,
  double? costPrice,
  double subtotal = 50.0,
  double discount = 0.0,
  double total = 50.0,
  String? notes,
}) {
  return SaleItemsTableData(
    id: id,
    saleId: saleId,
    productId: productId,
    productName: productName,
    productSku: productSku,
    productBarcode: productBarcode,
    qty: qty.toDouble(),
    unitPrice: unitPrice,
    costPrice: costPrice,
    subtotal: subtotal,
    discount: discount,
    total: total,
    notes: notes,
  );
}

// ============================================================================
// ORDERS
// ============================================================================

/// Create an [OrdersTableData] with sensible defaults.
OrdersTableData createTestOrder({
  String id = 'order-1',
  String storeId = 'test-store-1',
  String? customerId,
  String orderNumber = 'ORD-20260115-001',
  String channel = 'pos',
  String status = 'completed',
  double subtotal = 100.0,
  double taxAmount = 15.0,
  double deliveryFee = 0.0,
  double discount = 0.0,
  double total = 115.0,
  String? paymentMethod = 'cash',
  String paymentStatus = 'paid',
  String deliveryType = 'pickup',
  String? deliveryAddress,
  String? driverId,
  String? notes,
  DateTime? orderDate,
  DateTime? createdAt,
  DateTime? updatedAt,
  int confirmationAttempts = 0,
  bool autoReorderTriggered = false,
}) {
  final now = createdAt ?? DateTime(2026, 1, 15, 10, 30);
  return OrdersTableData(
    id: id,
    storeId: storeId,
    customerId: customerId,
    orderNumber: orderNumber,
    channel: channel,
    status: status,
    subtotal: subtotal,
    taxAmount: taxAmount,
    deliveryFee: deliveryFee,
    discount: discount,
    total: total,
    paymentMethod: paymentMethod,
    paymentStatus: paymentStatus,
    deliveryType: deliveryType,
    deliveryAddress: deliveryAddress,
    driverId: driverId,
    notes: notes,
    orderDate: orderDate ?? now,
    createdAt: now,
    updatedAt: updatedAt ?? now,
    confirmationAttempts: confirmationAttempts,
    autoReorderTriggered: autoReorderTriggered,
  );
}

// ============================================================================
// CUSTOMERS
// ============================================================================

/// Create a [CustomersTableData] with sensible defaults.
CustomersTableData createTestCustomer({
  String id = 'cust-1',
  String storeId = 'test-store-1',
  String name = '\u0639\u0645\u064a\u0644 \u062a\u062c\u0631\u064a\u0628\u064a', // عميل تجريبي
  String? phone = '0501234567',
  String? email,
  String? address,
  String? city,
  String? taxNumber,
  String type = 'individual',
  String? notes,
  bool isActive = true,
  DateTime? createdAt,
}) {
  return CustomersTableData(
    id: id,
    storeId: storeId,
    name: name,
    phone: phone,
    email: email,
    address: address,
    city: city,
    taxNumber: taxNumber,
    type: type,
    notes: notes,
    isActive: isActive,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

// ============================================================================
// SHIFTS
// ============================================================================

/// Create a [ShiftsTableData] with sensible defaults.
ShiftsTableData createTestShift({
  String id = 'shift-1',
  String storeId = 'test-store-1',
  String cashierId = 'test-user-1',
  String cashierName = '\u0643\u0627\u0634\u064a\u0631 \u062a\u062c\u0631\u064a\u0628\u064a', // كاشير تجريبي
  double openingCash = 500.0,
  double? closingCash,
  double? expectedCash,
  double? difference,
  int totalSales = 0,
  double totalSalesAmount = 0.0,
  int totalRefunds = 0,
  double totalRefundsAmount = 0.0,
  String status = 'open',
  String? notes,
  DateTime? openedAt,
  DateTime? closedAt,
}) {
  return ShiftsTableData(
    id: id,
    storeId: storeId,
    cashierId: cashierId,
    cashierName: cashierName,
    openingCash: openingCash,
    closingCash: closingCash,
    expectedCash: expectedCash,
    difference: difference,
    totalSales: totalSales,
    totalSalesAmount: totalSalesAmount,
    totalRefunds: totalRefunds,
    totalRefundsAmount: totalRefundsAmount,
    status: status,
    notes: notes,
    openedAt: openedAt ?? DateTime(2026, 1, 15, 8, 0),
    closedAt: closedAt,
  );
}

// ============================================================================
// CATEGORIES
// ============================================================================

/// Create a [CategoriesTableData] with sensible defaults.
CategoriesTableData createTestCategory({
  String id = 'cat-1',
  String storeId = 'test-store-1',
  String name = '\u062a\u0635\u0646\u064a\u0641 \u062a\u062c\u0631\u064a\u0628\u064a', // تصنيف تجريبي
  String? nameEn = 'Test Category',
  String? parentId,
  String? imageUrl,
  String? color,
  String? icon,
  int sortOrder = 0,
  bool isActive = true,
  DateTime? createdAt,
}) {
  return CategoriesTableData(
    id: id,
    storeId: storeId,
    name: name,
    nameEn: nameEn,
    parentId: parentId,
    imageUrl: imageUrl,
    color: color,
    icon: icon,
    sortOrder: sortOrder,
    isActive: isActive,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

// ============================================================================
// RETURNS
// ============================================================================

/// Create a [ReturnsTableData] with sensible defaults.
ReturnsTableData createTestReturn({
  String id = 'ret-1',
  String storeId = 'test-store-1',
  String returnNumber = 'RET-20260115-001',
  String saleId = 'sale-1',
  String? customerId,
  String? customerName = '\u0639\u0645\u064a\u0644 \u062a\u062c\u0631\u064a\u0628\u064a', // عميل تجريبي
  String? reason = '\u0639\u064a\u0628 \u0641\u064a \u0627\u0644\u0645\u0646\u062a\u062c', // عيب في المنتج
  String type = 'full',
  String refundMethod = 'cash',
  double totalRefund = 50.0,
  String status = 'completed',
  String? createdBy,
  String? notes,
  DateTime? createdAt,
}) {
  return ReturnsTableData(
    id: id,
    storeId: storeId,
    returnNumber: returnNumber,
    saleId: saleId,
    customerId: customerId,
    customerName: customerName,
    reason: reason,
    type: type,
    refundMethod: refundMethod,
    totalRefund: totalRefund,
    status: status,
    createdBy: createdBy,
    notes: notes,
    createdAt: createdAt ?? DateTime(2026, 1, 15),
  );
}

// ============================================================================
// HELPER: GENERATE LISTS
// ============================================================================

/// Generate a list of [n] test products with sequential IDs.
///
/// Useful for testing list/grid screens:
/// ```dart
/// final products = createTestProductList(20);
/// when(() => dao.watchAllByStore('test-store-1'))
///     .thenAnswer((_) => Stream.value(products));
/// ```
List<ProductsTableData> createTestProductList(int n, {String storeId = 'test-store-1'}) {
  return List.generate(n, (i) {
    return createTestProduct(
      id: 'prod-${i + 1}',
      storeId: storeId,
      name: '\u0645\u0646\u062a\u062c ${i + 1}', // منتج N
      price: 10.0 + i,
      stockQty: 50 + i,
    );
  });
}

/// Generate a list of [n] test sales with sequential IDs.
List<SalesTableData> createTestSaleList(int n, {String storeId = 'test-store-1'}) {
  return List.generate(n, (i) {
    return createTestSale(
      id: 'sale-${i + 1}',
      storeId: storeId,
      receiptNo: 'POS-20260115-${(i + 1).toString().padLeft(4, '0')}',
      total: 50.0 + (i * 10),
    );
  });
}

/// Generate a list of [n] test categories with sequential IDs.
List<CategoriesTableData> createTestCategoryList(int n, {String storeId = 'test-store-1'}) {
  return List.generate(n, (i) {
    return createTestCategory(
      id: 'cat-${i + 1}',
      storeId: storeId,
      name: '\u062a\u0635\u0646\u064a\u0641 ${i + 1}', // تصنيف N
      sortOrder: i,
    );
  });
}

/// Generate a list of [n] test customers with sequential IDs.
List<CustomersTableData> createTestCustomerList(int n, {String storeId = 'test-store-1'}) {
  return List.generate(n, (i) {
    return createTestCustomer(
      id: 'cust-${i + 1}',
      storeId: storeId,
      name: '\u0639\u0645\u064a\u0644 ${i + 1}', // عميل N
      phone: '050${(1000000 + i).toString()}',
    );
  });
}
