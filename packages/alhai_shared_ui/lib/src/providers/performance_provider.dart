import 'package:flutter_riverpod/flutter_riverpod.dart';

/// نظام قياس أداء الكاشير
///
/// يتتبع:
/// - متوسط وقت البيع
/// - عمليات/ساعة
/// - أخطاء الدفع

/// بيانات عملية بيع واحدة
class SalePerformance {
  final String saleId;
  final DateTime startTime;
  final DateTime? endTime;
  final int itemCount;
  final double totalAmount;
  final bool hasError;
  final String? errorMessage;

  const SalePerformance({
    required this.saleId,
    required this.startTime,
    this.endTime,
    this.itemCount = 0,
    this.totalAmount = 0,
    this.hasError = false,
    this.errorMessage,
  });

  /// مدة العملية بالثواني
  int get durationSeconds {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inSeconds;
  }

  /// هل اكتملت
  bool get isCompleted => endTime != null;

  SalePerformance copyWith({
    DateTime? endTime,
    int? itemCount,
    double? totalAmount,
    bool? hasError,
    String? errorMessage,
  }) {
    return SalePerformance(
      saleId: saleId,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      itemCount: itemCount ?? this.itemCount,
      totalAmount: totalAmount ?? this.totalAmount,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// إحصائيات الأداء
class PerformanceStats {
  final List<SalePerformance> sales;
  final DateTime sessionStart;

  PerformanceStats({this.sales = const [], DateTime? sessionStart})
    : sessionStart = sessionStart ?? DateTime.now();

  /// عدد العمليات المكتملة
  int get completedSales => sales.where((s) => s.isCompleted).length;

  /// عدد الأخطاء
  int get errorCount => sales.where((s) => s.hasError).length;

  /// متوسط وقت البيع (ثانية)
  double get avgSaleTime {
    final completed = sales.where((s) => s.isCompleted).toList();
    if (completed.isEmpty) return 0;
    final total = completed.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    return total / completed.length;
  }

  /// عمليات في الساعة
  double get salesPerHour {
    final now = DateTime.now();
    final hoursElapsed = now.difference(sessionStart).inMinutes / 60;
    if (hoursElapsed < 0.1) return 0;
    return completedSales / hoursElapsed;
  }

  /// إجمالي المبيعات
  double get totalSales {
    return sales
        .where((s) => s.isCompleted)
        .fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  /// نسبة الأخطاء
  double get errorRate {
    if (sales.isEmpty) return 0;
    return errorCount / sales.length * 100;
  }

  PerformanceStats copyWith({
    List<SalePerformance>? sales,
    DateTime? sessionStart,
  }) {
    return PerformanceStats(
      sales: sales ?? this.sales,
      sessionStart: sessionStart ?? this.sessionStart,
    );
  }
}

/// مدير الأداء
class PerformanceNotifier extends StateNotifier<PerformanceStats> {
  PerformanceNotifier() : super(PerformanceStats());

  /// الحد الأقصى لعدد العمليات المخزّنة لمنع تراكم الذاكرة
  static const int _maxSalesHistory = 100;

  String? _currentSaleId;

  /// بدء عملية بيع جديدة
  String startSale() {
    _currentSaleId = DateTime.now().millisecondsSinceEpoch.toString();
    final sale = SalePerformance(
      saleId: _currentSaleId!,
      startTime: DateTime.now(),
    );

    // Trim old entries to prevent unbounded memory growth
    var updatedSales = [...state.sales, sale];
    if (updatedSales.length > _maxSalesHistory) {
      updatedSales = updatedSales.sublist(
        updatedSales.length - _maxSalesHistory,
      );
    }

    state = state.copyWith(sales: updatedSales);
    return _currentSaleId!;
  }

  /// إنهاء عملية البيع الحالية
  void completeSale({required int itemCount, required double totalAmount}) {
    if (_currentSaleId == null) return;

    final updatedSales = state.sales.map((sale) {
      if (sale.saleId == _currentSaleId) {
        return sale.copyWith(
          endTime: DateTime.now(),
          itemCount: itemCount,
          totalAmount: totalAmount,
        );
      }
      return sale;
    }).toList();

    state = state.copyWith(sales: updatedSales);
    _currentSaleId = null;
  }

  /// تسجيل خطأ في البيع الحالي
  void recordError(String errorMessage) {
    if (_currentSaleId == null) return;

    final updatedSales = state.sales.map((sale) {
      if (sale.saleId == _currentSaleId) {
        return sale.copyWith(hasError: true, errorMessage: errorMessage);
      }
      return sale;
    }).toList();

    state = state.copyWith(sales: updatedSales);
  }

  /// إلغاء البيع الحالي
  void cancelSale() {
    if (_currentSaleId == null) return;

    final updatedSales = state.sales
        .where((s) => s.saleId != _currentSaleId)
        .toList();
    state = state.copyWith(sales: updatedSales);
    _currentSaleId = null;
  }

  /// إعادة تعيين الجلسة
  void resetSession() {
    state = PerformanceStats();
    _currentSaleId = null;
  }

  /// هل يوجد بيع نشط
  bool get hasSaleInProgress => _currentSaleId != null;
}

/// مزودات الأداء
final performanceProvider =
    StateNotifierProvider<PerformanceNotifier, PerformanceStats>(
      (ref) => PerformanceNotifier(),
    );

/// متوسط وقت البيع
final avgSaleTimeProvider = Provider<double>((ref) {
  return ref.watch(performanceProvider).avgSaleTime;
});

/// عمليات في الساعة
final salesPerHourProvider = Provider<double>((ref) {
  return ref.watch(performanceProvider).salesPerHour;
});

/// نسبة الأخطاء
final errorRateProvider = Provider<double>((ref) {
  return ref.watch(performanceProvider).errorRate;
});

/// عدد العمليات المكتملة
final completedSalesCountProvider = Provider<int>((ref) {
  return ref.watch(performanceProvider).completedSales;
});
