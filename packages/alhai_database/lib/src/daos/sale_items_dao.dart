import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sale_items_table.dart';

part 'sale_items_dao.g.dart';

/// DAO لعناصر البيع
@DriftAccessor(tables: [SaleItemsTable])
class SaleItemsDao extends DatabaseAccessor<AppDatabase>
    with _$SaleItemsDaoMixin {
  SaleItemsDao(super.db);

  /// الحصول على عناصر البيع
  Future<List<SaleItemsTableData>> getItemsBySaleId(String saleId) {
    return (select(
      saleItemsTable,
    )..where((i) => i.saleId.equals(saleId))).get();
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

  /// الحصول على إجمالي مبيعات منتج (مع فلتر المتجر)
  Future<double> getProductSalesCount(String productId, String storeId) async {
    final result = await customSelect(
      '''SELECT COALESCE(SUM(si.qty), 0) as total
         FROM sale_items si
         INNER JOIN sales s ON si.sale_id = s.id
         WHERE si.product_id = ? AND s.store_id = ?''',
      variables: [Variable.withString(productId), Variable.withString(storeId)],
    ).getSingle();

    return _toDouble(result.data['total']);
  }

  // ============================================================================
  // H03: JOIN queries - استعلامات مع ربط الجداول
  // ============================================================================

  /// عناصر البيع مع تفاصيل المنتج
  Future<List<SaleItemWithProduct>> getItemsWithProductDetails(
    String saleId,
  ) async {
    final result = await customSelect(
      '''SELECT si.*,
              p.name as product_name, p.sku as product_sku,
              p.barcode as product_barcode, p.category_id,
              p.image_thumbnail as product_image
         FROM sale_items si
         LEFT JOIN products p ON si.product_id = p.id
         WHERE si.sale_id = ?''',
      variables: [Variable.withString(saleId)],
    ).get();

    return result
        .map(
          (row) => SaleItemWithProduct(
            id: row.data['id'] as String,
            saleId: row.data['sale_id'] as String,
            productId: row.data['product_id'] as String,
            productName: row.data['product_name'] as String? ?? '',
            productSku: row.data['product_sku'] as String?,
            productBarcode: row.data['product_barcode'] as String?,
            productImage: row.data['product_image'] as String?,
            qty: _toDouble(row.data['qty']),
            price: _toDouble(row.data['price']),
            total: _toDouble(row.data['total']),
          ),
        )
        .toList();
  }

  /// حساب إجمالي عدد الأصناف لعدة مبيعات دفعة واحدة (بدلاً من N+1)
  Future<int> getTotalItemsCountForSales(List<String> saleIds) async {
    if (saleIds.isEmpty) return 0;

    // تقسيم إلى دفعات لتجنب تجاوز حد SQLite للمتغيرات
    int total = 0;
    const batchSize = 500;
    for (var i = 0; i < saleIds.length; i += batchSize) {
      final batch = saleIds.sublist(
        i,
        i + batchSize > saleIds.length ? saleIds.length : i + batchSize,
      );
      final placeholders = List.filled(batch.length, '?').join(', ');
      final result = await customSelect(
        'SELECT COALESCE(SUM(qty), 0) as total FROM sale_items WHERE sale_id IN ($placeholders)',
        variables: batch.map((id) => Variable.withString(id)).toList(),
      ).getSingle();

      total += (result.data['total'] is int)
          ? result.data['total'] as int
          : (result.data['total'] as double?)?.toInt() ?? 0;
    }
    return total;
  }

  /// أكثر المنتجات مبيعاً مع التفاصيل
  Future<List<ProductSalesSummary>> getTopSellingProducts(
    String storeId, {
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var whereClause = "s.store_id = ? AND s.status = 'completed'";
    final variables = <Variable>[Variable.withString(storeId)];

    if (startDate != null) {
      whereClause += ' AND s.created_at >= ?';
      variables.add(Variable.withDateTime(startDate));
    }
    if (endDate != null) {
      whereClause += ' AND s.created_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }

    final result = await customSelect(
      '''SELECT p.id, p.name, p.barcode, p.image_thumbnail,
              SUM(si.qty) as total_qty,
              SUM(si.total) as total_revenue,
              COUNT(DISTINCT si.sale_id) as sale_count
         FROM sale_items si
         INNER JOIN products p ON si.product_id = p.id
         INNER JOIN sales s ON si.sale_id = s.id
         WHERE $whereClause
         GROUP BY p.id
         ORDER BY total_qty DESC
         LIMIT ?''',
      variables: [...variables, Variable.withInt(limit)],
    ).get();

    return result
        .map(
          (row) => ProductSalesSummary(
            productId: row.data['id'] as String,
            productName: row.data['name'] as String,
            productBarcode: row.data['barcode'] as String?,
            productImage: row.data['image_thumbnail'] as String?,
            totalQty: _toDouble(row.data['total_qty']),
            totalRevenue: _toDouble(row.data['total_revenue']),
            saleCount: row.data['sale_count'] as int? ?? 0,
          ),
        )
        .toList();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    return value as double;
  }
}

/// عنصر بيع مع تفاصيل المنتج
class SaleItemWithProduct {
  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final String? productSku;
  final String? productBarcode;
  final String? productImage;
  final double qty;
  final double price;
  final double total;

  const SaleItemWithProduct({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    this.productSku,
    this.productBarcode,
    this.productImage,
    required this.qty,
    required this.price,
    required this.total,
  });
}

/// ملخص مبيعات منتج
class ProductSalesSummary {
  final String productId;
  final String productName;
  final String? productBarcode;
  final String? productImage;
  final double totalQty;
  final double totalRevenue;
  final int saleCount;

  const ProductSalesSummary({
    required this.productId,
    required this.productName,
    this.productBarcode,
    this.productImage,
    required this.totalQty,
    required this.totalRevenue,
    required this.saleCount,
  });
}
