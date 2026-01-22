import '../models/paginated.dart';

/// Repository contract for inventory transfer operations (v2.6.0)
/// Transfers stock between store branches
abstract class TransfersRepository {
  /// Gets a transfer by ID
  Future<Transfer> getTransfer(String id);

  /// Gets transfers for a store (as source or destination)
  Future<Paginated<Transfer>> getStoreTransfers(
    String storeId, {
    int page = 1,
    int limit = 20,
    TransferStatus? status,
    TransferDirection? direction,
  });

  /// Creates a new transfer request
  Future<Transfer> createTransfer({
    required String sourceStoreId,
    required String destinationStoreId,
    required List<TransferItem> items,
    String? notes,
  });

  /// Approves a transfer (destination store)
  Future<Transfer> approveTransfer(String id, String approvedBy);

  /// Rejects a transfer
  Future<Transfer> rejectTransfer(String id, String rejectedBy, String reason);

  /// Marks transfer as shipped
  Future<Transfer> shipTransfer(String id);

  /// Completes a transfer (items received)
  Future<Transfer> completeTransfer(String id, String receivedBy);

  /// Cancels a transfer
  Future<Transfer> cancelTransfer(String id, String reason);
}

/// Transfer direction filter
enum TransferDirection { incoming, outgoing }

/// Transfer status
enum TransferStatus {
  pending,
  approved,
  rejected,
  shipped,
  completed,
  cancelled,
}

/// Transfer model
class Transfer {
  final String id;
  final String sourceStoreId;
  final String destinationStoreId;
  final String? sourceStoreName;
  final String? destinationStoreName;
  final List<TransferItem> items;
  final TransferStatus status;
  final String? notes;
  final String? createdBy;
  final String? approvedBy;
  final String? rejectedBy;
  final String? rejectionReason;
  final String? receivedBy;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? shippedAt;
  final DateTime? completedAt;

  const Transfer({
    required this.id,
    required this.sourceStoreId,
    required this.destinationStoreId,
    this.sourceStoreName,
    this.destinationStoreName,
    required this.items,
    required this.status,
    this.notes,
    this.createdBy,
    this.approvedBy,
    this.rejectedBy,
    this.rejectionReason,
    this.receivedBy,
    required this.createdAt,
    this.approvedAt,
    this.shippedAt,
    this.completedAt,
  });
}

/// Transfer item
class TransferItem {
  final String productId;
  final String productName;
  final int quantity;
  final int? receivedQuantity;

  const TransferItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    this.receivedQuantity,
  });
}
