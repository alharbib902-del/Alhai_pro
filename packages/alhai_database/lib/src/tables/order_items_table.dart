import 'package:drift/drift.dart';

import 'orders_table.dart';
import 'products_table.dart';

/// جدول عناصر الطلب
@TableIndex(name: 'idx_order_items_order_id', columns: {#orderId})
@TableIndex(name: 'idx_order_items_product_id', columns: {#productId})
class OrderItemsTable extends Table {
  @override
  String get tableName => 'order_items';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orderId => text().references(OrdersTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text().references(ProductsTable, #id, onDelete: KeyAction.restrict)();
  
  // معلومات المنتج (نسخة وقت الطلب)
  TextColumn get productName => text()();
  TextColumn get productNameEn => text().nullable()();
  TextColumn get barcode => text().nullable()();
  
  // الكميات والأسعار
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get taxRate => real().withDefault(const Constant(15))();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  
  // ملاحظات
  TextColumn get notes => text().nullable()();
  
  // حالة الحجز
  BoolColumn get isReserved => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}
