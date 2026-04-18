import 'package:admin_lite/core/network/certificate_pinning_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CertificatePinningService', () {
    test('constantTimeEquals returns true for identical strings', () {
      expect(
        CertificatePinningService.constantTimeEquals('abc123', 'abc123'),
        isTrue,
      );
    });

    test('constantTimeEquals returns false for different strings', () {
      expect(
        CertificatePinningService.constantTimeEquals('abc123', 'abc124'),
        isFalse,
      );
    });

    test('constantTimeEquals returns false for different lengths', () {
      expect(
        CertificatePinningService.constantTimeEquals('abc', 'abcd'),
        isFalse,
      );
    });

    test('constantTimeEquals handles empty strings', () {
      expect(CertificatePinningService.constantTimeEquals('', ''), isTrue);
    });

    test('diagnosticStatus reports debug mode in tests', () {
      final status = CertificatePinningService.diagnosticStatus;
      expect(status, contains('debug mode'));
    });

    test('isEnabled is false in debug mode', () {
      expect(CertificatePinningService.isEnabled, isFalse);
    });

    test('createPinnedClient returns a client in debug mode', () {
      final client = CertificatePinningService.createPinnedClient();
      expect(client, isNotNull);
      client.close();
    });
  });
}
