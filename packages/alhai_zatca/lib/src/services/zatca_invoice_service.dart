import 'dart:convert';

import 'package:alhai_zatca/src/api/clearance_api.dart';
import 'package:alhai_zatca/src/api/reporting_api.dart';
import 'package:alhai_zatca/src/certificate/certificate_renewal_service.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/chaining/invoice_chain_service.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';
import 'package:alhai_zatca/src/qr/zatca_qr_service.dart';
import 'package:alhai_zatca/src/services/zatca_compliance_checker.dart';
import 'package:alhai_zatca/src/services/zatca_offline_queue.dart';
import 'package:alhai_zatca/src/signing/xades_signer.dart';
import 'package:alhai_zatca/src/xml/ubl_invoice_builder.dart';

/// Main orchestrator for ZATCA e-invoicing
///
/// Coordinates the full invoice lifecycle:
/// 1. Validate against ZATCA business rules
/// 2. Get PIH from chain service
/// 3. Build UBL XML from invoice model
/// 4. Sign with XAdES-BES
/// 5. Compute invoice hash
/// 6. Generate QR code with signature data
/// 7. Submit to ZATCA (reporting or clearance)
/// 8. Update invoice chain hash
/// 9. Handle offline queuing for failures
///
/// **Never throws** -- catches all errors and stores them in the invoice record.
class ZatcaInvoiceService {
  final UblInvoiceBuilder _xmlBuilder;
  final XadesSigner _signer;
  final ZatcaQrService _qrService;
  final InvoiceChainService _chainService;
  final ReportingApi _reportingApi;
  final ClearanceApi _clearanceApi;
  final CertificateStorage _certStorage;
  final ZatcaOfflineQueue _offlineQueue;
  final ZatcaComplianceChecker _complianceChecker;
  final CertificateRenewalService? _renewalService;

  ZatcaInvoiceService({
    required UblInvoiceBuilder xmlBuilder,
    required XadesSigner signer,
    required ZatcaQrService qrService,
    required InvoiceChainService chainService,
    required ReportingApi reportingApi,
    required ClearanceApi clearanceApi,
    required CertificateStorage certStorage,
    required ZatcaOfflineQueue offlineQueue,
    required ZatcaComplianceChecker complianceChecker,
    CertificateRenewalService? renewalService,
  })  : _xmlBuilder = xmlBuilder,
        _signer = signer,
        _qrService = qrService,
        _chainService = chainService,
        _reportingApi = reportingApi,
        _clearanceApi = clearanceApi,
        _certStorage = certStorage,
        _offlineQueue = offlineQueue,
        _complianceChecker = complianceChecker,
        _renewalService = renewalService;

  /// Process a ZATCA invoice end-to-end
  ///
  /// Pipeline:
  /// 1. Validate the invoice against ZATCA business rules
  /// 2. Get the production certificate from storage
  /// 3. Get PIH (Previous Invoice Hash) for chaining
  /// 4. Inject PIH into invoice and build UBL XML
  /// 5. Sign the XML with XAdES-BES
  /// 6. Compute the invoice hash
  /// 7. Generate enhanced QR code (tags 1-9)
  /// 8. Submit to ZATCA (report for B2C, clear for B2B)
  /// 9. Update the invoice chain hash
  ///
  /// Returns the updated invoice with hash, QR, signed XML, and status.
  /// **Never throws** -- errors are captured in the returned invoice's
  /// `errors` list and `reportingStatus`.
  Future<ZatcaInvoice> processInvoice({
    required ZatcaInvoice invoice,
    required String storeId,
  }) async {
    var result = invoice;

    try {
      // ── Step 1: Validate ──────────────────────────────────
      final complianceResult = _complianceChecker.check(invoice);
      if (!complianceResult.isValid &&
          complianceResult.blockingErrors.isNotEmpty) {
        return result.copyWith(
          reportingStatus: ReportingStatus.failed,
          errors:
              complianceResult.blockingErrors.map((e) => e.toString()).toList(),
          warnings: complianceResult.warnings.map((e) => e.toString()).toList(),
        );
      }

      // Carry forward warnings (non-blocking)
      final warningMessages =
          complianceResult.warnings.map((e) => e.toString()).toList();

      // ── Step 2: Get certificate ───────────────────────────
      final certificate = await _certStorage.getCertificate(storeId: storeId);
      if (certificate == null) {
        return result.copyWith(
          reportingStatus: ReportingStatus.failed,
          errors: [
            'No ZATCA certificate found for store $storeId. '
                'Complete onboarding first.'
          ],
          warnings: warningMessages,
        );
      }
      if (!certificate.isValid) {
        return result.copyWith(
          reportingStatus: ReportingStatus.failed,
          errors: ['ZATCA certificate has expired. Renewal required.'],
          warnings: warningMessages,
        );
      }

      // ── Step 2b: Check certificate expiry proximity ──────
      // Warn (but don't block) if the certificate is nearing expiry
      if (_renewalService != null) {
        try {
          final checkResult = await _renewalService.checkCertificate(
            storeId: storeId,
          );
          if (checkResult.status == CertificateStatus.nearExpiry) {
            warningMessages.add(
              'Certificate expires in ${checkResult.daysUntilExpiry} days. '
              'Renewal recommended.',
            );
          }
        } catch (_) {
          // Certificate check should never block invoice processing
        }
      }

      // ── Step 3: Get PIH ───────────────────────────────────
      final previousHash = await _chainService.getPreviousHash(
        storeId: storeId,
      );

      // ── Step 4: Build UBL XML ─────────────────────────────
      final invoiceWithPih = result.copyWith(
        previousInvoiceHash: previousHash,
      );
      final xml = _xmlBuilder.build(invoiceWithPih);

      // ── Step 5: Sign XML ──────────────────────────────────
      final signedXml = _signer.sign(
        invoiceXml: xml,
        certificate: certificate,
      );

      // ── Step 6: Compute invoice hash ──────────────────────
      final invoiceHash = _signer.computeInvoiceHash(signedXml);

      // ── Step 7: Generate QR ───────────────────────────────
      String qrCode;
      try {
        qrCode = _qrService.generateQrData(
          invoice: invoiceWithPih,
          invoiceHash: invoiceHash,
          digitalSignature: _extractSignatureValue(signedXml),
          certificate: certificate,
        );
      } catch (_) {
        // Fallback to simplified QR if enhanced fails
        qrCode = _qrService.generateSimplifiedQr(invoice: invoiceWithPih);
      }

      // Update invoice with generated data
      result = result.copyWith(
        previousInvoiceHash: previousHash,
        signedXml: signedXml,
        invoiceHash: invoiceHash,
        qrCode: qrCode,
        warnings: warningMessages,
      );

      // ── Step 8: Submit to ZATCA ───────────────────────────
      final signedXmlBase64 = base64Encode(utf8.encode(signedXml));

      if (invoice.isStandard) {
        result = await _processStandard(
          invoice: result,
          certificate: certificate,
          signedXml: signedXmlBase64,
          invoiceHash: invoiceHash,
        );
      } else {
        result = await _processSimplified(
          invoice: result,
          certificate: certificate,
          signedXml: signedXmlBase64,
          invoiceHash: invoiceHash,
        );
      }

      // ── Step 9: Update chain ──────────────────────────────
      if (result.reportingStatus.isSuccess ||
          result.reportingStatus == ReportingStatus.queued) {
        await _chainService.updateLastHash(
          storeId: storeId,
          invoiceHash: invoiceHash,
        );
      }

      return result;
    } catch (e) {
      // Never throw -- capture error in the invoice record
      return result.copyWith(
        reportingStatus: ReportingStatus.failed,
        errors: [...result.errors, 'Processing error: $e'],
      );
    }
  }

  /// Process a simplified (B2C) invoice - reporting flow
  ///
  /// Simplified invoices are reported to ZATCA asynchronously.
  /// ZATCA validates but does not modify the invoice.
  Future<ZatcaInvoice> _processSimplified({
    required ZatcaInvoice invoice,
    required CertificateInfo certificate,
    required String signedXml,
    required String invoiceHash,
  }) async {
    try {
      final response = await _reportingApi.reportInvoice(
        signedXmlBase64: signedXml,
        invoiceHash: invoiceHash,
        uuid: invoice.uuid,
        certificate: certificate,
      );

      return _applyResponse(invoice, response);
    } catch (e) {
      // Network failure -- queue for offline retry
      await _queueForRetry(
        invoice: invoice,
        signedXml: signedXml,
        invoiceHash: invoiceHash,
      );
      return invoice.copyWith(
        reportingStatus: ReportingStatus.queued,
        errors: [...invoice.errors, 'Queued for retry: $e'],
      );
    }
  }

  /// Process a standard (B2B) invoice - clearance flow
  ///
  /// Standard invoices must be cleared by ZATCA before being shared
  /// with the buyer. ZATCA may stamp/modify the invoice.
  Future<ZatcaInvoice> _processStandard({
    required ZatcaInvoice invoice,
    required CertificateInfo certificate,
    required String signedXml,
    required String invoiceHash,
  }) async {
    try {
      final response = await _clearanceApi.clearInvoice(
        signedXmlBase64: signedXml,
        invoiceHash: invoiceHash,
        uuid: invoice.uuid,
        certificate: certificate,
      );

      var updatedInvoice = _applyResponse(invoice, response);

      // If ZATCA returned a cleared/stamped invoice XML, use it
      if (response.isSuccess && response.clearedInvoiceXml != null) {
        updatedInvoice = updatedInvoice.copyWith(
          signedXml: response.clearedInvoiceXml,
          reportingStatus: ReportingStatus.cleared,
        );
      }

      return updatedInvoice;
    } catch (e) {
      // Network failure -- queue for offline retry
      await _queueForRetry(
        invoice: invoice,
        signedXml: signedXml,
        invoiceHash: invoiceHash,
      );
      return invoice.copyWith(
        reportingStatus: ReportingStatus.queued,
        errors: [...invoice.errors, 'Queued for retry: $e'],
      );
    }
  }

  /// Apply a ZATCA response to an invoice
  ZatcaInvoice _applyResponse(ZatcaInvoice invoice, ZatcaResponse response) {
    return invoice.copyWith(
      reportingStatus: response.reportingStatus,
      warnings: [
        ...invoice.warnings,
        ...response.warnings.map((w) => w.toString()),
      ],
      errors: response.isSuccess
          ? invoice.errors
          : [
              ...invoice.errors,
              ...response.errors.map((e) => e.toString()),
            ],
    );
  }

  /// Queue an invoice for later submission (offline scenario)
  Future<void> _queueForRetry({
    required ZatcaInvoice invoice,
    required String signedXml,
    required String invoiceHash,
  }) async {
    await _offlineQueue.enqueue(
      invoiceNumber: invoice.invoiceNumber,
      signedXmlBase64: signedXml,
      invoiceHash: invoiceHash,
      uuid: invoice.uuid,
      isStandard: invoice.isStandard,
    );
  }

  /// Public method for explicit queueing
  Future<void> queueForRetry({
    required ZatcaInvoice invoice,
    required String signedXml,
    required String invoiceHash,
  }) async {
    await _queueForRetry(
      invoice: invoice,
      signedXml: base64Encode(utf8.encode(signedXml)),
      invoiceHash: invoiceHash,
    );
  }

  /// Retry all queued invoices
  ///
  /// Processes the offline queue and returns results.
  Future<List<QueueProcessResult>> retryQueue({
    required String storeId,
  }) async {
    return _offlineQueue.processQueue(
      reportingApi: _reportingApi,
      clearanceApi: _clearanceApi,
      certStorage: _certStorage,
      storeId: storeId,
    );
  }

  /// Get the number of pending offline invoices
  Future<int> getPendingQueueCount() async {
    return _offlineQueue.pendingCount;
  }

  /// Validate an invoice without processing it
  ComplianceResult validateInvoice(ZatcaInvoice invoice) {
    return _complianceChecker.check(invoice);
  }

  /// Extract the ds:SignatureValue content from signed XML
  ///
  /// Used for QR code generation (Tag 7).
  String _extractSignatureValue(String signedXml) {
    // Look for <ds:SignatureValue> or <SignatureValue>
    final patterns = [
      RegExp(r'<ds:SignatureValue[^>]*>(.*?)</ds:SignatureValue>',
          dotAll: true),
      RegExp(r'<SignatureValue[^>]*>(.*?)</SignatureValue>', dotAll: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(signedXml);
      if (match != null) {
        // Clean up whitespace from base64 content
        return match.group(1)!.replaceAll(RegExp(r'\s'), '');
      }
    }

    // If signature extraction fails, return empty string
    // (QR will fall back to simplified)
    return '';
  }
}
