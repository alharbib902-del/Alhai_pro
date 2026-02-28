import '../../config/app_limits.dart';
import '../../dto/debts/debt_response.dart';
import '../../dto/debts/create_debt_request.dart';
import '../../dto/debts/debt_payment_response.dart';
import '../../dto/debts/debt_summary_response.dart';

/// Remote data source contract for debts API calls
abstract class DebtsRemoteDataSource {
  /// Gets debts for a store
  Future<List<DebtResponse>> getDebts(
    String storeId, {
    String? type,
    bool? overdueOnly,
    int page = 1,
    int limit = AppLimits.defaultPageSize,
  });

  /// Gets a debt by ID
  Future<DebtResponse> getDebt(String id);

  /// Gets debts for a specific party
  Future<List<DebtResponse>> getPartyDebts(String partyId);

  /// Creates a new debt
  Future<DebtResponse> createDebt(CreateDebtRequest request);

  /// Records a payment against a debt
  Future<DebtPaymentResponse> recordPayment(RecordPaymentRequest request);

  /// Gets payment history for a debt
  Future<List<DebtPaymentResponse>> getPayments(String debtId);

  /// Gets total outstanding debt summary for store
  Future<DebtSummaryResponse> getDebtSummary(String storeId);
}
