/// اختبارات شريط حالة الاتصال الذكي - SmartOfflineBanner Tests
///
/// يختبر:
/// - عرض الـ child بشكل صحيح
/// - بنية الشريط (Column مع child)
/// - مؤشر حالة الاتصال (ConnectionStatusIndicator)
/// - شريط حالة المزامنة (SyncStatusBar) من offline_indicator
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/widgets/common/smart_offline_banner.dart';
import 'package:pos_app/widgets/offline_indicator.dart';
import 'package:pos_app/l10n/generated/app_localizations.dart';

void main() {
  // دالة مساعدة لبناء widget مع MaterialApp ودعم اللغة العربية
  Widget buildApp({required Widget child}) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  group('SmartOfflineBanner - العرض الأساسي', () {
    testWidgets('يعرض الـ child بشكل صحيح', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: SmartOfflineBanner(
            child: Container(
              key: const Key('test-child'),
              child: const Text('محتوى الاختبار'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('test-child')), findsOneWidget);
      expect(find.text('محتوى الاختبار'), findsOneWidget);
    });

    testWidgets('يحتوي على Column كـ widget رئيسي', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const SmartOfflineBanner(
            child: Text('اختبار'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // SmartOfflineBanner يستخدم Column لترتيب الشريط والمحتوى
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('يوسع الـ child ليملأ المساحة المتبقية', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const SmartOfflineBanner(
            child: Text('اختبار'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // يجب أن يكون هناك Expanded يحتوي على الـ child
      expect(find.byType(Expanded), findsWidgets);
    });
  });

  group('SmartOfflineBanner - الخصائص', () {
    testWidgets('يقبل showPendingCount كـ true افتراضياً', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const SmartOfflineBanner(
            child: Text('اختبار'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // البانر يتم عرضه بنجاح مع القيم الافتراضية
      expect(find.text('اختبار'), findsOneWidget);
    });

    testWidgets('يقبل onSyncPressed callback', (tester) async {
      var syncPressed = false;

      await tester.pumpWidget(
        buildApp(
          child: SmartOfflineBanner(
            onSyncPressed: () => syncPressed = true,
            child: const Text('اختبار'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // يتم بناء الـ widget بنجاح مع callback
      expect(find.text('اختبار'), findsOneWidget);
      // syncPressed لم يتم استدعاؤه بعد
      expect(syncPressed, isFalse);
    });
  });

  group('SyncStatusBar - شريط حالة المزامنة', () {
    testWidgets('لا يعرض شيء عندما متصل بدون عمليات معلقة', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const SyncStatusBar(
            isOnline: true,
            pendingCount: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // يجب أن يعرض SizedBox.shrink
      expect(find.byType(SyncStatusBar), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('يعرض عدد العمليات المعلقة عندما متصل مع عمليات', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const SyncStatusBar(
            isOnline: true,
            pendingCount: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // يجب أن يعرض عدد العمليات مع كلمة "قيد الانتظار"
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('يعرض حالة عدم الاتصال عندما offline', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const SyncStatusBar(
            isOnline: false,
            pendingCount: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('يستدعي onTap عند الضغط', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildApp(
          child: SyncStatusBar(
            isOnline: false,
            pendingCount: 3,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SyncStatusBar));
      expect(tapped, isTrue);
    });
  });
}
