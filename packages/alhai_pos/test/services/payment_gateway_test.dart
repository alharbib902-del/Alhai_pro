import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/services/payment/payment_gateway.dart';

void main() {
  group('PaymentMethod enum', () {
    test('cash is not electronic', () {
      expect(PaymentMethod.cash.isElectronic, isFalse);
    });

    test('card methods are electronic', () {
      expect(PaymentMethod.card.isElectronic, isTrue);
      expect(PaymentMethod.mada.isElectronic, isTrue);
      expect(PaymentMethod.visa.isElectronic, isTrue);
    });

    test('mada/visa/mastercard/applePay require terminal', () {
      expect(PaymentMethod.mada.requiresTerminal, isTrue);
      expect(PaymentMethod.visa.requiresTerminal, isTrue);
      expect(PaymentMethod.mastercard.requiresTerminal, isTrue);
      expect(PaymentMethod.applePay.requiresTerminal, isTrue);
    });

    test('cash/stcPay/tamara do not require terminal', () {
      expect(PaymentMethod.cash.requiresTerminal, isFalse);
      expect(PaymentMethod.stcPay.requiresTerminal, isFalse);
      expect(PaymentMethod.tamara.requiresTerminal, isFalse);
    });

    test('tamara and tabby are BNPL', () {
      expect(PaymentMethod.tamara.isBNPL, isTrue);
      expect(PaymentMethod.tabby.isBNPL, isTrue);
    });

    test('other methods are not BNPL', () {
      expect(PaymentMethod.cash.isBNPL, isFalse);
      expect(PaymentMethod.mada.isBNPL, isFalse);
    });

    test('each method has Arabic name and code', () {
      for (final method in PaymentMethod.values) {
        expect(method.arabicName, isNotEmpty);
        expect(method.code, isNotEmpty);
      }
    });
  });

  group('PaymentStatus enum', () {
    test('approved is successful', () {
      expect(PaymentStatus.approved.isSuccessful, isTrue);
    });

    test('other statuses are not successful', () {
      expect(PaymentStatus.pending.isSuccessful, isFalse);
      expect(PaymentStatus.declined.isSuccessful, isFalse);
      expect(PaymentStatus.failed.isSuccessful, isFalse);
    });

    test('final statuses', () {
      expect(PaymentStatus.approved.isFinal, isTrue);
      expect(PaymentStatus.declined.isFinal, isTrue);
      expect(PaymentStatus.failed.isFinal, isTrue);
      expect(PaymentStatus.cancelled.isFinal, isTrue);
      expect(PaymentStatus.refunded.isFinal, isTrue);
    });

    test('non-final statuses', () {
      expect(PaymentStatus.pending.isFinal, isFalse);
      expect(PaymentStatus.processing.isFinal, isFalse);
      expect(PaymentStatus.partiallyRefunded.isFinal, isFalse);
    });
  });

  group('PaymentRequest', () {
    test('should create with required fields', () {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 100.0,
        method: PaymentMethod.cash,
      );

      expect(request.orderId, equals('order-1'));
      expect(request.amount, equals(100.0));
      expect(request.currency, equals('SAR'));
      expect(request.method, equals(PaymentMethod.cash));
    });

    test('toJson should serialize correctly', () {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 50.0,
        method: PaymentMethod.mada,
        customerPhone: '0512345678',
      );

      final json = request.toJson();
      expect(json['order_id'], equals('order-1'));
      expect(json['amount'], equals(50.0));
      expect(json['currency'], equals('SAR'));
      expect(json['method'], equals('mada'));
      expect(json['customer_phone'], equals('0512345678'));
    });
  });

  group('PaymentResult', () {
    test('success factory should create successful result', () {
      final result = PaymentResult.success(
        transactionId: 'tx-123',
        authCode: 'AUTH456',
        referenceNumber: 'REF789',
      );

      expect(result.success, isTrue);
      expect(result.status, equals(PaymentStatus.approved));
      expect(result.transactionId, equals('tx-123'));
      expect(result.authCode, equals('AUTH456'));
      expect(result.referenceNumber, equals('REF789'));
      expect(result.errorType, isNull);
    });

    test('failed factory should create failed result', () {
      final result = PaymentResult.failed(
        errorType: PaymentErrorType.insufficientFunds,
      );

      expect(result.success, isFalse);
      expect(result.status, equals(PaymentStatus.failed));
      expect(result.errorType, equals(PaymentErrorType.insufficientFunds));
      expect(result.errorMessage, isNotEmpty);
    });

    test('failed factory uses errorType arabicMessage as default', () {
      final result = PaymentResult.failed(
        errorType: PaymentErrorType.network,
      );

      expect(result.errorMessage, equals(PaymentErrorType.network.arabicMessage));
    });

    test('failed factory allows custom error message', () {
      final result = PaymentResult.failed(
        errorType: PaymentErrorType.unknown,
        errorMessage: 'Custom error',
      );

      expect(result.errorMessage, equals('Custom error'));
    });

    test('cancelled factory should create cancelled result', () {
      final result = PaymentResult.cancelled();

      expect(result.success, isFalse);
      expect(result.status, equals(PaymentStatus.cancelled));
      expect(result.errorType, equals(PaymentErrorType.cancelled));
    });
  });

  group('RefundRequest', () {
    test('should create with required fields', () {
      const request = RefundRequest(
        originalTransactionId: 'tx-123',
        amount: 50.0,
        reason: 'Defective product',
      );

      expect(request.originalTransactionId, equals('tx-123'));
      expect(request.amount, equals(50.0));
      expect(request.reason, equals('Defective product'));
      expect(request.isPartial, isFalse);
    });

    test('should support partial refund flag', () {
      const request = RefundRequest(
        originalTransactionId: 'tx-123',
        amount: 25.0,
        reason: 'Partial return',
        isPartial: true,
      );

      expect(request.isPartial, isTrue);
    });
  });

  group('CashPaymentGateway', () {
    late CashPaymentGateway gateway;

    setUp(() {
      gateway = CashPaymentGateway();
    });

    test('name should be Arabic', () {
      expect(gateway.name, isNotEmpty);
    });

    test('only supports cash method', () {
      expect(gateway.supportedMethods, contains(PaymentMethod.cash));
      expect(gateway.supportedMethods.length, equals(1));
    });

    test('isAvailable always returns true', () async {
      expect(await gateway.isAvailable(), isTrue);
    });

    test('processPayment always succeeds', () async {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 50.0,
        method: PaymentMethod.cash,
      );

      final result = await gateway.processPayment(request);

      expect(result.success, isTrue);
      expect(result.status, equals(PaymentStatus.approved));
      expect(result.transactionId, startsWith('CASH-'));
      expect(result.referenceNumber, equals('order-1'));
    });

    test('refund always succeeds', () async {
      const request = RefundRequest(
        originalTransactionId: 'CASH-123',
        amount: 50.0,
        reason: 'Return',
      );

      final result = await gateway.refund(request);

      expect(result.success, isTrue);
      expect(result.refundedAmount, equals(50.0));
      expect(result.refundId, startsWith('CASH-REF-'));
    });

    test('checkStatus always returns approved', () async {
      final status = await gateway.checkStatus('any-tx');
      expect(status, equals(PaymentStatus.approved));
    });

    test('cancel always returns true', () async {
      expect(await gateway.cancel('any-tx'), isTrue);
    });
  });

  group('PaymentService', () {
    late PaymentService service;

    setUp(() {
      service = PaymentService();
    });

    test('should have cash gateway registered by default', () {
      expect(service.availableMethods, contains(PaymentMethod.cash));
    });

    test('should process cash payment successfully', () async {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 100.0,
        method: PaymentMethod.cash,
      );

      final result = await service.processPayment(request);

      expect(result.success, isTrue);
      expect(result.status, equals(PaymentStatus.approved));
    });

    test('should reject unavailable electronic payment methods', () async {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 100.0,
        method: PaymentMethod.mada,
      );

      final result = await service.processPayment(request);

      expect(result.success, isFalse);
      expect(result.errorType, equals(PaymentErrorType.terminalError));
    });

    test('isMethodAvailable only returns true for cash', () {
      expect(PaymentService.isMethodAvailable(PaymentMethod.cash), isTrue);
      expect(PaymentService.isMethodAvailable(PaymentMethod.mada), isFalse);
      expect(PaymentService.isMethodAvailable(PaymentMethod.visa), isFalse);
      expect(PaymentService.isMethodAvailable(PaymentMethod.stcPay), isFalse);
      expect(PaymentService.isMethodAvailable(PaymentMethod.tamara), isFalse);
    });

    test('registerGateway adds a new gateway', () {
      final madaGateway = MadaPaymentGateway(
        merchantId: 'test-merchant',
        terminalId: 'test-terminal',
      );

      service.registerGateway(PaymentMethod.mada, madaGateway);

      expect(service.getGateway(PaymentMethod.mada), equals(madaGateway));
      expect(service.availableMethods, contains(PaymentMethod.mada));
    });

    test('refund with no gateway returns failure', () async {
      const request = RefundRequest(
        originalTransactionId: 'tx-1',
        amount: 50.0,
        reason: 'test',
      );

      final result = await service.refund(request, PaymentMethod.mada);

      expect(result.success, isFalse);
      expect(result.errorMessage, isNotEmpty);
    });

    test('refund with cash gateway succeeds', () async {
      const request = RefundRequest(
        originalTransactionId: 'CASH-1',
        amount: 25.0,
        reason: 'Return item',
      );

      final result = await service.refund(request, PaymentMethod.cash);

      expect(result.success, isTrue);
      expect(result.refundedAmount, equals(25.0));
    });
  });

  group('MadaPaymentGateway', () {
    late MadaPaymentGateway gateway;

    setUp(() {
      gateway = MadaPaymentGateway(
        merchantId: 'test-merchant',
        terminalId: 'test-terminal',
        isTestMode: true,
      );
    });

    test('name should be set', () {
      expect(gateway.name, isNotEmpty);
    });

    test('supports multiple card methods', () {
      expect(gateway.supportedMethods, contains(PaymentMethod.mada));
      expect(gateway.supportedMethods, contains(PaymentMethod.visa));
      expect(gateway.supportedMethods, contains(PaymentMethod.mastercard));
      expect(gateway.supportedMethods, contains(PaymentMethod.applePay));
    });
  });

  group('StcPayGateway', () {
    late StcPayGateway gateway;

    setUp(() {
      gateway = StcPayGateway(
        merchantId: 'test',
        apiKey: 'test-key',
        isTestMode: true,
      );
    });

    test('only supports STC Pay', () {
      expect(gateway.supportedMethods, contains(PaymentMethod.stcPay));
      expect(gateway.supportedMethods.length, equals(1));
    });
  });

  group('TamaraGateway', () {
    late TamaraGateway gateway;

    setUp(() {
      gateway = TamaraGateway(
        apiToken: 'test-token',
        merchantUrl: 'https://test.com',
        isTestMode: true,
      );
    });

    test('only supports Tamara', () {
      expect(gateway.supportedMethods, contains(PaymentMethod.tamara));
      expect(gateway.supportedMethods.length, equals(1));
    });

    test('has min and max order amounts', () {
      expect(gateway.minOrderAmount, equals(100.0));
      expect(gateway.maxOrderAmount, equals(5000.0));
    });
  });
}
