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

/// الإجماليات (مدين/دائن) على القائمة المفلترة
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
      return LedgerTotals(debit: debit, credit: credit);
    });

/// إجماليات المدين/الدائن للحركات المفلترة
class LedgerTotals {
  final double debit;
  final double credit;
  const LedgerTotals({required this.debit, required this.credit});
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
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
    list = list
        .where((t) => (t['date'] as DateTime).isAfter(threeMonthsAgo))
        .toList();
  } else if (filters.dateFilter == LedgerDateFilter.custom &&
      filters.customDateRange != null) {
    final range = filters.customDateRange!;
    list = list
        .where(
          (t) =>
              (t['date'] as DateTime).isAfter(range.start) &&
              (t['date'] as DateTime).isBefore(
                range.end.add(const Duration(days: 1)),
              ),
        )
        .toList();
  }

  if (filters.typeFilter != LedgerTypeFilter.all) {
    list = list.where((t) => t['type'] == filters.typeFilter).toList();
  }

  return list;
}
