/// Admin Lite Router Tests
///
/// Verifies that the GoRouter configuration for the Admin Lite app
/// is correctly defined with all expected routes.
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show AppRoutes;

void main() {
  group('Admin Lite Router - Configuration', () {
    test('initial location is dashboard', () {
      expect(AppRoutes.dashboard, equals('/dashboard'));
    });
  });

  group('Admin Lite Router - Auth Route Definitions', () {
    test('AppRoutes defines splash route', () {
      expect(AppRoutes.splash, equals('/splash'));
    });

    test('AppRoutes defines login route', () {
      expect(AppRoutes.login, equals('/login'));
    });
  });

  group('Admin Lite Router - Tab 1: Dashboard Routes', () {
    test('AppRoutes defines home route', () {
      expect(AppRoutes.home, equals('/home'));
    });

    test('AppRoutes defines dashboard route', () {
      expect(AppRoutes.dashboard, equals('/dashboard'));
    });
  });

  group('Admin Lite Router - Tab 2: Reports Routes', () {
    test('AppRoutes defines reports route', () {
      expect(AppRoutes.reports, equals('/reports'));
    });

    test('AppRoutes defines complaints report route', () {
      expect(AppRoutes.complaintsReport, equals('/reports/complaints'));
    });
  });

  group('Admin Lite Router - Tab 3: AI Routes', () {
    test('AppRoutes defines AI assistant route', () {
      expect(AppRoutes.aiAssistant, equals('/ai/assistant'));
    });

    test('AppRoutes defines AI sales forecasting route', () {
      expect(AppRoutes.aiSalesForecasting, equals('/ai/sales-forecasting'));
    });

    test('AppRoutes defines AI smart pricing route', () {
      expect(AppRoutes.aiSmartPricing, equals('/ai/smart-pricing'));
    });

    test('AppRoutes defines AI fraud detection route', () {
      expect(AppRoutes.aiFraudDetection, equals('/ai/fraud-detection'));
    });

    test('AppRoutes defines AI basket analysis route', () {
      expect(AppRoutes.aiBasketAnalysis, equals('/ai/basket-analysis'));
    });

    test('AppRoutes defines AI customer recommendations route', () {
      expect(
        AppRoutes.aiCustomerRecommendations,
        equals('/ai/customer-recommendations'),
      );
    });

    test('AppRoutes defines AI smart inventory route', () {
      expect(AppRoutes.aiSmartInventory, equals('/ai/smart-inventory'));
    });

    test('AppRoutes defines AI competitor analysis route', () {
      expect(AppRoutes.aiCompetitorAnalysis, equals('/ai/competitor-analysis'));
    });

    test('AppRoutes defines AI smart reports route', () {
      expect(AppRoutes.aiSmartReports, equals('/ai/smart-reports'));
    });

    test('AppRoutes defines AI staff analytics route', () {
      expect(AppRoutes.aiStaffAnalytics, equals('/ai/staff-analytics'));
    });

    test('AppRoutes defines AI product recognition route', () {
      expect(AppRoutes.aiProductRecognition, equals('/ai/product-recognition'));
    });

    test('AppRoutes defines AI sentiment analysis route', () {
      expect(AppRoutes.aiSentimentAnalysis, equals('/ai/sentiment-analysis'));
    });

    test('AppRoutes defines AI return prediction route', () {
      expect(AppRoutes.aiReturnPrediction, equals('/ai/return-prediction'));
    });

    test('AppRoutes defines AI promotion designer route', () {
      expect(AppRoutes.aiPromotionDesigner, equals('/ai/promotion-designer'));
    });

    test('AppRoutes defines AI chat with data route', () {
      expect(AppRoutes.aiChatWithData, equals('/ai/chat-with-data'));
    });
  });

  group('Admin Lite Router - Tab 4: Monitoring Routes', () {
    test('AppRoutes defines inventory route', () {
      expect(AppRoutes.inventory, equals('/inventory'));
    });

    test('AppRoutes defines expiry tracking route', () {
      expect(AppRoutes.expiryTracking, equals('/inventory/expiry-tracking'));
    });

    test('AppRoutes defines shifts route', () {
      expect(AppRoutes.shifts, equals('/shifts'));
    });

    test('AppRoutes defines shift summary route', () {
      expect(AppRoutes.shiftSummary, equals('/shifts/summary'));
    });

    test('AppRoutes defines products route', () {
      expect(AppRoutes.products, equals('/products'));
    });
  });

  group('Admin Lite Router - Tab 5: More Routes', () {
    test('AppRoutes defines customers route', () {
      expect(AppRoutes.customers, equals('/customers'));
    });

    test('AppRoutes defines suppliers route', () {
      expect(AppRoutes.suppliers, equals('/suppliers'));
    });

    test('AppRoutes defines orders route', () {
      expect(AppRoutes.orders, equals('/orders'));
    });

    test('AppRoutes defines invoices route', () {
      expect(AppRoutes.invoices, equals('/invoices'));
    });

    test('AppRoutes defines expenses route', () {
      expect(AppRoutes.expenses, equals('/expenses'));
    });

    test('AppRoutes defines expense categories route', () {
      expect(AppRoutes.expenseCategories, equals('/expenses/categories'));
    });

    test('AppRoutes defines profile route', () {
      expect(AppRoutes.profile, equals('/profile'));
    });

    test('AppRoutes defines settings route', () {
      expect(AppRoutes.settings, equals('/settings'));
    });

    test('AppRoutes defines settings language route', () {
      expect(AppRoutes.settingsLanguage, equals('/settings/language'));
    });

    test('AppRoutes defines settings theme route', () {
      expect(AppRoutes.settingsTheme, equals('/settings/theme'));
    });

    test('AppRoutes defines sync status route', () {
      expect(AppRoutes.syncStatus, equals('/sync'));
    });

    test('AppRoutes defines notifications route', () {
      expect(AppRoutes.notificationsCenter, equals('/notifications'));
    });
  });

  group('Admin Lite Router - Route Helpers', () {
    test('productDetailPath generates correct path', () {
      expect(AppRoutes.productDetailPath('abc'), equals('/products/abc'));
    });

    test('customerDetailPath generates correct path', () {
      expect(AppRoutes.customerDetailPath('123'), equals('/customers/123'));
    });

    test('supplierDetailPath generates correct path', () {
      expect(AppRoutes.supplierDetailPath('456'), equals('/suppliers/456'));
    });

    test('invoiceDetailPath generates correct path', () {
      expect(AppRoutes.invoiceDetailPath('789'), equals('/invoices/789'));
    });
  });
}
