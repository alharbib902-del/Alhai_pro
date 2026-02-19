import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/router/routes.dart';

// ===========================================
// Routes Tests
// ===========================================

void main() {
  group('AppRoutes - Auth Routes', () {
    test('مسارات المصادقة معرفة', () {
      expect(AppRoutes.splash, '/splash');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.storeSelect, '/store-select');
    });
  });

  group('AppRoutes - Main Routes', () {
    test('المسارات الرئيسية معرفة', () {
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.pos, '/pos');
      expect(AppRoutes.posPayment, '/pos/payment');
      expect(AppRoutes.posReceipt, '/pos/receipt');
      expect(AppRoutes.posSearch, '/pos/search');
      expect(AppRoutes.posCart, '/pos/cart');
      expect(AppRoutes.quickSale, '/pos/quick-sale');
    });
  });

  group('AppRoutes - Products Routes', () {
    test('مسارات المنتجات معرفة', () {
      expect(AppRoutes.products, '/products');
      expect(AppRoutes.productsAdd, '/products/add');
      expect(AppRoutes.productDetail, '/products/:id');
    });

    test('productDetailPath يُنشئ المسار الصحيح', () {
      expect(AppRoutes.productDetailPath('123'), '/products/123');
      expect(AppRoutes.productDetailPath('abc-def'), '/products/abc-def');
      expect(AppRoutes.productDetailPath('prod_001'), '/products/prod_001');
    });
  });

  group('AppRoutes - Other Routes', () {
    test('مسارات المخزون معرفة', () {
      expect(AppRoutes.inventory, '/inventory');
    });

    test('مسارات العملاء معرفة', () {
      expect(AppRoutes.customers, '/customers');
    });

    test('مسارات التقارير معرفة', () {
      expect(AppRoutes.reports, '/reports');
    });

    test('مسارات الموردين معرفة', () {
      expect(AppRoutes.suppliers, '/suppliers');
    });
  });

  group('AppRoutes - Settings Routes', () {
    test('مسارات الإعدادات معرفة', () {
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.settingsPrinter, '/settings/printer');
    });
  });

  group('AppRoutes - Consistency', () {
    test('جميع المسارات تبدأ بـ /', () {
      expect(AppRoutes.splash.startsWith('/'), true);
      expect(AppRoutes.login.startsWith('/'), true);
      expect(AppRoutes.home.startsWith('/'), true);
      expect(AppRoutes.pos.startsWith('/'), true);
      expect(AppRoutes.products.startsWith('/'), true);
      expect(AppRoutes.settings.startsWith('/'), true);
    });

    test('مسارات POS تبدأ بـ /pos', () {
      expect(AppRoutes.pos.startsWith('/pos'), true);
      expect(AppRoutes.posPayment.startsWith('/pos'), true);
      expect(AppRoutes.posReceipt.startsWith('/pos'), true);
      expect(AppRoutes.posSearch.startsWith('/pos'), true);
      expect(AppRoutes.posCart.startsWith('/pos'), true);
      expect(AppRoutes.quickSale.startsWith('/pos'), true);
    });

    test('مسارات المنتجات تبدأ بـ /products', () {
      expect(AppRoutes.products.startsWith('/products'), true);
      expect(AppRoutes.productsAdd.startsWith('/products'), true);
      expect(AppRoutes.productDetail.startsWith('/products'), true);
    });

    test('مسارات الإعدادات تبدأ بـ /settings', () {
      expect(AppRoutes.settings.startsWith('/settings'), true);
      expect(AppRoutes.settingsPrinter.startsWith('/settings'), true);
    });
  });
}
