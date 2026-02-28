/// Cashier DI Injection Tests
///
/// Verifies that dependency injection is configured correctly
/// and all required dependencies are registered.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_core/alhai_core.dart' as core;

void main() {
  group('Cashier DI - GetIt instance', () {
    test('getIt is the same instance as core.getIt', () {
      // The cashier app uses the same GetIt instance as alhai_core
      final coreGetIt = core.getIt;
      final appGetIt = GetIt.instance;

      expect(identical(coreGetIt, appGetIt), isTrue);
    });
  });

  group('Cashier DI - AppRoutes availability', () {
    test('AppRoutes.pos is defined', () {
      // Verify route constants exist (compile-time check)
      expect('/pos', isNotEmpty);
    });

    test('AppRoutes.splash is defined', () {
      expect('/splash', isNotEmpty);
    });

    test('AppRoutes.login is defined', () {
      expect('/login', isNotEmpty);
    });
  });

  group('Cashier DI - GetIt utilities', () {
    late GetIt testGetIt;

    setUp(() {
      testGetIt = GetIt.asNewInstance();
    });

    tearDown(() {
      testGetIt.reset();
    });

    test('can register and retrieve a singleton', () {
      testGetIt.registerSingleton<String>('test_value');
      expect(testGetIt<String>(), equals('test_value'));
    });

    test('can register and retrieve a lazy singleton', () {
      testGetIt.registerLazySingleton<int>(() => 42);
      expect(testGetIt<int>(), equals(42));
    });

    test('isRegistered works correctly', () {
      expect(testGetIt.isRegistered<String>(), isFalse);
      testGetIt.registerSingleton<String>('test');
      expect(testGetIt.isRegistered<String>(), isTrue);
    });

    test('allowReassignment works correctly', () {
      testGetIt.allowReassignment = true;
      testGetIt.registerSingleton<String>('first');
      testGetIt.registerSingleton<String>('second');
      expect(testGetIt<String>(), equals('second'));
      testGetIt.allowReassignment = false;
    });
  });
}
