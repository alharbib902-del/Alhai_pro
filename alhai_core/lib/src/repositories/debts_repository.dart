import '../models/debt.dart';
import '../models/paginated.dart';

/// Repository contract for debt operations
abstract class DebtsRepository {
  /// Gets all debts for a store
  Future<Paginated<Debt>> getDebts(
    String storeId, {
    DebtType? type,
    bool? overdueOnly,
    int page = 1,
    int limit = 20,
  });

  /// Gets a debt by ID
  Future<Debt> getDebt(String id);

  /// Gets debts for a specific party (customer or supplier)
  Future<List<Debt>> getPartyDebts(String partyId);

  /// Creates a new debt
  Future<Debt> createDebt(CreateDebtParams params);

  /// Records a payment against a debt
  Future<DebtPayment> recordPayment(RecordPaymentParams params);

  /// Gets payment history for a debt
  Future<List<DebtPayment>> getPayments(String debtId);

  /// Gets total outstanding debt for store
  Future<DebtSummary> getDebtSummary(String storeId);
}

/// Parameters for creating a debt
class CreateDebtParams {
  final String storeId;
  final DebtType type;
  final String partyId;
  final String partyName;
  final String? partyPhone;
  final double amount;
  final String? orderId;
  final String? notes;
  final DateTime? dueDate;

  const CreateDebtParams({
    required this.storeId,
    required this.type,
    required this.partyId,
    required this.partyName,
    this.partyPhone,
    required this.amount,
    this.orderId,
    this.notes,
    this.dueDate,
  });
}

/// Parameters for recording a payment
class RecordPaymentParams {
  final String debtId;
  final double amount;
  final String? paymentMethod;
  final String? notes;

  const RecordPaymentParams({
    required this.debtId,
    required this.amount,
    this.paymentMethod,
    this.notes,
  });
}

/// Debt summary for a store
class DebtSummary {
  final double totalCustomerDebts;
  final double totalSupplierDebts;
  final int overdueCount;
  final double overdueAmount;

  const DebtSummary({
    required this.totalCustomerDebts,
    required this.totalSupplierDebts,
    required this.overdueCount,
    required this.overdueAmount,
  });

  double get netDebt => totalCustomerDebts - totalSupplierDebts;
}
