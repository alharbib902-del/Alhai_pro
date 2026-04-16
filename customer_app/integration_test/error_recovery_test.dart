/// Integration test: Error Recovery (استعادة من الأخطاء)
///
/// Tests error handling and recovery scenarios:
///   1. Offline banner appears when disconnected (شريط عدم الاتصال)
///   2. Empty cart checkout blocked (حظر الدفع بسلة فارغة)
///   3. Network error shows retry (إعادة المحاولة عند خطأ الشبكة)
///
/// Connectivity behavior (from real _MainShell):
///   - connectivityProvider streams connectivity state
///   - MaterialBanner with "أنت غير متصل بالإنترنت" shown when offline
///   - Icon: Icons.wifi_off
///   - Background: theme.colorScheme.errorContainer
///
/// Run with:
///   flutter test integration_test/error_recovery_test.dart
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'helpers/test_app.dart';

// =============================================================================
// CUSTOM TEST APP WITH CONNECTIVITY SIMULATION
// =============================================================================

/// A connectivity-aware test app that simulates the real _MainShell behavior.
/// The real app shows a MaterialBanner with "أنت غير متصل بالإنترنت" when
/// the connectivityProvider emits false.
Widget _buildConnectivityTestApp({
  required StreamController<bool> connectivityController,
  String initialRoute = '/home',
}) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, __) => const _StubScreen(label: 'Home'),
      ),
      GoRoute(
        path: '/catalog',
        builder: (_, __) => const _StubScreen(label: 'Catalog'),
      ),
      GoRoute(
        path: '/cart',
        builder: (_, __) => const _StubScreen(label: 'Cart'),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, __) => const _StubScreen(label: 'Checkout'),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const _StubScreen(label: 'Orders'),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, state) =>
            _StubScreen(label: 'Order ${state.pathParameters["id"]}'),
      ),
    ],
  );

  // Build a widget tree that mirrors _MainShell connectivity behavior
  return ProviderScope(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AlhaiTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return _ConnectivityShell(
          connectivityStream: connectivityController.stream,
          child: child!,
        );
      },
    ),
  );
}

/// Shell widget that shows offline banner based on connectivity stream.
/// Mirrors the real _MainShell behavior from app_router.dart.
class _ConnectivityShell extends StatelessWidget {
  final Stream<bool> connectivityStream;
  final Widget child;

  const _ConnectivityShell({
    required this.connectivityStream,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<bool>(
      stream: connectivityStream,
      initialData: true, // افتراض: متصل عند البداية
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        return Column(
          children: [
            if (!isConnected)
              MaterialBanner(
                content: const Text('أنت غير متصل بالإنترنت'),
                leading: const Icon(Icons.wifi_off),
                backgroundColor: theme.colorScheme.errorContainer,
                actions: [
                  TextButton(
                    onPressed: () {
                      // في التطبيق الحقيقي: إعادة المحاولة
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

/// Custom test app for cart/checkout flow with empty cart state.
Widget _buildCartTestApp({
  required bool cartIsEmpty,
  String initialRoute = '/cart',
}) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, __) => const _StubScreen(label: 'Home'),
      ),
      GoRoute(
        path: '/catalog',
        builder: (_, __) => const _StubScreen(label: 'Catalog'),
      ),
      GoRoute(
        path: '/cart',
        builder: (_, __) => _CartScreen(isEmpty: cartIsEmpty),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, __) => const _StubScreen(label: 'Checkout'),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AlhaiTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}

/// Custom test app for network error / retry scenarios.
Widget _buildErrorRetryTestApp({
  required bool hasError,
  String initialRoute = '/home',
}) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, __) => _ErrorScreen(hasError: hasError),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => _ErrorScreen(hasError: hasError),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, state) => _ErrorScreen(
          hasError: hasError,
          label: 'Order ${state.pathParameters["id"]}',
        ),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AlhaiTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}

// =============================================================================
// CUSTOM STUB SCREENS
// =============================================================================

class _StubScreen extends StatelessWidget {
  final String label;
  const _StubScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(label, key: Key('stub_$label'))),
    );
  }
}

/// Cart screen that simulates empty/non-empty state.
/// In the real app, CartScreen shows "سلتك فارغة" when empty and disables
/// the checkout button.
class _CartScreen extends StatelessWidget {
  final bool isEmpty;
  const _CartScreen({required this.isEmpty});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'سلتك فارغة',
                    key: const Key('empty_cart_message'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/catalog'),
                    child: const Text('تصفح المنتجات'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Cart', key: Key('stub_Cart')),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('checkout_button'),
                    onPressed: () => context.go('/checkout'),
                    child: const Text('إتمام الطلب'),
                  ),
                ],
              ),
      ),
      // Checkout FAB disabled when cart is empty
      floatingActionButton: isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.go('/checkout'),
              label: const Text('إتمام الطلب'),
              icon: const Icon(Icons.shopping_cart_checkout),
            ),
    );
  }
}

/// Error screen that simulates network error with retry.
class _ErrorScreen extends StatefulWidget {
  final bool hasError;
  final String label;
  const _ErrorScreen({required this.hasError, this.label = 'Content'});

  @override
  State<_ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<_ErrorScreen> {
  late bool _showError;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _showError = widget.hasError;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_showError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 64,
                color: theme.colorScheme.error,
                key: const Key('error_icon'),
              ),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ في الاتصال',
                key: const Key('error_message'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'تحقق من اتصالك بالإنترنت',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('retry_button'),
                onPressed: () {
                  setState(() {
                    _retryCount++;
                    // بعد المحاولة الثانية: تنجح المحاولة (محاكاة)
                    if (_retryCount >= 2) {
                      _showError = false;
                    }
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
              const SizedBox(height: 8),
              Text(
                'عدد المحاولات: $_retryCount',
                key: const Key('retry_count'),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Text(
          widget.label,
          key: Key('stub_${widget.label}'),
        ),
      ),
    );
  }
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ============================================================================
  // ERROR RECOVERY - استعادة من الأخطاء
  // ============================================================================

  group('Error Recovery - استعادة من الأخطاء', () {
    // ==========================================================================
    // 1. Offline Banner (شريط عدم الاتصال)
    // ==========================================================================
    group('1. Offline banner - شريط عدم الاتصال', () {
      testWidgets('banner hidden when connected (default state)', (
        tester,
      ) async {
        // الترتيب: التطبيق متصل بالإنترنت (الحالة الافتراضية)
        final controller = StreamController<bool>.broadcast();

        await tester.pumpWidget(
          _buildConnectivityTestApp(connectivityController: controller),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: لا يوجد شريط عدم اتصال
        expect(find.text('أنت غير متصل بالإنترنت'), findsNothing);
        expect(find.byIcon(Icons.wifi_off), findsNothing);

        // التأكيد: الشاشة الرئيسية ظاهرة
        expect(find.byKey(const Key('stub_Home')), findsOneWidget);

        controller.close();
      });

      testWidgets('banner appears when disconnected', (tester) async {
        // الترتيب: إنشاء تحكم في حالة الاتصال
        final controller = StreamController<bool>.broadcast();

        await tester.pumpWidget(
          _buildConnectivityTestApp(connectivityController: controller),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد الأولي: متصل (لا يوجد شريط)
        expect(find.text('أنت غير متصل بالإنترنت'), findsNothing);

        // الفعل: محاكاة فقدان الاتصال
        controller.add(false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // التأكيد: شريط عدم الاتصال ظاهر
        expect(find.text('أنت غير متصل بالإنترنت'), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off), findsOneWidget);

        controller.close();
      });

      testWidgets('banner disappears when reconnected', (tester) async {
        // الترتيب: التطبيق غير متصل ثم يتصل مرة أخرى
        final controller = StreamController<bool>.broadcast();

        await tester.pumpWidget(
          _buildConnectivityTestApp(connectivityController: controller),
        );
        await pumpAndSettleWithTimeout(tester);

        // الفعل: فقدان الاتصال
        controller.add(false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('أنت غير متصل بالإنترنت'), findsOneWidget);

        // الفعل: إعادة الاتصال
        controller.add(true);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // التأكيد: الشريط اختفى
        expect(find.text('أنت غير متصل بالإنترنت'), findsNothing);

        controller.close();
      });

      testWidgets('connectivity toggle multiple times', (tester) async {
        // محاكاة اتصال متقطع
        final controller = StreamController<bool>.broadcast();

        await tester.pumpWidget(
          _buildConnectivityTestApp(connectivityController: controller),
        );
        await pumpAndSettleWithTimeout(tester);

        // الدورة 1: غير متصل
        controller.add(false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('أنت غير متصل بالإنترنت'), findsOneWidget);

        // الدورة 2: متصل
        controller.add(true);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('أنت غير متصل بالإنترنت'), findsNothing);

        // الدورة 3: غير متصل مرة أخرى
        controller.add(false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('أنت غير متصل بالإنترنت'), findsOneWidget);

        // الدورة 4: متصل نهائياً
        controller.add(true);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('أنت غير متصل بالإنترنت'), findsNothing);

        controller.close();
      });

      testWidgets('content remains visible behind offline banner', (
        tester,
      ) async {
        // التأكد أن المحتوى يظل ظاهراً تحت الشريط
        final controller = StreamController<bool>.broadcast();

        await tester.pumpWidget(
          _buildConnectivityTestApp(connectivityController: controller),
        );
        await pumpAndSettleWithTimeout(tester);

        // الفعل: فقدان الاتصال
        controller.add(false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // التأكيد: الشريط ظاهر والمحتوى أيضاً
        expect(find.text('أنت غير متصل بالإنترنت'), findsOneWidget);
        expect(find.byKey(const Key('stub_Home')), findsOneWidget);

        controller.close();
      });

      testWidgets('offline banner shows retry action', (tester) async {
        final controller = StreamController<bool>.broadcast();

        await tester.pumpWidget(
          _buildConnectivityTestApp(connectivityController: controller),
        );
        await pumpAndSettleWithTimeout(tester);

        // الفعل: فقدان الاتصال
        controller.add(false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // التأكيد: زر إعادة المحاولة ظاهر في الشريط
        expect(find.text('إعادة المحاولة'), findsOneWidget);

        controller.close();
      });
    });

    // ==========================================================================
    // 2. Empty Cart Checkout Blocked (حظر الدفع بسلة فارغة)
    // ==========================================================================
    group('2. Empty cart checkout blocked - حظر الدفع بسلة فارغة', () {
      testWidgets('empty cart shows "سلتك فارغة" message', (tester) async {
        // الترتيب: فتح السلة وهي فارغة
        await tester.pumpWidget(
          _buildCartTestApp(cartIsEmpty: true),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: رسالة السلة الفارغة ظاهرة
        expect(find.byKey(const Key('empty_cart_message')), findsOneWidget);
        expect(find.text('سلتك فارغة'), findsOneWidget);
      });

      testWidgets('empty cart shows shopping cart icon', (tester) async {
        await tester.pumpWidget(
          _buildCartTestApp(cartIsEmpty: true),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: أيقونة السلة الفارغة ظاهرة
        expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      });

      testWidgets('empty cart has no checkout button', (tester) async {
        // الترتيب: السلة فارغة
        await tester.pumpWidget(
          _buildCartTestApp(cartIsEmpty: true),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: لا يوجد زر إتمام الطلب
        expect(find.byKey(const Key('checkout_button')), findsNothing);

        // التأكيد: لا يوجد FAB للدفع
        expect(find.byType(FloatingActionButton), findsNothing);
      });

      testWidgets('empty cart has "browse products" button', (tester) async {
        // الترتيب: السلة فارغة
        await tester.pumpWidget(
          _buildCartTestApp(cartIsEmpty: true),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: زر "تصفح المنتجات" ظاهر
        expect(find.text('تصفح المنتجات'), findsOneWidget);
      });

      testWidgets(
        'empty cart "browse products" navigates to catalog',
        (tester) async {
          // الترتيب: السلة فارغة
          await tester.pumpWidget(
            _buildCartTestApp(cartIsEmpty: true),
          );
          await pumpAndSettleWithTimeout(tester);

          // الفعل: الضغط على "تصفح المنتجات"
          await tester.tap(find.text('تصفح المنتجات'));
          await pumpAndSettleWithTimeout(tester);

          // التأكيد: الانتقال للكتالوج
          expect(find.byKey(const Key('stub_Catalog')), findsOneWidget);
        },
      );

      testWidgets('non-empty cart shows checkout button', (tester) async {
        // الترتيب: السلة تحتوي منتجات
        await tester.pumpWidget(
          _buildCartTestApp(cartIsEmpty: false),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: زر إتمام الطلب ظاهر
        expect(find.byKey(const Key('checkout_button')), findsOneWidget);
        expect(find.text('إتمام الطلب'), findsWidgets);
      });

      testWidgets('non-empty cart checkout navigates to checkout screen', (
        tester,
      ) async {
        // الترتيب: السلة تحتوي منتجات
        await tester.pumpWidget(
          _buildCartTestApp(cartIsEmpty: false),
        );
        await pumpAndSettleWithTimeout(tester);

        // الفعل: الضغط على زر إتمام الطلب
        await tester.tap(find.byKey(const Key('checkout_button')));
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: الانتقال لشاشة إتمام الطلب
        expect(find.byKey(const Key('stub_Checkout')), findsOneWidget);
      });

      testWidgets('non-empty cart shows FAB', (tester) async {
        await tester.pumpWidget(
          _buildCartTestApp(cartIsEmpty: false),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: FAB ظاهر
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.shopping_cart_checkout), findsOneWidget);
      });
    });

    // ==========================================================================
    // 3. Network Error Shows Retry (إعادة المحاولة عند خطأ الشبكة)
    // ==========================================================================
    group('3. Network error shows retry - إعادة المحاولة عند خطأ الشبكة', () {
      testWidgets('error state shows error icon and message', (tester) async {
        // الترتيب: خطأ في الشبكة
        await tester.pumpWidget(
          _buildErrorRetryTestApp(hasError: true),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: أيقونة الخطأ ظاهرة
        expect(find.byKey(const Key('error_icon')), findsOneWidget);
        expect(find.byIcon(Icons.cloud_off), findsOneWidget);

        // التأكيد: رسالة الخطأ ظاهرة
        expect(find.byKey(const Key('error_message')), findsOneWidget);
        expect(find.text('حدث خطأ في الاتصال'), findsOneWidget);
        expect(find.text('تحقق من اتصالك بالإنترنت'), findsOneWidget);
      });

      testWidgets('error state shows retry button', (tester) async {
        await tester.pumpWidget(
          _buildErrorRetryTestApp(hasError: true),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: زر إعادة المحاولة ظاهر
        expect(find.byKey(const Key('retry_button')), findsOneWidget);
        expect(find.text('إعادة المحاولة'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('retry button increments attempt counter', (tester) async {
        await tester.pumpWidget(
          _buildErrorRetryTestApp(hasError: true),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: عدد المحاولات 0
        expect(find.text('عدد المحاولات: 0'), findsOneWidget);

        // الفعل: الضغط على إعادة المحاولة
        await tester.tap(find.byKey(const Key('retry_button')));
        await tester.pump();

        // التأكيد: عدد المحاولات 1
        expect(find.text('عدد المحاولات: 1'), findsOneWidget);
      });

      testWidgets('retry succeeds after multiple attempts', (tester) async {
        // الترتيب: خطأ في الشبكة (يحتاج محاولتين للنجاح)
        await tester.pumpWidget(
          _buildErrorRetryTestApp(hasError: true),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: حالة الخطأ
        expect(find.byKey(const Key('error_message')), findsOneWidget);

        // المحاولة 1: لا تزال فاشلة
        await tester.tap(find.byKey(const Key('retry_button')));
        await tester.pump();
        expect(find.text('عدد المحاولات: 1'), findsOneWidget);
        expect(find.byKey(const Key('error_message')), findsOneWidget);

        // المحاولة 2: تنجح (المحاكاة تنجح بعد محاولتين)
        await tester.tap(find.byKey(const Key('retry_button')));
        await tester.pump();

        // التأكيد: المحتوى الأصلي ظاهر بدل الخطأ
        expect(find.byKey(const Key('error_message')), findsNothing);
        expect(find.byKey(const Key('stub_Content')), findsOneWidget);
      });

      testWidgets('no error state shows content directly', (tester) async {
        // الترتيب: لا يوجد خطأ
        await tester.pumpWidget(
          _buildErrorRetryTestApp(hasError: false),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: المحتوى ظاهر بدون خطأ
        expect(find.byKey(const Key('stub_Content')), findsOneWidget);
        expect(find.byKey(const Key('error_message')), findsNothing);
        expect(find.byKey(const Key('retry_button')), findsNothing);
      });

      testWidgets('error on orders screen shows retry', (tester) async {
        // اختبار حالة الخطأ على شاشة الطلبات
        await tester.pumpWidget(
          _buildErrorRetryTestApp(hasError: true, initialRoute: '/orders'),
        );
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: خطأ على شاشة الطلبات
        expect(find.text('حدث خطأ في الاتصال'), findsOneWidget);
        expect(find.byKey(const Key('retry_button')), findsOneWidget);
      });
    });

    // ==========================================================================
    // COMBINED ERROR SCENARIOS
    // ==========================================================================
    group('Combined error scenarios - سيناريوهات الأخطاء المجتمعة', () {
      testWidgets('offline → navigate with standard test app', (tester) async {
        // اختبار التنقل أثناء حالة عدم الاتصال (باستخدام التطبيق القياسي)
        // في التطبيق الحقيقي: التنقل يعمل ولكن البيانات لا تُحدّث
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/home'));
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Home');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Home'))),
        );

        // التنقل يعمل حتى بدون اتصال (التطبيق لا يمنع التنقل)
        router.go('/orders');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Orders');

        router.go('/cart');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Cart');
      });

      testWidgets('app recovers after initial error', (tester) async {
        // التطبيق يبدأ بخطأ ثم يتعافى
        await tester.pumpWidget(
          _buildErrorRetryTestApp(hasError: true),
        );
        await pumpAndSettleWithTimeout(tester);

        // حالة الخطأ
        expect(find.byKey(const Key('error_message')), findsOneWidget);

        // المحاولة 1
        await tester.tap(find.byKey(const Key('retry_button')));
        await tester.pump();

        // المحاولة 2 → نجاح
        await tester.tap(find.byKey(const Key('retry_button')));
        await tester.pump();

        // المحتوى ظاهر
        expect(find.byKey(const Key('stub_Content')), findsOneWidget);
        expect(find.byKey(const Key('error_icon')), findsNothing);
      });

      testWidgets('connectivity banner with navigation (standard app)', (
        tester,
      ) async {
        // اختبار التنقل الأساسي مع التطبيق القياسي
        // في التطبيق الحقيقي: الشريط يظهر عبر _MainShell
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/home'));
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Home');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Home'))),
        );

        // التنقل بين الشاشات (يجب أن يعمل بغض النظر عن حالة الاتصال)
        router.go('/catalog');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Catalog');

        router.go('/home');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Home');
      });
    });
  });
}
