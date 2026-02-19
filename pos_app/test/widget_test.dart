// اختبارات Widget الأساسية لتطبيق نقاط البيع

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pos_app/core/monitoring/memory_monitor.dart';
import 'package:pos_app/screens/auth/splash_screen.dart';

/// Creates a GoRouter with splash as initial and a stub /login route
GoRouter _createTestRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login')),
        ),
      ),
    ],
  );
}

void main() {
  group('SplashScreen', () {
    testWidgets('يعرض شاشة البداية بشكل صحيح', (WidgetTester tester) async {
      final router = _createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // التحقق من عرض اسم التطبيق
      expect(find.text('نقاط البيع'), findsOneWidget);

      // إكمال العمليات غير المتزامنة
      await tester.pump(const Duration(seconds: 3));

      // إيقاف MemoryMonitor لتجنب pending timer
      MemoryMonitor.instance.stopMonitoring();
    });

    testWidgets('يعرض اسم التطبيق', (WidgetTester tester) async {
      final router = _createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // التحقق من وجود نص نقاط البيع
      expect(find.text('نقاط البيع'), findsOneWidget);

      // إكمال العمليات غير المتزامنة
      await tester.pump(const Duration(seconds: 3));

      // إيقاف MemoryMonitor لتجنب pending timer
      MemoryMonitor.instance.stopMonitoring();
    });

    testWidgets('يعرض مؤشر التحميل', (WidgetTester tester) async {
      final router = _createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // التحقق من وجود مؤشر التحميل
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // إكمال العمليات غير المتزامنة
      await tester.pump(const Duration(seconds: 3));

      // إيقاف MemoryMonitor لتجنب pending timer
      MemoryMonitor.instance.stopMonitoring();
    });
  });
}
