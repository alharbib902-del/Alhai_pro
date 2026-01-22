import 'package:alhai_core/alhai_core.dart';

/// خدمة المصادقة وإدارة الجلسات
/// متوافقة مع AuthRepository من alhai_core
class AuthService {
  final AuthRepository _authRepo;

  User? _currentUser;

  AuthService(this._authRepo);

  /// المستخدم الحالي
  User? get currentUser => _currentUser;

  /// هل المستخدم مسجل دخول؟
  bool get isLoggedIn => _currentUser != null;

  /// إرسال OTP
  Future<void> sendOtp(String phone) async {
    await _authRepo.sendOtp(phone);
  }

  /// التحقق من OTP وتسجيل الدخول
  Future<AuthResult> verifyOtp(String phone, String otp) async {
    final result = await _authRepo.verifyOtp(phone, otp);
    _currentUser = result.user;
    return result;
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _authRepo.logout();
    _currentUser = null;
  }

  /// التحقق من الجلسة الحالية
  Future<bool> checkSession() async {
    final isAuth = await _authRepo.isAuthenticated();
    if (isAuth) {
      _currentUser = await _authRepo.getCurrentUser();
      return true;
    }
    return false;
  }

  /// تحديث التوكن
  Future<AuthTokens> refreshToken() async {
    return await _authRepo.refreshToken();
  }

  /// التحقق من صلاحية معينة بناءً على الدور
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    
    final role = _currentUser!.role;
    switch (role) {
      case UserRole.superAdmin:
        return true;
      case UserRole.storeOwner:
        return permission != 'manage_admins';
      case UserRole.employee:
        return ['create_order', 'view_products', 'manage_cash']
            .contains(permission);
      case UserRole.delivery:
        return ['view_deliveries', 'update_delivery'].contains(permission);
      case UserRole.customer:
        return ['view_products', 'create_order', 'view_orders']
            .contains(permission);
    }
  }
}
