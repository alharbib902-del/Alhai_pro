import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sales_table.dart';

part 'sales_dao.g.dart';

/// DAO للمبيعات
@DriftAccessor(tables: [SalesTable])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  SalesDao(super.db);
  
  /// الحصول على جميع المبيعات للمتجر
  Future<List<SalesTableData>> getAllSales(String storeId) {
    return (select(salesTable)
      ..where((s) => s.storeId.equals(storeId))
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
      .get();
  }
  
  /// الحصول على مبيعات بتاريخ
  Future<List<SalesTableData>> getSalesByDate(String storeId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return (select(salesTable)
      ..where((s) => 
        s.storeId.equals(storeId) &
        s.createdAt.isBiggerOrEqualValue(startOfDay) &
        s.createdAt.isSmallerThanValue(endOfDay)
      )
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
      .get();
  }
  
  /// الحصول على مبيعات الفترة
  Future<List<SalesTableData>> getSalesByDateRange(
    String storeId, 
    DateTime startDate, 
    DateTime endDate,
  ) {
    return (select(salesTable)
      ..where((s) => 
        s.storeId.equals(storeId) &
        s.createdAt.isBiggerOrEqualValue(startDate) &
        s.createdAt.isSmallerOrEqualValue(endDate)
      )
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
      .get();
  }
  
  /// الحصول على بيع بالمعرف
  Future<SalesTableData?> getSaleById(String id) {
    return (select(salesTable)..where((s) => s.id.equals(id)))
      .getSingleOrNull();
  }
  
  /// الحصول على بيع برقم الإيصال
  Future<SalesTableData?> getSaleByReceiptNo(String receiptNo, String storeId) {
    return (select(salesTable)
      ..where((s) => s.receiptNo.equals(receiptNo) & s.storeId.equals(storeId)))
      .getSingleOrNull();
  }
  
  /// إدراج بيع
  Future<int> insertSale(SalesTableCompanion sale) {
    return into(salesTable).insert(sale);
  }
  
  /// تحديث بيع
  Future<bool> updateSale(SalesTableData sale) {
    return update(salesTable).replace(sale);
  }
  
  /// إلغاء بيع
  Future<int> voidSale(String id) {
    return (update(salesTable)..where((s) => s.id.equals(id)))
      .write(const SalesTableCompanion(
        status: Value('voided'),
        updatedAt: Value(null),
      ));
  }
  
  /// إجمالي مبيعات اليوم
  Future<double> getTodayTotal(String storeId, String cashierId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await customSelect(
      '''SELECT COALESCE(SUM(total), 0) as total 
         FROM sales 
         WHERE store_id = ? 
         AND cashier_id = ? 
         AND created_at >= ? 
         AND created_at < ?
         AND status = 'completed' ''',
      variables: [
        Variable.withString(storeId),
        Variable.withString(cashierId),
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
    ).getSingle();
    
    final total = result.data['total'];
    if (total == null) return 0.0;
    if (total is int) return total.toDouble();
    return total as double;
  }
  
  /// عدد مبيعات اليوم للكاشير
  Future<int> getTodayCount(String storeId, String cashierId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await customSelect(
      '''SELECT COUNT(*) as count
         FROM sales
         WHERE store_id = ?
         AND cashier_id = ?
         AND created_at >= ?
         AND created_at < ?
         AND status = 'completed' ''',
      variables: [
        Variable.withString(storeId),
        Variable.withString(cashierId),
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
    ).getSingle();

    return result.data['count'] as int? ?? 0;
  }

  /// عدد جميع مبيعات اليوم للمتجر (لتوليد رقم الإيصال)
  Future<int> getTodayStoreCount(String storeId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await customSelect(
      '''SELECT COUNT(*) as count
         FROM sales
         WHERE store_id = ?
         AND created_at >= ?
         AND created_at < ? ''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
    ).getSingle();

    return result.data['count'] as int? ?? 0;
  }
  
  /// تعيين تاريخ المزامنة
  Future<int> markAsSynced(String id) {
    return (update(salesTable)..where((s) => s.id.equals(id)))
      .write(SalesTableCompanion(syncedAt: Value(DateTime.now())));
  }
  
  /// الحصول على المبيعات غير المزامنة
  Future<List<SalesTableData>> getUnsyncedSales() {
    return (select(salesTable)..where((s) => s.syncedAt.isNull())).get();
  }
  
  /// مراقبة المبيعات (Stream)
  Stream<List<SalesTableData>> watchTodaySales(String storeId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(salesTable)
      ..where((s) =>
        s.storeId.equals(storeId) &
        s.createdAt.isBiggerOrEqualValue(startOfDay) &
        s.createdAt.isSmallerThanValue(endOfDay)
      )
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
      .watch();
  }

  // ============================================================================
  // Pagination & Performance Methods - تحسينات الأداء
  // ============================================================================

  /// الحصول على مبيعات مع Pagination
  Future<List<SalesTableData>> getSalesPaginated(
    String storeId, {
    int offset = 0,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? cashierId,
  }) {
    var query = select(salesTable)
      ..where((s) {
        var condition = s.storeId.equals(storeId);

        if (startDate != null) {
          condition = condition & s.createdAt.isBiggerOrEqualValue(startDate);
        }
        if (endDate != null) {
          condition = condition & s.createdAt.isSmallerOrEqualValue(endDate);
        }
        if (status != null) {
          condition = condition & s.status.equals(status);
        }
        if (cashierId != null) {
          condition = condition & s.cashierId.equals(cashierId);
        }

        return condition;
      })
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
      ..limit(limit, offset: offset);

    return query.get();
  }

  /// عدد المبيعات الكلي (للـ pagination)
  Future<int> getSalesCount(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? cashierId,
  }) async {
    final countExpression = salesTable.id.count();

    var query = selectOnly(salesTable)
      ..addColumns([countExpression])
      ..where(salesTable.storeId.equals(storeId));

    if (startDate != null) {
      query.where(salesTable.createdAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where(salesTable.createdAt.isSmallerOrEqualValue(endDate));
    }
    if (status != null) {
      query.where(salesTable.status.equals(status));
    }
    if (cashierId != null) {
      query.where(salesTable.cashierId.equals(cashierId));
    }

    final result = await query.getSingle();
    return result.read(countExpression) ?? 0;
  }

  /// إحصائيات سريعة للمبيعات
  /// يجمع المجموع، العدد، المتوسط في استعلام واحد
  Future<SalesStats> getSalesStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
    String? cashierId,
  }) async {
    var whereClause = 'store_id = ? AND status = \'completed\'';
    final variables = <Variable>[Variable.withString(storeId)];

    if (startDate != null) {
      whereClause += ' AND created_at >= ?';
      variables.add(Variable.withDateTime(startDate));
    }
    if (endDate != null) {
      whereClause += ' AND created_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }
    if (cashierId != null) {
      whereClause += ' AND cashier_id = ?';
      variables.add(Variable.withString(cashierId));
    }

    final result = await customSelect(
      '''SELECT
           COUNT(*) as count,
           COALESCE(SUM(total), 0) as total,
           COALESCE(AVG(total), 0) as average,
           COALESCE(MAX(total), 0) as max_sale,
           COALESCE(MIN(total), 0) as min_sale
         FROM sales
         WHERE $whereClause''',
      variables: variables,
    ).getSingle();

    return SalesStats(
      count: result.data['count'] as int? ?? 0,
      total: (result.data['total'] is int)
          ? (result.data['total'] as int).toDouble()
          : result.data['total'] as double? ?? 0.0,
      average: (result.data['average'] is int)
          ? (result.data['average'] as int).toDouble()
          : result.data['average'] as double? ?? 0.0,
      maxSale: (result.data['max_sale'] is int)
          ? (result.data['max_sale'] as int).toDouble()
          : result.data['max_sale'] as double? ?? 0.0,
      minSale: (result.data['min_sale'] is int)
          ? (result.data['min_sale'] as int).toDouble()
          : result.data['min_sale'] as double? ?? 0.0,
    );
  }

  /// المبيعات بالساعة (للتقارير)
  Future<List<HourlySales>> getHourlySales(String storeId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await customSelect(
      '''SELECT
           strftime('%H', created_at) as hour,
           COUNT(*) as count,
           COALESCE(SUM(total), 0) as total
         FROM sales
         WHERE store_id = ?
         AND created_at >= ?
         AND created_at < ?
         AND status = 'completed'
         GROUP BY strftime('%H', created_at)
         ORDER BY hour''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
    ).get();

    return result.map((row) => HourlySales(
      hour: int.parse(row.data['hour'] as String),
      count: row.data['count'] as int,
      total: (row.data['total'] is int)
          ? (row.data['total'] as int).toDouble()
          : row.data['total'] as double,
    )).toList();
  }

  /// أفضل طرق الدفع
  Future<List<PaymentMethodStats>> getPaymentMethodStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var whereClause = 'store_id = ? AND status = \'completed\'';
    final variables = <Variable>[Variable.withString(storeId)];

    if (startDate != null) {
      whereClause += ' AND created_at >= ?';
      variables.add(Variable.withDateTime(startDate));
    }
    if (endDate != null) {
      whereClause += ' AND created_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }

    final result = await customSelect(
      '''SELECT
           payment_method,
           COUNT(*) as count,
           COALESCE(SUM(total), 0) as total
         FROM sales
         WHERE $whereClause
         GROUP BY payment_method
         ORDER BY total DESC''',
      variables: variables,
    ).get();

    return result.map((row) => PaymentMethodStats(
      method: row.data['payment_method'] as String,
      count: row.data['count'] as int,
      total: (row.data['total'] is int)
          ? (row.data['total'] as int).toDouble()
          : row.data['total'] as double,
    )).toList();
  }
}

/// نموذج إحصائيات المبيعات
class SalesStats {
  final int count;
  final double total;
  final double average;
  final double maxSale;
  final double minSale;

  const SalesStats({
    required this.count,
    required this.total,
    required this.average,
    required this.maxSale,
    required this.minSale,
  });
}

/// نموذج المبيعات بالساعة
class HourlySales {
  final int hour;
  final int count;
  final double total;

  const HourlySales({
    required this.hour,
    required this.count,
    required this.total,
  });
}

/// نموذج إحصائيات طرق الدفع
class PaymentMethodStats {
  final String method;
  final int count;
  final double total;

  const PaymentMethodStats({
    required this.method,
    required this.count,
    required this.total,
  });
}
