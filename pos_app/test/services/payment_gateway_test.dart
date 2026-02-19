import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/payment/payment_gateway.dart';

void main() {
  group('PaymentMethod', () {
    test('has correct arabic names', () {
      expect(PaymentMethod.cash.arabicName, 'نقدي');
      expect(PaymentMethod.mada.arabicName, 'مدى');
      expect(PaymentMethod.visa.arabicName, 'فيزا');
      expect(PaymentMethod.mastercard.arabicName, 'ماستركارد');
      expect(PaymentMethod.applePay.arabicName, 'Apple Pay');
      expect(PaymentMethod.stcPay.arabicName, 'STC Pay');
      expect(PaymentMethod.tamara.arabicName, 'تمارا');
      expect(PaymentMethod.tabby.arabicName, 'تابي');
    });

    test('has correct codes', () {
      expect(PaymentMethod.cash.code, 'cash');
      expect(PaymentMethod.mada.code, 'mada');
      expect(PaymentMethod.visa.code, 'visa');
      expect(PaymentMethod.stcPay.code, 'stc_pay');
    });

    test('isElectronic returns correctly', () {
      expect(PaymentMethod.cash.isElectronic, false);
      expect(PaymentMethod.mada.isElectronic, true);
      expect(PaymentMethod.visa.isElectronic, true);
      expect(PaymentMethod.stcPay.isElectronic, true);
    });

    test('requiresTerminal returns correctly', () {
      expect(PaymentMethod.cash.requiresTerminal, false);
      expect(PaymentMethod.mada.requiresTerminal, true);
      expect(PaymentMethod.visa.requiresTerminal, true);
      expect(PaymentMethod.applePay.requiresTerminal, true);
      expect(PaymentMethod.stcPay.requiresTerminal, false);
    });

    test('isBNPL returns correctly', () {
      expect(PaymentMethod.cash.isBNPL, false);
      expect(PaymentMethod.mada.isBNPL, false);
      expect(PaymentMethod.tamara.isBNPL, true);
      expect(PaymentMethod.tabby.isBNPL, true);
    });
  });

  group('PaymentStatus', () {
    test('has correct arabic names', () {
      expect(PaymentStatus.pending.arabicName, 'قيد الانتظار');
      expect(PaymentStatus.processing.arabicName, 'جاري المعالجة');
      expect(PaymentStatus.approved.arabicName, 'مقبول');
      expect(PaymentStatus.declined.arabicName, 'مرفوض');
      expect(PaymentStatus.failed.arabicName, 'فشل');
      expect(PaymentStatus.cancelled.arabicName, 'ملغي');
      expect(PaymentStatus.refunded.arabicName, 'مسترجع');
    });

    test('isSuccessful returns correctly', () {
      expect(PaymentStatus.approved.isSuccessful, true);
      expect(PaymentStatus.pending.isSuccessful, false);
      expect(PaymentStatus.declined.isSuccessful, false);
      expect(PaymentStatus.failed.isSuccessful, false);
    });

    test('isFinal returns correctly', () {
      expect(PaymentStatus.pending.isFinal, false);
      expect(PaymentStatus.processing.isFinal, false);
      expect(PaymentStatus.approved.isFinal, true);
      expect(PaymentStatus.declined.isFinal, true);
      expect(PaymentStatus.failed.isFinal, true);
      expect(PaymentStatus.cancelled.isFinal, true);
      expect(PaymentStatus.refunded.isFinal, true);
    });
  });

  group('PaymentErrorType', () {
    test('has correct arabic messages', () {
      expect(PaymentErrorType.network.arabicMessage, 'خطأ في الاتصال');
      expect(PaymentErrorType.timeout.arabicMessage, 'انتهت المهلة');
      expect(PaymentErrorType.declined.arabicMessage, 'مرفوض من البنك');
      expect(PaymentErrorType.insufficientFunds.arabicMessage, 'رصيد غير كافٍ');
      expect(PaymentErrorType.invalidCard.arabicMessage, 'بطاقة غير صالحة');
      expect(PaymentErrorType.expiredCard.arabicMessage, 'بطاقة منتهية');
    });
  });

  group('PaymentRequest', () {
    test('creates correctly', () {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 100.0,
        method: PaymentMethod.mada,
        customerPhone: '+966501234567',
      );

      expect(request.orderId, 'order-123');
      expect(request.amount, 100.0);
      expect(request.currency, 'SAR');
      expect(request.method, PaymentMethod.mada);
      expect(request.customerPhone, '+966501234567');
    });

    test('toJson serializes correctly', () {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 100.0,
        method: PaymentMethod.cash,
      );

      final json = request.toJson();

      expect(json['order_id'], 'order-123');
      expect(json['amount'], 100.0);
      expect(json['currency'], 'SAR');
      expect(json['method'], 'cash');
    });
  });

  group('PaymentResult', () {
    test('success factory creates correct result', () {
      final result = PaymentResult.success(
        transactionId: 'txn-123',
        authCode: '123456',
        referenceNumber: 'ref-001',
      );

      expect(result.success, true);
      expect(result.status, PaymentStatus.approved);
      expect(result.transactionId, 'txn-123');
      expect(result.authCode, '123456');
      expect(result.errorType, null);
    });

    test('failed factory creates correct result', () {
      final result = PaymentResult.failed(
        errorType: PaymentErrorType.declined,
        errorMessage: 'Card declined',
      );

      expect(result.success, false);
      expect(result.status, PaymentStatus.failed);
      expect(result.errorType, PaymentErrorType.declined);
      expect(result.errorMessage, 'Card declined');
    });

    test('cancelled factory creates correct result', () {
      final result = PaymentResult.cancelled();

      expect(result.success, false);
      expect(result.status, PaymentStatus.cancelled);
      expect(result.errorType, PaymentErrorType.cancelled);
    });
  });

  group('RefundRequest', () {
    test('creates correctly', () {
      const request = RefundRequest(
        originalTransactionId: 'txn-123',
        amount: 50.0,
        reason: 'Customer request',
        isPartial: true,
      );

      expect(request.originalTransactionId, 'txn-123');
      expect(request.amount, 50.0);
      expect(request.reason, 'Customer request');
      expect(request.isPartial, true);
    });
  });

  group('CashPaymentGateway', () {
    late CashPaymentGateway gateway;

    setUp(() {
      gateway = CashPaymentGateway();
    });

    test('has correct properties', () {
      expect(gateway.name, 'نقدي');
      expect(gateway.supportedMethods, [PaymentMethod.cash]);
    });

    test('isAvailable always returns true', () async {
      final result = await gateway.isAvailable();
      expect(result, true);
    });

    test('processPayment always succeeds', () async {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 100.0,
        method: PaymentMethod.cash,
      );

      final result = await gateway.processPayment(request);

      expect(result.success, true);
      expect(result.status, PaymentStatus.approved);
      expect(result.transactionId, startsWith('CASH-'));
      expect(result.referenceNumber, 'order-123');
    });

    test('refund always succeeds', () async {
      const request = RefundRequest(
        originalTransactionId: 'CASH-123',
        amount: 50.0,
        reason: 'Return',
      );

      final result = await gateway.refund(request);

      expect(result.success, true);
      expect(result.refundId, startsWith('CASH-REF-'));
      expect(result.refundedAmount, 50.0);
    });

    test('checkStatus returns approved', () async {
      final status = await gateway.checkStatus('CASH-123');
      expect(status, PaymentStatus.approved);
    });

    test('cancel returns true', () async {
      final result = await gateway.cancel('CASH-123');
      expect(result, true);
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

    test('has correct properties', () {
      expect(gateway.name, 'مدى');
      expect(gateway.supportedMethods, contains(PaymentMethod.mada));
      expect(gateway.supportedMethods, contains(PaymentMethod.visa));
      expect(gateway.supportedMethods, contains(PaymentMethod.mastercard));
      expect(gateway.supportedMethods, contains(PaymentMethod.applePay));
    });

    test('isAvailable returns true', () async {
      final result = await gateway.isAvailable();
      expect(result, true);
    });

    test('processPayment succeeds in test mode', () async {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 100.0,
        method: PaymentMethod.mada,
      );

      final result = await gateway.processPayment(request);

      expect(result.success, true);
      expect(result.transactionId, startsWith('MADA-'));
      expect(result.authCode, '123456');
    }, timeout: const Timeout(Duration(seconds: 10)));
  });

  group('StcPayGateway', () {
    late StcPayGateway gateway;

    setUp(() {
      gateway = StcPayGateway(
        merchantId: 'test-merchant',
        apiKey: 'test-key',
        isTestMode: true,
      );
    });

    test('has correct properties', () {
      expect(gateway.name, 'STC Pay');
      expect(gateway.supportedMethods, [PaymentMethod.stcPay]);
    });

    test('fails without phone number', () async {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 100.0,
        method: PaymentMethod.stcPay,
        // No phone number
      );

      final result = await gateway.processPayment(request);

      expect(result.success, false);
      expect(result.errorType, PaymentErrorType.authenticationFailed);
      expect(result.errorMessage, contains('رقم الجوال'));
    });

    test('succeeds with phone number in test mode', () async {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 100.0,
        method: PaymentMethod.stcPay,
        customerPhone: '+966501234567',
      );

      final result = await gateway.processPayment(request);

      expect(result.success, true);
      expect(result.transactionId, startsWith('STC-'));
    }, timeout: const Timeout(Duration(seconds: 10)));
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

    test('has correct properties', () {
      expect(gateway.name, 'تمارا');
      expect(gateway.supportedMethods, [PaymentMethod.tamara]);
      expect(gateway.minOrderAmount, 100);
      expect(gateway.maxOrderAmount, 5000);
    });

    test('fails when amount below minimum', () async {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 50.0, // Below 100
        method: PaymentMethod.tamara,
        customerPhone: '+966501234567',
      );

      final result = await gateway.processPayment(request);

      expect(result.success, false);
      expect(result.errorMessage, contains('الحد الأدنى'));
    });

    test('fails when amount above maximum', () async {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 6000.0, // Above 5000
        method: PaymentMethod.tamara,
        customerPhone: '+966501234567',
      );

      final result = await gateway.processPayment(request);

      expect(result.success, false);
      expect(result.errorMessage, contains('الحد الأقصى'));
    });

    test('fails without phone number', () async {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 500.0,
        method: PaymentMethod.tamara,
        // No phone
      );

      final result = await gateway.processPayment(request);

      expect(result.success, false);
      expect(result.errorMessage, contains('رقم الجوال'));
    });

    test('succeeds with valid request in test mode', () async {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 500.0,
        method: PaymentMethod.tamara,
        customerPhone: '+966501234567',
      );

      final result = await gateway.processPayment(request);

      expect(result.success, true);
      expect(result.transactionId, startsWith('TAMARA-'));
      expect(result.rawResponse?['installments'], 4);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });

  group('PaymentService', () {
    late PaymentService service;

    setUp(() {
      service = PaymentService();
    });

    test('has cash gateway by default', () {
      expect(service.availableMethods, contains(PaymentMethod.cash));
    });

    test('registerGateway adds gateway', () {
      final madaGateway = MadaPaymentGateway(
        merchantId: 'test',
        terminalId: 'test',
      );

      service.registerGateway(PaymentMethod.mada, madaGateway);

      expect(service.availableMethods, contains(PaymentMethod.mada));
      expect(service.getGateway(PaymentMethod.mada), madaGateway);
    });

    test('processPayment fails for unsupported method', () async {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 100.0,
        method: PaymentMethod.visa, // Not registered
      );

      final result = await service.processPayment(request);

      expect(result.success, false);
      expect(result.errorMessage, contains('غير مدعومة'));
    });

    test('processPayment succeeds for cash', () async {
      const request = PaymentRequest(
        orderId: 'order-123',
        amount: 100.0,
        method: PaymentMethod.cash,
      );

      final result = await service.processPayment(request);

      expect(result.success, true);
    });

    test('refund fails for unsupported method', () async {
      const request = RefundRequest(
        originalTransactionId: 'txn-123',
        amount: 50.0,
        reason: 'Test',
      );

      final result = await service.refund(request, PaymentMethod.visa);

      expect(result.success, false);
      expect(result.errorMessage, contains('غير متاحة'));
    });

    test('refund succeeds for cash', () async {
      const request = RefundRequest(
        originalTransactionId: 'CASH-123',
        amount: 50.0,
        reason: 'Test',
      );

      final result = await service.refund(request, PaymentMethod.cash);

      expect(result.success, true);
    });
  });
}
