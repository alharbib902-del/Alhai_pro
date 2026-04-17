/// خدمة الحد من محاولات تسجيل الدخول (Rate Limiter)
///
/// تمنع هجمات Brute-Force على شاشة تسجيل الدخول:
/// - بعد [_kMaxAttempts] محاولات فاشلة خلال نافذة [_kWindowMinutes] دقيقة
/// - يُقفل المعرّف (البريد/الهاتف) لمدة [_kLockoutMinutes] دقائق
/// - تسجيل الدخول الناجح يمسح العدّاد فوراً
///
/// يستخدم [StorageInterface] (FlutterSecureStorage على الأجهزة، SharedPreferences
/// على الويب عبر _WebStorage) لمقاومة العبث بعدّ المحاولات.
library;

import 'dart:convert';
import 'secure_storage_service.dart';

/// الحد الأقصى للمحاولات قبل القفل
const int _kMaxAttempts = 5;

/// نافذة العدّ بالدقائق (بعد انتهائها يُعاد العدّاد إلى الصفر)
const int _kWindowMinutes = 15;

/// مدة القفل بالدقائق بعد تجاوز [_kMaxAttempts]
const int _kLockoutMinutes = 5;

/// بادئة مفتاح التخزين داخل الـ SecureStorage
const String _kKeyPrefix = 'login_rate_limit_';

// ============================================================================
// RateLimitStatus — النتيجة المُرجعة من checkStatus
// ============================================================================

/// نتيجة فحص حالة الحد
sealed class RateLimitStatus {
  const RateLimitStatus();
}

/// مسموح بالمتابعة — مع عدد المحاولات المتبقية
class RateLimitAllowed extends RateLimitStatus {
  final int attemptsLeft;
  const RateLimitAllowed({required this.attemptsLeft});
}

/// مقفل مؤقتاً — مع الوقت المتبقي حتى ينتهي القفل
class RateLimitLocked extends RateLimitStatus {
  final Duration remaining;
  const RateLimitLocked({required this.remaining});

  /// الثواني المتبقية (لعرضها للمستخدم)
  int get remainingSeconds => remaining.inSeconds;
}

// ============================================================================
// _Entry — تمثيل JSON للحالة المخزّنة لكل معرّف
// ============================================================================

class _Entry {
  final int attempts;
  final DateTime firstAttemptAt;
  final DateTime? lockedUntil;

  const _Entry({
    required this.attempts,
    required this.firstAttemptAt,
    this.lockedUntil,
  });

  Map<String, dynamic> toJson() => {
    'attempts': attempts,
    'firstAttemptAt': firstAttemptAt.toIso8601String(),
    if (lockedUntil != null) 'lockedUntil': lockedUntil!.toIso8601String(),
  };

  static _Entry? fromJson(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final attempts = map['attempts'] as int?;
      final firstAt = map['firstAttemptAt'] as String?;
      if (attempts == null || firstAt == null) return null;
      final parsedFirst = DateTime.tryParse(firstAt);
      if (parsedFirst == null) return null;
      final lockedRaw = map['lockedUntil'] as String?;
      final lockedUntil = lockedRaw == null
          ? null
          : DateTime.tryParse(lockedRaw);
      return _Entry(
        attempts: attempts,
        firstAttemptAt: parsedFirst,
        lockedUntil: lockedUntil,
      );
    } catch (_) {
      return null;
    }
  }
}

// ============================================================================
// LoginRateLimiter — الواجهة العامة
// ============================================================================

/// مُدير الحد من محاولات تسجيل الدخول.
///
/// يُستخدم كالتالي:
/// ```dart
/// final limiter = LoginRateLimiter();
/// final status = await limiter.checkStatus(email);
/// if (status is RateLimitLocked) { ... }
/// // ... attempt login ...
/// if (failed) await limiter.recordFailure(email);
/// else await limiter.recordSuccess(email);
/// ```
class LoginRateLimiter {
  final StorageInterface _storage;

  /// [storage] — واجهة التخزين الآمن. إذا لم تُمرَّر، يُستخدم
  /// التخزين الافتراضي المُسجَّل داخل [SecureStorageService].
  LoginRateLimiter({StorageInterface? storage})
    : _storage = storage ?? SecureStorageService.storage;

  /// تطبيع المعرّف: lowercase + trim + إزالة المسافات والشرطات
  /// (يوحّد "A@X.com" و " a@x.com " و "+966-50 123" إلخ)
  static String _normalize(String identifier) {
    return identifier
        .trim()
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('-', '');
  }

  /// مفتاح التخزين لمعرّف مُطبَّع
  String _key(String identifier) =>
      '$_kKeyPrefix${_normalize(identifier)}';

  /// قراءة الحالة من التخزين (أو null إذا لم توجد)
  Future<_Entry?> _read(String identifier) async {
    final raw = await _storage.read(key: _key(identifier));
    if (raw == null || raw.isEmpty) return null;
    return _Entry.fromJson(raw);
  }

  /// كتابة الحالة (أو حذفها إذا كانت null)
  Future<void> _write(String identifier, _Entry? entry) async {
    if (entry == null) {
      await _storage.delete(key: _key(identifier));
      return;
    }
    await _storage.write(
      key: _key(identifier),
      value: jsonEncode(entry.toJson()),
    );
  }

  /// فحص الحالة الحالية للمعرّف.
  ///
  /// - إذا كان مقفلاً وانتهت مدة القفل → يُعاد تصفير العدّاد ويُسمح بالدخول.
  /// - إذا كان مقفلاً ولم تنته المدة → يُرجع [RateLimitLocked].
  /// - غير ذلك → يُرجع [RateLimitAllowed] مع المحاولات المتبقية.
  ///
  /// **يجب استدعاؤها قبل محاولة تسجيل الدخول.**
  Future<RateLimitStatus> checkStatus(String identifier) async {
    final entry = await _read(identifier);
    final now = DateTime.now();

    if (entry == null) {
      return const RateLimitAllowed(attemptsLeft: _kMaxAttempts);
    }

    // لو كان مقفلاً وما زال ضمن مدة القفل
    if (entry.lockedUntil != null && entry.lockedUntil!.isAfter(now)) {
      return RateLimitLocked(remaining: entry.lockedUntil!.difference(now));
    }

    // انتهى القفل → صفّر العدّاد
    if (entry.lockedUntil != null && !entry.lockedUntil!.isAfter(now)) {
      await _write(identifier, null);
      return const RateLimitAllowed(attemptsLeft: _kMaxAttempts);
    }

    // لو انتهت النافذة الزمنية → عدّاد جديد
    final windowEnd = entry.firstAttemptAt.add(
      const Duration(minutes: _kWindowMinutes),
    );
    if (now.isAfter(windowEnd)) {
      await _write(identifier, null);
      return const RateLimitAllowed(attemptsLeft: _kMaxAttempts);
    }

    final left = _kMaxAttempts - entry.attempts;
    return RateLimitAllowed(attemptsLeft: left < 0 ? 0 : left);
  }

  /// تسجيل محاولة فاشلة (استدعها عند AuthException أو عند استجابة
  /// ناجحة من الشبكة ولكن الاعتمادات غير صحيحة).
  ///
  /// عند بلوغ [_kMaxAttempts] يُفعَّل قفل لمدة [_kLockoutMinutes].
  Future<void> recordFailure(String identifier) async {
    final now = DateTime.now();
    final entry = await _read(identifier);

    // إذا كان مقفلاً وانتهت المدة → يُعامل كأول محاولة جديدة
    final lockedExpired =
        entry?.lockedUntil != null && !entry!.lockedUntil!.isAfter(now);

    // إذا لم توجد حالة، أو انتهت النافذة، أو انتهى القفل → نبدأ من جديد
    final windowExpired =
        entry != null &&
        now.isAfter(
          entry.firstAttemptAt.add(const Duration(minutes: _kWindowMinutes)),
        );

    if (entry == null || windowExpired || lockedExpired) {
      await _write(
        identifier,
        _Entry(attempts: 1, firstAttemptAt: now),
      );
      return;
    }

    final newAttempts = entry.attempts + 1;
    DateTime? lockedUntil;
    if (newAttempts >= _kMaxAttempts) {
      lockedUntil = now.add(const Duration(minutes: _kLockoutMinutes));
    }

    await _write(
      identifier,
      _Entry(
        attempts: newAttempts,
        firstAttemptAt: entry.firstAttemptAt,
        lockedUntil: lockedUntil,
      ),
    );
  }

  /// تسجيل دخول ناجح — يمسح العدّاد فوراً.
  Future<void> recordSuccess(String identifier) async {
    await _write(identifier, null);
  }

  /// مسح جميع سجلات الحد (للاختبار / إعادة تعيين إداري).
  Future<void> clearAll() async {
    // لا يمكن listKeys() عبر StorageInterface الحالي؛ يحذف جميع
    // مفاتيح التخزين. يُستخدم في الاختبارات و أزرار إعادة الضبط
    // الإدارية فقط.
    await _storage.deleteAll();
  }
}
