import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:cashier/core/services/audit_service.dart';

import '../helpers/mock_database.dart';

// ---------------------------------------------------------------------------
// AuditService funnels every logging operation through
// AuditLogDao.appendLogWithHashChain so every audit row is part of the
// tamper-evident SHA-256 chain (ZATCA regulatory requirement).
//
// These tests verify each public method invokes the DAO with the expected
// action, entity type, payload fields, and description.
//
// IMPORTANT: mocktail's `verify(...).captured` consumes the recorded call,
// so we can only call it once per test. Tests here capture ALL named args
// in a single verify and read by position in the method-declaration order:
//   0: storeId  1: userId  2: userName  3: action  4: payload
//   5: entityType  6: entityId  7: oldValue  8: description
//   9: ipAddress  10: deviceInfo  11: timestamp
// ---------------------------------------------------------------------------

// Position in the captured list, matching the method's named-parameter
// declaration order (NOT the verify-block order).
const int _iStoreId = 0;
const int _iUserId = 1;
const int _iUserName = 2;
const int _iAction = 3;
const int _iPayload = 4;
const int _iEntityType = 5;
const int _iEntityId = 6;
const int _iOldValue = 7;
const int _iDescription = 8;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAppDatabase db;
  late MockAuditLogDao dao;
  late AuditService service;

  setUpAll(() {
    registerFallbackValue(AuditAction.saleCreate);
  });

  setUp(() {
    dao = MockAuditLogDao();
    db = setupMockDatabase(auditLogDao: dao);
    service = AuditService(db);

    when(
      () => dao.appendLogWithHashChain(
        storeId: any(named: 'storeId'),
        userId: any(named: 'userId'),
        userName: any(named: 'userName'),
        action: any(named: 'action'),
        payload: any(named: 'payload'),
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        oldValue: any(named: 'oldValue'),
        description: any(named: 'description'),
        ipAddress: any(named: 'ipAddress'),
        deviceInfo: any(named: 'deviceInfo'),
        timestamp: any(named: 'timestamp'),
      ),
    ).thenAnswer((_) async => 'mock-audit-id');
  });

  /// Capture every named argument from the most-recent
  /// `appendLogWithHashChain` invocation, in method-declaration order.
  List<dynamic> captureAllArgs() {
    return verify(
      () => dao.appendLogWithHashChain(
        storeId: captureAny(named: 'storeId'),
        userId: captureAny(named: 'userId'),
        userName: captureAny(named: 'userName'),
        action: captureAny(named: 'action'),
        payload: captureAny(named: 'payload'),
        entityType: captureAny(named: 'entityType'),
        entityId: captureAny(named: 'entityId'),
        oldValue: captureAny(named: 'oldValue'),
        description: captureAny(named: 'description'),
        ipAddress: captureAny(named: 'ipAddress'),
        deviceInfo: captureAny(named: 'deviceInfo'),
        timestamp: captureAny(named: 'timestamp'),
      ),
    ).captured;
  }

  // -------------------------------------------------------------------------
  // Sale operations
  // -------------------------------------------------------------------------
  group('sale operations', () {
    test('logSaleCreate delegates to DAO with sale payload', () async {
      await service.logSaleCreate(
        storeId: 'store-1',
        userId: 'u1',
        userName: 'Ahmad',
        saleId: 'sale-123',
        total: 150.0,
        paymentMethod: 'cash',
        receiptNo: 'R-001',
      );

      final c = captureAllArgs();
      expect(c[_iStoreId], equals('store-1'));
      expect(c[_iUserId], equals('u1'));
      expect(c[_iUserName], equals('Ahmad'));
      expect(c[_iAction], equals(AuditAction.saleCreate));
      expect(c[_iEntityType], equals('sale'));
      expect(c[_iEntityId], equals('sale-123'));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['total'], equals(150.0));
      expect(payload['paymentMethod'], equals('cash'));
      expect(payload['receiptNo'], equals('R-001'));
      expect(c[_iDescription] as String, contains('150'));
    });

    test('logSaleCreate omits receiptNo when null', () async {
      await service.logSaleCreate(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        saleId: 'sale-1',
        total: 50,
        paymentMethod: 'card',
      );

      final c = captureAllArgs();
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload.containsKey('receiptNo'), isFalse);
    });

    test('logSaleCancel uses saleCancel action with reason', () async {
      await service.logSaleCancel(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        saleId: 'sale-2',
        total: 80,
        reason: 'customer cancelled',
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.saleCancel));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['reason'], equals('customer cancelled'));
    });

    test('logRefund routes through hash chain with fallback reason', () async {
      await service.logRefund(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        saleId: 'sale-3',
        amount: 40,
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.saleRefund));
      expect(c[_iEntityType], equals('sale'));
      expect(c[_iEntityId], equals('sale-3'));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['amount'], equals(40.0));
      expect(payload['reason'], equals('مرتجع')); // fallback reason
    });

    test('logExchange uses saleRefund action and exchange entity', () async {
      await service.logExchange(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        returnCount: 2,
        newCount: 3,
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.saleRefund));
      expect(c[_iEntityType], equals('exchange'));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['returnItems'], equals(2));
      expect(payload['newItems'], equals(3));
    });
  });

  // -------------------------------------------------------------------------
  // Payment / Transaction operations
  // -------------------------------------------------------------------------
  group('payment operations', () {
    test('logTransaction invoice uses invoice description', () async {
      await service.logTransaction(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        transactionId: 't1',
        accountName: 'أحمد',
        type: 'invoice',
        amount: -100,
        balanceAfter: 100,
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.paymentRecord));
      expect(c[_iEntityType], equals('transaction'));
      expect(c[_iEntityId], equals('t1'));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['type'], equals('invoice'));
      expect(payload['balanceAfter'], equals(100.0));
      expect(payload['accountName'], equals('أحمد'));
      expect(c[_iDescription] as String, contains('دين'));
    });

    test('logTransaction payment uses payment description', () async {
      await service.logTransaction(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        transactionId: 't2',
        accountName: 'محمد',
        type: 'payment',
        amount: 50,
        balanceAfter: 50,
      );

      final c = captureAllArgs();
      expect(c[_iDescription] as String, contains('دفعة'));
    });

  });

  // -------------------------------------------------------------------------
  // Shift operations
  // -------------------------------------------------------------------------
  group('shift operations', () {
    test('logShiftOpen delegates with opening cash', () async {
      await service.logShiftOpen(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        shiftId: 'shift-1',
        openingCash: 500,
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.shiftOpen));
      expect(c[_iEntityType], equals('shift'));
      expect(c[_iEntityId], equals('shift-1'));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['openingCash'], equals(500.0));
    });

    test('logShiftClose records closing cash and difference', () async {
      await service.logShiftClose(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        shiftId: 'shift-1',
        closingCash: 1500,
        expectedCash: 1550,
        difference: -50,
        totalSales: 30,
        totalSalesAmount: 1000,
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.shiftClose));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['closingCash'], equals(1500.0));
      expect(payload['expectedCash'], equals(1550.0));
      expect(payload['difference'], equals(-50.0));
      expect(payload['totalSales'], equals(30));
      expect(payload['totalSalesAmount'], equals(1000.0));
    });

    test('logCashDrawer for cash_in uses deposit description', () async {
      await service.logCashDrawer(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        type: 'cash_in',
        amount: 200,
        reason: 'opening float',
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.cashDrawerOpen));
      expect(c[_iEntityType], equals('cash_movement'));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['type'], equals('cash_in'));
      expect(payload['amount'], equals(200.0));
      expect(payload['reason'], equals('opening float'));
      expect(c[_iDescription] as String, contains('إيداع'));
    });

    test('logCashDrawer for cash_out uses withdrawal description', () async {
      await service.logCashDrawer(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        type: 'cash_out',
        amount: 75,
      );

      final c = captureAllArgs();
      expect(c[_iDescription] as String, contains('سحب'));
    });
  });

  // -------------------------------------------------------------------------
  // Product operations
  // -------------------------------------------------------------------------
  group('product operations', () {
    test('logProductCreate records productId and price', () async {
      await service.logProductCreate(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        productId: 'p1',
        productName: 'Coffee',
        price: 12.5,
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.productCreate));
      expect(c[_iEntityType], equals('product'));
      expect(c[_iEntityId], equals('p1'));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['name'], equals('Coffee'));
      expect(payload['price'], equals(12.5));
    });

    test('logPriceChange routes through hash chain with old+new prices',
        () async {
      await service.logPriceChange(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        productId: 'p1',
        productName: 'Tea',
        oldPrice: 5,
        newPrice: 7,
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.priceChange));
      expect(c[_iEntityType], equals('product'));
      expect(c[_iEntityId], equals('p1'));
      final oldVal = c[_iOldValue] as Map<String, dynamic>;
      expect(oldVal['price'], equals(5.0));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['price'], equals(7.0));
    });
  });

  // -------------------------------------------------------------------------
  // Inventory operations
  // -------------------------------------------------------------------------
  group('inventory operations', () {
    test('logStockAdjust routes through hash chain with old+new qty',
        () async {
      await service.logStockAdjust(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        productId: 'p1',
        productName: 'Milk',
        oldQty: 20,
        newQty: 15,
        reason: 'wastage',
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.stockAdjust));
      expect(c[_iEntityType], equals('product'));
      expect(c[_iEntityId], equals('p1'));
      final oldVal = c[_iOldValue] as Map<String, dynamic>;
      expect(oldVal['quantity'], equals(20.0));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['quantity'], equals(15.0));
      expect(c[_iDescription] as String, contains('wastage'));
    });

    test('logStockReceive records purchase number and item count', () async {
      await service.logStockReceive(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        purchaseId: 'pur-1',
        purchaseNumber: 'PO-100',
        itemCount: 25,
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.stockReceive));
      expect(c[_iEntityType], equals('purchase'));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['purchaseNumber'], equals('PO-100'));
      expect(payload['itemCount'], equals(25));
      expect(c[_iDescription] as String, contains('PO-100'));
    });

    test('logStockReceive omits purchaseNumber when null', () async {
      await service.logStockReceive(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        purchaseId: 'pur-1',
        itemCount: 10,
      );

      final c = captureAllArgs();
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload.containsKey('purchaseNumber'), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Customer operations
  // -------------------------------------------------------------------------
  group('customer operations', () {
    test('logCustomerCreate records customer name', () async {
      await service.logCustomerCreate(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        customerId: 'c1',
        customerName: 'خالد',
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.customerCreate));
      expect(c[_iEntityType], equals('customer'));
      expect(c[_iEntityId], equals('c1'));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['name'], equals('خالد'));
    });

    test('logCustomerEdit merges additional changes map', () async {
      await service.logCustomerEdit(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        customerId: 'c1',
        customerName: 'خالد',
        changes: {'phone': '555', 'address': 'Riyadh'},
      );

      final c = captureAllArgs();
      expect(c[_iAction], equals(AuditAction.customerEdit));
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['name'], equals('خالد'));
      expect(payload['phone'], equals('555'));
      expect(payload['address'], equals('Riyadh'));
    });

    test('logCustomerEdit with null changes does not throw', () async {
      await service.logCustomerEdit(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        customerId: 'c1',
        customerName: 'name',
      );

      final c = captureAllArgs();
      final payload = c[_iPayload] as Map<String, dynamic>;
      expect(payload['name'], equals('name'));
      // Only 'name' key -- no merged changes
      expect(payload.keys.length, equals(1));
    });
  });
}
