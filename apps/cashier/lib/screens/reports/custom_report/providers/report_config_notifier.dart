/// إعدادات بناء التقرير المخصص (نوع + تجميع + مدى زمني)
///
/// يحمل تكوين التقرير بصيغة ثابتة (immutable) ويُعرض عبر
/// [reportConfigProvider] لتتابعه الـ widgets بدل `setState`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// كائن إعداد تقرير ثابت
@immutable
class ReportConfig {
  final String reportType;
  final String groupBy;
  final DateTimeRange? dateRange;

  const ReportConfig({
    required this.reportType,
    required this.groupBy,
    this.dateRange,
  });

  /// إعداد افتراضي: مبيعات + يومي + الشهر الحالي حتى الآن
  factory ReportConfig.initial() {
    final now = DateTime.now();
    return ReportConfig(
      reportType: 'sales',
      groupBy: 'day',
      dateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
    );
  }

  ReportConfig copyWith({
    String? reportType,
    String? groupBy,
    DateTimeRange? dateRange,
  }) => ReportConfig(
    reportType: reportType ?? this.reportType,
    groupBy: groupBy ?? this.groupBy,
    dateRange: dateRange ?? this.dateRange,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportConfig &&
          runtimeType == other.runtimeType &&
          reportType == other.reportType &&
          groupBy == other.groupBy &&
          dateRange?.start == other.dateRange?.start &&
          dateRange?.end == other.dateRange?.end;

  @override
  int get hashCode => Object.hash(
    reportType,
    groupBy,
    dateRange?.start,
    dateRange?.end,
  );
}

/// Notifier لإدارة إعداد التقرير
class ReportConfigNotifier extends StateNotifier<ReportConfig> {
  ReportConfigNotifier() : super(ReportConfig.initial());

  void setReportType(String type) => state = state.copyWith(reportType: type);

  void setGroupBy(String group) => state = state.copyWith(groupBy: group);

  void setDateRange(DateTimeRange range) =>
      state = state.copyWith(dateRange: range);
}

/// Provider يوفّر تكوين التقرير الحالي
final reportConfigProvider =
    StateNotifierProvider.autoDispose<ReportConfigNotifier, ReportConfig>(
      (ref) => ReportConfigNotifier(),
    );
