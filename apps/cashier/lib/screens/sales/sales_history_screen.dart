/// Backward-compat bridge for 3.3 split.
///
/// الملف الأصلي (1148 سطر + 40 setState) قُسِّم إلى:
///   sales_history/sales_history_screen.dart  (container ≈ 140)
///   sales_history/widgets/filters_bar.dart
///   sales_history/widgets/sales_list.dart
///   sales_history/widgets/sale_detail_sheet.dart
///   sales_history/widgets/sales_summary_header.dart
///   sales_history/providers/sales_history_providers.dart
///
/// هذا الملف يُبقي المسار القديم `screens/sales/sales_history_screen.dart`
/// يعمل لتوافق الـ router والاختبارات الموجودة.
library;

export 'sales_history/sales_history_screen.dart';
