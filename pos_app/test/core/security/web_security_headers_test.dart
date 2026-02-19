import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/web_security_headers.dart';

void main() {
  group('WebSecurityHeaders', () {
    group('getHeaders', () {
      test('يعيد headers للمستوى strict', () {
        final headers = WebSecurityHeaders.getHeaders(
          level: SecurityLevel.strict,
        );

        expect(headers.containsKey('Content-Security-Policy'), isTrue);
        expect(headers.containsKey('Strict-Transport-Security'), isTrue);
        expect(headers.containsKey('X-Content-Type-Options'), isTrue);
        expect(headers.containsKey('X-Frame-Options'), isTrue);
        expect(headers.containsKey('Referrer-Policy'), isTrue);
        expect(headers.containsKey('Permissions-Policy'), isTrue);
      });

      test('X-Frame-Options يكون DENY في strict', () {
        final headers = WebSecurityHeaders.getHeaders(
          level: SecurityLevel.strict,
        );

        expect(headers['X-Frame-Options'], equals('DENY'));
      });

      test('X-Frame-Options يكون SAMEORIGIN في moderate', () {
        final headers = WebSecurityHeaders.getHeaders(
          level: SecurityLevel.moderate,
        );

        expect(headers['X-Frame-Options'], equals('SAMEORIGIN'));
      });

      test('يضيف Cross-Origin headers في strict', () {
        final headers = WebSecurityHeaders.getHeaders(
          level: SecurityLevel.strict,
        );

        expect(headers.containsKey('Cross-Origin-Opener-Policy'), isTrue);
        expect(headers.containsKey('Cross-Origin-Embedder-Policy'), isTrue);
        expect(headers.containsKey('Cross-Origin-Resource-Policy'), isTrue);
      });

      test('يقبل custom CSP', () {
        final customCSP = CSPConfig.strict.addDirective(
          'script-src',
          ["'self'", 'https://trusted.com'],
        );

        final headers = WebSecurityHeaders.getHeaders(
          customCSP: customCSP,
        );

        expect(headers['Content-Security-Policy'], contains('trusted.com'));
      });

      test('يمكن تعطيل XSS Protection', () {
        final headers = WebSecurityHeaders.getHeaders(
          enableXSSProtection: false,
        );

        expect(headers.containsKey('X-XSS-Protection'), isFalse);
      });
    });

    group('validateHeaders', () {
      test('يحسب نقاط الأمان', () {
        final headers = WebSecurityHeaders.getHeaders(
          level: SecurityLevel.strict,
        );
        final result = WebSecurityHeaders.validateHeaders(headers);

        expect(result.score, greaterThan(0));
        expect(result.score, lessThanOrEqualTo(100));
      });

      test('يكشف Headers المفقودة', () {
        final result = WebSecurityHeaders.validateHeaders({});

        expect(result.issues, isNotEmpty);
        expect(result.score, equals(0));
      });

      test('يعطي نقاط أعلى للـ strict', () {
        final strictHeaders = WebSecurityHeaders.getHeaders(
          level: SecurityLevel.strict,
        );
        final relaxedHeaders = WebSecurityHeaders.getHeaders(
          level: SecurityLevel.relaxed,
        );

        final strictResult = WebSecurityHeaders.validateHeaders(strictHeaders);
        final relaxedResult = WebSecurityHeaders.validateHeaders(relaxedHeaders);

        expect(strictResult.score, greaterThan(relaxedResult.score));
      });

      test('يحذر من unsafe-inline', () {
        final headers = WebSecurityHeaders.getHeaders(
          level: SecurityLevel.relaxed,
        );
        final result = WebSecurityHeaders.validateHeaders(headers);

        // relaxed يحتوي على unsafe-inline فيحصل على نقاط أقل
        expect(result.score, lessThan(100));
      });
    });
  });

  group('CSPConfig', () {
    group('toHeaderValue', () {
      test('يحول directives لـ string صحيح', () {
        const csp = CSPConfig(
          directives: {
            'default-src': ["'self'"],
            'script-src': ["'self'", 'https://example.com'],
          },
        );

        final value = csp.toHeaderValue();

        expect(value, contains("default-src 'self'"));
        expect(value, contains("script-src 'self' https://example.com"));
      });

      test('يتعامل مع directives بدون قيم', () {
        const csp = CSPConfig(
          directives: {
            'upgrade-insecure-requests': [],
          },
        );

        final value = csp.toHeaderValue();

        expect(value, contains('upgrade-insecure-requests'));
      });
    });

    group('addDirective', () {
      test('يضيف directive جديد', () {
        const csp = CSPConfig(directives: {'default-src': ["'self'"]});
        final newCsp = csp.addDirective('script-src', ["'self'"]);

        expect(newCsp.directives.containsKey('script-src'), isTrue);
        expect(newCsp.directives.containsKey('default-src'), isTrue);
      });
    });

    group('appendToDirective', () {
      test('يضيف قيمة لـ directive موجود', () {
        const csp = CSPConfig(
          directives: {'script-src': ["'self'"]},
        );
        final newCsp = csp.appendToDirective('script-src', 'https://cdn.com');

        expect(newCsp.directives['script-src'], contains("'self'"));
        expect(newCsp.directives['script-src'], contains('https://cdn.com'));
      });

      test('ينشئ directive جديد إذا غير موجود', () {
        const csp = CSPConfig(directives: {});
        final newCsp = csp.appendToDirective('img-src', "'self'");

        expect(newCsp.directives.containsKey('img-src'), isTrue);
      });
    });

    group('presets', () {
      test('strict لا يحتوي على unsafe', () {
        final value = CSPConfig.strict.toHeaderValue();

        expect(value, isNot(contains("'unsafe-inline'")));
        expect(value, isNot(contains("'unsafe-eval'")));
      });

      test('relaxed يحتوي على unsafe للـ development', () {
        final value = CSPConfig.relaxed.toHeaderValue();

        expect(value, contains("'unsafe-inline'"));
        expect(value, contains("'unsafe-eval'"));
      });
    });
  });

  group('HSTSConfig', () {
    test('toHeaderValue ينتج format صحيح', () {
      const hsts = HSTSConfig(
        maxAge: 31536000,
        includeSubDomains: true,
        preload: true,
      );

      final value = hsts.toHeaderValue();

      expect(value, contains('max-age=31536000'));
      expect(value, contains('includeSubDomains'));
      expect(value, contains('preload'));
    });

    test('production config صحيح', () {
      final value = HSTSConfig.production.toHeaderValue();

      expect(value, contains('max-age=31536000'));
      expect(value, contains('includeSubDomains'));
      expect(value, contains('preload'));
    });

    test('staging config بدون preload', () {
      final value = HSTSConfig.staging.toHeaderValue();

      expect(value, isNot(contains('preload')));
      expect(value, contains('max-age=86400'));
    });
  });

  group('PermissionsPolicyConfig', () {
    test('toHeaderValue ينتج format صحيح', () {
      const policy = PermissionsPolicyConfig(
        features: {
          'camera': [],
          'geolocation': ['self'],
        },
      );

      final value = policy.toHeaderValue();

      expect(value, contains('camera=()'));
      expect(value, contains('geolocation=(self)'));
    });

    test('strict يعطل جميع الميزات', () {
      final value = PermissionsPolicyConfig.strict.toHeaderValue();

      expect(value, contains('camera=()'));
      expect(value, contains('microphone=()'));
      expect(value, contains('geolocation=()'));
    });
  });

  group('HeadersValidationResult', () {
    test('isSecure يتطلب score >= 80 و issues فارغة', () {
      const secure = HeadersValidationResult(
        score: 85,
        issues: [],
        warnings: ['warning'],
        headers: {},
      );

      const insecure = HeadersValidationResult(
        score: 85,
        issues: ['issue'],
        warnings: [],
        headers: {},
      );

      expect(secure.isSecure, isTrue);
      expect(insecure.isSecure, isFalse);
    });

    test('grade يحسب بشكل صحيح', () {
      expect(
        const HeadersValidationResult(score: 95, issues: [], warnings: [], headers: {}).grade,
        equals('A'),
      );
      expect(
        const HeadersValidationResult(score: 85, issues: [], warnings: [], headers: {}).grade,
        equals('B'),
      );
      expect(
        const HeadersValidationResult(score: 75, issues: [], warnings: [], headers: {}).grade,
        equals('C'),
      );
      expect(
        const HeadersValidationResult(score: 65, issues: [], warnings: [], headers: {}).grade,
        equals('D'),
      );
      expect(
        const HeadersValidationResult(score: 50, issues: [], warnings: [], headers: {}).grade,
        equals('F'),
      );
    });

    test('toJson يعمل', () {
      const result = HeadersValidationResult(
        score: 90,
        issues: ['issue1'],
        warnings: ['warning1'],
        headers: {'header': 'value'},
      );

      final json = result.toJson();

      expect(json['score'], equals(90));
      expect(json['grade'], equals('A'));
      expect(json['isSecure'], isFalse); // has issue
    });
  });

  group('generateCSPMetaTag', () {
    test('ينتج meta tag صحيح', () {
      const csp = CSPConfig(
        directives: {'default-src': ["'self'"]},
      );

      final tag = WebSecurityHeaders.generateCSPMetaTag(csp);

      expect(tag, startsWith('<meta'));
      expect(tag, contains('Content-Security-Policy'));
      expect(tag, contains("default-src 'self'"));
    });
  });
}
