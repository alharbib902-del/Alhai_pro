import 'package:json_annotation/json_annotation.dart';
import '../../repositories/debts_repository.dart';

part 'debt_summary_response.g.dart';

/// Response DTO for debt summary
@JsonSerializable()
class DebtSummaryResponse {
  final double totalCustomerDebts;
  final double totalSupplierDebts;
  final int overdueCount;
  final double overdueAmount;

  const DebtSummaryResponse({
    required this.totalCustomerDebts,
    required this.totalSupplierDebts,
    required this.overdueCount,
    required this.overdueAmount,
  });

  factory DebtSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$DebtSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DebtSummaryResponseToJson(this);

  /// Converts to domain model
  DebtSummary toDomain() {
    return DebtSummary(
      totalCustomerDebts: totalCustomerDebts,
      totalSupplierDebts: totalSupplierDebts,
      overdueCount: overdueCount,
      overdueAmount: overdueAmount,
    );
  }
}
