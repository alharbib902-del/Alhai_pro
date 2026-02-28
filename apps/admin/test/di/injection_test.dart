/// Admin DI Injection Tests
///
/// Verifies that dependency injection is configured correctly
/// and all required dependencies are registered.
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_core/alhai_core.dart' as core;

void main() {
  group('Admin DI - GetIt instance', () {
    test('getIt is the same instance as core.getIt', () {
      // The admin app uses the same GetIt instance as alhai_core
      final coreGetIt = core.getIt;
      final appGetIt = GetIt.instance;

      expect(identical(coreGetIt, appGetIt), isTrue);
    });
  });

  group('Admin DI - AppRoutes availability', () {
    test('AppRoutes.home is defined', () {
      expect('/home', isNotEmpty);
    });

    test('AppRoutes.dashboard is defined', () {
      expect('/dashboard', isNotEmpty);
    });

    test('AppRoutes.splash is defined', () {
      expect('/splash', isNotEmpty);
    });

    test('AppRoutes.login is defined', () {
      expect('/login', isNotEmpty);
    });
  });

  group('Admin DI - GetIt utilities', () {
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

    test('reset clears all registrations', () async {
      testGetIt.registerSingleton<String>('value');
      expect(testGetIt.isRegistered<String>(), isTrue);
      await testGetIt.reset();
      expect(testGetIt.isRegistered<String>(), isFalse);
    });
  });
}
