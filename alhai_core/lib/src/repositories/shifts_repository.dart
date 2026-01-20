import '../models/paginated.dart';
import '../models/shift.dart';

/// Repository contract for shift operations (v2.4.0)
abstract class ShiftsRepository {
  /// Gets current open shift for a cashier
  Future<Shift?> getCurrentShift(String cashierId);

  /// Gets all shifts for a store
  Future<Paginated<Shift>> getStoreShifts(
    String storeId, {
    int page = 1,
    int limit = 20,
    ShiftStatus? status,
    String? cashierId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets shift by ID
  Future<Shift> getShift(String id);

  /// Opens a new shift
  Future<Shift> openShift({
    required String storeId,
    required String cashierId,
    required double openingCash,
    String? notes,
  });

  /// Closes an open shift
  Future<Shift> closeShift(
    String shiftId, {
    required double closingCash,
    String? notes,
  });

  /// Updates shift notes
  Future<Shift> updateNotes(String shiftId, String notes);

  /// Gets shift summary for reporting
  Future<ShiftSummary> getShiftSummary(String shiftId);

  /// Gets daily shifts summary
  Future<List<Shift>> getDailyShifts(String storeId, DateTime date);
}

/// Shift summary with calculated totals
class ShiftSummary {
  final String shiftId;
  final double openingCash;
  final double closingCash;
  final double expectedCash;
  final double cashDifference;
  final int totalOrders;
  final double totalSales;
  final Map<String, double> salesByMethod;

  const ShiftSummary({
    required this.shiftId,
    required this.openingCash,
    required this.closingCash,
    required this.expectedCash,
    required this.cashDifference,
    required this.totalOrders,
    required this.totalSales,
    required this.salesByMethod,
  });
}
