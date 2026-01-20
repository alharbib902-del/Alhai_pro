import '../../dto/inventory/stock_adjustment_response.dart';
import '../../dto/inventory/low_stock_product_response.dart';
import '../../dto/inventory/adjust_stock_request.dart';

/// Remote data source contract for inventory API calls
abstract class InventoryRemoteDataSource {
  /// Gets stock adjustments for a product
  Future<List<StockAdjustmentResponse>> getAdjustments(
    String productId, {
    int page = 1,
    int limit = 20,
  });

  /// Gets all adjustments for a store
  Future<List<StockAdjustmentResponse>> getStoreAdjustments(
    String storeId, {
    String? type,
    int page = 1,
    int limit = 20,
  });

  /// Adjusts stock for a product
  Future<StockAdjustmentResponse> adjustStock(AdjustStockRequest request);

  /// Gets low stock products
  Future<List<LowStockProductResponse>> getLowStockProducts(String storeId);

  /// Gets out of stock product IDs
  Future<List<String>> getOutOfStockProductIds(String storeId);
}
