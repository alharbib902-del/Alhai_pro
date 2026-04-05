/// خدمة فحص قدرة NFC على الجهاز
library;

import 'package:flutter/foundation.dart';

/// نتيجة فحص NFC
class NfcCapability {
  /// هل الجهاز يدعم NFC
  final bool isSupported;

  /// هل NFC مفعّل في إعدادات الجهاز
  final bool isEnabled;

  /// سبب عدم التوفر
  final String? unavailableReason;

  const NfcCapability({
    required this.isSupported,
    required this.isEnabled,
    this.unavailableReason,
  });

  /// هل NFC جاهز للاستخدام
  bool get isReady => isSupported && isEnabled;

  const NfcCapability.notSupported()
      : isSupported = false,
        isEnabled = false,
        unavailableReason = 'الجهاز لا يدعم NFC';

  const NfcCapability.disabled()
      : isSupported = true,
        isEnabled = false,
        unavailableReason = 'NFC معطّل في إعدادات الجهاز';

  const NfcCapability.ready()
      : isSupported = true,
        isEnabled = true,
        unavailableReason = null;

  /// للويب: NFC Web API support check
  const NfcCapability.webNotSupported()
      : isSupported = false,
        isEnabled = false,
        unavailableReason =
            'المتصفح لا يدعم NFC — يتطلب جهاز Android مع Chrome';
}

/// خدمة فحص قدرة NFC
abstract class NfcCapabilityService {
  /// فحص قدرة الجهاز
  Future<NfcCapability> checkCapability();

  /// مراقبة تغيرات حالة NFC (تفعيل/تعطيل)
  Stream<NfcCapability> get capabilityChanges;
}

/// فحص NFC للويب
///
/// Web NFC API متاح فقط على Chrome Android.
/// على Desktop و iOS: غير مدعوم.
class WebNfcCapabilityService implements NfcCapabilityService {
  @override
  Future<NfcCapability> checkCapability() async {
    if (!kIsWeb) return const NfcCapability.notSupported();

    // Web NFC API is only available on Chrome Android
    // For SoftPOS, the actual NFC happens via native SDK, not web
    // So on web, we report not supported (NFC requires native app)
    return const NfcCapability.webNotSupported();
  }

  @override
  Stream<NfcCapability> get capabilityChanges =>
      Stream.value(const NfcCapability.webNotSupported());
}

/// فحص NFC للأجهزة المحلية (Android/iOS)
///
/// TODO: تكامل مع nfc_manager package عند الحاجة
/// حالياً يُرجع mock بناءً على المنصة
class NativeNfcCapabilityService implements NfcCapabilityService {
  @override
  Future<NfcCapability> checkCapability() async {
    // TODO: Use nfc_manager to check actual hardware
    // For now, return simulated result based on platform
    if (kDebugMode) {
      debugPrint(
          '[NFC] Capability check: simulated (native SDK not integrated)');
      return const NfcCapability.ready(); // Simulate available in debug
    }
    return const NfcCapability.notSupported();
  }

  @override
  Stream<NfcCapability> get capabilityChanges {
    return Stream.fromFuture(checkCapability());
  }
}
