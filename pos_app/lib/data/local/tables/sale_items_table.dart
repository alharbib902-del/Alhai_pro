import 'package:drift/drift.dart';

/// جدول عناصر البيع
///
/// Indexes:
/// - idx_sale_items_sale_id: للربط السريع بالفاتورة
/// - idx_sale_items_product_id: للتقارير حسب المنتج
@TableIndex(name: 'idx_sale_items_sale_id', columns: {#saleId})
@TableIndex(name: 'idx_sale_items_product_id', columns: {#productId})
class SaleItemsTable extends Table {
  @override
  String get tableName => 'sale_items';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  
  // بيانات المنتج (للاحتفاظ بها وقت البيع)
  TextColumn get productName => text()();
  TextColumn get productSku => text().nullable()();
  TextColumn get productBarcode => text().nullable()();
  
  // الكميات والأسعار
  IntColumn get qty => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get costPrice => real().nullable()();
  RealColumn get subtotal => real()();
  
  // الخصم على مستوى العنصر
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  
  // ملاحظات
  TextColumn get notes => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
