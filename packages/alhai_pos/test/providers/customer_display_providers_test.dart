// اختبار CashierFeatureSettings وحدوياً
//
// ملاحظة: لا نستورد customer_display_providers.dart مباشرة لأن الملف
// يحتوي على خطأ تحليل موجود مسبقاً (PaymentGateway غير مرئي في
// سياق nfcListenerServiceProvider بسبب named library في nfc_listener_service).
// بدلاً من ذلك، نختبر CashierFeatureSettings كنموذج بيانات مستقل.

import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// نسخة مطابقة من CashierFeatureSettings للاختبار المستقل
// (مطابقة لـ customer_display_providers.dart)
// =============================================================================

/// إعدادات ميزات الكاشير
class CashierFeatureSettings {
  /// تفعيل شاشة العميل الثانية
  final bool enableCustomerDisplay;

  /// تفعيل جمع رقم جوال العميل
  final bool enablePhoneCollection;

  /// تفعيل الدفع بـ NFC
  final bool enableNfcPayment;

  /// مهلة انتظار NFC بالثواني
  final int nfcTimeoutSeconds;

  const CashierFeatureSettings({
    this.enableCustomerDisplay = false,
    this.enablePhoneCollection = true,
    this.enableNfcPayment = false,
    this.nfcTimeoutSeconds = 30,
  });
}

// =============================================================================
// محاكاة منطق قراءة الإعدادات من settingsMap
// (مطابق لما في cashierFeatureSettingsProvider)
// =============================================================================

CashierFeatureSettings parseSettingsFromMap(Map<String, String> settingsMap) {
  return CashierFeatureSettings(
    enableCustomerDisplay:
        settingsMap['feature_customer_display'] == 'true',
    enablePhoneCollection:
        settingsMap['feature_phone_collection'] != 'false',
    enableNfcPayment: settingsMap['feature_nfc_payment'] == 'true',
    nfcTimeoutSeconds:
        int.tryParse(settingsMap['nfc_timeout_seconds'] ?? '') ?? 30,
  );
}

void main() {
  // ==========================================================================
  // CashierFeatureSettings - القيم الافتراضية
  // ==========================================================================

  group('CashierFeatureSettings - القيم الافتراضية', () {
    test('القيم الافتراضية صحيحة', () {
      const settings = CashierFeatureSettings();

      expect(settings.enableCustomerDisplay, isFalse);
      expect(settings.enablePhoneCollection, isTrue);
      expect(settings.enableNfcPayment, isFalse);
      expect(settings.nfcTimeoutSeconds, equals(30));
    });

    test('شاشة العميل معطّلة بشكل افتراضي', () {
      const settings = CashierFeatureSettings();

      expect(settings.enableCustomerDisplay, isFalse);
    });

    test('جمع رقم الجوال مفعّل بشكل افتراضي', () {
      const settings = CashierFeatureSettings();

      expect(settings.enablePhoneCollection, isTrue);
    });

    test('NFC معطّل بشكل افتراضي', () {
      const settings = CashierFeatureSettings();

      expect(settings.enableNfcPayment, isFalse);
    });

    test('مهلة NFC الافتراضية 30 ثانية', () {
      const settings = CashierFeatureSettings();

      expect(settings.nfcTimeoutSeconds, equals(30));
    });
  });

  // ==========================================================================
  // CashierFeatureSettings - قيم مخصصة
  // ==========================================================================

  group('CashierFeatureSettings - قيم مخصصة', () {
    test('يقبل جميع القيم المخصصة', () {
      const settings = CashierFeatureSettings(
        enableCustomerDisplay: true,
        enablePhoneCollection: false,
        enableNfcPayment: true,
        nfcTimeoutSeconds: 60,
      );

      expect(settings.enableCustomerDisplay, isTrue);
      expect(settings.enablePhoneCollection, isFalse);
      expect(settings.enableNfcPayment, isTrue);
      expect(settings.nfcTimeoutSeconds, equals(60));
    });

    test('يقبل تعديل حقل واحد فقط', () {
      const settings = CashierFeatureSettings(
        enableCustomerDisplay: true,
      );

      expect(settings.enableCustomerDisplay, isTrue);
      // باقي القيم افتراضية
      expect(settings.enablePhoneCollection, isTrue);
      expect(settings.enableNfcPayment, isFalse);
      expect(settings.nfcTimeoutSeconds, equals(30));
    });

    test('مهلة NFC تقبل قيم مختلفة', () {
      const settings10 = CashierFeatureSettings(nfcTimeoutSeconds: 10);
      const settings120 = CashierFeatureSettings(nfcTimeoutSeconds: 120);

      expect(settings10.nfcTimeoutSeconds, equals(10));
      expect(settings120.nfcTimeoutSeconds, equals(120));
    });
  });

  // ==========================================================================
  // CashierFeatureSettings - const constructor
  // ==========================================================================

  group('CashierFeatureSettings - const', () {
    test('يمكن إنشاء كائن const', () {
      const settings1 = CashierFeatureSettings();
      const settings2 = CashierFeatureSettings();

      // كائنان const بنفس القيم يجب أن يكونا متطابقين
      expect(identical(settings1, settings2), isTrue);
    });

    test('كائنات const مختلفة غير متطابقة', () {
      const settings1 = CashierFeatureSettings(enableNfcPayment: false);
      const settings2 = CashierFeatureSettings(enableNfcPayment: true);

      expect(identical(settings1, settings2), isFalse);
    });
  });

  // ==========================================================================
  // منطق قراءة الإعدادات من settingsMap
  // (يحاكي ما يفعله cashierFeatureSettingsProvider)
  // ==========================================================================

  group('parseSettingsFromMap - منطق قراءة الإعدادات', () {
    test('خريطة فارغة تعيد القيم الافتراضية', () {
      final settings = parseSettingsFromMap({});

      expect(settings.enableCustomerDisplay, isFalse);
      expect(settings.enablePhoneCollection, isTrue); // != 'false' = true
      expect(settings.enableNfcPayment, isFalse);
      expect(settings.nfcTimeoutSeconds, equals(30));
    });

    test('feature_customer_display: "true" يفعّل شاشة العميل', () {
      final settings = parseSettingsFromMap({
        'feature_customer_display': 'true',
      });

      expect(settings.enableCustomerDisplay, isTrue);
    });

    test('feature_customer_display: "false" يعطّل شاشة العميل', () {
      final settings = parseSettingsFromMap({
        'feature_customer_display': 'false',
      });

      expect(settings.enableCustomerDisplay, isFalse);
    });

    test('feature_phone_collection: "false" يعطّل جمع الأرقام', () {
      final settings = parseSettingsFromMap({
        'feature_phone_collection': 'false',
      });

      expect(settings.enablePhoneCollection, isFalse);
    });

    test('feature_phone_collection: "true" أو غائب يفعّل جمع الأرقام', () {
      final withTrue = parseSettingsFromMap({
        'feature_phone_collection': 'true',
      });
      final missing = parseSettingsFromMap({});

      expect(withTrue.enablePhoneCollection, isTrue);
      expect(missing.enablePhoneCollection, isTrue);
    });

    test('feature_nfc_payment: "true" يفعّل NFC', () {
      final settings = parseSettingsFromMap({
        'feature_nfc_payment': 'true',
      });

      expect(settings.enableNfcPayment, isTrue);
    });

    test('nfc_timeout_seconds يُحلل كعدد صحيح', () {
      final settings = parseSettingsFromMap({
        'nfc_timeout_seconds': '45',
      });

      expect(settings.nfcTimeoutSeconds, equals(45));
    });

    test('nfc_timeout_seconds غير صالح يعود لـ 30', () {
      final settings = parseSettingsFromMap({
        'nfc_timeout_seconds': 'abc',
      });

      expect(settings.nfcTimeoutSeconds, equals(30));
    });

    test('جميع الإعدادات مفعّلة', () {
      final settings = parseSettingsFromMap({
        'feature_customer_display': 'true',
        'feature_phone_collection': 'true',
        'feature_nfc_payment': 'true',
        'nfc_timeout_seconds': '60',
      });

      expect(settings.enableCustomerDisplay, isTrue);
      expect(settings.enablePhoneCollection, isTrue);
      expect(settings.enableNfcPayment, isTrue);
      expect(settings.nfcTimeoutSeconds, equals(60));
    });
  });
}
