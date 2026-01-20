import '../models/cash_movement.dart';
import '../models/paginated.dart';

/// Repository contract for cash movement operations (v2.5.0)
/// Referenced by: US-6.3 (Cash In/Out)
abstract class CashMovementsRepository {
  /// Gets all cash movements for a shift
  Future<List<CashMovement>> getShiftMovements(String shiftId);

  /// Gets paginated cash movements for a store
  Future<Paginated<CashMovement>> getStoreMovements(
    String storeId, {
    int page = 1,
    int limit = 20,
    CashMovementType? type,
    String? cashierId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Creates a new cash movement (deposit/withdrawal)
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
  });

  /// Validates supervisor PIN for cash out approval
  Future<bool> validateSupervisorPin(String supervisorId, String pin);

  /// Gets total cash movements for a shift
  Future<CashMovementsSummary> getShiftSummary(String shiftId);
}

/// Cash movements summary for a shift
class CashMovementsSummary {
  final String shiftId;
  final double totalCashIn;
  final double totalCashOut;
  final double netMovement;
  final int movementCount;

  const CashMovementsSummary({
    required this.shiftId,
    required this.totalCashIn,
    required this.totalCashOut,
    required this.netMovement,
    required this.movementCount,
  });
}
