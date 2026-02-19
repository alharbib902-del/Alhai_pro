/// اختبارات شاشة قائمة الطباعة - PrintQueueScreen Tests
///
/// يختبر:
/// - حالة القائمة الفارغة مع رسالة "لا توجد مهام طباعة معلقة"
/// - عرض قائمة مهام الطباعة
/// - حالة الطابعة المتصلة
/// - إحصائيات المهام (إجمالي، في الانتظار، فشلت)
/// - أزرار طباعة الكل ومسح الكل
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/screens/printing/print_queue_screen.dart';
import 'package:pos_app/providers/print_providers.dart';
import 'package:pos_app/providers/theme_provider.dart';
import 'package:pos_app/l10n/generated/app_localizations.dart';

void main() {
  // دالة مساعدة لبناء الشاشة مع تهيئة البيئة
  Widget buildScreen({
    List<PrintJob>? initialJobs,
    double screenWidth = 1200,
  }) {
    return ProviderScope(
      overrides: [
        // تهيئة قائمة الطباعة
        printQueueProvider.overrideWith((ref) {
          final notifier = PrintQueueNotifier();
          if (initialJobs != null) {
            for (final job in initialJobs) {
              notifier.addJob(job);
            }
          }
          return notifier;
        }),
        // تهيئة الثيم بوضع فاتح (تجنب SharedPreferences)
        themeProvider.overrideWith((ref) => ThemeNotifier(ThemeMode.light)),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(size: Size(screenWidth, 800)),
          child: const Scaffold(
            body: PrintQueueScreen(),
          ),
        ),
      ),
    );
  }

  // إنشاء مهمة طباعة وهمية
  PrintJob createTestJob({
    String? id,
    String? saleId,
    String? receiptNo,
    String type = 'receipt',
    String status = 'pending',
    String? errorMessage,
  }) {
    return PrintJob(
      id: id ?? 'job-${DateTime.now().millisecondsSinceEpoch}',
      saleId: saleId ?? 'sale-001',
      receiptNo: receiptNo ?? 'INV-001',
      type: type,
      status: status,
      errorMessage: errorMessage,
      createdAt: DateTime.now(),
    );
  }

  group('PrintQueueScreen - الحالة الفارغة', () {
    testWidgets('يعرض رسالة "لا توجد مهام طباعة معلقة" عند عدم وجود مهام',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('لا توجد مهام طباعة معلقة'), findsOneWidget);
    });

    testWidgets('يعرض أيقونة print_disabled في الحالة الفارغة',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.print_disabled), findsOneWidget);
    });
  });

  group('PrintQueueScreen - عرض المهام', () {
    testWidgets('يعرض مهام الطباعة عند وجودها', (tester) async {
      final jobs = [
        createTestJob(id: 'job-1', receiptNo: 'INV-001'),
        createTestJob(id: 'job-2', receiptNo: 'INV-002'),
      ];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.text('INV-001'), findsOneWidget);
      expect(find.text('INV-002'), findsOneWidget);
    });

    testWidgets('يعرض حالة "في الانتظار" للمهام المعلقة', (tester) async {
      final jobs = [
        createTestJob(id: 'job-1', status: 'pending'),
      ];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.text('في الانتظار'), findsWidgets);
    });

    testWidgets('يعرض رسالة خطأ للمهام الفاشلة', (tester) async {
      final jobs = [
        createTestJob(
          id: 'job-1',
          status: 'failed',
          errorMessage: 'خطأ',
        ),
      ];

      await tester.pumpWidget(buildScreen(initialJobs: jobs, screenWidth: 1400));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('فشل'),
        findsWidgets,
      );
    });

    testWidgets('يعرض أيقونة receipt للمهام من نوع receipt', (tester) async {
      final jobs = [
        createTestJob(id: 'job-1', type: 'receipt'),
      ];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt), findsWidgets);
    });

    testWidgets('يعرض أيقونة description للمهام غير receipt', (tester) async {
      final jobs = [
        createTestJob(id: 'job-1', type: 'report'),
      ];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.description), findsOneWidget);
    });
  });

  group('PrintQueueScreen - حالة الطابعة والإحصائيات', () {
    testWidgets('يعرض حالة "الطابعة متصلة" عند وجود مهام', (tester) async {
      final jobs = [createTestJob(id: 'job-1')];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.text('الطابعة متصلة'), findsOneWidget);
    });

    testWidgets('يعرض طراز الطابعة XP-80C', (tester) async {
      final jobs = [createTestJob(id: 'job-1')];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.text('XP-80C'), findsOneWidget);
    });

    testWidgets('يعرض إحصائيات المهام', (tester) async {
      final jobs = [
        createTestJob(id: 'job-1', status: 'pending'),
        createTestJob(id: 'job-2', status: 'pending'),
        createTestJob(id: 'job-3', status: 'failed'),
      ];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      // إجمالي المهام
      expect(find.text('3'), findsWidgets);
      // عدد المعلقة
      expect(find.text('2'), findsWidgets);
      // عدد الفاشلة
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('يعرض تسميات الإحصائيات', (tester) async {
      final jobs = [createTestJob(id: 'job-1')];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.text('إجمالي'), findsOneWidget);
      expect(find.text('في الانتظار'), findsWidgets);
      expect(find.text('فشلت'), findsOneWidget);
    });
  });

  group('PrintQueueScreen - الأزرار', () {
    testWidgets('يعرض زر "طباعة الكل"', (tester) async {
      final jobs = [createTestJob(id: 'job-1')];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.text('طباعة الكل'), findsOneWidget);
    });

    testWidgets('يعرض زر "مسح الكل"', (tester) async {
      final jobs = [createTestJob(id: 'job-1')];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.text('مسح الكل'), findsOneWidget);
    });

    testWidgets('الضغط على "مسح الكل" يعرض حوار تأكيد', (tester) async {
      final jobs = [createTestJob(id: 'job-1')];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      await tester.tap(find.text('مسح الكل'));
      await tester.pumpAndSettle();

      expect(find.text('مسح قائمة الطباعة'), findsOneWidget);
      expect(
        find.text('هل تريد مسح جميع مهام الطباعة المعلقة؟'),
        findsOneWidget,
      );
    });

    testWidgets('يعرض أيقونة إعدادات الطابعة', (tester) async {
      final jobs = [createTestJob(id: 'job-1')];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('كل مهمة تحتوي على زر طباعة وحذف', (tester) async {
      final jobs = [createTestJob(id: 'job-1')];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      // أيقونة طباعة في المهمة (إضافة للأخرى في الهيدر)
      expect(find.byIcon(Icons.print), findsWidgets);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });

  group('PrintQueueScreen - عرض العدد', () {
    testWidgets('يعرض عدد المهام المعلقة', (tester) async {
      final jobs = [
        createTestJob(id: 'job-1'),
        createTestJob(id: 'job-2'),
        createTestJob(id: 'job-3'),
      ];

      await tester.pumpWidget(buildScreen(initialJobs: jobs));
      await tester.pumpAndSettle();

      expect(find.text('3 مهام معلقة'), findsOneWidget);
    });
  });
}
