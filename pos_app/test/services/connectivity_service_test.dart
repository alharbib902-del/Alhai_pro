import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ===========================================
// Connectivity Service Tests
// ===========================================

// Mock class for testing connectivity logic
class MockConnectivityChecker {
  // ignore: unused_field
  bool _isConnected = true;

  void setConnected(bool value) => _isConnected = value;

  bool isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }
}

void main() {
  group('ConnectivityService', () {
    late MockConnectivityChecker checker;

    setUp(() {
      checker = MockConnectivityChecker();
    });

    group('isConnected', () {
      test('يُرجع true عند اتصال WiFi', () {
        final result = checker.isConnected(ConnectivityResult.wifi);
        expect(result, isTrue);
      });

      test('يُرجع true عند اتصال Mobile', () {
        final result = checker.isConnected(ConnectivityResult.mobile);
        expect(result, isTrue);
      });

      test('يُرجع true عند اتصال Ethernet', () {
        final result = checker.isConnected(ConnectivityResult.ethernet);
        expect(result, isTrue);
      });

      test('يُرجع false عند عدم الاتصال', () {
        final result = checker.isConnected(ConnectivityResult.none);
        expect(result, isFalse);
      });

      test('يُرجع false عند اتصال Bluetooth', () {
        final result = checker.isConnected(ConnectivityResult.bluetooth);
        expect(result, isFalse);
      });

      test('يُرجع false عند اتصال VPN', () {
        final result = checker.isConnected(ConnectivityResult.vpn);
        expect(result, isFalse);
      });
    });
  });
}
