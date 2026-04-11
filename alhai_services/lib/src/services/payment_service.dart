import 'package:alhai_core/alhai_core.dart';

/// خدمة المدفوعات وإدارة الوردية
/// متوافقة مع ShiftsRepository, CashMovementsRepository, OrderPaymentsRepository
class PaymentService {
  final ShiftsRepository _shiftsRepo;
  final CashMovementsRepository _cashRepo;
  final OrderPaymentsRepository _paymentsRepo;

  Shift? _currentShift;

  PaymentService(this._shiftsRepo, this._cashRepo, this._paymentsRepo);

  /// الوردية الحالية
  Shift? get currentShift => _currentShift;

  /// هل الوردية مفتوحة؟
  bool get isShiftOpen => _currentShift != null;

  // ==================== إدارة الوردية ====================

  /// فتح وردية جديدة
  Future<Shift> openShift({
    required String storeId,
    required String cashierId,
    required double openingCash,
    String? notes,
  }) async {
    _currentShift = await _shiftsRepo.openShift(
      storeId: storeId,
      cashierId: cashierId,
      openingCash: openingCash,
      notes: notes,
    );
    return _currentShift!;
  }

  /// إغلاق الوردية الحالية
  Future<Shift> closeShift({required double closingCash, String? notes}) async {
    if (_currentShift == null) {
      throw Exception('لا توجد وردية مفتوحة');
    }

    final closed = await _shiftsRepo.closeShift(
      _currentShift!.id,
      closingCash: closingCash,
      notes: notes,
    );
    _currentShift = null;
    return closed;
  }

  /// الحصول على الوردية الحالية للكاشير
  Future<Shift?> getCurrentShift(String cashierId) async {
    _currentShift = await _shiftsRepo.getCurrentShift(cashierId);
    return _currentShift;
  }

  /// الحصول على ملخص الوردية
  Future<ShiftSummary> getShiftSummary(String shiftId) async {
    return await _shiftsRepo.getShiftSummary(shiftId);
  }

  // ==================== المدفوعات ====================

  /// إضافة دفعة للطلب
  Future<OrderPayment> addPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
    String? referenceNo,
  }) async {
    return await _paymentsRepo.addPayment(
      orderId: orderId,
      method: method,
      amount: amount,
      referenceNo: referenceNo,
    );
  }

  /// الحصول على مدفوعات الطلب
  Future<List<OrderPayment>> getOrderPayments(String orderId) async {
    return await _paymentsRepo.getOrderPayments(orderId);
  }

  /// الحصول على المبلغ المدفوع للطلب
  Future<double> getTotalPaid(String orderId) async {
    return await _paymentsRepo.getTotalPaid(orderId);
  }

  /// الحصول على الرصيد المتبقي للطلب
  Future<double> getRemainingBalance(String orderId, double orderTotal) async {
    return await _paymentsRepo.getRemainingBalance(orderId, orderTotal);
  }

  // ==================== حركات النقد ====================

  /// تسجيل حركة نقدية (إيداع/سحب)
  Future<CashMovement> recordCashMovement({
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
    return await _cashRepo.createMovement(
      shiftId: shiftId,
      storeId: storeId,
      cashierId: cashierId,
      type: type,
      amount: amount,
      reason: reason,
      notes: notes,
      supervisorId: supervisorId,
      supervisorPin: supervisorPin,
    );
  }

  /// الحصول على حركات النقد للوردية
  Future<List<CashMovement>> getShiftCashMovements(String shiftId) async {
    return await _cashRepo.getShiftMovements(shiftId);
  }

  /// الحصول على ملخص حركات النقد للوردية
  Future<CashMovementsSummary> getCashMovementsSummary(String shiftId) async {
    return await _cashRepo.getShiftSummary(shiftId);
  }

  /// التحقق من PIN المشرف
  Future<bool> validateSupervisorPin(String supervisorId, String pin) async {
    return await _cashRepo.validateSupervisorPin(supervisorId, pin);
  }
}
