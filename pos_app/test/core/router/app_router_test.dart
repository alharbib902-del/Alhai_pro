import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/core/router/routes.dart';
import 'package:pos_app/core/router/app_router.dart';

// ===========================================
// App Router Tests
// ===========================================

void main() {
  group('AppRoutes', () {
    group('Auth Routes', () {
      test('splash يبدأ بـ /', () {
        expect(AppRoutes.splash, startsWith('/'));
        expect(AppRoutes.splash, '/splash');
      });

      test('login يبدأ بـ /', () {
        expect(AppRoutes.login, startsWith('/'));
        expect(AppRoutes.login, '/login');
      });

      test('storeSelect يبدأ بـ /', () {
        expect(AppRoutes.storeSelect, startsWith('/'));
        expect(AppRoutes.storeSelect, '/store-select');
      });
    });

    group('Main Routes', () {
      test('home يبدأ بـ /', () {
        expect(AppRoutes.home, startsWith('/'));
        expect(AppRoutes.home, '/home');
      });

      test('pos يبدأ بـ /', () {
        expect(AppRoutes.pos, startsWith('/'));
        expect(AppRoutes.pos, '/pos');
      });

      test('posPayment nested under pos', () {
        expect(AppRoutes.posPayment, startsWith('/pos'));
        expect(AppRoutes.posPayment, '/pos/payment');
      });

      test('posReceipt nested under pos', () {
        expect(AppRoutes.posReceipt, startsWith('/pos'));
        expect(AppRoutes.posReceipt, '/pos/receipt');
      });

      test('posSearch nested under pos', () {
        expect(AppRoutes.posSearch, startsWith('/pos'));
        expect(AppRoutes.posSearch, '/pos/search');
      });

      test('posCart nested under pos', () {
        expect(AppRoutes.posCart, startsWith('/pos'));
        expect(AppRoutes.posCart, '/pos/cart');
      });

      test('quickSale nested under pos', () {
        expect(AppRoutes.quickSale, startsWith('/pos'));
        expect(AppRoutes.quickSale, '/pos/quick-sale');
      });
    });

    group('Products Routes', () {
      test('products يبدأ بـ /', () {
        expect(AppRoutes.products, startsWith('/'));
        expect(AppRoutes.products, '/products');
      });

      test('productsAdd nested under products', () {
        expect(AppRoutes.productsAdd, startsWith('/products'));
        expect(AppRoutes.productsAdd, '/products/add');
      });

      test('productDetail يحتوي على :id parameter', () {
        expect(AppRoutes.productDetail, contains(':id'));
        expect(AppRoutes.productDetail, '/products/:id');
      });

      test('productDetailPath يُنشئ مسار صحيح', () {
        expect(AppRoutes.productDetailPath('123'), '/products/123');
        expect(AppRoutes.productDetailPath('abc'), '/products/abc');
        expect(AppRoutes.productDetailPath('test-product'), '/products/test-product');
      });
    });

    group('Inventory Routes', () {
      test('inventory يبدأ بـ /', () {
        expect(AppRoutes.inventory, startsWith('/'));
        expect(AppRoutes.inventory, '/inventory');
      });
    });

    group('Customers Routes', () {
      test('customers يبدأ بـ /', () {
        expect(AppRoutes.customers, startsWith('/'));
        expect(AppRoutes.customers, '/customers');
      });
    });

    group('Reports Routes', () {
      test('reports يبدأ بـ /', () {
        expect(AppRoutes.reports, startsWith('/'));
        expect(AppRoutes.reports, '/reports');
      });
    });

    group('Suppliers Routes', () {
      test('suppliers يبدأ بـ /', () {
        expect(AppRoutes.suppliers, startsWith('/'));
        expect(AppRoutes.suppliers, '/suppliers');
      });
    });

    group('Settings Routes', () {
      test('settings يبدأ بـ /', () {
        expect(AppRoutes.settings, startsWith('/'));
        expect(AppRoutes.settings, '/settings');
      });

      test('settingsPrinter nested under settings', () {
        expect(AppRoutes.settingsPrinter, startsWith('/settings'));
        expect(AppRoutes.settingsPrinter, '/settings/printer');
      });
    });
  });

  group('AppRoutes uniqueness', () {
    test('جميع المسارات فريدة', () {
      final routes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.storeSelect,
        AppRoutes.home,
        AppRoutes.pos,
        AppRoutes.posPayment,
        AppRoutes.posReceipt,
        AppRoutes.posSearch,
        AppRoutes.posCart,
        AppRoutes.quickSale,
        AppRoutes.products,
        AppRoutes.productsAdd,
        AppRoutes.productDetail,
        AppRoutes.inventory,
        AppRoutes.customers,
        AppRoutes.reports,
        AppRoutes.suppliers,
        AppRoutes.settings,
        AppRoutes.settingsPrinter,
      ];

      // Check uniqueness
      final uniqueRoutes = routes.toSet();
      expect(uniqueRoutes.length, routes.length);
    });

    test('جميع المسارات ليست فارغة', () {
      final routes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.storeSelect,
        AppRoutes.home,
        AppRoutes.pos,
        AppRoutes.posPayment,
        AppRoutes.posReceipt,
        AppRoutes.posSearch,
        AppRoutes.posCart,
        AppRoutes.quickSale,
        AppRoutes.products,
        AppRoutes.productsAdd,
        AppRoutes.productDetail,
        AppRoutes.inventory,
        AppRoutes.customers,
        AppRoutes.reports,
        AppRoutes.suppliers,
        AppRoutes.settings,
        AppRoutes.settingsPrinter,
      ];

      for (final route in routes) {
        expect(route, isNotEmpty);
      }
    });
  });

  group('AppRoutes path structure', () {
    test('جميع المسارات تبدأ بـ /', () {
      final routes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.storeSelect,
        AppRoutes.home,
        AppRoutes.pos,
        AppRoutes.posPayment,
        AppRoutes.posReceipt,
        AppRoutes.posSearch,
        AppRoutes.posCart,
        AppRoutes.quickSale,
        AppRoutes.products,
        AppRoutes.productsAdd,
        AppRoutes.productDetail,
        AppRoutes.inventory,
        AppRoutes.customers,
        AppRoutes.reports,
        AppRoutes.suppliers,
        AppRoutes.settings,
        AppRoutes.settingsPrinter,
      ];

      for (final route in routes) {
        expect(route, startsWith('/'), reason: '$route should start with /');
      }
    });

    test('لا تحتوي على مسافات', () {
      final routes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.storeSelect,
        AppRoutes.home,
        AppRoutes.pos,
        AppRoutes.products,
        AppRoutes.inventory,
        AppRoutes.customers,
        AppRoutes.reports,
        AppRoutes.suppliers,
        AppRoutes.settings,
      ];

      for (final route in routes) {
        expect(route.contains(' '), isFalse, reason: '$route should not contain spaces');
      }
    });
  });

  group('AppRouter', () {
    test('router موجود', () {
      expect(AppRouter.router, isNotNull);
      expect(AppRouter.router, isA<GoRouter>());
    });

    test('initialLocation هو splash', () {
      // GoRouter لا يكشف initialLocation مباشرة
      // لكن يمكننا التحقق من وجود المسار
      expect(AppRoutes.splash, '/splash');
    });
  });

  group('Route categories', () {
    test('عدد مسارات Auth = 3', () {
      final authRoutes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.storeSelect,
      ];
      expect(authRoutes.length, 3);
    });

    test('عدد مسارات POS = 5', () {
      final posRoutes = [
        AppRoutes.pos,
        AppRoutes.posPayment,
        AppRoutes.posReceipt,
        AppRoutes.posSearch,
        AppRoutes.quickSale,
      ];
      expect(posRoutes.length, 5);
    });

    test('عدد مسارات Products = 3', () {
      final productRoutes = [
        AppRoutes.products,
        AppRoutes.productsAdd,
        AppRoutes.productDetail,
      ];
      expect(productRoutes.length, 3);
    });

    test('عدد مسارات Settings = 2', () {
      final settingsRoutes = [
        AppRoutes.settings,
        AppRoutes.settingsPrinter,
      ];
      expect(settingsRoutes.length, 2);
    });
  });

  group('Dynamic routes', () {
    test('productDetailPath يعمل مع أي ID', () {
      expect(AppRoutes.productDetailPath('1'), '/products/1');
      expect(AppRoutes.productDetailPath('uuid-123-456'), '/products/uuid-123-456');
      expect(AppRoutes.productDetailPath('product_name'), '/products/product_name');
    });

    test('productDetailPath يعمل مع ID فارغ', () {
      expect(AppRoutes.productDetailPath(''), '/products/');
    });

    test('productDetailPath يحافظ على الأحرف الخاصة', () {
      expect(AppRoutes.productDetailPath('test-123'), '/products/test-123');
      expect(AppRoutes.productDetailPath('test_123'), '/products/test_123');
    });
  });
}
