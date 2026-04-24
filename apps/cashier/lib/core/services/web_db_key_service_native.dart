// Native stub لـ `WebDbKeyService`.
//
// هذا الملف يُحمَّل على Android/iOS/Desktop/test VM بدلاً من
// `web_db_key_service_web.dart` (الذي يستخدم `dart:js_interop`).
// الـ conditional import في `web_db_key_service.dart` يتولى التوجيه.
//
// لا يُفترض أن تُستدعى `getOrCreateWebDbKey` خارج `kIsWeb == true` لأن
// `main.dart` يختار native path (FlutterSecureStorage) حينئذ — لكن الـ
// stub يُعيد خطأ واضح إن حدث سوء استخدام.

/// Native stub — يرمي UnsupportedError عند الاستدعاء.
///
/// الواجهة متطابقة مع نسخة الويب لضمان نفس contract.
class WebDbKeyService {
  WebDbKeyService._();

  /// على native platforms، استخدم `FlutterSecureStorage` بدلاً من هذا.
  ///
  /// هذه الدالة موجودة فقط لتجعل `main.dart` يُجمَّع على جميع platforms.
  /// على الـ runtime لن تُستدعى أبداً لأن `if (kIsWeb)` يحميها.
  static Future<String> getOrCreateWebDbKey() async {
    throw UnsupportedError(
      'WebDbKeyService.getOrCreateWebDbKey() يعمل فقط على platform الويب. '
      'استخدم FlutterSecureStorage على Android/iOS/Desktop.',
    );
  }
}
