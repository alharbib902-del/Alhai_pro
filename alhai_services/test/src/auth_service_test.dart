import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

// ---------------------------------------------------------------------------
// Fake AuthRepository
// ---------------------------------------------------------------------------
class FakeAuthRepository implements AuthRepository {
  bool sendOtpCalled = false;
  String? lastPhone;
  String? lastOtp;
  bool shouldThrow = false;
  User? _currentUser;
  bool _isAuthenticated = false;

  void setCurrentUser(User? user) {
    _currentUser = user;
    _isAuthenticated = user != null;
  }

  @override
  Future<void> sendOtp(String phone) async {
    if (shouldThrow) throw Exception('OTP send failed');
    sendOtpCalled = true;
    lastPhone = phone;
  }

  @override
  Future<AuthResult> verifyOtp(String phone, String otp) async {
    if (shouldThrow) throw Exception('OTP verify failed');
    lastPhone = phone;
    lastOtp = otp;
    final user = User(
      id: 'user-1',
      phone: phone,
      name: 'Test User',
      role: UserRole.storeOwner,
      createdAt: DateTime(2026, 1, 1),
    );
    _currentUser = user;
    _isAuthenticated = true;
    return AuthResult(
      user: user,
      tokens: AuthTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
  }

  @override
  Future<User?> getCurrentUser() async => _currentUser;

  @override
  Future<bool> isAuthenticated() async => _isAuthenticated;

  @override
  Future<AuthTokens> refreshToken() async {
    if (shouldThrow) throw Exception('Refresh failed');
    return AuthTokens(
      accessToken: 'new-access-token',
      refreshToken: 'new-refresh-token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }
}

void main() {
  late AuthService authService;
  late FakeAuthRepository fakeAuthRepo;

  setUp(() {
    fakeAuthRepo = FakeAuthRepository();
    authService = AuthService(fakeAuthRepo);
  });

  group('AuthService', () {
    test('should be created', () {
      expect(authService, isNotNull);
    });

    test('initial state should be logged out', () {
      expect(authService.isLoggedIn, isFalse);
      expect(authService.currentUser, isNull);
    });

    group('sendOtp', () {
      test('should delegate to repository', () async {
        await authService.sendOtp('0512345678');
        expect(fakeAuthRepo.sendOtpCalled, isTrue);
        expect(fakeAuthRepo.lastPhone, equals('0512345678'));
      });

      test('should propagate errors', () async {
        fakeAuthRepo.shouldThrow = true;
        expect(
          () => authService.sendOtp('0512345678'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('verifyOtp', () {
      test('should set current user on success', () async {
        final result = await authService.verifyOtp('0512345678', '1234');

        expect(result.user.phone, equals('0512345678'));
        expect(authService.isLoggedIn, isTrue);
        expect(authService.currentUser, isNotNull);
        expect(authService.currentUser!.phone, equals('0512345678'));
      });

      test('should return AuthResult with tokens', () async {
        final result = await authService.verifyOtp('0512345678', '1234');

        expect(result.tokens.accessToken, isNotEmpty);
        expect(result.tokens.refreshToken, isNotEmpty);
      });
    });

    group('logout', () {
      test('should clear current user', () async {
        await authService.verifyOtp('0512345678', '1234');
        expect(authService.isLoggedIn, isTrue);

        await authService.logout();

        expect(authService.isLoggedIn, isFalse);
        expect(authService.currentUser, isNull);
      });
    });

    group('checkSession', () {
      test('should return true when authenticated', () async {
        fakeAuthRepo.setCurrentUser(User(
          id: 'user-1',
          phone: '0512345678',
          name: 'Test',
          role: UserRole.storeOwner,
          createdAt: DateTime(2026, 1, 1),
        ));

        final result = await authService.checkSession();

        expect(result, isTrue);
        expect(authService.currentUser, isNotNull);
      });

      test('should return false when not authenticated', () async {
        final result = await authService.checkSession();
        expect(result, isFalse);
      });
    });

    group('refreshToken', () {
      test('should return new tokens', () async {
        final tokens = await authService.refreshToken();
        expect(tokens.accessToken, equals('new-access-token'));
      });
    });

    group('hasPermission', () {
      test('should return false when not logged in', () {
        expect(authService.hasPermission('create_order'), isFalse);
      });

      test('superAdmin should have all permissions', () async {
        await authService.verifyOtp('0512345678', '1234');
        // verifyOtp returns storeOwner, so let's set a superAdmin
        fakeAuthRepo.setCurrentUser(User(
          id: 'admin-1',
          phone: '0512345678',
          name: 'Admin',
          role: UserRole.superAdmin,
          createdAt: DateTime(2026, 1, 1),
        ));
        await authService.checkSession();

        expect(authService.hasPermission('manage_admins'), isTrue);
        expect(authService.hasPermission('any_permission'), isTrue);
      });

      test('storeOwner should not have manage_admins', () async {
        await authService.verifyOtp('0512345678', '1234');

        expect(authService.hasPermission('manage_admins'), isFalse);
        expect(authService.hasPermission('create_order'), isTrue);
      });

      test('employee should only have specific permissions', () async {
        fakeAuthRepo.setCurrentUser(User(
          id: 'emp-1',
          phone: '0512345678',
          name: 'Employee',
          role: UserRole.employee,
          createdAt: DateTime(2026, 1, 1),
        ));
        await authService.checkSession();

        expect(authService.hasPermission('create_order'), isTrue);
        expect(authService.hasPermission('view_products'), isTrue);
        expect(authService.hasPermission('manage_cash'), isTrue);
        expect(authService.hasPermission('manage_admins'), isFalse);
        expect(authService.hasPermission('view_deliveries'), isFalse);
      });

      test('delivery should only have delivery permissions', () async {
        fakeAuthRepo.setCurrentUser(User(
          id: 'del-1',
          phone: '0512345678',
          name: 'Driver',
          role: UserRole.delivery,
          createdAt: DateTime(2026, 1, 1),
        ));
        await authService.checkSession();

        expect(authService.hasPermission('view_deliveries'), isTrue);
        expect(authService.hasPermission('update_delivery'), isTrue);
        expect(authService.hasPermission('create_order'), isFalse);
      });

      test('customer should only have customer permissions', () async {
        fakeAuthRepo.setCurrentUser(User(
          id: 'cust-1',
          phone: '0512345678',
          name: 'Customer',
          role: UserRole.customer,
          createdAt: DateTime(2026, 1, 1),
        ));
        await authService.checkSession();

        expect(authService.hasPermission('view_products'), isTrue);
        expect(authService.hasPermission('create_order'), isTrue);
        expect(authService.hasPermission('view_orders'), isTrue);
        expect(authService.hasPermission('manage_cash'), isFalse);
      });
    });
  });
}
