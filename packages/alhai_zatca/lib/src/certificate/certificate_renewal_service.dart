import 'dart:async';

import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/certificate/csid_onboarding_service.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/services/zatca_invoice_service.dart';

/// Monitors certificate expiration and handles automatic renewal
///
/// ZATCA production certificates have a limited validity period.
/// This service checks for upcoming expiration and triggers renewal.
class CertificateRenewalService {
  /// Number of days before expiry to trigger renewal
  static const int renewalThresholdDays = 30;

  /// Check interval for automatic monitoring (hours)
  static const int checkIntervalHours = 24;

  final CertificateStorage _storage;
  final CsidOnboardingService _onboardingService;

  Timer? _monitorTimer;

  /// Callback invoked when a certificate is near expiry
  void Function(String storeId, int daysRemaining)? onNearExpiry;

  /// Callback invoked when a certificate has expired
  void Function(String storeId)? onExpired;

  /// Callback invoked when renewal succeeds
  void Function(String storeId, CertificateInfo newCert)? onRenewed;

  /// Callback invoked when renewal fails
  void Function(String storeId, Object error)? onRenewalFailed;

  CertificateRenewalService({
    required CertificateStorage storage,
    required CsidOnboardingService onboardingService,
  }) : _storage = storage,
       _onboardingService = onboardingService;

  /// Check if the certificate for a store needs renewal
  Future<bool> needsRenewal({required String storeId}) async {
    final cert = await _storage.getCertificate(storeId: storeId);
    if (cert == null) return true;
    if (!cert.isValid) return true;
    return cert.isNearExpiry;
  }

  /// Get the certificate status for a store
  Future<CertificateStatus> getStatus({required String storeId}) async {
    final cert = await _storage.getCertificate(storeId: storeId);
    if (cert == null) return CertificateStatus.missing;
    if (!cert.isValid) return CertificateStatus.expired;
    if (cert.isNearExpiry) return CertificateStatus.nearExpiry;
    return CertificateStatus.valid;
  }

  /// Get detailed renewal info for a store
  Future<RenewalInfo> getRenewalInfo({required String storeId}) async {
    final cert = await _storage.getCertificate(storeId: storeId);
    if (cert == null) {
      return const RenewalInfo(
        status: CertificateStatus.missing,
        daysUntilExpiry: null,
        requiresOtp: true,
      );
    }

    final days = cert.daysUntilExpiry;
    final status = await getStatus(storeId: storeId);

    return RenewalInfo(
      status: status,
      daysUntilExpiry: days,
      expiryDate: cert.validTo,
      isProduction: cert.isProduction,
      requiresOtp: status != CertificateStatus.valid,
    );
  }

  /// Renew the production CSID for a store
  ///
  /// Requires re-running the onboarding process with a new OTP.
  Future<CertificateInfo> renewCertificate({
    required String storeId,
    required String otp,
    required CsrConfig csrConfig,
  }) async {
    // 1. Get a new Compliance CSID
    final complianceCert = await _onboardingService.requestComplianceCsid(
      otp: otp,
      config: csrConfig,
    );

    // 2. Exchange for Production CSID
    // (Skip compliance checks for renewal -- ZATCA allows direct exchange
    // when a valid production certificate already existed)
    final productionCert = await _onboardingService.requestProductionCsid(
      complianceCertificate: complianceCert,
    );

    // 3. Store the new production certificate
    await _storage.saveCertificate(
      storeId: storeId,
      certificate: productionCert,
    );

    // 4. Notify listeners
    onRenewed?.call(storeId, productionCert);

    return productionCert;
  }

  /// Renew with full compliance checks (required when previous cert has expired)
  Future<CertificateInfo> renewWithComplianceChecks({
    required String storeId,
    required String otp,
    required CsrConfig csrConfig,
    required ZatcaInvoiceService invoiceService,
    required ZatcaSeller seller,
  }) async {
    final result = await _onboardingService.performFullOnboarding(
      otp: otp,
      config: csrConfig,
      storeId: storeId,
      invoiceService: invoiceService,
      seller: seller,
    );

    onRenewed?.call(storeId, result.certificate);
    return result.certificate;
  }

  /// Start automatic monitoring for certificate expiry
  ///
  /// Checks all stored certificates periodically and invokes callbacks
  /// when certificates are near expiry or have expired.
  void startMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(
      const Duration(hours: checkIntervalHours),
      (_) => _checkAllCertificates(),
    );
    // Also run immediately
    _checkAllCertificates();
  }

  /// Stop automatic monitoring
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  /// Check all stored certificates for expiry
  Future<void> _checkAllCertificates() async {
    try {
      final storeIds = await _storage.listStoreIds();
      for (final storeId in storeIds) {
        // Skip temporary compliance certificates
        if (storeId.startsWith('_')) continue;

        final cert = await _storage.getCertificate(storeId: storeId);
        if (cert == null) continue;

        if (!cert.isValid) {
          onExpired?.call(storeId);
        } else if (cert.isNearExpiry) {
          onNearExpiry?.call(storeId, cert.daysUntilExpiry ?? 0);
        }
      }
    } catch (_) {
      // Monitoring should not throw -- failures are silent
    }
  }

  /// Check a single store's certificate and return status
  Future<CertificateCheckResult> checkCertificate({
    required String storeId,
  }) async {
    final cert = await _storage.getCertificate(storeId: storeId);
    if (cert == null) {
      return const CertificateCheckResult(
        status: CertificateStatus.missing,
        message: 'No certificate found. Complete ZATCA onboarding first.',
      );
    }
    if (!cert.isValid) {
      return CertificateCheckResult(
        status: CertificateStatus.expired,
        message:
            'Certificate expired${cert.validTo != null ? ' on ${cert.validTo!.toIso8601String().split('T').first}' : ''}. '
            'Renewal required with a new OTP from ZATCA portal.',
      );
    }
    if (cert.isNearExpiry) {
      return CertificateCheckResult(
        status: CertificateStatus.nearExpiry,
        message:
            'Certificate expires in ${cert.daysUntilExpiry} days. '
            'Renewal recommended.',
        daysUntilExpiry: cert.daysUntilExpiry,
      );
    }
    return CertificateCheckResult(
      status: CertificateStatus.valid,
      message:
          'Certificate is valid'
          '${cert.daysUntilExpiry != null ? ' (${cert.daysUntilExpiry} days remaining)' : ''}.',
      daysUntilExpiry: cert.daysUntilExpiry,
    );
  }

  /// Dispose of the monitoring timer
  void dispose() {
    stopMonitoring();
  }
}

/// Certificate validity status
enum CertificateStatus {
  /// No certificate stored
  missing,

  /// Certificate is valid and not near expiry
  valid,

  /// Certificate is valid but expires within threshold
  nearExpiry,

  /// Certificate has expired
  expired,
}

/// Detailed info about certificate renewal status
class RenewalInfo {
  final CertificateStatus status;
  final int? daysUntilExpiry;
  final DateTime? expiryDate;
  final bool isProduction;
  final bool requiresOtp;

  const RenewalInfo({
    required this.status,
    this.daysUntilExpiry,
    this.expiryDate,
    this.isProduction = false,
    this.requiresOtp = true,
  });
}

/// Result of a certificate health check
class CertificateCheckResult {
  final CertificateStatus status;
  final String message;
  final int? daysUntilExpiry;

  const CertificateCheckResult({
    required this.status,
    required this.message,
    this.daysUntilExpiry,
  });

  bool get isHealthy => status == CertificateStatus.valid;
  bool get needsAction =>
      status == CertificateStatus.expired ||
      status == CertificateStatus.missing;
}
