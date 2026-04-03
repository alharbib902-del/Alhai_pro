import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart';

class ProductsDatasource {
  final SupabaseClient _client;

  ProductsDatasource(this._client);

  Future<Paginated<Product>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
  }) async {
    var query = _client
        .from('products')
        .select()
        .eq('store_id', storeId)
        .eq('is_active', true);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('name.ilike.%$searchQuery%,barcode.eq.$searchQuery,sku.ilike.%$searchQuery%');
    }

    final from = (page - 1) * limit;
    final to = from + limit - 1;

    final data = await query
        .order('name')
        .range(from, to);

    final products = (data as List)
        .map((row) => _productFromRow(row as Map<String, dynamic>))
        .toList();

    return Paginated(
      items: products,
      page: page,
      limit: limit,
      total: null,
      hasMore: products.length == limit,
    );
  }

  Future<Product> getProduct(String id) async {
    final data = await _client
        .from('products')
        .select()
        .eq('id', id)
        .single();
    return _productFromRow(data);
  }

  Product _productFromRow(Map<String, dynamic> row) {
    return Product(
      id: row['id'] as String,
      storeId: row['store_id'] as String,
      name: row['name'] as String,
      sku: row['sku'] as String?,
      barcode: row['barcode'] as String?,
      price: (row['price'] as num).toDouble(),
      costPrice: (row['cost_price'] as num?)?.toDouble(),
      stockQty: (row['stock_qty'] as num?)?.toInt() ?? 0,
      minQty: (row['min_qty'] as num?)?.toInt() ?? 1,
      unit: row['unit'] as String?,
      description: row['description'] as String?,
      imageThumbnail: row['image_thumbnail'] as String?,
      imageMedium: row['image_medium'] as String?,
      imageLarge: row['image_large'] as String?,
      imageHash: row['image_hash'] as String?,
      categoryId: row['category_id'] as String?,
      isActive: row['is_active'] as bool? ?? true,
      trackInventory: row['track_inventory'] as bool? ?? true,
      createdAt: DateTime.parse(
        row['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }
}
