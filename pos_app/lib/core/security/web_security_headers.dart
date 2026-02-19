/// Web Security Headers Service
///
/// إدارة HTTP Security Headers للويب
/// يتضمن:
/// - Content-Security-Policy (CSP)
/// - Strict-Transport-Security (HSTS)
/// - X-Content-Type-Options
/// - X-Frame-Options
/// - X-XSS-Protection
/// - Referrer-Policy
/// - Permissions-Policy
library;

import 'package:flutter/foundation.dart';

/// مستوى صرامة الأمان
enum SecurityLevel {
  /// صارم - للـ production
  strict,

  /// متوسط - للـ staging
  moderate,

  /// مرن - للـ development
  relaxed,
}

/// تكوين CSP
class CSPConfig {
  final Map<String, List<String>> directives;
  final bool reportOnly;
  final String? reportUri;

  const CSPConfig({
    required this.directives,
    this.reportOnly = false,
    this.reportUri,
  });

  /// تكوين صارم للـ production
  static const strict = CSPConfig(
    directives: {
      'default-src': ["'self'"],
      'script-src': ["'self'"],
      'style-src': ["'self'"],
      'img-src': ["'self'", 'data:', 'https:'],
      'font-src': ["'self'", 'https://fonts.gstatic.com'],
      'connect-src': ["'self'", 'https://api.supabase.co', 'wss://'],
      'frame-src': ["'none'"],
      'object-src': ["'none'"],
      'base-uri': ["'self'"],
      'form-action': ["'self'"],
      'frame-ancestors': ["'none'"],
      'upgrade-insecure-requests': [],
    },
  );

  /// تكوين متوسط للـ staging
  static const moderate = CSPConfig(
    directives: {
      'default-src': ["'self'"],
      'script-src': ["'self'", "'unsafe-inline'"], // للـ hot reload
      'style-src': ["'self'", "'unsafe-inline'"],
      'img-src': ["'self'", 'data:', 'https:', 'blob:'],
      'font-src': ["'self'", 'https://fonts.gstatic.com'],
      'connect-src': ["'self'", 'https:', 'wss:'],
      'frame-src': ["'self'"],
      'object-src': ["'none'"],
    },
  );

  /// تكوين مرن للـ development
  static const relaxed = CSPConfig(
    directives: {
      'default-src': ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
      'script-src': ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
      'style-src': ["'self'", "'unsafe-inline'"],
      'img-src': ['*', 'data:', 'blob:'],
      'font-src': ['*'],
      'connect-src': ['*'],
    },
  );

  /// تحويل لـ header string
  String toHeaderValue() {
    final parts = <String>[];

    for (final entry in directives.entries) {
      final directive = entry.key;
      final values = entry.value;

      if (values.isEmpty) {
        parts.add(directive);
      } else {
        parts.add('$directive ${values.join(" ")}');
      }
    }

    return parts.join('; ');
  }

  /// إضافة directive
  CSPConfig addDirective(String name, List<String> values) {
    final newDirectives = Map<String, List<String>>.from(directives);
    newDirectives[name] = values;
    return CSPConfig(
      directives: newDirectives,
      reportOnly: reportOnly,
      reportUri: reportUri,
    );
  }

  /// إضافة قيمة لـ directive موجود
  CSPConfig appendToDirective(String name, String value) {
    final newDirectives = Map<String, List<String>>.from(directives);
    if (newDirectives.containsKey(name)) {
      newDirectives[name] = [...newDirectives[name]!, value];
    } else {
      newDirectives[name] = [value];
    }
    return CSPConfig(
      directives: newDirectives,
      reportOnly: reportOnly,
      reportUri: reportUri,
    );
  }
}

/// تكوين HSTS
class HSTSConfig {
  final int maxAge; // seconds
  final bool includeSubDomains;
  final bool preload;

  const HSTSConfig({
    this.maxAge = 31536000, // 1 year
    this.includeSubDomains = true,
    this.preload = false,
  });

  static const production = HSTSConfig(
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  );

  static const staging = HSTSConfig(
    maxAge: 86400, // 1 day
    includeSubDomains: false,
    preload: false,
  );

  String toHeaderValue() {
    final parts = ['max-age=$maxAge'];
    if (includeSubDomains) parts.add('includeSubDomains');
    if (preload) parts.add('preload');
    return parts.join('; ');
  }
}

/// تكوين Permissions-Policy
class PermissionsPolicyConfig {
  final Map<String, List<String>> features;

  const PermissionsPolicyConfig({required this.features});

  static const strict = PermissionsPolicyConfig(
    features: {
      'camera': [],
      'microphone': [],
      'geolocation': [],
      'payment': [],
      'usb': [],
      'bluetooth': [],
      'magnetometer': [],
      'gyroscope': [],
      'accelerometer': [],
    },
  );

  static const moderate = PermissionsPolicyConfig(
    features: {
      'camera': ['self'],
      'microphone': [],
      'geolocation': [],
      'payment': ['self'],
    },
  );

  String toHeaderValue() {
    final parts = <String>[];

    for (final entry in features.entries) {
      final feature = entry.key;
      final allowList = entry.value;

      if (allowList.isEmpty) {
        parts.add('$feature=()');
      } else {
        final formatted = allowList.map((a) => a == 'self' ? 'self' : '"$a"').join(' ');
        parts.add('$feature=($formatted)');
      }
    }

    return parts.join(', ');
  }
}

/// Web Security Headers Service
class WebSecurityHeaders {
  WebSecurityHeaders._();

  /// الحصول على جميع headers الأمنية
  static Map<String, String> getHeaders({
    SecurityLevel level = SecurityLevel.strict,
    CSPConfig? customCSP,
    HSTSConfig? customHSTS,
    PermissionsPolicyConfig? customPermissions,
    bool enableXSSProtection = true,
  }) {
    final headers = <String, String>{};

    // Content-Security-Policy
    final csp = customCSP ?? _getCSPForLevel(level);
    final cspHeaderName =
        csp.reportOnly ? 'Content-Security-Policy-Report-Only' : 'Content-Security-Policy';
    headers[cspHeaderName] = csp.toHeaderValue();

    // Strict-Transport-Security
    final hsts = customHSTS ?? _getHSTSForLevel(level);
    headers['Strict-Transport-Security'] = hsts.toHeaderValue();

    // X-Content-Type-Options
    headers['X-Content-Type-Options'] = 'nosniff';

    // X-Frame-Options
    headers['X-Frame-Options'] = level == SecurityLevel.strict ? 'DENY' : 'SAMEORIGIN';

    // X-XSS-Protection
    if (enableXSSProtection) {
      headers['X-XSS-Protection'] = '1; mode=block';
    }

    // Referrer-Policy
    headers['Referrer-Policy'] = _getReferrerPolicyForLevel(level);

    // Permissions-Policy
    final permissions = customPermissions ?? _getPermissionsForLevel(level);
    headers['Permissions-Policy'] = permissions.toHeaderValue();

    // Cross-Origin headers
    if (level == SecurityLevel.strict) {
      headers['Cross-Origin-Opener-Policy'] = 'same-origin';
      headers['Cross-Origin-Embedder-Policy'] = 'require-corp';
      headers['Cross-Origin-Resource-Policy'] = 'same-origin';
    }

    return headers;
  }

  /// الحصول على CSP حسب المستوى
  static CSPConfig _getCSPForLevel(SecurityLevel level) {
    return switch (level) {
      SecurityLevel.strict => CSPConfig.strict,
      SecurityLevel.moderate => CSPConfig.moderate,
      SecurityLevel.relaxed => CSPConfig.relaxed,
    };
  }

  /// الحصول على HSTS حسب المستوى
  static HSTSConfig _getHSTSForLevel(SecurityLevel level) {
    return switch (level) {
      SecurityLevel.strict => HSTSConfig.production,
      SecurityLevel.moderate => HSTSConfig.staging,
      SecurityLevel.relaxed => const HSTSConfig(maxAge: 0),
    };
  }

  /// الحصول على Permissions-Policy حسب المستوى
  static PermissionsPolicyConfig _getPermissionsForLevel(SecurityLevel level) {
    return switch (level) {
      SecurityLevel.strict => PermissionsPolicyConfig.strict,
      SecurityLevel.moderate => PermissionsPolicyConfig.moderate,
      SecurityLevel.relaxed => const PermissionsPolicyConfig(features: {}),
    };
  }

  /// الحصول على Referrer-Policy حسب المستوى
  static String _getReferrerPolicyForLevel(SecurityLevel level) {
    return switch (level) {
      SecurityLevel.strict => 'strict-origin-when-cross-origin',
      SecurityLevel.moderate => 'origin-when-cross-origin',
      SecurityLevel.relaxed => 'no-referrer-when-downgrade',
    };
  }

  /// التحقق من headers الأمنية
  static HeadersValidationResult validateHeaders(Map<String, String> headers) {
    final issues = <String>[];
    final warnings = <String>[];
    final score = _calculateSecurityScore(headers, issues, warnings);

    return HeadersValidationResult(
      score: score,
      issues: issues,
      warnings: warnings,
      headers: headers,
    );
  }

  /// حساب نقاط الأمان
  static int _calculateSecurityScore(
    Map<String, String> headers,
    List<String> issues,
    List<String> warnings,
  ) {
    var score = 0;
    const maxScore = 100;

    // CSP (25 points)
    if (headers.containsKey('Content-Security-Policy')) {
      score += 15;
      final csp = headers['Content-Security-Policy']!;
      if (!csp.contains("'unsafe-inline'")) score += 5;
      if (!csp.contains("'unsafe-eval'")) score += 5;
    } else {
      issues.add('Missing Content-Security-Policy header');
    }

    // HSTS (20 points)
    if (headers.containsKey('Strict-Transport-Security')) {
      score += 10;
      final hsts = headers['Strict-Transport-Security']!;
      if (hsts.contains('includeSubDomains')) score += 5;
      if (hsts.contains('preload')) score += 5;
    } else {
      issues.add('Missing Strict-Transport-Security header');
    }

    // X-Content-Type-Options (10 points)
    if (headers['X-Content-Type-Options'] == 'nosniff') {
      score += 10;
    } else {
      warnings.add('X-Content-Type-Options should be "nosniff"');
    }

    // X-Frame-Options (10 points)
    if (headers.containsKey('X-Frame-Options')) {
      score += 10;
      if (headers['X-Frame-Options'] != 'DENY') {
        warnings.add('Consider using X-Frame-Options: DENY for maximum protection');
      }
    } else {
      issues.add('Missing X-Frame-Options header');
    }

    // Referrer-Policy (10 points)
    if (headers.containsKey('Referrer-Policy')) {
      score += 10;
    } else {
      warnings.add('Missing Referrer-Policy header');
    }

    // Permissions-Policy (10 points)
    if (headers.containsKey('Permissions-Policy')) {
      score += 10;
    } else {
      warnings.add('Missing Permissions-Policy header');
    }

    // Cross-Origin headers (15 points)
    if (headers.containsKey('Cross-Origin-Opener-Policy')) score += 5;
    if (headers.containsKey('Cross-Origin-Embedder-Policy')) score += 5;
    if (headers.containsKey('Cross-Origin-Resource-Policy')) score += 5;

    return score.clamp(0, maxScore);
  }

  /// توليد HTML meta tags للـ CSP
  static String generateCSPMetaTag(CSPConfig csp) {
    return '<meta http-equiv="Content-Security-Policy" content="${csp.toHeaderValue()}">';
  }

  /// طباعة تقرير Headers
  static void printSecurityReport({
    SecurityLevel level = SecurityLevel.strict,
  }) {
    if (!kDebugMode) return;

    final headers = getHeaders(level: level);
    final validation = validateHeaders(headers);

    debugPrint('╔══════════════════════════════════════════════════════════════╗');
    debugPrint('║              Security Headers Report                         ║');
    debugPrint('╠══════════════════════════════════════════════════════════════╣');
    debugPrint('║  Security Level: ${level.name.padRight(44)}║');
    debugPrint('║  Security Score: ${validation.score}/100${' '.padRight(39)}║');
    debugPrint('╠══════════════════════════════════════════════════════════════╣');

    for (final entry in headers.entries) {
      final key = entry.key;
      final value = entry.value.length > 50
          ? '${entry.value.substring(0, 50)}...'
          : entry.value;
      debugPrint('║  $key:');
      debugPrint('║    $value');
    }

    if (validation.issues.isNotEmpty) {
      debugPrint('╠══════════════════════════════════════════════════════════════╣');
      debugPrint('║  Issues:');
      for (final issue in validation.issues) {
        debugPrint('║    ❌ $issue');
      }
    }

    if (validation.warnings.isNotEmpty) {
      debugPrint('╠══════════════════════════════════════════════════════════════╣');
      debugPrint('║  Warnings:');
      for (final warning in validation.warnings) {
        debugPrint('║    ⚠️ $warning');
      }
    }

    debugPrint('╚══════════════════════════════════════════════════════════════╝');
  }
}

/// نتيجة التحقق من Headers
class HeadersValidationResult {
  final int score;
  final List<String> issues;
  final List<String> warnings;
  final Map<String, String> headers;

  const HeadersValidationResult({
    required this.score,
    required this.issues,
    required this.warnings,
    required this.headers,
  });

  bool get isSecure => score >= 80 && issues.isEmpty;

  String get grade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'grade': grade,
        'isSecure': isSecure,
        'issues': issues,
        'warnings': warnings,
      };
}
