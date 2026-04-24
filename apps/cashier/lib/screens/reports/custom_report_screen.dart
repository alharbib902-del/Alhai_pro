/// Bridge للملف المُعاد هيكلته تحت [custom_report/].
///
/// تم تقسيم الشاشة الأصلية (1251 سطر + 48 setState) إلى container +
/// widgets + providers تحت `custom_report/`. هذا الملف يُبقي المسار
/// القديم `screens/reports/custom_report_screen.dart` شغّالاً عبر
/// إعادة التصدير، حتى لا يتغيّر router أو الاختبارات الحالية.
library;

export 'custom_report/custom_report_screen.dart' show CustomReportScreen;
