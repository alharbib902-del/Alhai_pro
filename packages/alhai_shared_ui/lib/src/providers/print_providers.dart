/// مزودات قائمة الطباعة - Print Queue Providers
///
/// يدير قائمة مهام الطباعة المعلقة والفاشلة باستخدام Riverpod
/// يعمل بالذاكرة (in-memory) بدون حاجة لجدول قاعدة بيانات إضافي
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// نموذج مهمة الطباعة
class PrintJob {
  final String id;
  final String saleId;
  final String receiptNo;
  final String type; // 'receipt', 'report', 'barcode'
  final String status; // 'pending', 'failed', 'printing', 'completed'
  final String? errorMessage;
  final int retryCount;
  final DateTime createdAt;

  PrintJob({
    required this.id,
    required this.saleId,
    required this.receiptNo,
    required this.type,
    this.status = 'pending',
    this.errorMessage,
    this.retryCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'saleId': saleId,
        'receiptNo': receiptNo,
        'type': type,
        'status': status,
        'errorMessage': errorMessage,
        'retryCount': retryCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PrintJob.fromJson(Map<String, dynamic> json) => PrintJob(
        id: json['id'] as String,
        saleId: json['saleId'] as String? ?? '',
        receiptNo: json['receiptNo'] as String? ?? '',
        type: json['type'] as String,
        status: json['status'] as String? ?? 'pending',
        errorMessage: json['errorMessage'] as String?,
        retryCount: json['retryCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  PrintJob copyWith({
    String? status,
    String? errorMessage,
    int? retryCount,
  }) =>
      PrintJob(
        id: id,
        saleId: saleId,
        receiptNo: receiptNo,
        type: type,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt,
      );
}

/// مدير قائمة الطباعة
class PrintQueueNotifier extends StateNotifier<List<PrintJob>> {
  PrintQueueNotifier() : super([]);

  /// إضافة مهمة طباعة جديدة
  void addJob(PrintJob job) {
    state = [...state, job];
  }

  /// إزالة مهمة من القائمة
  void removeJob(String id) {
    state = state.where((j) => j.id != id).toList();
  }

  /// مسح جميع المهام
  void clearAll() {
    state = [];
  }

  /// مسح المهام المكتملة فقط
  void clearCompleted() {
    state = state.where((j) => j.status != 'completed').toList();
  }

  /// تحديد مهمة كفاشلة
  void markFailed(String id, String error) {
    state = state
        .map((j) => j.id == id
            ? j.copyWith(
                status: 'failed',
                errorMessage: error,
                retryCount: j.retryCount + 1,
              )
            : j)
        .toList();
  }

  /// تحديد مهمة كمكتملة
  void markCompleted(String id) {
    state = state
        .map((j) => j.id == id ? j.copyWith(status: 'completed') : j)
        .toList();
  }

  /// إعادة محاولة طباعة مهمة فاشلة
  void retryJob(String id) {
    state = state
        .map((j) => j.id == id
            ? j.copyWith(status: 'pending', errorMessage: null)
            : j)
        .toList();
  }

  /// تحديد مهمة كجاري الطباعة
  void markPrinting(String id) {
    state = state
        .map((j) => j.id == id ? j.copyWith(status: 'printing') : j)
        .toList();
  }

  /// عدد المهام المعلقة
  int get pendingCount => state.where((j) => j.status == 'pending').length;

  /// عدد المهام الفاشلة
  int get failedCount => state.where((j) => j.status == 'failed').length;
}

/// مزود قائمة الطباعة
final printQueueProvider =
    StateNotifierProvider<PrintQueueNotifier, List<PrintJob>>(
  (ref) => PrintQueueNotifier(),
);

/// مزود عدد المهام المعلقة (للشارة في القائمة الجانبية)
final pendingPrintCountProvider = Provider<int>((ref) {
  final jobs = ref.watch(printQueueProvider);
  return jobs.where((j) => j.status == 'pending' || j.status == 'failed').length;
});

/// Callback type for auto-printing a receipt by sale ID
///
/// Implementations should fetch sale data from the database and print
/// using the configured thermal printer (ESC/POS).
typedef AutoPrintCallback = Future<bool> Function(String saleId);

/// Provider for the auto-print callback, set by the app layer (e.g. cashier).
/// When non-null and auto-print is enabled, the POS screen will automatically
/// print a receipt after each successful payment.
final autoPrintCallbackProvider =
    StateProvider<AutoPrintCallback?>((ref) => null);

/// Whether auto-print is enabled
final autoPrintEnabledProvider = StateProvider<bool>((ref) => false);
