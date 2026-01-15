import '../models/auth_result.dart';
import '../models/auth_tokens.dart';
import '../models/user.dart';

/// Repository contract for authentication operations
/// UI ↔ Repository = Domain Models only
abstract class AuthRepository {
  /// Sends OTP to the given phone number
  Future<void> sendOtp(String phone);

  /// Verifies OTP and returns authenticated user with tokens
  Future<AuthResult> verifyOtp(String phone, String otp);

  /// Refreshes access token using stored refresh token
  Future<AuthTokens> refreshToken();

  /// Logs out user and clears local storage
  Future<void> logout();

  /// Gets currently stored user (null if not logged in)
  Future<User?> getCurrentUser();

  /// Checks if user is authenticated with valid tokens
  Future<bool> isAuthenticated();
}
