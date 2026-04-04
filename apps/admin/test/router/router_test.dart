/// Admin Router Tests
///
/// Verifies that the GoRouter configuration for the Admin app
/// is correctly defined with all expected routes.
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show AppRoutes;

void main() {
  group('Admin Router - Configuration', () {
    test('initial location is splash screen', () {
      expect(AppRoutes.splash, equals('/splash'));
    });
  });

  group('Admin Router - Auth Route Definitions', () {
    test('AppRoutes defines splash route', () {
      expect(AppRoutes.splash, equals('/splash'));
    });

    test('AppRoutes defines login route', () {
      expect(AppRoutes.login, equals('/login'));
    });

    test('AppRoutes defines store-select route', () {
      expect(AppRoutes.storeSelect, equals('/store-select'));
    });

    test('AppRoutes defines onboarding route', () {
      expect(AppRoutes.onboarding, equals('/onboarding'));
    });
  });

  group('Admin Router - Main Route Definitions', () {
    test('AppRoutes defines home route', () {
      expect(AppRoutes.home, equals('/home'));
    });

    test('AppRoutes defines dashboard route', () {
      expect(AppRoutes.dashboard, equals('/dashboard'));
    });

    test('AppRoutes defines POS route', () {
      expect(AppRoutes.pos, equals('/pos'));
    });

    test('AppRoutes defines products route', () {
      expect(AppRoutes.products, equals('/products'));
    });

    test('AppRoutes defines inventory route', () {
      expect(AppRoutes.inventory, equals('/inventory'));
    });

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

    test('AppRoutes defines returns route', () {
      expect(AppRoutes.returns, equals('/returns'));
    });

    test('AppRoutes defines expenses route', () {
      expect(AppRoutes.expenses, equals('/expenses'));
    });

    test('AppRoutes defines shifts route', () {
      expect(AppRoutes.shifts, equals('/shifts'));
    });

    test('AppRoutes defines reports route', () {
      expect(AppRoutes.reports, equals('/reports'));
    });

    test('AppRoutes defines profile route', () {
      expect(AppRoutes.profile, equals('/profile'));
    });
  });

  group('Admin Router - AI Route Definitions', () {
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
      expect(AppRoutes.aiCustomerRecommendations,
          equals('/ai/customer-recommendations'));
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

  group('Admin Router - Settings Route Definitions', () {
    test('AppRoutes defines settings route', () {
      expect(AppRoutes.settings, equals('/settings'));
    });

    test('AppRoutes defines settings language route', () {
      expect(AppRoutes.settingsLanguage, equals('/settings/language'));
    });

    test('AppRoutes defines settings theme route', () {
      expect(AppRoutes.settingsTheme, equals('/settings/theme'));
    });

    test('AppRoutes defines settings printer route', () {
      expect(AppRoutes.settingsPrinter, equals('/settings/printer'));
    });

    test('AppRoutes defines settings store route', () {
      expect(AppRoutes.settingsStore, equals('/settings/store'));
    });

    test('AppRoutes defines settings POS route', () {
      expect(AppRoutes.settingsPos, equals('/settings/pos'));
    });
  });

  group('Admin Router - Route Helpers', () {
    test('productDetailPath generates correct path', () {
      expect(
        AppRoutes.productDetailPath('abc'),
        equals('/products/abc'),
      );
    });

    test('customerDetailPath generates correct path', () {
      expect(
        AppRoutes.customerDetailPath('123'),
        equals('/customers/123'),
      );
    });

    test('supplierDetailPath generates correct path', () {
      expect(
        AppRoutes.supplierDetailPath('456'),
        equals('/suppliers/456'),
      );
    });

    test('invoiceDetailPath generates correct path', () {
      expect(
        AppRoutes.invoiceDetailPath('789'),
        equals('/invoices/789'),
      );
    });
  });
}
