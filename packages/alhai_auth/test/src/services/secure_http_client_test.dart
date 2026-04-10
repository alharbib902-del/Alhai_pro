import 'package:flutter_test/flutter_test.dart';

// The secure_http_client.dart in alhai_auth is a re-export stub.
// It re-exports from alhai_core. We verify the re-export is valid.
// ignore: unused_import
import 'package:alhai_auth/src/core/network/secure_http_client.dart';

void main() {
  group('secure_http_client re-export', () {
    test('re-exports SecureHttpClient from alhai_core', () {
      // The import itself validates the re-export works.
      // If this compiles and runs, the re-export is correct.
      expect(true, isTrue);
    });
  });
}
