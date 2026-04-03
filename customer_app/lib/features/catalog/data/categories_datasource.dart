import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart';

class CategoriesDatasource {
  final SupabaseClient _client;

  CategoriesDatasource(this._client);

  Future<List<Category>> getCategories(String storeId) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('store_id', storeId)
        .eq('is_active', true)
        .order('sort_order');

    return (data as List)
        .map((row) => _categoryFromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<Category>> getRootCategories(String storeId) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('store_id', storeId)
        .eq('is_active', true)
        .isFilter('parent_id', null)
        .order('sort_order');

    return (data as List)
        .map((row) => _categoryFromRow(row as Map<String, dynamic>))
        .toList();
  }

  Category _categoryFromRow(Map<String, dynamic> row) {
    return Category(
      id: row['id'] as String,
      name: row['name'] as String,
      parentId: row['parent_id'] as String?,
      imageUrl: row['image_url'] as String?,
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      isActive: row['is_active'] as bool? ?? true,
    );
  }
}
