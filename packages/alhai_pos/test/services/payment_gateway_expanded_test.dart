import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_pos/src/services/payment/payment_gateway.dart';

// ============================================================================
// MOCKS
// ============================================================================

/// Fake PaymentRequest for mocktail fallback
class FakePaymentRequest extends Fake implements PaymentRequest {}

/// Mock PaymentGateway for testing PaymentService with custom behavior
class MockPaymentGateway extends Mock implements PaymentGateway {}

/// A gateway that always throws to test error handling
class ThrowingGateway implements PaymentGateway {
  @override
  String get name => 'Throwing';

  @override
  List<PaymentMethod> get supportedMethods => [PaymentMethod.wallet];

  @override
  PaymentGatewayStatus get configurationStatus =>
      PaymentGatewayStatus.available;

  @override
  bool get isSimulated => false;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) =>
      throw Exception('Simulated gateway failure');

  @override
  Future<RefundResult> refund(RefundRequest request) =>
      throw Exception('Simulated refund failure');

  @override
  Future<PaymentStatus> checkStatus(String transactionId) async =>
      PaymentStatus.failed;

  @override
  Future<bool> cancel(String transactionId) async => false;
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePaymentRequest());
  });

  group('PaymentService - Expanded', () {
    late PaymentService service;

    setUp(() {
      service = PaymentService();
    });

    group('processPayment error handling', () {
      test('should catch gateway exceptions and return failed result',
          () async {
        // Arrange - register a gateway that throws
        // Note: PaymentService.isMethodAvailable only allows cash right now
        // so we test the error handling path by using a mock gateway for cash
        final mockGateway = MockPaymentGateway();
        when(() => mockGateway.name).thenReturn('Mock');
        when(() => mockGateway.isAvailable()).thenAnswer((_) async => true);
        when(() => mockGateway.processPayment(any()))
            .thenThrow(Exception('Network failure'));

        service.registerGateway(PaymentMethod.cash, mockGateway);

        final request = PaymentRequest(
          orderId: 'order-1',
          amount: 100.0,
          method: PaymentMethod.cash,
        );

        // Act
        final result = await service.processPayment(request);

        // Assert
        expect(result.success, isFalse);
        expect(result.errorType, equals(PaymentErrorType.unknown));
      });

      test('should return failure when gateway is unavailable', () async {
        final mockGateway = MockPaymentGateway();
        when(() => mockGateway.name).thenReturn('Mock');
        when(() => mockGateway.isAvailable()).thenAnswer((_) async => false);

        service.registerGateway(PaymentMethod.cash, mockGateway);

        final request = PaymentRequest(
          orderId: 'order-1',
          amount: 100.0,
          method: PaymentMethod.cash,
        );

        final result = await service.processPayment(request);

        expect(result.success, isFalse);
        expect(result.errorType, equals(PaymentErrorType.gatewayNotConfigured));
      });
    });

    group('refund error handling', () {
      test('should catch gateway exceptions during refund', () async {
        final throwingGateway = ThrowingGateway();
        service.registerGateway(PaymentMethod.wallet, throwingGateway);

        const request = RefundRequest(
          originalTransactionId: 'tx-1',
          amount: 50.0,
          reason: 'test',
        );

        final result = await service.refund(request, PaymentMethod.wallet);

        expect(result.success, isFalse);
        expect(result.refundedAmount, equals(0));
        expect(result.errorMessage, isNotEmpty);
      });

      test('should return failure for unregistered gateway refund', () async {
        const request = RefundRequest(
          originalTransactionId: 'tx-1',
          amount: 50.0,
          reason: 'test',
        );

        final result = await service.refund(request, PaymentMethod.tamara);

        expect(result.success, isFalse);
        expect(result.refundedAmount, equals(0));
      });
    });

    group('gateway registration', () {
      test('should allow overriding an existing gateway', () {
        final newCashGateway = CashPaymentGateway();
        service.registerGateway(PaymentMethod.cash, newCashGateway);

        expect(service.getGateway(PaymentMethod.cash), equals(newCashGateway));
      });

      test('getGateway should return null for unregistered method', () {
        expect(service.getGateway(PaymentMethod.tabby), isNull);
      });

      test('availableMethods should reflect registered gateways', () {
        expect(service.availableMethods.length, equals(1));

        final stcGateway = StcPayGateway(
          merchantId: 'test',
          apiKey: 'key',
        );
        service.registerGateway(PaymentMethod.stcPay, stcGateway);

        expect(service.availableMethods.length, equals(2));
        expect(service.availableMethods, contains(PaymentMethod.stcPay));
      });
    });
  });

  group('PaymentRequest - Expanded', () {
    test('toJson should handle null optional fields', () {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 100.0,
        method: PaymentMethod.cash,
      );

      final json = request.toJson();
      expect(json['customer_phone'], isNull);
      expect(json['customer_email'], isNull);
      expect(json['customer_name'], isNull);
      expect(json['metadata'], isNull);
    });

    test('toJson should include all optional fields when provided', () {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 250.0,
        method: PaymentMethod.mada,
        currency: 'SAR',
        customerPhone: '0512345678',
        customerEmail: 'test@example.com',
        customerName: 'Ahmad',
        metadata: {'source': 'pos', 'terminal': 'T-001'},
      );

      final json = request.toJson();
      expect(json['customer_phone'], equals('0512345678'));
      expect(json['customer_email'], equals('test@example.com'));
      expect(json['customer_name'], equals('Ahmad'));
      expect(json['metadata'], isA<Map>());
      expect(json['metadata']['source'], equals('pos'));
    });

    test('default currency should be SAR', () {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 100.0,
        method: PaymentMethod.cash,
      );

      expect(request.currency, equals('SAR'));
    });
  });

  group('PaymentResult - Expanded', () {
    test('success factory should set timestamp', () {
      final before = DateTime.now();
      final result = PaymentResult.success(transactionId: 'tx-1');
      final after = DateTime.now();

      expect(
          result.timestamp.isAfter(before) ||
              result.timestamp.isAtSameMomentAs(before),
          isTrue);
      expect(
          result.timestamp.isBefore(after) ||
              result.timestamp.isAtSameMomentAs(after),
          isTrue);
    });

    test('failed factory should set timestamp', () {
      final result = PaymentResult.failed(
        errorType: PaymentErrorType.network,
      );

      expect(result.timestamp, isNotNull);
    });

    test('success result should have no error fields', () {
      final result = PaymentResult.success(
        transactionId: 'tx-1',
        authCode: 'AUTH',
      );

      expect(result.errorType, isNull);
      expect(result.errorMessage, isNull);
    });

    test('all PaymentErrorType values should have non-empty Arabic messages',
        () {
      for (final errorType in PaymentErrorType.values) {
        expect(errorType.arabicMessage, isNotEmpty,
            reason: '${errorType.name} should have an Arabic message');
      }
    });
  });

  group('CashPaymentGateway - Expanded', () {
    late CashPaymentGateway gateway;

    setUp(() {
      gateway = CashPaymentGateway();
    });

    test('transaction ID should start with CASH- prefix', () async {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 50.0,
        method: PaymentMethod.cash,
      );

      final result = await gateway.processPayment(request);
      expect(result.transactionId, startsWith('CASH-'));
    });

    test('refund ID should start with CASH-REF- prefix', () async {
      const request = RefundRequest(
        originalTransactionId: 'CASH-123',
        amount: 50.0,
        reason: 'Return',
      );

      final result = await gateway.refund(request);
      expect(result.refundId, startsWith('CASH-REF-'));
    });

    test('should handle zero amount payment', () async {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 0.0,
        method: PaymentMethod.cash,
      );

      final result = await gateway.processPayment(request);
      expect(result.success, isTrue);
    });

    test('should handle very large amount payment', () async {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 999999.99,
        method: PaymentMethod.cash,
      );

      final result = await gateway.processPayment(request);
      expect(result.success, isTrue);
    });
  });

  group('TamaraGateway - Expanded', () {
    late TamaraGateway gateway;

    setUp(() {
      gateway = TamaraGateway(
        apiToken: 'test-token',
        merchantUrl: 'https://test.com',
        isTestMode: true,
      );
    });

    test('should reject amount below minimum in test mode', () async {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 50.0, // below minOrderAmount of 100
        method: PaymentMethod.tamara,
        customerPhone: '0512345678',
      );

      final result = await gateway.processPayment(request);

      expect(result.success, isFalse);
      expect(result.errorType, equals(PaymentErrorType.declined));
    });

    test('should reject amount above maximum in test mode', () async {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 6000.0, // above maxOrderAmount of 5000
        method: PaymentMethod.tamara,
        customerPhone: '0512345678',
      );

      final result = await gateway.processPayment(request);

      expect(result.success, isFalse);
      expect(result.errorType, equals(PaymentErrorType.declined));
    });

    test('should require customer phone', () async {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 200.0,
        method: PaymentMethod.tamara,
        // no customerPhone
      );

      final result = await gateway.processPayment(request);

      expect(result.success, isFalse);
      expect(result.errorType, equals(PaymentErrorType.authenticationFailed));
    });
  });

  group('StcPayGateway - Expanded', () {
    late StcPayGateway gateway;

    setUp(() {
      gateway = StcPayGateway(
        merchantId: 'test',
        apiKey: 'test-key',
        isTestMode: true,
      );
    });

    test('should require customer phone', () async {
      final request = PaymentRequest(
        orderId: 'order-1',
        amount: 100.0,
        method: PaymentMethod.stcPay,
        // no customerPhone
      );

      final result = await gateway.processPayment(request);

      expect(result.success, isFalse);
      expect(result.errorType, equals(PaymentErrorType.authenticationFailed));
    });
  });
}
