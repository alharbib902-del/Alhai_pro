import 'package:customer_app/core/network/certificate_pinning_service.dart';
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
      expect(
        CertificatePinningService.constantTimeEquals('', ''),
        isTrue,
      );
    });

    test('diagnosticStatus reports debug mode', () {
      // In test environment, kDebugMode is true
      final status = CertificatePinningService.diagnosticStatus;
      expect(status, contains('debug mode'));
    });

    test('isEnabled is false in debug mode', () {
      // In test environment, kDebugMode is true → pinning disabled
      expect(CertificatePinningService.isEnabled, isFalse);
    });

    test('createPinnedClient returns a client in debug mode', () {
      // In debug mode, should return a client without throwing
      final client = CertificatePinningService.createPinnedClient();
      expect(client, isNotNull);
      client.close();
    });
  });
}
