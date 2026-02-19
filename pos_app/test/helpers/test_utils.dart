/// أدوات الاختبار لتطبيق نقاط البيع
///
/// يصدر جميع أدوات الاختبار من alhai_core ويضيف أدوات خاصة بالتطبيق
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// إعادة تصدير أدوات alhai_core
// أدوات alhai_core متاحة عبر الحزمة الرئيسية

/// ينشئ widget للاختبار مع MaterialApp وRiverpod
Widget createTestApp({
  required Widget child,
  List<Override>? overrides,
  ThemeData? theme,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      theme: theme ?? AlhaiTheme.light,
      home: child,
    ),
  );
}

/// ينشئ widget للاختبار مع Scaffold
Widget createScaffoldTestApp({
  required Widget body,
  List<Override>? overrides,
  PreferredSizeWidget? appBar,
}) {
  return createTestApp(
    overrides: overrides,
    child: Scaffold(
      appBar: appBar,
      body: body,
    ),
  );
}

/// Extension لتسهيل اختبارات Widget
extension WidgetTesterX on WidgetTester {
  /// يضخ widget مع انتظار الرسوم المتحركة
  Future<void> pumpApp(Widget widget, {List<Override>? overrides}) async {
    await pumpWidget(createTestApp(child: widget, overrides: overrides));
    await pumpAndSettle();
  }

  /// يضغط على widget وينتظر
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// يدخل نص وينتظر
  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }
}

/// Extension لتسهيل البحث عن widgets
extension FinderX on CommonFinders {
  /// يبحث عن widget بواسطة Key string
  Finder byKeyString(String key) => byKey(Key(key));

  /// يبحث عن زر بنص معين
  Finder buttonWithText(String text) => widgetWithText(ElevatedButton, text);

  /// يبحث عن حقل إدخال بتلميح معين
  Finder textFieldWithHint(String hint) =>
      widgetWithText(TextField, hint);
}
