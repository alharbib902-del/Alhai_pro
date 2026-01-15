import '../models/paginated.dart';
import '../models/stock_adjustment.dart';

/// Repository contract for inventory operations
abstract class InventoryRepository {
  /// Gets stock adjustments for a product
  Future<Paginated<StockAdjustment>> getAdjustments(
    String productId, {
    int page = 1,
    int limit = 20,
  });

  /// Gets all adjustments for a store
  Future<Paginated<StockAdjustment>> getStoreAdjustments(
    String storeId, {
    AdjustmentType? type,
    int page = 1,
    int limit = 20,
  });

  /// Adjusts stock for a product
  Future<StockAdjustment> adjustStock({
    required String productId,
    required String storeId,
    required AdjustmentType type,
    required int quantity,
    String? reason,
    String? referenceId,
  });

  /// Gets low stock products
  Future<List<LowStockProduct>> getLowStockProducts(String storeId);

  /// Gets out of stock products
  Future<List<String>> getOutOfStockProductIds(String storeId);
}

/// Low stock product info
class LowStockProduct {
  final String productId;
  final String productName;
  final int currentQty;
  final int minQty;

  const LowStockProduct({
    required this.productId,
    required this.productName,
    required this.currentQty,
    required this.minQty,
  });

  int get deficit => minQty - currentQty;
}
