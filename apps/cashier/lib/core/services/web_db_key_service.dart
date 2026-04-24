// واجهة خدمة تخزين مفتاح قاعدة البيانات على Web.
//
// تستخدم conditional imports لاختيار التنفيذ المناسب:
// - Web (dart.library.html): `web_db_key_service_web.dart` — WebCrypto +
//   IndexedDB + AES-GCM key wrapping.
// - Native / VM (كل شيء آخر): `web_db_key_service_native.dart` — stub يرمي
//   UnsupportedError إن استُدعي (حماية برمجية، لا يُفترض استدعاؤه).
//
// `main.dart` يستدعي `WebDbKeyService.getOrCreateWebDbKey()` داخل
// `if (kIsWeb)` — لذا stub لن يُستدعى على runtime، لكنه ضروري ليجمَّع
// الكود على Android/iOS/VM (اختبارات flutter test تعمل على VM).
//
// للتفاصيل الأمنية (threat model + WebCrypto strategy)، انظر
// `web_db_key_service_web.dart`.
export 'web_db_key_service_native.dart'
    if (dart.library.html) 'web_db_key_service_web.dart';
