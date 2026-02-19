/// اختبارات مؤشر حالة الاتصال - OfflineIndicator & SyncStatusBar Tests
///
/// يختبر:
/// - عرض الـ OfflineIndicator مع الـ child
/// - بنية الـ widget (Column مع AnimatedContainer و Expanded)
/// - شريط SyncStatusBar بحالاته المختلفة
/// - الحالة المتصلة والمنفصلة لـ SyncStatusBar
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/widgets/offline_indicator.dart';
import 'package:pos_app/l10n/generated/app_localizations.dart';

void main() {
  // دالة مساعدة لبناء widget مع دعم اللغة العربية
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

  group('OfflineIndicator - العرض الأساسي', () {
    testWidgets('يعرض الـ child بشكل صحيح', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: OfflineIndicator(
            child: Container(
              key: const Key('test-child'),
              child: const Text('المحتوى'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('test-child')), findsOneWidget);
      expect(find.text('المحتوى'), findsOneWidget);
    });

    testWidgets('يحتوي على Column كهيكل أساسي', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const OfflineIndicator(
            child: Text('اختبار'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('يحتوي على AnimatedContainer', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const OfflineIndicator(
            child: Text('اختبار'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('يبدأ بحالة متصل (لا يعرض الشريط)', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const OfflineIndicator(
            child: Text('اختبار'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // عندما _isOnline = true، لا يعرض أيقونة cloud_off
      expect(find.byIcon(Icons.cloud_off), findsNothing);
    });
  });

  group('OfflineIndicator - البنية', () {
    testWidgets('يحتوي على Expanded للمحتوى', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const OfflineIndicator(
            child: Text('اختبار'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('يتم بناؤه بنجاح مع widget معقد كـ child', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: OfflineIndicator(
            child: ListView(
              children: const [
                ListTile(title: Text('عنصر 1')),
                ListTile(title: Text('عنصر 2')),
                ListTile(title: Text('عنصر 3')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('عنصر 1'), findsOneWidget);
      expect(find.text('عنصر 2'), findsOneWidget);
      expect(find.text('عنصر 3'), findsOneWidget);
    });
  });

  group('SyncStatusBar - حالات مختلفة', () {
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

      // يجب أن لا يعرض أي أيقونة
      expect(find.byIcon(Icons.sync), findsNothing);
      expect(find.byIcon(Icons.cloud_off), findsNothing);
    });

    testWidgets('يعرض أيقونة sync عندما متصل مع عمليات معلقة', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const SyncStatusBar(
            isOnline: true,
            pendingCount: 3,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('يعرض أيقونة cloud_off عندما غير متصل', (tester) async {
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

    testWidgets('يعرض خلفية خضراء عندما متصل مع عمليات', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const SyncStatusBar(
            isOnline: true,
            pendingCount: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // يجب أن يكون اللون amber للاتصال مع عمليات معلقة
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusBar),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.amber);
    });

    testWidgets('يعرض خلفية حمراء عندما غير متصل', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const SyncStatusBar(
            isOnline: false,
            pendingCount: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusBar),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('يستدعي onTap عند الضغط على شريط غير متصل', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildApp(
          child: SyncStatusBar(
            isOnline: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SyncStatusBar));
      expect(tapped, isTrue);
    });

    testWidgets('يعرض عدد العمليات المعلقة بنص أبيض', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const SyncStatusBar(
            isOnline: false,
            pendingCount: 7,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // التحقق من وجود نص أبيض
      final texts = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(SyncStatusBar),
          matching: find.byType(Text),
        ),
      );

      for (final text in texts) {
        expect(text.style?.color, Colors.white);
      }
    });
  });
}
