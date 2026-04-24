import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_sync/src/validators/pre_sync_validator.dart';

import '../../helpers/sync_test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late PreSyncValidator validator;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockDb = MockAppDatabase();
    validator = PreSyncValidator(mockDb);
  });

  // ==========================================================================
  // sales
  // ==========================================================================
  group('sales', () {
    test('valid sale passes', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sales',
        operation: 'create',
        data: {
          'id': 'sale-1',
          'storeId': 'store-1',
          'subtotal': 10000,
          'discount': 500,
          'tax': 1425,
          'total': 10925,
          'cashAmount': 10925,
        },
      ));
      expect(result.isValid, isTrue, reason: result.errors.toString());
    });

    test('invalid total arithmetic is caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sales',
        operation: 'create',
        data: {
          'id': 'sale-2',
          'storeId': 'store-1',
          'subtotal': 10000,
          'discount': 0,
          'tax': 1500,
          'total': 99999, // wrong
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('sale.total.arithmetic'),
      );
    });

    test('rounding within ±1 cent is tolerated', () async {
      // Floating-point drift: subtotal-discount+tax = 10924.5 vs total=10925
      final result = await validator.validate(SyncPayload(
        table: 'sales',
        operation: 'create',
        data: {
          'id': 'sale-3',
          'storeId': 'store-1',
          'subtotal': 9999,
          'discount': 0,
          'tax': 1425.5,
          'total': 11425,
        },
      ));
      expect(result.isValid, isTrue, reason: result.errors.toString());
    });

    test('missing storeId is caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sales',
        operation: 'create',
        data: {
          'id': 'sale-4',
          'subtotal': 1000,
          'tax': 150,
          'total': 1150,
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('sale.storeId.required'),
      );
    });

    test('total must be > 0', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sales',
        operation: 'create',
        data: {
          'id': 'sale-5',
          'storeId': 'store-1',
          'subtotal': 0,
          'tax': 0,
          'total': 0,
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('sale.total.positive'),
      );
    });

    test('underpaid sale (payments < total) is caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sales',
        operation: 'create',
        data: {
          'id': 'sale-6',
          'storeId': 'store-1',
          'subtotal': 10000,
          'discount': 0,
          'tax': 0,
          'total': 10000,
          'cashAmount': 5000,
          'cardAmount': 0,
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('sale.payments.coverage'),
      );
    });
  });

  // ==========================================================================
  // sale_items
  // ==========================================================================
  group('sale_items', () {
    test('valid sale_item passes', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sale_items',
        operation: 'create',
        data: {
          'id': 'si-1',
          'productId': 'p-1',
          'qty': 2,
          'unitPrice': 500,
          'subtotal': 1000,
        },
      ));
      expect(result.isValid, isTrue, reason: result.errors.toString());
    });

    test('negative qty is caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sale_items',
        operation: 'create',
        data: {
          'id': 'si-2',
          'productId': 'p-1',
          'qty': -1,
          'unitPrice': 500,
          'subtotal': -500,
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('sale_item.qty.positive'),
      );
    });

    test('zero unitPrice edge case (0 is allowed — free sample)', () async {
      // unitPrice == 0 is legit for free samples. Only NEGATIVE unitPrice
      // should be rejected. subtotal 0 = qty 1 * 0 so arithmetic holds.
      final result = await validator.validate(SyncPayload(
        table: 'sale_items',
        operation: 'create',
        data: {
          'id': 'si-3',
          'productId': 'p-1',
          'qty': 1,
          'unitPrice': 0,
          'subtotal': 0,
        },
      ));
      expect(result.isValid, isTrue, reason: result.errors.toString());
    });

    test('subtotal arithmetic mismatch is caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sale_items',
        operation: 'create',
        data: {
          'id': 'si-4',
          'productId': 'p-1',
          'qty': 2,
          'unitPrice': 500,
          'subtotal': 950, // 2*500 = 1000, diff 50 > 1 margin
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('sale_item.subtotal.arithmetic'),
      );
    });

    test('missing productId caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sale_items',
        operation: 'create',
        data: {
          'id': 'si-5',
          'qty': 1,
          'unitPrice': 500,
          'subtotal': 500,
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('sale_item.productId.required'),
      );
    });
  });

  // ==========================================================================
  // invoices (ZATCA P0 gate)
  // ==========================================================================
  group('invoices', () {
    test('valid invoice passes', () async {
      final result = await validator.validate(SyncPayload(
        table: 'invoices',
        operation: 'create',
        data: {
          'id': 'inv-1',
          'zatcaQr': 'base64qrstring==',
          'zatcaUuid': 'uuid-123',
          'subtotal': 10000,
          'discount': 0,
          'taxAmount': 1500,
          'total': 11500,
          'amountPaid': 11500,
          'amountDue': 0,
        },
      ));
      expect(result.isValid, isTrue, reason: result.errors.toString());
    });

    test('missing ZATCA QR is caught (P0 compliance gate)', () async {
      final result = await validator.validate(SyncPayload(
        table: 'invoices',
        operation: 'create',
        data: {
          'id': 'inv-2',
          'zatcaUuid': 'uuid-123',
          'subtotal': 10000,
          'taxAmount': 1500,
          'total': 11500,
          'amountPaid': 11500,
          'amountDue': 0,
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('invoice.zatcaQr.required'),
      );
    });

    test('empty zatcaQr string is caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'invoices',
        operation: 'create',
        data: {
          'id': 'inv-3',
          'zatcaQr': '',
          'zatcaUuid': 'uuid-123',
          'subtotal': 10000,
          'taxAmount': 1500,
          'total': 11500,
          'amountPaid': 11500,
          'amountDue': 0,
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('invoice.zatcaQr.required'),
      );
    });

    test('invoice total=0 caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'invoices',
        operation: 'create',
        data: {
          'id': 'inv-4',
          'zatcaQr': 'qrcode',
          'zatcaUuid': 'uuid',
          'subtotal': 0,
          'taxAmount': 0,
          'total': 0,
          'amountPaid': 0,
          'amountDue': 0,
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('invoice.total.positive'),
      );
    });

    test('invoice total arithmetic mismatch caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'invoices',
        operation: 'create',
        data: {
          'id': 'inv-5',
          'zatcaQr': 'qrcode',
          'zatcaUuid': 'uuid',
          'subtotal': 10000,
          'discount': 0,
          'taxAmount': 1500,
          'total': 99999,
          'amountPaid': 99999,
          'amountDue': 0,
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('invoice.total.arithmetic'),
      );
    });

    test('invoice paid + due != total caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'invoices',
        operation: 'create',
        data: {
          'id': 'inv-6',
          'zatcaQr': 'qrcode',
          'zatcaUuid': 'uuid',
          'subtotal': 10000,
          'taxAmount': 1500,
          'total': 11500,
          'amountPaid': 5000,
          'amountDue': 5000,
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('invoice.payments.balance'),
      );
    });
  });

  // ==========================================================================
  // transactions
  // ==========================================================================
  group('transactions', () {
    test('valid transaction passes', () async {
      final result = await validator.validate(SyncPayload(
        table: 'transactions',
        operation: 'create',
        data: {
          'id': 't-1',
          'accountId': 'acc-1',
          'amount': 500,
          'type': 'payment',
        },
      ));
      expect(result.isValid, isTrue, reason: result.errors.toString());
    });

    test('zero amount is caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'transactions',
        operation: 'create',
        data: {
          'id': 't-2',
          'accountId': 'acc-1',
          'amount': 0,
          'type': 'payment',
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('transaction.amount.nonZero'),
      );
    });

    test('invalid transaction type is caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'transactions',
        operation: 'create',
        data: {
          'id': 't-3',
          'accountId': 'acc-1',
          'amount': 100,
          'type': 'bogus_type',
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('transaction.type.enum'),
      );
    });

    test('refund amount (negative) is accepted', () async {
      final result = await validator.validate(SyncPayload(
        table: 'transactions',
        operation: 'create',
        data: {
          'id': 't-4',
          'accountId': 'acc-1',
          'amount': -500,
          'type': 'refund',
        },
      ));
      expect(result.isValid, isTrue, reason: result.errors.toString());
    });
  });

  // ==========================================================================
  // returns
  // ==========================================================================
  group('returns', () {
    test('valid return passes', () async {
      final result = await validator.validate(SyncPayload(
        table: 'returns',
        operation: 'create',
        data: {
          'id': 'r-1',
          'saleId': 's-1',
          'totalRefund': 1000,
          'reason': 'defect',
        },
      ));
      expect(result.isValid, isTrue, reason: result.errors.toString());
    });

    test('totalRefund <= 0 is caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'returns',
        operation: 'create',
        data: {
          'id': 'r-2',
          'saleId': 's-1',
          'totalRefund': 0,
          'reason': 'defect',
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('return.totalRefund.positive'),
      );
    });

    test('missing saleId caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'returns',
        operation: 'create',
        data: {
          'id': 'r-3',
          'totalRefund': 1000,
          'reason': 'defect',
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('return.saleId.required'),
      );
    });
  });

  // ==========================================================================
  // stock_deltas
  // ==========================================================================
  group('stock_deltas', () {
    test('valid stock_delta passes', () async {
      final result = await validator.validate(SyncPayload(
        table: 'stock_deltas',
        operation: 'create',
        data: {
          'id': 'sd-1',
          'productId': 'p-1',
          'deviceId': 'd-1',
          'quantityChange': -3,
          'operationType': 'sale',
        },
      ));
      expect(result.isValid, isTrue, reason: result.errors.toString());
    });

    test('quantityChange = 0 is caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'stock_deltas',
        operation: 'create',
        data: {
          'id': 'sd-2',
          'productId': 'p-1',
          'deviceId': 'd-1',
          'quantityChange': 0,
          'operationType': 'sale',
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('stock_delta.quantityChange.nonZero'),
      );
    });

    test('invalid operationType caught', () async {
      final result = await validator.validate(SyncPayload(
        table: 'stock_deltas',
        operation: 'create',
        data: {
          'id': 'sd-3',
          'productId': 'p-1',
          'deviceId': 'd-1',
          'quantityChange': -1,
          'operationType': 'magical_unicorn',
        },
      ));
      expect(result.hasErrors, isTrue);
      expect(
        result.errors.map((e) => e.rule),
        contains('stock_delta.operationType.enum'),
      );
    });
  });

  // ==========================================================================
  // meta — operation routing
  // ==========================================================================
  group('operation routing', () {
    test('update operations skip validation (partial payloads OK)', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sales',
        operation: 'update',
        data: {'id': 'sale-1', 'note': 'changed'},
      ));
      expect(result.isValid, isTrue);
    });

    test('delete operations skip validation', () async {
      final result = await validator.validate(SyncPayload(
        table: 'invoices',
        operation: 'delete',
        data: {'id': 'inv-1', 'deleted': true},
      ));
      expect(result.isValid, isTrue);
    });

    test('unknown table yields no errors (no rules defined)', () async {
      final result = await validator.validate(SyncPayload(
        table: 'products',
        operation: 'create',
        data: {'id': 'p-1', 'name': 'Widget'},
      ));
      expect(result.isValid, isTrue);
    });

    test('ValidationError.toJson produces expected shape', () async {
      final result = await validator.validate(SyncPayload(
        table: 'sales',
        operation: 'create',
        data: {'id': 'sale-broken', 'total': 0}, // total=0 + no storeId
      ));
      expect(result.hasErrors, isTrue);
      final json = result.errors.first.toJson();
      expect(json.containsKey('rule'), isTrue);
      expect(json.containsKey('message'), isTrue);
    });
  });
}
