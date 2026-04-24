/// فلاتر كشف حساب العميل — حالة التاريخ والنوع والمدى المخصص
///
/// يستبدل متغيّرات `setState` الثلاثة في الشاشة القديمة
/// (`_dateFilter`, `_typeFilter`, `_customDateRange`) بـ StateNotifier
/// موحَّد لتتبّع تغييرات الفلاتر دون setState داخل الشاشة.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// قيم فلتر التاريخ المدعومة
class LedgerDateFilter {
  static const all = 'all';
  static const thisMonth = 'thisMonth';
  static const threeMonths = 'threeMonths';
  static const custom = 'custom';
}

/// قيم فلتر نوع الحركة المدعومة
class LedgerTypeFilter {
  static const all = 'all';
  static const invoice = 'invoice';
  static const payment = 'payment';
  static const returnType = 'return';
  static const adjustment = 'adjustment';
}

/// كائن فلاتر كشف الحساب (immutable)
@immutable
class LedgerFilters {
  final String dateFilter;
  final String typeFilter;
  final DateTimeRange? customDateRange;

  const LedgerFilters({
    this.dateFilter = LedgerDateFilter.all,
    this.typeFilter = LedgerTypeFilter.all,
    this.customDateRange,
  });

  LedgerFilters copyWith({
    String? dateFilter,
    String? typeFilter,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
  }) => LedgerFilters(
    dateFilter: dateFilter ?? this.dateFilter,
    typeFilter: typeFilter ?? this.typeFilter,
    customDateRange: clearCustomDateRange
        ? null
        : (customDateRange ?? this.customDateRange),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LedgerFilters &&
          runtimeType == other.runtimeType &&
          dateFilter == other.dateFilter &&
          typeFilter == other.typeFilter &&
          customDateRange?.start == other.customDateRange?.start &&
          customDateRange?.end == other.customDateRange?.end;

  @override
  int get hashCode => Object.hash(
    dateFilter,
    typeFilter,
    customDateRange?.start,
    customDateRange?.end,
  );
}

/// Notifier لإدارة فلاتر كشف الحساب
class LedgerFiltersNotifier extends StateNotifier<LedgerFilters> {
  LedgerFiltersNotifier() : super(const LedgerFilters());

  /// تعيين فلتر التاريخ (يمسح المدى المخصّص عند الخيار "الكل")
  void setDateFilter(String value) {
    if (value == LedgerDateFilter.all) {
      state = state.copyWith(
        dateFilter: value,
        clearCustomDateRange: true,
      );
    } else {
      state = state.copyWith(dateFilter: value);
    }
  }

  /// تعيين فلتر النوع
  void setTypeFilter(String value) =>
      state = state.copyWith(typeFilter: value);

  /// تعيين مدى تاريخ مخصّص (يُرفِق تلقائياً بـ dateFilter='custom')
  void setCustomDateRange(DateTimeRange range) => state = state.copyWith(
    dateFilter: LedgerDateFilter.custom,
    customDateRange: range,
  );

  /// إعادة الضبط للإعدادات الافتراضية
  void reset() => state = const LedgerFilters();
}

/// Provider يوفّر فلاتر كشف الحساب الحالية (autoDispose لكل شاشة حساب)
final ledgerFiltersProvider =
    StateNotifierProvider.autoDispose<LedgerFiltersNotifier, LedgerFilters>(
      (ref) => LedgerFiltersNotifier(),
    );
