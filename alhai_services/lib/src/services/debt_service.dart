import 'package:alhai_core/alhai_core.dart';

/// خدمة إدارة الديون والعملاء
/// متوافقة مع DebtsRepository من alhai_core
class DebtService {
  final DebtsRepository _debtsRepo;

  DebtService(this._debtsRepo);

  /// الحصول على ديون المتجر
  Future<Paginated<Debt>> getDebts(
    String storeId, {
    DebtType? type,
    bool? overdueOnly,
    int page = 1,
    int limit = 20,
  }) async {
    return await _debtsRepo.getDebts(
      storeId,
      type: type,
      overdueOnly: overdueOnly,
      page: page,
      limit: limit,
    );
  }

  /// الحصول على دين بالـ ID
  Future<Debt> getDebt(String id) async {
    return await _debtsRepo.getDebt(id);
  }

  /// الحصول على ديون عميل/مورد معين
  Future<List<Debt>> getPartyDebts(String partyId) async {
    return await _debtsRepo.getPartyDebts(partyId);
  }

  /// إنشاء دين جديد
  Future<Debt> createDebt(CreateDebtParams params) async {
    return await _debtsRepo.createDebt(params);
  }

  /// تسجيل دفعة على الدين
  Future<DebtPayment> recordPayment(RecordPaymentParams params) async {
    return await _debtsRepo.recordPayment(params);
  }

  /// الحصول على سجل الدفعات
  Future<List<DebtPayment>> getPaymentHistory(String debtId) async {
    return await _debtsRepo.getPayments(debtId);
  }

  /// الحصول على ملخص الديون
  Future<DebtSummary> getDebtSummary(String storeId) async {
    return await _debtsRepo.getDebtSummary(storeId);
  }

  /// الحصول على الديون المستحقة
  Future<Paginated<Debt>> getOverdueDebts(String storeId) async {
    return await _debtsRepo.getDebts(storeId, overdueOnly: true);
  }

  /// الحصول على إجمالي ديون العملاء
  Future<double> getTotalCustomerDebts(String storeId) async {
    final summary = await _debtsRepo.getDebtSummary(storeId);
    return summary.totalCustomerDebts;
  }

  /// الحصول على إجمالي ديون الموردين
  Future<double> getTotalSupplierDebts(String storeId) async {
    final summary = await _debtsRepo.getDebtSummary(storeId);
    return summary.totalSupplierDebts;
  }
}
