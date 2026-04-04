/// ZATCA API endpoint URLs for sandbox and production environments
class ZatcaEndpoints {
  const ZatcaEndpoints._();

  // ─── Base URLs ─────────────────────────────────────────────

  /// Sandbox (developer portal) base URL
  static const String sandboxBase =
      'https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal';

  /// Simulation base URL
  static const String simulationBase =
      'https://gw-fatoora.zatca.gov.sa/e-invoicing/simulation';

  /// Production base URL
  static const String productionBase =
      'https://gw-fatoora.zatca.gov.sa/e-invoicing/core';

  // ─── Compliance Endpoints ──────────────────────────────────

  /// CSID issuance (compliance)
  static const String complianceCsid = '/compliance';

  /// Compliance invoice check
  static const String complianceCheck = '/compliance/invoices';

  // ─── Production CSID ───────────────────────────────────────

  /// Production CSID issuance
  static const String productionCsid = '/production/csids';

  /// Production CSID renewal
  static const String renewProductionCsid = '/production/csids';

  // ─── Invoice Submission ────────────────────────────────────

  /// Invoice reporting (simplified invoices - B2C)
  static const String reporting = '/invoices/reporting/single';

  /// Invoice clearance (standard invoices - B2B)
  static const String clearance = '/invoices/clearance/single';

  /// Get the full URL for an endpoint
  static String url(String baseUrl, String endpoint) => '$baseUrl$endpoint';

  /// Build the full URL from environment + path in one call
  static String fullUrl(ZatcaEnvironment env, String endpoint) =>
      '${env.baseUrl}$endpoint';
}

/// ZATCA API environment configuration
enum ZatcaEnvironment {
  /// Developer sandbox for testing
  sandbox,

  /// Simulation environment
  simulation,

  /// Live production environment
  production;

  /// Get the base URL for this environment
  String get baseUrl {
    switch (this) {
      case ZatcaEnvironment.sandbox:
        return ZatcaEndpoints.sandboxBase;
      case ZatcaEnvironment.simulation:
        return ZatcaEndpoints.simulationBase;
      case ZatcaEnvironment.production:
        return ZatcaEndpoints.productionBase;
    }
  }

  /// Whether this environment is safe for testing (not production)
  bool get isSandbox =>
      this == ZatcaEnvironment.sandbox || this == ZatcaEnvironment.simulation;
}
