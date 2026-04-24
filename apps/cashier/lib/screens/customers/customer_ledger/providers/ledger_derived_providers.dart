/// Providers مشتقّة (derived) — تنتج قوائم مفلترة + إجماليات
///
/// تعتمد على:
/// - [accountLedgerDataProvider] (البيانات الخام من DB)
/// - [ledgerFiltersProvider] (اختيار المستخدم للفلاتر)
///
/// عند تغيير أي مدخل يُعاد الحساب تلقائياً (Riverpod reactive).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';

import '../widgets/_ledger_helpers.dart';
import 'customer_ledger_providers.dart';
import 'ledger_filters_notifier.dart';

/// قائمة الحركات المفلترة (maps جاهزة للعرض)
///
/// family: accountId (لمطابقة accountLedgerDataProvider)
final filteredLedgerTxnsProvider = Provider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, accountId) {
      final dataAsync = ref.watch(accountLedgerDataProvider(accountId));
      final filters = ref.watch(ledgerFiltersProvider);
      return dataAsync.maybeWhen(
        data: (data) => _filter(data.transactions, filters),
        orElse: () => const [],
      );
    });

/// الإجماليات (مدين/دائن) على القائمة المفلترة + الرصيد النهائي الحقيقي.
///
/// P1 #11: finalBalance سابقاً كان (debit - credit) على القائمة المفلترة
/// وهذا يتجاهل الرصيد الافتتاحي. الحل: نستخرج `balance` من آخر حركة
/// (أحدث تاريخ) في القائمة المفلترة — هذه هي قيمة `balance_after` التي
/// سجّلتها الحركة، وتُمثّل الرصيد الفعلي بعد تطبيق كل الحركات السابقة
/// بما فيها الرصيد الافتتاحي.
final ledgerTotalsProvider =
    Provider.autoDispose.family<LedgerTotals, String>((ref, accountId) {
      final filtered = ref.watch(filteredLedgerTxnsProvider(accountId));
      final debit = filtered.fold<double>(
        0.0,
        (sum, t) => sum + (t['debit'] as double),
      );
      final credit = filtered.fold<double>(
        0.0,
        (sum, t) => sum + (t['credit'] as double),
      );
      // Pick the most recent transaction's balance_after. Entries from
      // `ledgerTxnToMap` store `balance` as the post-transaction SAR value;
      // the helper doesn't guarantee order, so we pick max-date defensively.
      double? finalBalance;
      if (filtered.isNotEmpty) {
        var latestIdx = 0;
        var latestDate = filtered[0]['date'] as DateTime;
        for (var i = 1; i < filtered.length; i++) {
          final d = filtered[i]['date'] as DateTime;
          if (d.isAfter(latestDate)) {
            latestDate = d;
            latestIdx = i;
          }
        }
        finalBalance = filtered[latestIdx]['balance'] as double?;
      }
      return LedgerTotals(
        debit: debit,
        credit: credit,
        finalBalance: finalBalance,
      );
    });

/// إجماليات المدين/الدائن للحركات المفلترة + الرصيد النهائي الحقيقي.
class LedgerTotals {
  final double debit;
  final double credit;

  /// الرصيد النهائي من آخر حركة مفلترة (post-transaction balance).
  /// يكون null عندما تكون القائمة فارغة.
  final double? finalBalance;
  const LedgerTotals({
    required this.debit,
    required this.credit,
    this.finalBalance,
  });
}

/// فلترة خام حسب [LedgerFilters] (منطق pure)
List<Map<String, dynamic>> _filter(
  List<TransactionsTableData> transactions,
  LedgerFilters filters,
) {
  var list = transactions.expand(ledgerTxnToMap).toList();

  final now = DateTime.now();
  if (filters.dateFilter == LedgerDateFilter.thisMonth) {
    list = list
        .where(
          (t) =>
              (t['date'] as DateTime).month == now.month &&
              (t['date'] as DateTime).year == now.year,
        )
        .toList();
  } else if (filters.dateFilter == LedgerDateFilter.threeMonths) {
    // P1 #15: `DateTime(y, m - 3, d)` is unreliable when `d >= 29`.
    // Example: on Mar 30, `DateTime(2026, 0, 30)` → Dec 30 2025 (fine),
    // but on May 31 `DateTime(2026, 2, 31)` → Mar 3 (Feb has 28 days,
    // overflow rolls forward). Use day=1 to pin the cutoff at the start
    // of the target month — predictable and matches "last three months"
    // semantics (we don't care about the exact day-of-month boundary).
    final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
    list = list
        .where((t) => (t['date'] as DateTime).isAfter(threeMonthsAgo))
        .toList();
  } else if (filters.dateFilter == LedgerDateFilter.custom &&
      filters.customDateRange != null) {
    final range = filters.customDateRange!;
    // P2 #8: `isAfter(range.start)` is strict — it drops transactions that
    // happened at the exact start millisecond. `!isBefore(range.start)`
    // is inclusive of the boundary, which matches user intent for a
    // day-granularity range picker ("from 2026-04-01" should include
    // 00:00:00.000 of that day).
    list = list
        .where((t) {
          final d = t['date'] as DateTime;
          return !d.isBefore(range.start) &&
              d.isBefore(range.end.add(const Duration(days: 1)));
        })
        .toList();
  }

  if (filters.typeFilter != LedgerTypeFilter.all) {
    list = list.where((t) => t['type'] == filters.typeFilter).toList();
  }

  return list;
}
