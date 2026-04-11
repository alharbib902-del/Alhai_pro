/// Customer Display & Feature Settings Providers
/// مزودات شاشة العميل والميزات
///
/// يوفر:
/// - [cashierFeatureSettingsProvider]: إعدادات الميزات من settings_table
/// - [customerDisplayServiceProvider]: خدمة شاشة العميل (singleton)
/// - [customerDisplayStreamProvider]: بث حالة شاشة العميل
/// - [nfcListenerServiceProvider]: خدمة مستمع NFC
/// - [nfcListenerStreamProvider]: بث أحداث NFC
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../services/customer_display/customer_display_service.dart';
import '../services/customer_display/customer_display_state.dart';
import '../services/payment/nfc_capability_service.dart';
import '../services/payment/nfc_listener_service.dart';
import '../services/payment/payment_gateway.dart';

// ============================================================================
// FEATURE SETTINGS MODEL
// ============================================================================

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

// ============================================================================
// FEATURE SETTINGS PROVIDER
// ============================================================================

/// مزود إعدادات الميزات (يقرأ من settings_table)
final cashierFeatureSettingsProvider =
    FutureProvider.autoDispose<CashierFeatureSettings>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return const CashierFeatureSettings();

      final db = GetIt.I<AppDatabase>();
      try {
        final settings = await (db.select(
          db.settingsTable,
        )..where((s) => s.storeId.equals(storeId))).get();

        final settingsMap = <String, String>{};
        for (final s in settings) {
          settingsMap[s.key] = s.value;
        }

        return CashierFeatureSettings(
          enableCustomerDisplay:
              settingsMap['feature_customer_display'] == 'true',
          enablePhoneCollection:
              settingsMap['feature_phone_collection'] != 'false',
          enableNfcPayment: settingsMap['feature_nfc_payment'] == 'true',
          nfcTimeoutSeconds:
              int.tryParse(settingsMap['nfc_timeout_seconds'] ?? '') ?? 30,
        );
      } catch (_) {
        return const CashierFeatureSettings();
      }
    });

// ============================================================================
// CUSTOMER DISPLAY SERVICE PROVIDER
// ============================================================================

/// مزود خدمة شاشة العميل (singleton)
final customerDisplayServiceProvider = Provider<CustomerDisplayService>((ref) {
  final service = CustomerDisplayService();

  // تفعيل/تعطيل حسب الإعدادات
  final settingsAsync = ref.watch(cashierFeatureSettingsProvider);
  settingsAsync.whenData((settings) {
    if (settings.enableCustomerDisplay) {
      service.enable(storeName: '');
    } else {
      service.disable();
    }
  });

  ref.onDispose(() => service.dispose());
  return service;
});

// ============================================================================
// CUSTOMER DISPLAY STREAM PROVIDER
// ============================================================================

/// بث حالة شاشة العميل (لشاشة العميل المستقبِلة)
final customerDisplayStreamProvider = StreamProvider<CustomerDisplayState>((
  ref,
) {
  final service = ref.watch(customerDisplayServiceProvider);
  return service.stateStream;
});

// ============================================================================
// NFC LISTENER PROVIDERS
// ============================================================================

/// مزود خدمة مستمع NFC
///
/// يستخدم MadaPaymentGateway (محاكاة) لمعالجة عمليات الدفع اللاتلامسي.
/// في الإنتاج، يُستبدل بـ SDK فعلي (Nearpay SoftPOS).
final nfcListenerServiceProvider = Provider<NfcListenerService>((ref) {
  // استخدام MadaPaymentGateway لمعالجة المدفوعات من NFC
  final gateway = MadaPaymentGateway(
    merchantId: 'default',
    terminalId: 'softpos',
    isTestMode: true,
  );

  // قراءة إعدادات المهلة من الميزات
  final settingsAsync = ref.watch(cashierFeatureSettingsProvider);
  final timeoutSeconds = settingsAsync.valueOrNull?.nfcTimeoutSeconds ?? 30;
  final isEnabled = settingsAsync.valueOrNull?.enableNfcPayment ?? false;

  final config = NfcConfiguration(
    timeoutDuration: Duration(seconds: timeoutSeconds),
    isEnabled: isEnabled,
  );

  final service = MockNfcListenerService(
    gateway: gateway,
    configuration: config,
  );

  ref.onDispose(() => service.dispose());
  return service;
});

/// بث أحداث NFC
final nfcListenerStreamProvider = StreamProvider<NfcListenerEvent>((ref) {
  final service = ref.watch(nfcListenerServiceProvider);
  return service.events;
});

// ============================================================================
// NFC CAPABILITY PROVIDERS
// ============================================================================

/// مزود خدمة فحص NFC
final nfcCapabilityServiceProvider = Provider<NfcCapabilityService>((ref) {
  if (kIsWeb) {
    return WebNfcCapabilityService();
  }
  return NativeNfcCapabilityService();
});

/// مزود حالة قدرة NFC
final nfcCapabilityProvider = FutureProvider.autoDispose<NfcCapability>((
  ref,
) async {
  final service = ref.watch(nfcCapabilityServiceProvider);
  return service.checkCapability();
});
