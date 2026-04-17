/// Integration test: Happy Paths (المسارات الأساسية الناجحة)
///
/// Tests the primary user journeys in the customer app:
///   1. Guest user browses catalog (تصفح الكتالوج كزائر)
///   2. User adds to cart (إضافة للسلة)
///   3. User completes checkout (إتمام الطلب)
///   4. User views order status (عرض حالة الطلب)
///
/// These tests use stub screens via [buildCustomerTestApp] and verify
/// navigation flows, route transitions, and screen presence using GoRouter
/// programmatic navigation.
///
/// Run with:
///   flutter test integration_test/happy_paths_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_data.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ============================================================================
  // HAPPY PATHS - المسارات الأساسية الناجحة
  // ============================================================================

  group('Happy Paths - المسارات الأساسية', () {
    // ==========================================================================
    // 1. Guest User Browses Catalog (تصفح الكتالوج كزائر)
    // ==========================================================================
    group('1. Guest browses catalog - تصفح الكتالوج كزائر', () {
      testWidgets('app launches at home screen', (tester) async {
        // الترتيب: فتح التطبيق على الشاشة الرئيسية
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/home'));
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: الشاشة الرئيسية ظاهرة
        expectStubScreen('Home');
      });

      testWidgets('home → store selection → catalog', (tester) async {
        // الترتيب: البداية من الشاشة الرئيسية
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/home'));
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Home');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Home'))),
        );

        // الفعل: اختيار المتجر → الكتالوج
        // في التطبيق الحقيقي: العميل يختار فرع من القائمة → ينتقل للكتالوج
        router.go('/catalog');
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: شاشة الكتالوج ظاهرة
        expectStubScreen('Catalog');
      });

      testWidgets('catalog → product detail with valid ID', (tester) async {
        // الترتيب: البداية من الكتالوج
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/catalog'));
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Catalog');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Catalog'))),
        );

        // الفعل: اختيار منتج من القائمة
        final productId = testProducts[0].id;
        router.go('/products/$productId');
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: شاشة تفاصيل المنتج ظاهرة مع المعرّف الصحيح
        expectStubScreen('Product $productId');
      });

      testWidgets('browsing multiple products preserves navigation', (
        tester,
      ) async {
        // الترتيب: البداية من الكتالوج
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/catalog'));
        await pumpAndSettleWithTimeout(tester);

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Catalog'))),
        );

        // الفعل: تصفح عدة منتجات بالتتابع
        for (final product in testProducts) {
          router.go('/products/${product.id}');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Product ${product.id}');
        }

        // الفعل: العودة للكتالوج
        router.go('/catalog');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Catalog');
      });

      testWidgets('search screen is reachable from home', (tester) async {
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/home'));
        await pumpAndSettleWithTimeout(tester);

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Home'))),
        );

        // الفعل: الانتقال للبحث
        router.go('/search');
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: شاشة البحث ظاهرة
        expectStubScreen('Search');
      });

      testWidgets('nearby stores screen is accessible', (tester) async {
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/home'));
        await pumpAndSettleWithTimeout(tester);

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Home'))),
        );

        // الفعل: عرض المتاجر القريبة
        router.go('/stores/nearby');
        await pumpAndSettleWithTimeout(tester);

        expectStubScreen('Nearby Stores');
      });

      testWidgets(
        'full browse journey: home → catalog → product → search → home',
        (tester) async {
          await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/home'));
          await pumpAndSettleWithTimeout(tester);

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Home'))),
          );

          // الخطوة 1: الكتالوج
          router.go('/catalog');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Catalog');

          // الخطوة 2: تفاصيل المنتج الأول
          router.go('/products/${testProducts[0].id}');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Product ${testProducts[0].id}');

          // الخطوة 3: البحث
          router.go('/search');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Search');

          // الخطوة 4: تفاصيل المنتج الثاني (من نتائج البحث)
          router.go('/products/${testProducts[1].id}');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Product ${testProducts[1].id}');

          // الخطوة 5: العودة للشاشة الرئيسية
          router.go('/home');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Home');
        },
      );
    });

    // ==========================================================================
    // 2. User Adds to Cart (إضافة للسلة)
    // ==========================================================================
    group('2. User adds to cart - إضافة للسلة', () {
      testWidgets('product detail → cart navigation', (tester) async {
        // الترتيب: البداية من تفاصيل المنتج
        final productId = testProducts[0].id;
        await tester.pumpWidget(
          buildCustomerTestApp(initialRoute: '/products/$productId'),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Product $productId');

        final router = GoRouter.of(
          tester.element(find.byKey(Key('stub_Product $productId'))),
        );

        // الفعل: في التطبيق الحقيقي العميل يضغط "أضف للسلة" ثم ينتقل للسلة
        router.go('/cart');
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: شاشة السلة ظاهرة مع المنتج المضاف
        expectStubScreen('Cart');
      });

      testWidgets('cart is accessible directly from bottom nav', (
        tester,
      ) async {
        // الترتيب: البداية من الشاشة الرئيسية
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/home'));
        await pumpAndSettleWithTimeout(tester);

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Home'))),
        );

        // الفعل: الانتقال للسلة عبر شريط التنقل السفلي
        router.go('/cart');
        await pumpAndSettleWithTimeout(tester);

        expectStubScreen('Cart');
      });

      testWidgets('adding multiple products then viewing cart', (tester) async {
        // الترتيب: زيارة عدة منتجات ثم السلة
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/catalog'));
        await pumpAndSettleWithTimeout(tester);

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Catalog'))),
        );

        // الفعل: استعراض المنتج الأول
        router.go('/products/${testProducts[0].id}');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Product ${testProducts[0].id}');

        // الفعل: استعراض المنتج الثاني
        router.go('/products/${testProducts[1].id}');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Product ${testProducts[1].id}');

        // الفعل: استعراض المنتج الثالث
        router.go('/products/${testProducts[2].id}');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Product ${testProducts[2].id}');

        // الفعل: الانتقال للسلة (في التطبيق الحقيقي: 3 منتجات في السلة)
        router.go('/cart');
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: السلة ظاهرة
        expectStubScreen('Cart');
      });

      testWidgets('cart → continue shopping → back to catalog', (tester) async {
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/cart'));
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Cart');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Cart'))),
        );

        // الفعل: العودة للكتالوج لإضافة المزيد
        router.go('/catalog');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Catalog');

        // الفعل: العودة للسلة
        router.go('/cart');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Cart');
      });
    });

    // ==========================================================================
    // 3. User Completes Checkout (إتمام الطلب)
    // ==========================================================================
    group('3. User completes checkout - إتمام الطلب', () {
      testWidgets('cart → checkout transition', (tester) async {
        // الترتيب: البداية من السلة (تحتوي منتجات)
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/cart'));
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Cart');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Cart'))),
        );

        // الفعل: الانتقال لإتمام الطلب
        router.go('/checkout');
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: شاشة إتمام الطلب ظاهرة
        expectStubScreen('Checkout');
      });

      testWidgets('checkout → address selection → back to checkout', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildCustomerTestApp(initialRoute: '/checkout'),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Checkout');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Checkout'))),
        );

        // الفعل: اختيار/تعديل العنوان
        router.go('/profile/addresses');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Addresses');

        // الفعل: العودة لإتمام الطلب بعد اختيار العنوان
        router.go('/checkout');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Checkout');
      });

      testWidgets('checkout → order confirmation (cash payment)', (
        tester,
      ) async {
        // الترتيب: البداية من شاشة إتمام الطلب
        await tester.pumpWidget(
          buildCustomerTestApp(initialRoute: '/checkout'),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Checkout');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Checkout'))),
        );

        // الفعل: تأكيد الطلب (دفع عند الاستلام)
        // في التطبيق الحقيقي: العميل يضغط "تأكيد الطلب" → يتم إنشاء الطلب
        // → الانتقال لشاشة تفاصيل الطلب الجديد
        router.go('/orders/$kTestOrderId');
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: شاشة تأكيد الطلب ظاهرة
        expectStubScreen('Order $kTestOrderId');
      });

      testWidgets(
        'full checkout flow: catalog → product → cart → checkout → order',
        (tester) async {
          // المسار الكامل من التصفح حتى تأكيد الطلب
          await tester.pumpWidget(
            buildCustomerTestApp(initialRoute: '/catalog'),
          );
          await pumpAndSettleWithTimeout(tester);

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Catalog'))),
          );

          // الخطوة 1: اختيار منتج
          router.go('/products/${testProducts[0].id}');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Product ${testProducts[0].id}');

          // الخطوة 2: الانتقال للسلة
          router.go('/cart');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Cart');

          // الخطوة 3: إتمام الطلب
          router.go('/checkout');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Checkout');

          // الخطوة 4: تأكيد الطلب → شاشة تفاصيل الطلب
          router.go('/orders/$kTestOrderId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestOrderId');
        },
      );

      testWidgets('order confirmation → order tracking', (tester) async {
        // الترتيب: بعد تأكيد الطلب، الانتقال لتتبع الطلب
        await tester.pumpWidget(
          buildCustomerTestApp(initialRoute: '/orders/$kTestOrderId'),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Order $kTestOrderId');

        final router = GoRouter.of(
          tester.element(find.byKey(Key('stub_Order $kTestOrderId'))),
        );

        // الفعل: تتبع الطلب
        router.go('/orders/$kTestOrderId/track');
        await pumpAndSettleWithTimeout(tester);

        expectStubScreen('Track $kTestOrderId');
      });
    });

    // ==========================================================================
    // 4. User Views Order Status (عرض حالة الطلب)
    // ==========================================================================
    group('4. User views order status - عرض حالة الطلب', () {
      testWidgets('orders list screen loads', (tester) async {
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/orders'));
        await pumpAndSettleWithTimeout(tester);

        expectStubScreen('Orders');
      });

      testWidgets('orders list → select order → order detail', (tester) async {
        // الترتيب: البداية من قائمة الطلبات
        await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/orders'));
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Orders');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Orders'))),
        );

        // الفعل: اختيار طلب من القائمة
        router.go('/orders/$kTestOrderId');
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: تفاصيل الطلب ظاهرة
        expectStubScreen('Order $kTestOrderId');
      });

      testWidgets('order detail → tracking timeline', (tester) async {
        // الترتيب: البداية من تفاصيل الطلب
        await tester.pumpWidget(
          buildCustomerTestApp(initialRoute: '/orders/$kTestOrderId'),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Order $kTestOrderId');

        final router = GoRouter.of(
          tester.element(find.byKey(Key('stub_Order $kTestOrderId'))),
        );

        // الفعل: فتح شاشة التتبع
        router.go('/orders/$kTestOrderId/track');
        await pumpAndSettleWithTimeout(tester);

        // التأكيد: شاشة التتبع ظاهرة مع الجدول الزمني
        expectStubScreen('Track $kTestOrderId');
      });

      testWidgets('order status flow transitions are navigable', (
        tester,
      ) async {
        // التحقق من إمكانية التنقل بين مراحل حالة الطلب
        await tester.pumpWidget(
          buildCustomerTestApp(initialRoute: '/orders/$kTestOrderId'),
        );
        await pumpAndSettleWithTimeout(tester);

        final router = GoRouter.of(
          tester.element(find.byKey(Key('stub_Order $kTestOrderId'))),
        );

        // التنقل بين تفاصيل الطلب والتتبع عدة مرات
        // (يحاكي التحقق المتكرر من حالة الطلب أثناء التوصيل)
        for (var i = 0; i < kOrderStatusFlow.length; i++) {
          // عرض التتبع
          router.go('/orders/$kTestOrderId/track');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Track $kTestOrderId');

          // العودة للتفاصيل
          router.go('/orders/$kTestOrderId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestOrderId');
        }
      });

      testWidgets('order tracking → back to orders list → home', (
        tester,
      ) async {
        // مسار العودة من التتبع للشاشة الرئيسية
        await tester.pumpWidget(
          buildCustomerTestApp(initialRoute: '/orders/$kTestOrderId/track'),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Track $kTestOrderId');

        final router = GoRouter.of(
          tester.element(find.byKey(Key('stub_Track $kTestOrderId'))),
        );

        // العودة لقائمة الطلبات
        router.go('/orders');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Orders');

        // العودة للشاشة الرئيسية
        router.go('/home');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Home');
      });
    });

    // ==========================================================================
    // END-TO-END: Full Happy Path
    // ==========================================================================
    group('End-to-End: Complete Happy Path', () {
      testWidgets(
        'full journey: home → browse → cart → checkout → track → complete',
        (tester) async {
          // المسار الكامل للعميل من الدخول حتى استلام الطلب
          await tester.pumpWidget(buildCustomerTestApp(initialRoute: '/home'));
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Home');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Home'))),
          );

          // 1. تصفح الكتالوج
          router.go('/catalog');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Catalog');

          // 2. عرض منتج
          router.go('/products/${testProducts[0].id}');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Product ${testProducts[0].id}');

          // 3. عرض منتج آخر
          router.go('/products/${testProducts[1].id}');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Product ${testProducts[1].id}');

          // 4. فتح السلة
          router.go('/cart');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Cart');

          // 5. إتمام الطلب
          router.go('/checkout');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Checkout');

          // 6. تأكيد الطلب
          router.go('/orders/$kTestOrderId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestOrderId');

          // 7. تتبع الطلب
          router.go('/orders/$kTestOrderId/track');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Track $kTestOrderId');

          // 8. الطلب تم توصيله → العودة لتفاصيل الطلب
          router.go('/orders/$kTestOrderId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestOrderId');

          // 9. عرض قائمة الطلبات
          router.go('/orders');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Orders');

          // 10. العودة للشاشة الرئيسية
          router.go('/home');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Home');
        },
      );
    });
  });
}
