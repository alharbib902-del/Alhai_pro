import 'package:drift/drift.dart';

/// جدول عناصر الطلب
class OrderItemsTable extends Table {
  @override
  String get tableName => 'order_items';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orderId => text()(); // FK to orders
  TextColumn get productId => text()(); // FK to products
  
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
