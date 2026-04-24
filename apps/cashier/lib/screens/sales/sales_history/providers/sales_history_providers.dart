/// Sales History providers
///
/// قرار معماري:
/// - `getSalesPaginated` الحالي في SalesDao يُرجِع Future (ليس Stream).
/// - لا يوجد `watchSalesPaginated` لذا لا يمكن استبدال FutureProvider
///   بـ StreamProvider دون تعديل DAO (خارج نطاق 3.3).
/// - البديل: `AsyncNotifier` يحمل state غير قابل للتبديل ويُعرِّض:
///     • `reload()` - يعيد تحميل الصفحة الأولى (عند تغيير فلتر).
///     • `loadMore()` - يجلب الصفحة التالية ويلحقها بالقائمة.
///     • `setDateFilter()` / `setCustomRange()` / `setSearchQuery()`
///   Realtime: عند تحديث محلي (e.g. بعد عملية بيع) يستطيع الـ caller
///   استدعاء `ref.invalidate(salesHistoryNotifierProvider)` لإعادة التحميل.
///   هذا أقرب ما يمكن من StreamProvider دون تعديل DAO.
library;

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart'
    show currentStoreIdProvider, globalSyncActivationProvider;

import '../../../../core/services/sentry_service.dart';

/// حجم الصفحة عند الـ pagination.
const int kSalesHistoryPageSize = 50;

/// نوع فلتر التاريخ.
enum SalesDateFilter { today, week, month, all, custom }

/// حالة سجل المبيعات (immutable).
class SalesHistoryState {
  const SalesHistoryState({
    this.orders = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.dateFilter = SalesDateFilter.today,
    this.customRange,
    this.searchQuery = '',
  });

  final List<SalesTableData> orders;
  final bool hasMore;
  final bool isLoadingMore;
  final SalesDateFilter dateFilter;
  final DateTimeRange? customRange;
  final String searchQuery;

  /// القائمة بعد تطبيق البحث النصي على العناصر المحمّلة.
  /// ملاحظة: البحث محلي على ما هو محمّل فقط (نفس سلوك الشاشة القديمة).
  List<SalesTableData> get filtered {
    final q = searchQuery.toLowerCase().trim();
    if (q.isEmpty) return orders;
    return orders.where((o) {
      return o.id.toLowerCase().contains(q) ||
          (o.customerId?.toLowerCase().contains(q) ?? false) ||
          (o.customerName?.toLowerCase().contains(q) ?? false) ||
          // C-4: total مخزّن كـ cents — اعرض بصيغة SAR عند البحث.
          (o.total / 100.0).toStringAsFixed(2).contains(q);
    }).toList();
  }

  SalesHistoryState copyWith({
    List<SalesTableData>? orders,
    bool? hasMore,
    bool? isLoadingMore,
    SalesDateFilter? dateFilter,
    DateTimeRange? customRange,
    bool clearCustomRange = false,
    String? searchQuery,
  }) {
    return SalesHistoryState(
      orders: orders ?? this.orders,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      dateFilter: dateFilter ?? this.dateFilter,
      customRange: clearCustomRange ? null : (customRange ?? this.customRange),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// حساب نطاق التاريخ من الفلتر الحالي.
({DateTime? start, DateTime? end}) computeDateRange(
  SalesDateFilter filter,
  DateTimeRange? customRange,
) {
  final now = DateTime.now().toUtc();
  final todayStart = DateTime.utc(now.year, now.month, now.day);

  switch (filter) {
    case SalesDateFilter.today:
      return (start: todayStart, end: null);
    case SalesDateFilter.week:
      return (start: todayStart.subtract(const Duration(days: 7)), end: null);
    case SalesDateFilter.month:
      return (start: DateTime.utc(now.year, now.month, 1), end: null);
    case SalesDateFilter.custom:
      if (customRange == null) return (start: null, end: null);
      return (
        start: customRange.start,
        end: customRange.end.add(const Duration(days: 1)),
      );
    case SalesDateFilter.all:
      return (start: null, end: null);
  }
}

/// AsyncNotifier المسؤول عن سجل المبيعات.
class SalesHistoryNotifier extends AsyncNotifier<SalesHistoryState> {
  AppDatabase get _db => GetIt.I<AppDatabase>();

  @override
  Future<SalesHistoryState> build() async {
    // إعادة تحميل القائمة تلقائياً عند تغيّر store_id (تبديل الفرع
    // في UI). بدون هذا الـ listener تبقى القائمة على الفرع السابق حتى
    // يُعيد المستخدم تطبيق الفلتر يدوياً.
    ref.listen<String?>(currentStoreIdProvider, (prev, next) {
      if (prev != next) {
        // reload يعيد تحميل الصفحة الأولى مع الفلاتر الحالية.
        reload();
      }
    });
    return _loadFirstPage(const SalesHistoryState());
  }

  Future<SalesHistoryState> _loadFirstPage(SalesHistoryState base) async {
    // انتظر اكتمال التزامن العام إن كان متاحاً (صامت عند الفشل).
    try {
      await ref.read(globalSyncActivationProvider.future);
    } catch (e) {
      if (kDebugMode) debugPrint('Sync activation skipped: $e');
    }

    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return base;

    final range = computeDateRange(base.dateFilter, base.customRange);
    // Phase 5 §5.4 — trace sales history first-page load.
    final orders = await tracePerformance(
      name: 'loadSalesPage',
      operation: 'db.query',
      data: {
        'offset': 0,
        'limit': kSalesHistoryPageSize,
        'page': 'first',
      },
      body: () => _db.salesDao.getSalesPaginated(
        storeId,
        offset: 0,
        limit: kSalesHistoryPageSize,
        startDate: range.start,
        endDate: range.end,
      ),
    );

    return base.copyWith(
      orders: orders,
      hasMore: orders.length >= kSalesHistoryPageSize,
      isLoadingMore: false,
    );
  }

  /// إعادة تحميل الصفحة الأولى (مع الفلتر الحالي).
  Future<void> reload() async {
    final current = state.valueOrNull ?? const SalesHistoryState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadFirstPage(current));
  }

  /// جلب الصفحة التالية وإلحاقها.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
        return;
      }
      final range = computeDateRange(current.dateFilter, current.customRange);
      // Phase 5 §5.4 — trace sales history next-page load.
      final more = await tracePerformance(
        name: 'loadSalesPage',
        operation: 'db.query',
        data: {
          'offset': current.orders.length,
          'limit': kSalesHistoryPageSize,
          'page': 'more',
        },
        body: () => _db.salesDao.getSalesPaginated(
          storeId,
          offset: current.orders.length,
          limit: kSalesHistoryPageSize,
          startDate: range.start,
          endDate: range.end,
        ),
      );
      state = AsyncData(
        current.copyWith(
          orders: [...current.orders, ...more],
          hasMore: more.length >= kSalesHistoryPageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// تغيير فلتر التاريخ (يعيد التحميل من الصفحة الأولى).
  Future<void> setDateFilter(SalesDateFilter filter) async {
    final current = state.valueOrNull ?? const SalesHistoryState();
    final next = current.copyWith(
      dateFilter: filter,
      clearCustomRange: filter != SalesDateFilter.custom,
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadFirstPage(next));
  }

  /// تعيين نطاق تاريخ مخصّص (يعيد التحميل).
  Future<void> setCustomRange(DateTimeRange range) async {
    final current = state.valueOrNull ?? const SalesHistoryState();
    final next = current.copyWith(
      dateFilter: SalesDateFilter.custom,
      customRange: range,
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadFirstPage(next));
  }

  /// تحديث نص البحث (فلترة محلية — لا استعلام).
  void setSearchQuery(String query) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(searchQuery: query));
  }
}

/// مزود سجل المبيعات.
final salesHistoryNotifierProvider =
    AsyncNotifierProvider<SalesHistoryNotifier, SalesHistoryState>(
      SalesHistoryNotifier.new,
    );
