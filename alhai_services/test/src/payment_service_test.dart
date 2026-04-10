import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------
class FakeShiftsRepository implements ShiftsRepository {
  Shift? _currentShift;

  @override
  Future<Shift> openShift({
    required String storeId,
    required String cashierId,
    required double openingCash,
    String? notes,
  }) async {
    _currentShift = Shift(
      id: 'shift-1',
      storeId: storeId,
      cashierId: cashierId,
      openingCash: openingCash,
      status: ShiftStatus.open,
      openedAt: DateTime.now(),
    );
    return _currentShift!;
  }

  @override
  Future<Shift> closeShift(String shiftId,
      {required double closingCash, String? notes}) async {
    _currentShift = _currentShift!.copyWith(
      status: ShiftStatus.closed,
      closingCash: closingCash,
      closedAt: DateTime.now(),
    );
    final closed = _currentShift!;
    _currentShift = null;
    return closed;
  }

  @override
  Future<Shift?> getCurrentShift(String cashierId) async => _currentShift;

  @override
  Future<ShiftSummary> getShiftSummary(String shiftId) async {
    return ShiftSummary(
      shiftId: shiftId,
      openingCash: 500.0,
      closingCash: 600.0,
      expectedCash: 600.0,
      cashDifference: 0.0,
      totalOrders: 10,
      totalSales: 500.0,
      salesByMethod: {'cash': 300.0, 'card': 200.0},
    );
  }

  @override
  Future<Paginated<Shift>> getStoreShifts(String storeId,
          {int page = 1,
          int limit = 20,
          ShiftStatus? status,
          String? cashierId,
          DateTime? startDate,
          DateTime? endDate}) async =>
      Paginated(items: [], total: 0, page: page, limit: limit);

  @override
  Future<Shift> getShift(String id) async => throw UnimplementedError();

  @override
  Future<Shift> updateNotes(String shiftId, String notes) async =>
      throw UnimplementedError();

  @override
  Future<List<Shift>> getDailyShifts(String storeId, DateTime date) async => [];
}

class FakeCashMovementsRepository implements CashMovementsRepository {
  @override
  Future<CashMovement> createMovement({
    required String shiftId,
    required String storeId,
    required String cashierId,
    required CashMovementType type,
    required double amount,
    required CashMovementReason reason,
    String? notes,
    String? supervisorId,
    String? supervisorPin,
  }) async {
    return CashMovement(
      id: 'mov-1',
      shiftId: shiftId,
      storeId: storeId,
      cashierId: cashierId,
      type: type,
      amount: amount,
      reason: reason,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<CashMovement>> getShiftMovements(String shiftId) async => [];

  @override
  Future<CashMovementsSummary> getShiftSummary(String shiftId) async {
    return CashMovementsSummary(
      shiftId: shiftId,
      totalCashIn: 100.0,
      totalCashOut: 50.0,
      netMovement: 50.0,
      movementCount: 2,
    );
  }

  @override
  Future<bool> validateSupervisorPin(String supervisorId, String pin) async =>
      pin == '1234';

  @override
  Future<Paginated<CashMovement>> getStoreMovements(String storeId,
          {int page = 1,
          int limit = 20,
          CashMovementType? type,
          String? cashierId,
          DateTime? startDate,
          DateTime? endDate}) async =>
      Paginated(items: [], total: 0, page: page, limit: limit);
}

class FakeOrderPaymentsRepo implements OrderPaymentsRepository {
  @override
  Future<OrderPayment> addPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
    String? referenceNo,
  }) async {
    return OrderPayment(
      id: 'pay-1',
      orderId: orderId,
      method: method,
      amount: amount,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<OrderPayment>> getOrderPayments(String orderId) async => [];
  @override
  Future<double> getTotalPaid(String orderId) async => 50.0;
  @override
  Future<double> getRemainingBalance(String orderId, double orderTotal) async =>
      orderTotal - 50.0;
  @override
  Future<OrderPayment> getPayment(String id) async =>
      throw UnimplementedError();
  @override
  Future<List<OrderPayment>> getPaymentsByMethod(String storeId,
          {required DateTime startDate,
          required DateTime endDate,
          PaymentMethod? method}) async =>
      [];
}

void main() {
  late PaymentService paymentService;

  setUp(() {
    paymentService = PaymentService(
      FakeShiftsRepository(),
      FakeCashMovementsRepository(),
      FakeOrderPaymentsRepo(),
    );
  });

  group('PaymentService', () {
    test('should be created', () {
      expect(paymentService, isNotNull);
    });

    test('initial state should have no open shift', () {
      expect(paymentService.isShiftOpen, isFalse);
      expect(paymentService.currentShift, isNull);
    });

    group('shift management', () {
      test('openShift should set current shift', () async {
        final shift = await paymentService.openShift(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          openingCash: 500.0,
        );
        expect(shift.id, isNotEmpty);
        expect(paymentService.isShiftOpen, isTrue);
      });

      test('closeShift should clear current shift', () async {
        await paymentService.openShift(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          openingCash: 500.0,
        );
        final closed = await paymentService.closeShift(closingCash: 600.0);
        expect(closed.status, equals(ShiftStatus.closed));
        expect(paymentService.isShiftOpen, isFalse);
      });

      test('closeShift without open shift should throw', () async {
        expect(
          () => paymentService.closeShift(closingCash: 0),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('payments', () {
      test('addPayment should delegate', () async {
        final payment = await paymentService.addPayment(
          orderId: 'order-1',
          method: PaymentMethod.cash,
          amount: 100.0,
        );
        expect(payment.amount, equals(100.0));
      });

      test('getTotalPaid should return amount', () async {
        final paid = await paymentService.getTotalPaid('order-1');
        expect(paid, equals(50.0));
      });

      test('getRemainingBalance should return correct balance', () async {
        final remaining =
            await paymentService.getRemainingBalance('order-1', 100.0);
        expect(remaining, equals(50.0));
      });
    });

    group('cash movements', () {
      test('recordCashMovement should create movement', () async {
        final movement = await paymentService.recordCashMovement(
          shiftId: 'shift-1',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          type: CashMovementType.cashIn,
          amount: 100.0,
          reason: CashMovementReason.changeFund,
        );
        expect(movement.amount, equals(100.0));
      });

      test('validateSupervisorPin should validate correct pin', () async {
        expect(await paymentService.validateSupervisorPin('sup-1', '1234'),
            isTrue);
      });

      test('validateSupervisorPin should reject wrong pin', () async {
        expect(await paymentService.validateSupervisorPin('sup-1', '0000'),
            isFalse);
      });
    });
  });
}
