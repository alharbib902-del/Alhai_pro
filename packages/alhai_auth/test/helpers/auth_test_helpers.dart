import 'package:mocktail/mocktail.dart';
import 'package:alhai_auth/alhai_auth.dart';

// =============================================================================
// MOCK CLASSES
// =============================================================================

/// Mock for StorageInterface (used by SecureStorageService)
class MockStorageInterface extends Mock implements StorageInterface {}

// =============================================================================
// FALLBACK VALUES
// =============================================================================

void registerAuthFallbackValues() {
  // No complex objects need fallback registration for these tests
}

// =============================================================================
// HELPER FACTORIES
// =============================================================================

/// Create a pre-populated InMemoryStorage for testing
InMemoryStorage createPopulatedStorage({
  String? accessToken,
  String? refreshToken,
  String? sessionExpiry,
  String? userId,
  String? storeId,
}) {
  final storage = InMemoryStorage();
  if (accessToken != null) {
    storage.write(key: 'access_token', value: accessToken);
  }
  if (refreshToken != null) {
    storage.write(key: 'refresh_token', value: refreshToken);
  }
  if (sessionExpiry != null) {
    storage.write(key: 'session_expiry', value: sessionExpiry);
  }
  if (userId != null) {
    storage.write(key: 'user_id', value: userId);
  }
  if (storeId != null) {
    storage.write(key: 'store_id', value: storeId);
  }
  return storage;
}
