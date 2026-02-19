import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/monitoring/memory_monitor.dart';

void main() {
  group('MemoryPressureLevel', () {
    test('يحتوي على 3 مستويات', () {
      expect(MemoryPressureLevel.values.length, 3);
      expect(MemoryPressureLevel.values, contains(MemoryPressureLevel.normal));
      expect(
          MemoryPressureLevel.values, contains(MemoryPressureLevel.moderate));
      expect(
          MemoryPressureLevel.values, contains(MemoryPressureLevel.critical));
    });
  });

  group('MemoryMonitor', () {
    test('instance يعيد نفس الـ instance (Singleton)', () {
      final instance1 = MemoryMonitor.instance;
      final instance2 = MemoryMonitor.instance;

      expect(identical(instance1, instance2), isTrue);
    });

    test('registerCleanupCallback يسجل callback', () {
      bool callbackCalled = false;
      callback(MemoryPressureLevel level) async {
        callbackCalled = true;
      }

      MemoryMonitor.instance.registerCleanupCallback(callback);
      // التنظيف
      MemoryMonitor.instance.unregisterCleanupCallback(callback);

      expect(callbackCalled, isFalse);
    });
  });

  group('MemoryReport', () {
    test('يُنشئ من البيانات الصحيحة', () {
      const report = MemoryReport(
        imageCacheSize: 1024 * 1024, // 1 MB
        imageCacheCount: 10,
        maxImageCacheSize: 100 * 1024 * 1024, // 100 MB
        maxImageCacheCount: 100,
        pressureLevel: MemoryPressureLevel.normal,
        criticalPressureCount: 0,
        isMonitoring: true,
      );

      expect(report.imageCacheSize, 1024 * 1024);
      expect(report.imageCacheCount, 10);
      expect(report.maxImageCacheSize, 100 * 1024 * 1024);
      expect(report.maxImageCacheCount, 100);
      expect(report.pressureLevel, MemoryPressureLevel.normal);
      expect(report.criticalPressureCount, 0);
      expect(report.isMonitoring, true);
    });

    test('imageCacheSizeMB يحسب بشكل صحيح', () {
      const report = MemoryReport(
        imageCacheSize: 50 * 1024 * 1024, // 50 MB
        imageCacheCount: 10,
        maxImageCacheSize: 100 * 1024 * 1024,
        maxImageCacheCount: 100,
        pressureLevel: MemoryPressureLevel.normal,
        criticalPressureCount: 0,
        isMonitoring: true,
      );

      expect(report.imageCacheSizeMB, 50.0);
    });

    test('cacheUsagePercent يحسب بشكل صحيح', () {
      const report = MemoryReport(
        imageCacheSize: 50 * 1024 * 1024, // 50 MB
        imageCacheCount: 10,
        maxImageCacheSize: 100 * 1024 * 1024, // 100 MB
        maxImageCacheCount: 100,
        pressureLevel: MemoryPressureLevel.normal,
        criticalPressureCount: 0,
        isMonitoring: true,
      );

      expect(report.cacheUsagePercent, 50.0);
    });

    test('cacheUsagePercent يعيد 0 عندما maxImageCacheSize = 0', () {
      const report = MemoryReport(
        imageCacheSize: 50 * 1024 * 1024,
        imageCacheCount: 10,
        maxImageCacheSize: 0,
        maxImageCacheCount: 0,
        pressureLevel: MemoryPressureLevel.normal,
        criticalPressureCount: 0,
        isMonitoring: true,
      );

      expect(report.cacheUsagePercent, 0.0);
    });

    test('toString يعيد تقريراً قابل للقراءة', () {
      const report = MemoryReport(
        imageCacheSize: 50 * 1024 * 1024,
        imageCacheCount: 10,
        maxImageCacheSize: 100 * 1024 * 1024,
        maxImageCacheCount: 100,
        pressureLevel: MemoryPressureLevel.moderate,
        criticalPressureCount: 2,
        isMonitoring: true,
      );

      final str = report.toString();
      expect(str, contains('MemoryReport'));
      expect(str, contains('Image Cache'));
      expect(str, contains('moderate'));
    });
  });

  group('MemoryAwareMixin', () {
    testWidgets('يتتبع ويتخلص من الموارد', (tester) async {
      bool timerCancelled = false;
      bool subscriptionCancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: _TestMemoryAwareWidget(
            onTimerCancel: () => timerCancelled = true,
            onSubscriptionCancel: () => subscriptionCancelled = true,
          ),
        ),
      );

      // التخلص من الـ widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(timerCancelled, isTrue);
      expect(subscriptionCancelled, isTrue);
    });
  });

  group('MemoryLeakDetector', () {
    testWidgets('يطبع رسائل debug عند الإنشاء والتخلص', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MemoryLeakDetector(
            name: 'TestWidget',
            child: Text('Test'),
          ),
        ),
      );

      // التحقق من أن الـ widget يعمل
      expect(find.text('Test'), findsOneWidget);

      // التخلص
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    });
  });

  group('DisposableExtension', () {
    test('safeDispose يعمل مع Timer', () {
      final timer = Timer(const Duration(hours: 1), () {});
      expect(timer.isActive, isTrue);

      timer.safeDispose();
      expect(timer.isActive, isFalse);
    });

    test('safeDispose يعمل مع StreamSubscription', () async {
      final controller = StreamController<int>();
      bool cancelled = false;

      final subscription = controller.stream.listen((_) {});
      subscription.onDone(() => cancelled = true);

      subscription.safeDispose();
      await controller.close();

      // التحقق من الإلغاء
      expect(cancelled, isFalse); // onDone لا يُستدعى عند cancel
    });
  });
}

/// Widget اختباري يستخدم MemoryAwareMixin
class _TestMemoryAwareWidget extends StatefulWidget {
  final VoidCallback onTimerCancel;
  final VoidCallback onSubscriptionCancel;

  const _TestMemoryAwareWidget({
    required this.onTimerCancel,
    required this.onSubscriptionCancel,
  });

  @override
  State<_TestMemoryAwareWidget> createState() => _TestMemoryAwareWidgetState();
}

class _TestMemoryAwareWidgetState extends State<_TestMemoryAwareWidget>
    with MemoryAwareMixin {
  @override
  void initState() {
    super.initState();

    // تسجيل timer
    final timer = Timer(const Duration(hours: 1), () {});
    registerDisposable(() {
      timer.cancel();
      widget.onTimerCancel();
    });

    // تسجيل subscription
    final controller = StreamController<int>();
    final subscription = controller.stream.listen((_) {});
    registerDisposable(() {
      subscription.cancel();
      controller.close();
      widget.onSubscriptionCancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Text('Test');
  }
}
