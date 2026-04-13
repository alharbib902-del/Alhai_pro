import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/constants/app_constants.dart';

class CategoriesDatasource {
  final SupabaseClient _client;

  CategoriesDatasource(this._client);

  Future<List<Category>> getCategories(String storeId, {int limit = 100, int offset = 0}) async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .eq('store_id', storeId)
          .eq('is_active', true)
          .order('sort_order')
          .range(offset, offset + limit - 1)
          .timeout(AppConstants.networkTimeout);

      return (data as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(_categoryFromRow)
          .toList();
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال، حاول مرة أخرى');
    }
  }

  Future<List<Category>> getRootCategories(String storeId, {int limit = 100, int offset = 0}) async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .eq('store_id', storeId)
          .eq('is_active', true)
          .isFilter('parent_id', null)
          .order('sort_order')
          .range(offset, offset + limit - 1)
          .timeout(AppConstants.networkTimeout);

      return (data as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(_categoryFromRow)
          .toList();
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال، حاول مرة أخرى');
    }
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
