import 'package:drift/drift.dart';

/// جدول حركات الحسابات (المدفوعات والفوائد والفواتير)
class TransactionsTable extends Table {
  @override
  String get tableName => 'transactions';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get accountId => text()(); // FK to accounts
  
  // نوع الحركة
  TextColumn get type => text()(); // invoice, payment, interest, adjustment
  
  // المبلغ والوصف
  RealColumn get amount => real()();
  RealColumn get balanceAfter => real()(); // الرصيد بعد الحركة
  TextColumn get description => text().nullable()();
  
  // مرجع خارجي
  TextColumn get referenceId => text().nullable()(); // saleId, purchaseId, etc
  TextColumn get referenceType => text().nullable()(); // sale, purchase
  
  // فترة الفائدة (للفوائد الشهرية)
  TextColumn get periodKey => text().nullable()(); // YYYY-MM format
  
  // طريقة الدفع (للمدفوعات)
  TextColumn get paymentMethod => text().nullable()(); // cash, card, transfer
  
  // المستخدم
  TextColumn get createdBy => text().nullable()();
  
  // التواريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
