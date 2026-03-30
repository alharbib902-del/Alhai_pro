/// Centralized API endpoint configuration.
/// All external service URLs should be defined here.
///
/// API versioning: All endpoints use [apiVersion] prefix for backward-compatible
/// evolution. When introducing breaking changes, bump the version and keep
/// old endpoints functional during the deprecation period.
class AppEndpoints {
  AppEndpoints._();

  /// Current API version prefix. Used in all versioned endpoint paths.
  /// Bump to 'v2' when introducing breaking changes to the API contract.
  static const String apiVersion = 'v1';

  // Core API
  static const String apiBase = 'https://api.alhai.app';

  /// Versioned API base: `https://api.alhai.app/v1`
  static const String apiBaseVersioned = '$apiBase/$apiVersion';

  // AI Service
  static const String aiProduction = String.fromEnvironment(
    'AI_SERVER_URL',
    defaultValue: 'https://believable-art-production-d981.up.railway.app',
  );
  static const String aiDebug = String.fromEnvironment(
    'AI_DEBUG_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  static const String aiInvoice = '$apiBase/$apiVersion/ai';

  // WhatsApp
  static const String whatsAppGraph = 'https://graph.facebook.com/v17.0';
  static const String wasender = 'https://www.wasenderapi.com/api';

  // SMS Providers
  static const String twilioBase = 'https://api.twilio.com/2010-04-01/Accounts';
  static const String nexmoBase = 'https://rest.nexmo.com';
  static const String unifonicBase = 'https://el.cloud.unifonic.com';

  // ─── Versioned Endpoints ──────────────────────────────────────
  // All new endpoints should use apiBaseVersioned as prefix.

  /// Products endpoint: `/v1/products`
  static const String products = '$apiBaseVersioned/products';

  /// Orders endpoint: `/v1/orders`
  static const String orders = '$apiBaseVersioned/orders';

  /// Customers endpoint: `/v1/customers`
  static const String customers = '$apiBaseVersioned/customers';

  /// Stores endpoint: `/v1/stores`
  static const String stores = '$apiBaseVersioned/stores';

  /// Inventory endpoint: `/v1/inventory`
  static const String inventory = '$apiBaseVersioned/inventory';

  /// Reports endpoint: `/v1/reports`
  static const String reports = '$apiBaseVersioned/reports';

  /// Sync endpoint: `/v1/sync`
  static const String sync = '$apiBaseVersioned/sync';

  // ─── Dynamic Endpoints ────────────────────────────────────────

  /// Receipt URL: `/v1/receipt/{orderId}`
  static String receiptUrl(String orderId) => '$apiBaseVersioned/receipt/$orderId';

  /// Product by ID: `/v1/products/{id}`
  static String productUrl(String id) => '$products/$id';

  /// Order by ID: `/v1/orders/{id}`
  static String orderUrl(String id) => '$orders/$id';

  /// Store by ID: `/v1/stores/{id}`
  static String storeUrl(String id) => '$stores/$id';
}
