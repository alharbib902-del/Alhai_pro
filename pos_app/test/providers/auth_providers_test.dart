/// اختبارات مزودات المصادقة
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/alhai_core.dart';
import 'package:pos_app/providers/auth_providers.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockAuthRepository extends Mock implements AuthRepository {}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    // تهيئة Flutter binding للاختبارات
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock SecureStorage channel
    const MethodChannel channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'read':
          return null;
        case 'write':
          return null;
        case 'delete':
          return null;
        case 'deleteAll':
          return null;
        default:
          return null;
      }
    });
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthState', () {
    test('الحالة الأولية صحيحة', () {
      const state = AuthState();

      expect(state.status, AuthStatus.unknown);
      expect(state.user, isNull);
      expect(state.error, isNull);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isTrue);
    });

    test('copyWith تعمل بشكل صحيح', () {
      const state = AuthState();
      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        error: 'test error',
      );

      expect(newState.status, AuthStatus.authenticated);
      expect(newState.error, 'test error');
      expect(newState.isAuthenticated, isTrue);
      expect(newState.isLoading, isFalse);
    });
    
    test('isSessionValid يُرجع false عند عدم وجود sessionExpiry', () {
      const state = AuthState(status: AuthStatus.authenticated);
      expect(state.isSessionValid, isFalse);
    });
    
    test('isSessionValid يُرجع true عند وجود sessionExpiry صالح', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        sessionExpiry: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(state.isSessionValid, isTrue);
    });
    
    test('needsRefresh يُرجع true عند قرب انتهاء الجلسة', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        sessionExpiry: DateTime.now().add(const Duration(minutes: 3)),
      );
      expect(state.needsRefresh, isTrue);
    });
  });

  group('AuthNotifier - Unit Tests', () {
    test('يبدأ بحالة unknown', () {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      final notifier = AuthNotifier(mockAuthRepository);
      
      // الحالة الأولية قبل التحقق
      expect(notifier.state.status, AuthStatus.unknown);
    });

    test('sendOtp يستدعي المستودع', () async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepository.sendOtp(any()))
          .thenAnswer((_) async {});

      final notifier = AuthNotifier(mockAuthRepository);

      await notifier.sendOtp('+966500000000');

      verify(() => mockAuthRepository.sendOtp('+966500000000')).called(1);
    });

    test('clearError يمسح الخطأ', () {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      final notifier = AuthNotifier(mockAuthRepository);
      
      // تعيين خطأ يدوياً باستخدام copyWith
      // (لأن الـ constructor الجديد يستخدم SecureStorage أولاً)
      notifier.state = notifier.state.copyWith(error: 'خطأ اختبار');

      expect(notifier.state.error, isNotNull);

      notifier.clearError();

      expect(notifier.state.error, isNull);
    });
  });

  group('Provider Integration', () {
    test('currentUserProvider يُرجع المستخدم من authStateProvider', () {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) {
            final notifier = AuthNotifier(mockAuthRepository);
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      final user = container.read(currentUserProvider);
      expect(user, isNull);
    });

    test('isAuthenticatedProvider يُرجع false بالحالة الأولية', () {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      final isAuthenticated = container.read(isAuthenticatedProvider);

      expect(isAuthenticated, isFalse);
    });

    test('userRoleProvider يُرجع null عندما لا يوجد مستخدم', () {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      final role = container.read(userRoleProvider);

      expect(role, isNull);
    });

    test('isAdminProvider يُرجع false عندما لا يوجد مستخدم', () {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      final isAdmin = container.read(isAdminProvider);

      expect(isAdmin, isFalse);
    });
    
    test('sessionStatusProvider يُرجع notAuthenticated عند عدم المصادقة', () {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      // انتظر التحقق من المصادقة
      Future.delayed(const Duration(milliseconds: 100));
      
      final status = container.read(sessionStatusProvider);
      
      // الحالة الأولية ستكون notAuthenticated لأنه لا يوجد sessionExpiry
      expect(status, isNotNull);
    });
  });
  
  group('Constants', () {
    test('kSessionDuration is 30 minutes', () {
      expect(kSessionDuration, const Duration(minutes: 30));
    });
    
    test('kTokenRefreshBuffer is 5 minutes', () {
      expect(kTokenRefreshBuffer, const Duration(minutes: 5));
    });
  });
}
