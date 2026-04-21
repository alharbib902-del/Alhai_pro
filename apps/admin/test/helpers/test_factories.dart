/// Test data factories for Admin tests.
///
/// Each factory returns a valid Drift data object with sensible defaults.
/// Override any field via named parameters.
/// Arabic text is used for user-facing strings since the app is Arabic-first.
library;

import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// ORDERS
// ============================================================================

OrdersTableData createTestOrder({
  String id = 'order-1',
  String? orgId,
  String storeId = 'test-store-1',
  String? customerId,
  String orderNumber = 'ORD-20260115-001',
  String channel = 'app',
  String status = 'completed',
  double subtotal = 100.0,
  double taxAmount = 15.0,
  double deliveryFee = 0.0,
  double discount = 0.0,
  double total = 115.0,
  String? paymentMethod = 'cash',
  String paymentStatus = 'paid',
  String deliveryType = 'delivery',
  String? deliveryAddress,
  double? deliveryLat,
  double? deliveryLng,
  String? driverId,
  String? notes,
  String? cancelReason,
  DateTime? orderDate,
  DateTime? confirmedAt,
  DateTime? preparingAt,
  DateTime? readyAt,
  DateTime? deliveringAt,
  DateTime? deliveredAt,
  DateTime? cancelledAt,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? syncedAt,
  int confirmationAttempts = 0,
  bool autoReorderTriggered = false,
}) {
  final now = DateTime(2026, 1, 15, 10, 30);
  return OrdersTableData(
    id: id,
    orgId: orgId,
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
    deliveryLat: deliveryLat,
    deliveryLng: deliveryLng,
    driverId: driverId,
    notes: notes,
    cancelReason: cancelReason,
    orderDate: orderDate ?? now,
    confirmedAt: confirmedAt,
    preparingAt: preparingAt,
    readyAt: readyAt,
    deliveringAt: deliveringAt,
    deliveredAt: deliveredAt,
    cancelledAt: cancelledAt,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
    syncedAt: syncedAt,
    confirmationAttempts: confirmationAttempts,
    autoReorderTriggered: autoReorderTriggered,
  );
}

// ============================================================================
// PRODUCTS
// ============================================================================

ProductsTableData createTestProduct({
  String id = 'prod-1',
  String? orgId,
  String storeId = 'test-store-1',
  String name =
      '\u0645\u0646\u062a\u062c \u062a\u062c\u0631\u064a\u0628\u064a', // منتج تجريبي
  String? sku,
  String? barcode,
  double price = 25.0,
  double? costPrice = 15.0,
  double stockQty = 100,
  double minQty = 5,
  String? unit,
  String? description,
  String? imageThumbnail,
  String? imageMedium,
  String? imageLarge,
  String? imageHash,
  String? categoryId,
  bool isActive = true,
  bool trackInventory = true,
  bool onlineAvailable = false,
  double onlineReservedQty = 0.0,
  bool autoReorder = false,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? syncedAt,
}) {
  return ProductsTableData(
    id: id,
    orgId: orgId,
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
    imageThumbnail: imageThumbnail,
    imageMedium: imageMedium,
    imageLarge: imageLarge,
    imageHash: imageHash,
    categoryId: categoryId,
    isActive: isActive,
    trackInventory: trackInventory,
    onlineAvailable: onlineAvailable,
    onlineReservedQty: onlineReservedQty,
    autoReorder: autoReorder,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
    updatedAt: updatedAt,
    syncedAt: syncedAt,
  );
}

// ============================================================================
// SALES
// ============================================================================

SalesTableData createTestSale({
  String id = 'sale-1',
  String? orgId,
  String receiptNo = 'POS-20260115-0001',
  String storeId = 'test-store-1',
  String cashierId = 'test-user-1',
  String? terminalId,
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
  DateTime? updatedAt,
  DateTime? syncedAt,
}) {
  return SalesTableData(
    id: id,
    orgId: orgId,
    receiptNo: receiptNo,
    storeId: storeId,
    cashierId: cashierId,
    terminalId: terminalId,
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
    updatedAt: updatedAt,
    syncedAt: syncedAt,
  );
}

// ============================================================================
// CUSTOMERS
// ============================================================================

CustomersTableData createTestCustomer({
  String id = 'cust-1',
  String? orgId,
  String storeId = 'test-store-1',
  String name =
      '\u0639\u0645\u064a\u0644 \u062a\u062c\u0631\u064a\u0628\u064a', // عميل تجريبي
  String? phone = '0501234567',
  String? email,
  String? address,
  String? city,
  String? taxNumber,
  String type = 'individual',
  String? notes,
  bool isActive = true,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? syncedAt,
}) {
  return CustomersTableData(
    id: id,
    orgId: orgId,
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
    updatedAt: updatedAt,
    syncedAt: syncedAt,
  );
}

// ============================================================================
// SHIFTS
// ============================================================================

ShiftsTableData createTestShift({
  String id = 'shift-1',
  String? orgId,
  String storeId = 'test-store-1',
  String? terminalId,
  String cashierId = 'test-user-1',
  String cashierName =
      '\u0645\u0648\u0638\u0641 \u062a\u062c\u0631\u064a\u0628\u064a', // موظف تجريبي
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
  DateTime? syncedAt,
}) {
  return ShiftsTableData(
    id: id,
    orgId: orgId,
    storeId: storeId,
    terminalId: terminalId,
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
    syncedAt: syncedAt,
  );
}

// ============================================================================
// CATEGORIES
// ============================================================================

CategoriesTableData createTestCategory({
  String id = 'cat-1',
  String? orgId,
  String storeId = 'test-store-1',
  String name =
      '\u062a\u0635\u0646\u064a\u0641 \u062a\u062c\u0631\u064a\u0628\u064a', // تصنيف تجريبي
  String? nameEn = 'Test Category',
  String? parentId,
  String? imageUrl,
  String? color,
  String? icon,
  int sortOrder = 0,
  bool isActive = true,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? syncedAt,
}) {
  return CategoriesTableData(
    id: id,
    orgId: orgId,
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
    updatedAt: updatedAt,
    syncedAt: syncedAt,
  );
}

// ============================================================================
// DISCOUNTS
// ============================================================================

DiscountsTableData createTestDiscount({
  String id = 'disc-1',
  String? orgId,
  String storeId = 'test-store-1',
  String name =
      '\u062e\u0635\u0645 \u062a\u062c\u0631\u064a\u0628\u064a', // خصم تجريبي
  String? nameEn = 'Test Discount',
  String type = 'percentage',
  // C-4 Stage A: stored as INTEGER (× 100). Default 10% → 1000.
  int value = 1000,
  int minPurchase = 0,
  int? maxDiscount,
  String appliesTo = 'all',
  String? productIds,
  String? categoryIds,
  DateTime? startDate,
  DateTime? endDate,
  bool isActive = true,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? syncedAt,
}) {
  final now = DateTime(2026, 1, 1);
  return DiscountsTableData(
    id: id,
    orgId: orgId,
    storeId: storeId,
    name: name,
    nameEn: nameEn,
    type: type,
    value: value,
    minPurchase: minPurchase,
    maxDiscount: maxDiscount,
    appliesTo: appliesTo,
    productIds: productIds,
    categoryIds: categoryIds,
    startDate: startDate ?? now,
    endDate: endDate ?? now.add(const Duration(days: 30)),
    isActive: isActive,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt,
    syncedAt: syncedAt,
  );
}

// ============================================================================
// COUPONS
// ============================================================================

CouponsTableData createTestCoupon({
  String id = 'coupon-1',
  String? orgId,
  String storeId = 'test-store-1',
  String code = 'TEST10',
  String? discountId,
  String type = 'percentage',
  double value = 10.0,
  int maxUses = 100,
  int currentUses = 0,
  double minPurchase = 0.0,
  bool isActive = true,
  DateTime? expiresAt,
  DateTime? createdAt,
  DateTime? syncedAt,
}) {
  final now = DateTime(2026, 1, 1);
  return CouponsTableData(
    id: id,
    orgId: orgId,
    storeId: storeId,
    code: code,
    discountId: discountId,
    type: type,
    value: value,
    maxUses: maxUses,
    currentUses: currentUses,
    minPurchase: minPurchase,
    isActive: isActive,
    expiresAt: expiresAt ?? now.add(const Duration(days: 30)),
    createdAt: createdAt ?? now,
    syncedAt: syncedAt,
  );
}

// ============================================================================
// SUPPLIERS
// ============================================================================

SuppliersTableData createTestSupplier({
  String id = 'sup-1',
  String? orgId,
  String storeId = 'test-store-1',
  String name =
      '\u0645\u0648\u0631\u062f \u062a\u062c\u0631\u064a\u0628\u064a', // مورد تجريبي
  String? phone = '0501234567',
  String? email,
  String? address,
  String? city,
  String? taxNumber,
  String? paymentTerms,
  int rating = 0,
  double balance = 0.0,
  String? notes,
  bool isActive = true,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? syncedAt,
}) {
  return SuppliersTableData(
    id: id,
    orgId: orgId,
    storeId: storeId,
    name: name,
    phone: phone,
    email: email,
    address: address,
    city: city,
    taxNumber: taxNumber,
    paymentTerms: paymentTerms,
    rating: rating,
    balance: balance,
    notes: notes,
    isActive: isActive,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
    updatedAt: updatedAt,
    syncedAt: syncedAt,
  );
}

// ============================================================================
// PURCHASES
// ============================================================================

PurchasesTableData createTestPurchase({
  String id = 'pur-1',
  String? orgId,
  String storeId = 'test-store-1',
  String? supplierId = 'sup-1',
  String? supplierName =
      '\u0645\u0648\u0631\u062f \u062a\u062c\u0631\u064a\u0628\u064a', // مورد تجريبي
  String purchaseNumber = 'PUR-20260115-001',
  String status = 'received',
  double subtotal = 1000.0,
  double tax = 150.0,
  double discount = 0.0,
  double total = 1150.0,
  String paymentStatus = 'paid',
  String? paymentMethod = 'cash',
  String? notes,
  DateTime? receivedAt,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? syncedAt,
}) {
  return PurchasesTableData(
    id: id,
    orgId: orgId,
    storeId: storeId,
    supplierId: supplierId,
    supplierName: supplierName,
    purchaseNumber: purchaseNumber,
    status: status,
    subtotal: subtotal,
    tax: tax,
    discount: discount,
    total: total,
    paymentStatus: paymentStatus,
    paymentMethod: paymentMethod,
    notes: notes,
    receivedAt: receivedAt,
    createdAt: createdAt ?? DateTime(2026, 1, 15),
    updatedAt: updatedAt,
    syncedAt: syncedAt,
  );
}

// ============================================================================
// RETURNS
// ============================================================================

ReturnsTableData createTestReturn({
  String id = 'ret-1',
  String? orgId,
  String returnNumber = 'RET-20260115-001',
  String saleId = 'sale-1',
  String storeId = 'test-store-1',
  String? customerId,
  String? customerName =
      '\u0639\u0645\u064a\u0644 \u062a\u062c\u0631\u064a\u0628\u064a', // عميل تجريبي
  String? reason =
      '\u0639\u064a\u0628 \u0641\u064a \u0627\u0644\u0645\u0646\u062a\u062c', // عيب في المنتج
  String type = 'full',
  String refundMethod = 'cash',
  double totalRefund = 50.0,
  String status = 'completed',
  String? createdBy,
  String? notes,
  DateTime? createdAt,
  DateTime? syncedAt,
}) {
  return ReturnsTableData(
    id: id,
    orgId: orgId,
    returnNumber: returnNumber,
    saleId: saleId,
    storeId: storeId,
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
    syncedAt: syncedAt,
  );
}

// ============================================================================
// EXPENSES
// ============================================================================

ExpensesTableData createTestExpense({
  String id = 'exp-1',
  String? orgId,
  String storeId = 'test-store-1',
  String? categoryId,
  double amount = 200.0,
  String? description =
      '\u0645\u0635\u0631\u0648\u0641 \u062a\u062c\u0631\u064a\u0628\u064a', // مصروف تجريبي
  String paymentMethod = 'cash',
  String? receiptImage,
  String? createdBy = 'test-user-1',
  DateTime? expenseDate,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? syncedAt,
}) {
  final now = DateTime(2026, 1, 15);
  return ExpensesTableData(
    id: id,
    orgId: orgId,
    storeId: storeId,
    categoryId: categoryId,
    amount: amount,
    description: description,
    paymentMethod: paymentMethod,
    receiptImage: receiptImage,
    createdBy: createdBy,
    expenseDate: expenseDate ?? now,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt,
    syncedAt: syncedAt,
  );
}
