import 'package:drift/drift.dart';

import 'sales_table.dart';
import 'products_table.dart';

/// جدول عناصر البيع
///
/// Indexes:
/// - idx_sale_items_sale_id: للربط السريع بالفاتورة
/// - idx_sale_items_product_id: للتقارير حسب المنتج
/// - idx_sale_items_product_sale: للـ JOIN مع sales في تقارير المبيعات
@TableIndex(name: 'idx_sale_items_sale_id', columns: {#saleId})
@TableIndex(name: 'idx_sale_items_product_id', columns: {#productId})
@TableIndex(name: 'idx_sale_items_product_sale', columns: {#productId, #saleId})
class SaleItemsTable extends Table {
  @override
  String get tableName => 'sale_items';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get saleId =>
      text().references(SalesTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId =>
      text().references(ProductsTable, #id, onDelete: KeyAction.restrict)();

  // بيانات المنتج (للاحتفاظ بها وقت البيع)
  TextColumn get productName => text()();
  TextColumn get productSku => text().nullable()();
  TextColumn get productBarcode => text().nullable()();

  // الكميات والأسعار
  // C-4 Session 2: money columns are int cents (ROUND_HALF_UP).
  // qty stays Real — fractional quantities (e.g. 1.5 kg) are valid.
  RealColumn get qty => real()();
  IntColumn get unitPrice => integer()();
  IntColumn get costPrice => integer().nullable()();
  IntColumn get subtotal => integer()();

  // الخصم على مستوى العنصر
  IntColumn get discount => integer().withDefault(const Constant(0))();
  IntColumn get total => integer()();

  // ملاحظات
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
