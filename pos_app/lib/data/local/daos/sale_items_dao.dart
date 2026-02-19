import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sale_items_table.dart';

part 'sale_items_dao.g.dart';

/// DAO لعناصر البيع
@DriftAccessor(tables: [SaleItemsTable])
class SaleItemsDao extends DatabaseAccessor<AppDatabase> with _$SaleItemsDaoMixin {
  SaleItemsDao(super.db);
  
  /// الحصول على عناصر البيع
  Future<List<SaleItemsTableData>> getItemsBySaleId(String saleId) {
    return (select(saleItemsTable)..where((i) => i.saleId.equals(saleId))).get();
  }
  
  /// إدراج عنصر
  Future<int> insertItem(SaleItemsTableCompanion item) {
    return into(saleItemsTable).insert(item);
  }
  
  /// إدراج عناصر متعددة
  Future<void> insertItems(List<SaleItemsTableCompanion> items) async {
    await batch((b) {
      b.insertAll(saleItemsTable, items);
    });
  }
  
  /// حذف عناصر البيع
  Future<int> deleteItemsBySaleId(String saleId) {
    return (delete(saleItemsTable)..where((i) => i.saleId.equals(saleId))).go();
  }
  
  /// الحصول على إجمالي مبيعات منتج
  Future<int> getProductSalesCount(String productId) async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(qty), 0) as total FROM sale_items WHERE product_id = ?',
      variables: [Variable.withString(productId)],
    ).getSingle();
    
    return result.data['total'] as int? ?? 0;
  }
}
