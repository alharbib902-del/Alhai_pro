/// Settings & Reports Providers - مزودات الإعدادات والتقارير
///
/// توفر بيانات التقارير والإعدادات من قاعدة البيانات
library;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

// ============================================================================
// REPORTS PROVIDERS
// ============================================================================

/// إحصائيات المبيعات (للتقارير)
final salesAnalyticsProvider = FutureProvider.autoDispose
    .family<SalesStats, DateRange?>((ref, dateRange) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) {
    return const SalesStats(
      count: 0,
      total: 0,
      average: 0,
      maxSale: 0,
      minSale: 0,
    );
  }
  final db = GetIt.I<AppDatabase>();
  return db.salesDao.getSalesStats(
    storeId,
    startDate: dateRange?.start,
    endDate: dateRange?.end,
  );
});

/// المبيعات بالساعة (تقرير أوقات الذروة)
final hourlySalesProvider = FutureProvider.autoDispose
    .family<List<HourlySales>, DateTime>((ref, date) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.salesDao.getHourlySales(storeId, date);
});

/// مبيعات يوم محدد
final dailySalesProvider = FutureProvider.autoDispose
    .family<List<SalesTableData>, DateTime>((ref, date) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.salesDao.getSalesByDate(storeId, date);
});

/// إحصائيات طرق الدفع (للتقارير)
final paymentReportProvider =
    FutureProvider.autoDispose<List<PaymentMethodStats>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.salesDao.getPaymentMethodStats(storeId);
});

// ============================================================================
// SETTINGS PROVIDERS - Users & Roles
// ============================================================================

/// قائمة المستخدمين
final usersListProvider = FutureProvider.autoDispose<List<UsersTableData>>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.usersDao.getAllUsers(storeId);
});

/// قائمة الأدوار
final rolesListProvider = FutureProvider.autoDispose<List<RolesTableData>>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.usersDao.getAllRoles(storeId);
});

/// سجل النشاطات
final activityLogProvider = FutureProvider.autoDispose<List<AuditLogTableData>>(
  (ref) async {
    final storeId = ref.watch(currentStoreIdProvider);
    if (storeId == null) return [];
    final db = GetIt.I<AppDatabase>();
    return db.auditLogDao.getLogs(storeId, limit: 100);
  },
);

/// سجل النشاطات حسب الفترة
final activityLogByDateProvider = FutureProvider.autoDispose
    .family<List<AuditLogTableData>, DateRange>((ref, dateRange) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.auditLogDao.getLogsByDateRange(
    storeId,
    dateRange.start,
    dateRange.end,
  );
});

// ============================================================================
// PAYMENT DEVICE SETTINGS PROVIDER
// ============================================================================

/// بيانات إعدادات أجهزة الدفع
class PaymentDeviceSettings {
  final bool enableMada;
  final bool enableVisa;
  final bool enableStcPay;
  final bool enableApplePay;
  final String terminalType;
  final bool autoSettle;
  final bool enableNfcSoftPos;
  final String softPosMode;

  const PaymentDeviceSettings({
    this.enableMada = true,
    this.enableVisa = true,
    this.enableStcPay = false,
    this.enableApplePay = false,
    this.terminalType = 'ingenico',
    this.autoSettle = true,
    this.enableNfcSoftPos = false,
    this.softPosMode = 'mock',
  });

  /// Whether any card-based payment method is enabled
  bool get hasCardPayment => enableMada || enableVisa;

  /// Whether any digital wallet is enabled
  bool get hasDigitalWallet => enableStcPay || enableApplePay;

  /// Whether NFC SoftPOS is enabled
  bool get hasSoftPos => enableNfcSoftPos;
}

/// مزود إعدادات أجهزة الدفع
final paymentDeviceSettingsProvider =
    FutureProvider.autoDispose<PaymentDeviceSettings>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const PaymentDeviceSettings();

  final db = GetIt.I<AppDatabase>();
  try {
    final settings = await (db.select(
      db.settingsTable,
    )..where((s) => s.storeId.equals(storeId)))
        .get();

    final settingsMap = <String, String>{};
    for (final s in settings) {
      settingsMap[s.key] = s.value;
    }

    return PaymentDeviceSettings(
      enableMada: settingsMap['payment_enable_mada'] != 'false',
      enableVisa: settingsMap['payment_enable_visa'] != 'false',
      enableStcPay: settingsMap['payment_enable_stc_pay'] == 'true',
      enableApplePay: settingsMap['payment_enable_apple_pay'] == 'true',
      terminalType: settingsMap['payment_terminal_type'] ?? 'ingenico',
      autoSettle: settingsMap['payment_auto_settle'] != 'false',
      enableNfcSoftPos: settingsMap['payment_enable_nfc_softpos'] == 'true',
      softPosMode: settingsMap['payment_softpos_mode'] ?? 'mock',
    );
  } catch (e) {
    if (kDebugMode) debugPrint('Error parsing payment settings: $e');
    return const PaymentDeviceSettings();
  }
});

// ============================================================================
// DATA MODELS
// ============================================================================

/// نطاق زمني
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}
