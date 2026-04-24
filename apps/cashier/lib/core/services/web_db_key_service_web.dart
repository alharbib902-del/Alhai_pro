// تخزين مُقوَّى لمفتاح تشفير قاعدة البيانات على Web.
//
// النموذج التهديدي (Threat Model):
// =================================
// - الخطر: XSS يقرأ مفتاح SQLCipher من localStorage → يفك تشفير كامل الـ DB
//   (مبيعات، عملاء، أرقام ضريبية) → انتهاك ZATCA compliance.
// - كود قديم: مفتاح raw مُخزَّن base64 في localStorage — XSS يأخذه مباشرة.
//
// الحل (Key Wrapping + non-extractable CryptoKey):
// ================================================
// 1. نُولِّد wrappingKey (AES-GCM 256, extractable=false) ونُخزِّنه في IndexedDB.
//    المتصفح يضمن أن CryptoKey غير قابل للتصدير — حتى XSS لا يمكنه
//    استخراج bytes الخام عبر crypto.subtle.exportKey().
// 2. نُولِّد dbKey (raw 32 bytes)، نُشفِّره بـ AES-GCM باستخدام wrappingKey،
//    ونُخزِّن الـ ciphertext + IV في localStorage.
// 3. XSS يمكنه قراءة ciphertext من localStorage لكن لا يستطيع فكه دون
//    wrappingKey (المحمي في IndexedDB كـ non-extractable).
//
// ما يحميه:
// ---------
//   ✅ XSS يقرأ localStorage → يحصل على ciphertext عديم الفائدة
//   ✅ نسخ localStorage إلى متصفح آخر (لا wrappingKey هناك)
//   ✅ استخراج wrappingKey عبر exportKey() (مرفوض من المتصفح)
//
// ما لا يحميه:
// -----------
//   ❌ XSS يستطيع استدعاء crypto.subtle.decrypt عبر wrappingKey
//      طالما هو يعمل في نفس origin — لكنه مقيَّد بدورة حياة الـ session
//      ولا يمكنه exfiltrate الـ key نفسه (فقط plaintext في اللحظة الحالية).
//   ❌ مسح بيانات المتصفح يُفقد المفتاح → DB تبقى مشفَّرة ولا يمكن فكها
//      (سلوك مقبول لأن المستخدم عرَّف الإجراء بنفسه).
//   ❌ هجوم مستوى OS (malware على الجهاز) — خارج نطاق Web.
//
// Fallback:
// ---------
// إذا WebCrypto أو IndexedDB غير مدعومَين (متصفح قديم جداً) → نسقط على
// localStorage كما في الكود القديم، ونُسجِّل WARN في Sentry.
// لا نكسر التطبيق لمستخدم لا يملك WebCrypto.

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sentry_service.dart';

/// اسم قاعدة بيانات IndexedDB التي تحتوي wrappingKey
const String _wrapIdbName = 'alhai_cashier_key_wrap';

/// اسم Object Store داخل الـ IDB
const String _wrapIdbStore = 'wrapping_keys';

/// إصدار قاعدة IndexedDB — زيادته تُفعِّل onupgradeneeded
const int _wrapIdbVersion = 1;

/// المفتاح المُستخدَم لتخزين الـ CryptoKey داخل Object Store
const String _wrapKeyId = 'db_wrap_key';

/// اسم مفتاح localStorage الذي يحتوي الـ ciphertext المُشفَّر
const String _wrappedKeyStorageKey = 'cashier_db_wrapped_key_v1';

/// المفتاح القديم (قبل التقوية) — نقرأه مرة واحدة للـ migration
const String _legacyKeyStorageKey = 'secure_storage_db_encryption_key';

/// طول مفتاح DB (AES-256 → 32 bytes راو)
const int _dbKeyLengthBytes = 32;

/// طول IV لـ AES-GCM (12 bytes هو التوصية القياسية)
const int _ivLengthBytes = 12;

/// خدمة تخزين/استرجاع مفتاح تشفير قاعدة بيانات Cashier على Web.
///
/// تُستدعى حصرياً عند `kIsWeb == true`. على Android/iOS/Desktop
/// استخدم `FlutterSecureStorage` بدلاً من هذا.
class WebDbKeyService {
  WebDbKeyService._(); // Static-only utility class

  /// Public entry point — احصل أو أنشئ مفتاح تشفير DB على web.
  ///
  /// ترتيب المحاولات:
  ///   1. WebCrypto + IndexedDB (الأكثر أماناً)
  ///   2. Legacy localStorage migration → WebCrypto
  ///   3. Fallback إلى localStorage plain (مع تحذير Sentry)
  static Future<String> getOrCreateWebDbKey() async {
    assert(kIsWeb, 'WebDbKeyService يجب استخدامه فقط على platform الويب');
    try {
      return await _getOrCreateWithWebCrypto();
    } catch (e, st) {
      // WebCrypto أو IndexedDB فشل — متصفح قديم أو سياق غير آمن
      // (مثلاً http بدل https، crypto.subtle null على non-secure contexts).
      await _reportDowngrade(e, st);
      return _getOrCreateFromLocalStorage();
    }
  }

  // ----- WebCrypto path -----

  /// المسار المُقوَّى: wrapping key غير قابل للتصدير + ciphertext في localStorage.
  static Future<String> _getOrCreateWithWebCrypto() async {
    // تحقُّق مُسبَق من دعم WebCrypto
    _ensureWebCryptoAvailable();

    // (1) الحصول على wrappingKey (إنشاء أو قراءة من IDB)
    final wrappingKey = await _getOrCreateWrappingKey();

    final prefs = await SharedPreferences.getInstance();

    // (2) إذا لدينا wrapped ciphertext → نفكه ونُرجع raw key
    final wrapped = prefs.getString(_wrappedKeyStorageKey);
    if (wrapped != null) {
      try {
        return await _decryptWrappedKey(wrappedBase64: wrapped, key: wrappingKey);
      } catch (e, st) {
        // الـ wrapping key في IDB لا يطابق ciphertext في localStorage
        // (مثلاً مسح IDB يدوياً) → نُسجِّل ثم نُعيد بناء مفتاح جديد.
        // تحذير: هذا يعني DB الحالية لن تُفك! — سيناريو user-caused data loss.
        await reportError(
          e,
          stackTrace: st,
          hint: 'web_db_key: wrapped decrypt فشل — إعادة بناء مفتاح',
        );
      }
    }

    // (3) migration من المفتاح القديم إن وُجد
    final legacyKey = prefs.getString(_legacyKeyStorageKey);
    if (legacyKey != null && legacyKey.isNotEmpty) {
      // استخدم المفتاح القديم لكن شفِّره بالصيغة الجديدة
      final newWrapped = await _encryptRawKey(
        rawBase64: legacyKey,
        key: wrappingKey,
      );
      await prefs.setString(_wrappedKeyStorageKey, newWrapped);
      // نحذف المفتاح القديم من localStorage — لا يعود XSS يستطيع قراءته
      await prefs.remove(_legacyKeyStorageKey);
      addBreadcrumb(
        message: 'web_db_key: migrated legacy key to wrapped storage',
        category: 'security',
      );
      return legacyKey;
    }

    // (4) لا شيء موجود → نُولِّد جديد، نُشفِّره، ونُخزِّنه
    final random = Random.secure();
    final rawBytes = Uint8List.fromList(
      List<int>.generate(_dbKeyLengthBytes, (_) => random.nextInt(256)),
    );
    final rawBase64 = base64Url.encode(rawBytes);
    final newWrapped = await _encryptRawKey(rawBase64: rawBase64, key: wrappingKey);
    await prefs.setString(_wrappedKeyStorageKey, newWrapped);
    addBreadcrumb(
      message: 'web_db_key: generated new wrapped key',
      category: 'security',
    );
    return rawBase64;
  }

  /// تأكَّد من أن `window.crypto.subtle` متاح — يُستدعى قبل أي عملية WebCrypto.
  static void _ensureWebCryptoAvailable() {
    final crypto = globalContext['crypto'];
    if (crypto == null) {
      throw StateError('WebCrypto: window.crypto غير متاح');
    }
    final subtle = (crypto as JSObject)['subtle'];
    if (subtle == null) {
      throw StateError(
        'WebCrypto: crypto.subtle غير متاح (يتطلب secure context — https)',
      );
    }
    final indexedDB = globalContext['indexedDB'];
    if (indexedDB == null) {
      throw StateError('WebCrypto: indexedDB غير متاح');
    }
  }

  /// احصل على wrappingKey من IndexedDB، أو أنشئه لأول مرة.
  ///
  /// الـ CryptoKey غير قابل للتصدير (`extractable=false`) — المتصفح يُرجع
  /// DOMException إذا حاول XSS `crypto.subtle.exportKey()`.
  static Future<JSObject> _getOrCreateWrappingKey() async {
    final db = await _openWrapDb();
    try {
      final existing = await _idbGet(db, _wrapKeyId);
      if (existing != null) {
        return existing as JSObject;
      }

      // إنشاء مفتاح جديد
      final subtle = _subtle();
      final algorithmSpec = _jsObj({'name': 'AES-GCM', 'length': 256});
      final keyUsages = <JSString>['encrypt'.toJS, 'decrypt'.toJS].toJS;

      final keyPromise = subtle.callMethod<JSPromise<JSObject>>(
        'generateKey'.toJS,
        algorithmSpec,
        false.toJS, // extractable = false ← القلب الأمني
        keyUsages,
      );
      final newKey = await keyPromise.toDart;

      await _idbPut(db, _wrapKeyId, newKey);
      return newKey;
    } finally {
      db.callMethod<JSAny?>('close'.toJS);
    }
  }

  /// شفِّر raw DB key بـ AES-GCM باستخدام wrappingKey.
  ///
  /// الصيغة المُخزَّنة: `{iv: base64Url, ct: base64Url}` مُسلسَلة JSON.
  static Future<String> _encryptRawKey({
    required String rawBase64,
    required JSObject key,
  }) async {
    final rawBytes = base64Url.decode(rawBase64);
    final iv = _randomBytes(_ivLengthBytes);

    final subtle = _subtle();
    final algorithm = _jsObj({'name': 'AES-GCM', 'iv': iv.toJS});

    final ctPromise = subtle.callMethod<JSPromise<JSArrayBuffer>>(
      'encrypt'.toJS,
      algorithm,
      key,
      Uint8List.fromList(rawBytes).toJS,
    );
    final ctBuffer = await ctPromise.toDart;
    final ctBytes = ctBuffer.toDart.asUint8List();

    return jsonEncode({
      'iv': base64Url.encode(iv),
      'ct': base64Url.encode(ctBytes),
    });
  }

  /// فك ciphertext وأعد raw DB key.
  static Future<String> _decryptWrappedKey({
    required String wrappedBase64,
    required JSObject key,
  }) async {
    final decoded = jsonDecode(wrappedBase64) as Map<String, dynamic>;
    final iv = base64Url.decode(decoded['iv'] as String);
    final ct = base64Url.decode(decoded['ct'] as String);

    final subtle = _subtle();
    final algorithm = _jsObj({'name': 'AES-GCM', 'iv': iv.toJS});

    final ptPromise = subtle.callMethod<JSPromise<JSArrayBuffer>>(
      'decrypt'.toJS,
      algorithm,
      key,
      Uint8List.fromList(ct).toJS,
    );
    final ptBuffer = await ptPromise.toDart;
    final ptBytes = ptBuffer.toDart.asUint8List();

    return base64Url.encode(ptBytes);
  }

  // ----- IndexedDB helpers (CryptoKey-aware) -----

  static Future<JSObject> _openWrapDb() async {
    final indexedDB = globalContext['indexedDB'] as JSObject;
    final request = indexedDB.callMethod<JSObject>(
      'open'.toJS,
      _wrapIdbName.toJS,
      _wrapIdbVersion.toJS,
    );

    final completer = Completer<JSObject>();

    request['onupgradeneeded'] = ((JSObject event) {
      final db = (event['target'] as JSObject)['result'] as JSObject;
      final storeNames = db['objectStoreNames'] as JSObject;
      final contains = storeNames.callMethod<JSBoolean>(
        'contains'.toJS,
        _wrapIdbStore.toJS,
      );
      if (!contains.toDart) {
        db.callMethod<JSObject>(
          'createObjectStore'.toJS,
          _wrapIdbStore.toJS,
        );
      }
    }).toJS;

    request['onsuccess'] = ((JSObject event) {
      if (!completer.isCompleted) {
        completer.complete((event['target'] as JSObject)['result'] as JSObject);
      }
    }).toJS;

    request['onerror'] = ((JSObject _) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('فشل فتح IndexedDB: $_wrapIdbName'),
        );
      }
    }).toJS;

    return completer.future;
  }

  /// قراءة CryptoKey (أو أي JSAny) من IDB — null إن لم يوجد.
  ///
  /// ملاحظة: IDB يحفظ CryptoKey objects مباشرة (structured clone) — لذا
  /// الـ non-extractable property مُصانة عبر التخزين.
  static Future<JSAny?> _idbGet(JSObject db, String key) async {
    final tx = db.callMethod<JSObject>(
      'transaction'.toJS,
      _wrapIdbStore.toJS,
      'readonly'.toJS,
    );
    final store = tx.callMethod<JSObject>(
      'objectStore'.toJS,
      _wrapIdbStore.toJS,
    );
    final request = store.callMethod<JSObject>('get'.toJS, key.toJS);

    final completer = Completer<JSAny?>();

    request['onsuccess'] = ((JSObject event) {
      if (!completer.isCompleted) {
        final result = (event['target'] as JSObject)['result'];
        completer.complete(result);
      }
    }).toJS;

    request['onerror'] = ((JSObject _) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('IDB get فشل: $key'));
      }
    }).toJS;

    return completer.future;
  }

  /// كتابة CryptoKey أو أي JSAny إلى IDB.
  static Future<void> _idbPut(JSObject db, String key, JSAny value) async {
    final tx = db.callMethod<JSObject>(
      'transaction'.toJS,
      _wrapIdbStore.toJS,
      'readwrite'.toJS,
    );
    final store = tx.callMethod<JSObject>(
      'objectStore'.toJS,
      _wrapIdbStore.toJS,
    );
    final request = store.callMethod<JSObject>('put'.toJS, value, key.toJS);

    final completer = Completer<void>();

    request['onsuccess'] = ((JSObject _) {
      if (!completer.isCompleted) completer.complete();
    }).toJS;

    request['onerror'] = ((JSObject _) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('IDB put فشل: $key'));
      }
    }).toJS;

    return completer.future;
  }

  // ----- Fallback path -----

  /// مسار الـ legacy — localStorage فقط (سلوك ما قبل التقوية).
  ///
  /// يُستخدَم إذا WebCrypto غير متاح (متصفحات قديمة جداً أو non-secure
  /// context). آمن لفشل التشغيل، غير آمن من XSS.
  static Future<String> _getOrCreateFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    var key = prefs.getString(_legacyKeyStorageKey);
    if (key == null) {
      final random = Random.secure();
      final values = List<int>.generate(
        _dbKeyLengthBytes,
        (_) => random.nextInt(256),
      );
      key = base64Url.encode(values);
      await prefs.setString(_legacyKeyStorageKey, key);
    }
    return key;
  }

  /// أبلِغ Sentry عن downgrade إلى localStorage — تنبيه للـ ops.
  static Future<void> _reportDowngrade(Object error, StackTrace st) async {
    await reportError(
      error,
      stackTrace: st,
      hint:
          'web_db_key: تم الرجوع إلى localStorage — WebCrypto غير متاح. '
          'المفتاح معرَّض لـ XSS. تأكد من https + CSP على هذا الـ deployment.',
    );
  }

  // ----- JS helpers -----

  /// اختصار للوصول إلى `window.crypto.subtle`.
  static JSObject _subtle() {
    final crypto = globalContext['crypto'] as JSObject;
    return crypto['subtle'] as JSObject;
  }

  /// ينشئ JS object من Map<String, dynamic> — يحوِّل القيم عبر `.toJS`.
  static JSObject _jsObj(Map<String, dynamic> fields) {
    final obj = JSObject();
    fields.forEach((k, v) {
      if (v is String) {
        obj[k] = v.toJS;
      } else if (v is int) {
        obj[k] = v.toJS;
      } else if (v is JSAny) {
        obj[k] = v;
      } else {
        throw ArgumentError('قيمة غير مدعومة لـ _jsObj: $v (${v.runtimeType})');
      }
    });
    return obj;
  }

  /// توليد Uint8List عشوائية آمنة عبر dart:math Random.secure.
  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}
