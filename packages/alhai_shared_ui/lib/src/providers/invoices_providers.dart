/// Invoices Providers - مزودات الفواتير
///
/// توفر بيانات الفواتير من قاعدة البيانات بدلاً من البيانات الوهمية
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

// ============================================================================
// DATA MODELS
// ============================================================================

/// بيانات تفاصيل الفاتورة الكاملة
class InvoiceDetailData {
  final SalesTableData sale;
  final List<SaleItemsTableData> items;

  const InvoiceDetailData({required this.sale, required this.items});
}

/// عدد الفواتير حسب الحالة
class InvoiceStatusCounts {
  final int totalCount;
  final int completedCount;
  final int voidedCount;
  final double completedTotal;
  final double voidedTotal;

  const InvoiceStatusCounts({
    this.totalCount = 0,
    this.completedCount = 0,
    this.voidedCount = 0,
    this.completedTotal = 0,
    this.voidedTotal = 0,
  });
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// قائمة جميع الفواتير (المبيعات)
final invoicesListProvider = FutureProvider.autoDispose<List<SalesTableData>>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.salesDao.getAllSales(storeId);
});

/// إحصائيات المبيعات
final invoicesStatsProvider = FutureProvider.autoDispose<SalesStats>((
  ref,
) async {
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
  return db.salesDao.getSalesStats(storeId);
});

/// إحصائيات طرق الدفع
final paymentMethodStatsProvider =
    FutureProvider.autoDispose<List<PaymentMethodStats>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.salesDao.getPaymentMethodStats(storeId);
    });

/// تفاصيل فاتورة واحدة (بيع + عناصر)
final invoiceDetailProvider = FutureProvider.autoDispose
    .family<InvoiceDetailData?, String>((ref, saleId) async {
      final db = GetIt.I<AppDatabase>();
      final sale = await db.salesDao.getSaleById(saleId);
      if (sale == null) return null;
      final items = await db.saleItemsDao.getItemsBySaleId(saleId);
      return InvoiceDetailData(sale: sale, items: items);
    });

/// إحصائيات حالات الفواتير
final invoiceStatusCountsProvider =
    FutureProvider.autoDispose<InvoiceStatusCounts>((ref) async {
      final invoices = await ref.watch(invoicesListProvider.future);
      int completed = 0, voided = 0;
      double completedTotal = 0, voidedTotal = 0;

      for (final sale in invoices) {
        if (sale.status == 'completed') {
          completed++;
          completedTotal += sale.total;
        } else if (sale.status == 'voided') {
          voided++;
          voidedTotal += sale.total;
        }
      }

      return InvoiceStatusCounts(
        totalCount: invoices.length,
        completedCount: completed,
        voidedCount: voided,
        completedTotal: completedTotal,
        voidedTotal: voidedTotal,
      );
    });
