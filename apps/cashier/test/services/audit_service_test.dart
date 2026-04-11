import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:cashier/core/services/audit_service.dart';

import '../helpers/mock_database.dart';

// ---------------------------------------------------------------------------
// AuditService delegates all logging operations to AuditLogDao. We verify
// that each public method calls the DAO with the expected arguments
// (action, entity type, payload fields, description) using a mock.
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAppDatabase db;
  late MockAuditLogDao dao;
  late AuditService service;

  setUpAll(() {
    // Register fallbacks for mocktail argument matchers that use enums / maps.
    registerFallbackValue(AuditAction.saleCreate);
  });

  setUp(() {
    dao = MockAuditLogDao();
    db = setupMockDatabase(auditLogDao: dao);
    service = AuditService(db);

    // The DAO `log` returns an int (row id) and `logRefund`, `logPriceChange`,
    // `logStockAdjust` also return int.
    when(
      () => dao.log(
        storeId: any(named: 'storeId'),
        userId: any(named: 'userId'),
        userName: any(named: 'userName'),
        action: any(named: 'action'),
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        oldValue: any(named: 'oldValue'),
        newValue: any(named: 'newValue'),
        description: any(named: 'description'),
        ipAddress: any(named: 'ipAddress'),
        deviceInfo: any(named: 'deviceInfo'),
      ),
    ).thenAnswer((_) async => 1);

    when(
      () => dao.logRefund(
        storeId: any(named: 'storeId'),
        userId: any(named: 'userId'),
        userName: any(named: 'userName'),
        saleId: any(named: 'saleId'),
        amount: any(named: 'amount'),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async => 1);

    when(
      () => dao.logPriceChange(
        storeId: any(named: 'storeId'),
        userId: any(named: 'userId'),
        userName: any(named: 'userName'),
        productId: any(named: 'productId'),
        productName: any(named: 'productName'),
        oldPrice: any(named: 'oldPrice'),
        newPrice: any(named: 'newPrice'),
      ),
    ).thenAnswer((_) async => 1);

    when(
      () => dao.logStockAdjust(
        storeId: any(named: 'storeId'),
        userId: any(named: 'userId'),
        userName: any(named: 'userName'),
        productId: any(named: 'productId'),
        productName: any(named: 'productName'),
        oldQty: any(named: 'oldQty'),
        newQty: any(named: 'newQty'),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async => 1);
  });

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

      final captured = verify(
        () => dao.log(
          storeId: captureAny(named: 'storeId'),
          userId: captureAny(named: 'userId'),
          userName: captureAny(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: captureAny(named: 'entityType'),
          entityId: captureAny(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: captureAny(named: 'description'),
        ),
      ).captured;

      expect(captured[0], equals('store-1'));
      expect(captured[1], equals('u1'));
      expect(captured[2], equals('Ahmad'));
      expect(captured[3], equals(AuditAction.saleCreate));
      expect(captured[4], equals('sale'));
      expect(captured[5], equals('sale-123'));
      final newVal = captured[6] as Map<String, dynamic>;
      expect(newVal['total'], equals(150.0));
      expect(newVal['paymentMethod'], equals('cash'));
      expect(newVal['receiptNo'], equals('R-001'));
      expect(captured[7] as String, contains('150'));
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;
      final newVal = captured.first as Map<String, dynamic>;
      expect(newVal.containsKey('receiptNo'), isFalse);
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;
      expect(captured[0], equals(AuditAction.saleCancel));
      final newVal = captured[1] as Map<String, dynamic>;
      expect(newVal['reason'], equals('customer cancelled'));
    });

    test('logRefund delegates to dao.logRefund with fallback reason', () async {
      await service.logRefund(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        saleId: 'sale-3',
        amount: 40,
      );

      final captured = verify(
        () => dao.logRefund(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          saleId: captureAny(named: 'saleId'),
          amount: captureAny(named: 'amount'),
          reason: captureAny(named: 'reason'),
        ),
      ).captured;
      expect(captured[0], equals('sale-3'));
      expect(captured[1], equals(40.0));
      expect(captured[2], equals('مرتجع')); // fallback reason
    });

    test('logExchange uses saleRefund action and exchange entity', () async {
      await service.logExchange(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        returnCount: 2,
        newCount: 3,
      );

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: captureAny(named: 'entityType'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;

      expect(captured[0], equals(AuditAction.saleRefund));
      expect(captured[1], equals('exchange'));
      final newVal = captured[2] as Map<String, dynamic>;
      expect(newVal['returnItems'], equals(2));
      expect(newVal['newItems'], equals(3));
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: captureAny(named: 'entityType'),
          entityId: captureAny(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: captureAny(named: 'description'),
        ),
      ).captured;

      expect(captured[0], equals(AuditAction.paymentRecord));
      expect(captured[1], equals('transaction'));
      expect(captured[2], equals('t1'));
      final newVal = captured[3] as Map<String, dynamic>;
      expect(newVal['type'], equals('invoice'));
      expect(newVal['balanceAfter'], equals(100.0));
      expect(newVal['accountName'], equals('أحمد'));
      expect(captured[4] as String, contains('دين'));
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          newValue: any(named: 'newValue'),
          description: captureAny(named: 'description'),
        ),
      ).captured;
      expect(captured.first as String, contains('دفعة'));
    });

    test('logInterestApply captures rate and total', () async {
      await service.logInterestApply(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        accountCount: 4,
        rate: 2.5,
        totalInterest: 125,
      );

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: any(named: 'entityType'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;

      expect(captured[0], equals(AuditAction.interestApply));
      final newVal = captured[1] as Map<String, dynamic>;
      expect(newVal['accountCount'], equals(4));
      expect(newVal['rate'], equals(2.5));
      expect(newVal['totalInterest'], equals(125.0));
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: captureAny(named: 'entityType'),
          entityId: captureAny(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;

      expect(captured[0], equals(AuditAction.shiftOpen));
      expect(captured[1], equals('shift'));
      expect(captured[2], equals('shift-1'));
      final newVal = captured[3] as Map<String, dynamic>;
      expect(newVal['openingCash'], equals(500.0));
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;

      expect(captured[0], equals(AuditAction.shiftClose));
      final newVal = captured[1] as Map<String, dynamic>;
      expect(newVal['closingCash'], equals(1500.0));
      expect(newVal['expectedCash'], equals(1550.0));
      expect(newVal['difference'], equals(-50.0));
      expect(newVal['totalSales'], equals(30));
      expect(newVal['totalSalesAmount'], equals(1000.0));
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: captureAny(named: 'entityType'),
          newValue: captureAny(named: 'newValue'),
          description: captureAny(named: 'description'),
        ),
      ).captured;

      expect(captured[0], equals(AuditAction.cashDrawerOpen));
      expect(captured[1], equals('cash_movement'));
      final newVal = captured[2] as Map<String, dynamic>;
      expect(newVal['type'], equals('cash_in'));
      expect(newVal['amount'], equals(200.0));
      expect(newVal['reason'], equals('opening float'));
      expect(captured[3] as String, contains('إيداع'));
    });

    test('logCashDrawer for cash_out uses withdrawal description', () async {
      await service.logCashDrawer(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        type: 'cash_out',
        amount: 75,
      );

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          newValue: any(named: 'newValue'),
          description: captureAny(named: 'description'),
        ),
      ).captured;
      expect(captured.first as String, contains('سحب'));
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: captureAny(named: 'entityType'),
          entityId: captureAny(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;
      expect(captured[0], equals(AuditAction.productCreate));
      expect(captured[1], equals('product'));
      expect(captured[2], equals('p1'));
      final newVal = captured[3] as Map<String, dynamic>;
      expect(newVal['name'], equals('Coffee'));
      expect(newVal['price'], equals(12.5));
    });

    test('logPriceChange delegates to dao.logPriceChange', () async {
      await service.logPriceChange(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        productId: 'p1',
        productName: 'Tea',
        oldPrice: 5,
        newPrice: 7,
      );

      verify(
        () => dao.logPriceChange(
          storeId: 's',
          userId: 'u',
          userName: 'n',
          productId: 'p1',
          productName: 'Tea',
          oldPrice: 5,
          newPrice: 7,
        ),
      ).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // Inventory operations
  // -------------------------------------------------------------------------
  group('inventory operations', () {
    test('logStockAdjust delegates to dao.logStockAdjust', () async {
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

      verify(
        () => dao.logStockAdjust(
          storeId: 's',
          userId: 'u',
          userName: 'n',
          productId: 'p1',
          productName: 'Milk',
          oldQty: 20,
          newQty: 15,
          reason: 'wastage',
        ),
      ).called(1);
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: captureAny(named: 'entityType'),
          entityId: any(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: captureAny(named: 'description'),
        ),
      ).captured;
      expect(captured[0], equals(AuditAction.stockReceive));
      expect(captured[1], equals('purchase'));
      final newVal = captured[2] as Map<String, dynamic>;
      expect(newVal['purchaseNumber'], equals('PO-100'));
      expect(newVal['itemCount'], equals(25));
      expect(captured[3] as String, contains('PO-100'));
    });

    test('logStockReceive omits purchaseNumber when null', () async {
      await service.logStockReceive(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        purchaseId: 'pur-1',
        itemCount: 10,
      );

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;
      final newVal = captured.first as Map<String, dynamic>;
      expect(newVal.containsKey('purchaseNumber'), isFalse);
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: captureAny(named: 'entityType'),
          entityId: captureAny(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;
      expect(captured[0], equals(AuditAction.customerCreate));
      expect(captured[1], equals('customer'));
      expect(captured[2], equals('c1'));
      final newVal = captured[3] as Map<String, dynamic>;
      expect(newVal['name'], equals('خالد'));
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

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: captureAny(named: 'action'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;
      expect(captured[0], equals(AuditAction.customerEdit));
      final newVal = captured[1] as Map<String, dynamic>;
      expect(newVal['name'], equals('خالد'));
      expect(newVal['phone'], equals('555'));
      expect(newVal['address'], equals('Riyadh'));
    });

    test('logCustomerEdit with null changes does not throw', () async {
      await service.logCustomerEdit(
        storeId: 's',
        userId: 'u',
        userName: 'n',
        customerId: 'c1',
        customerName: 'name',
      );

      final captured = verify(
        () => dao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          newValue: captureAny(named: 'newValue'),
          description: any(named: 'description'),
        ),
      ).captured;
      final newVal = captured.first as Map<String, dynamic>;
      expect(newVal['name'], equals('name'));
      // Only 'name' key -- no merged changes
      expect(newVal.keys.length, equals(1));
    });
  });
}
