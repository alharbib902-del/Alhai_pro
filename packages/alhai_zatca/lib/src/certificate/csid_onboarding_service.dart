import 'dart:convert';

import 'package:alhai_zatca/src/api/compliance_api.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/certificate/csr_generator.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/services/zatca_invoice_service.dart';
import 'package:uuid/uuid.dart';

/// Orchestrates the ZATCA CSID onboarding process
///
/// The 3-step onboarding flow:
/// 1. Generate CSR and obtain Compliance CSID (CCSID)
/// 2. Submit test invoices for compliance validation
/// 3. Exchange CCSID for Production CSID (PCSID)
class CsidOnboardingService {
  final CsrGenerator _csrGenerator;
  final ComplianceApi _complianceApi;
  final CertificateStorage _storage;

  CsidOnboardingService({
    required CsrGenerator csrGenerator,
    required ComplianceApi complianceApi,
    required CertificateStorage storage,
  }) : _csrGenerator = csrGenerator,
       _complianceApi = complianceApi,
       _storage = storage;

  /// Step 1: Generate CSR and request Compliance CSID
  ///
  /// [otp] - One-Time Password from ZATCA portal
  /// Returns the compliance CertificateInfo for use in Step 2.
  Future<CertificateInfo> requestComplianceCsid({
    required String otp,
    required CsrConfig config,
  }) async {
    // 1. Generate CSR using CsrGenerator
    final serialNumber =
        '1-${config.solutionName}|2-${config.modelVersion}|3-${config.serialNumber}';

    final csrResult = await _csrGenerator.generateCsr(
      commonName: config.solutionName,
      organizationUnit: config.branchId,
      organizationName: config.organizationName,
      country: 'SA',
      serialNumber: serialNumber,
      invoiceType: config.invoiceType,
      branchLocation: config.branchLocation,
      industryBusinessCategory: config.industryCategory,
    );

    final csrPem = csrResult['csr']!;
    final privateKeyPem = csrResult['privateKey']!;

    // 2. Submit CSR to ZATCA with OTP (base64 encode the PEM body)
    final csrBase64 = _extractBase64FromPem(csrPem);
    final response = await _complianceApi.requestComplianceCsid(
      csrBase64: csrBase64,
      otp: otp,
    );

    if (!response.isSuccess || response.binarySecurityToken == null) {
      throw OnboardingException(
        step: OnboardingStep.complianceCsid,
        message:
            response.errorMessage ??
            'Failed to obtain compliance CSID from ZATCA',
      );
    }

    // 3. Parse response to get compliance certificate
    // The binarySecurityToken is the base64-encoded X.509 certificate
    final certificate = CertificateInfo(
      certificatePem: response.binarySecurityToken!,
      privateKeyPem: privateKeyPem,
      csid: response.csid!,
      secret: response.secret!,
      isProduction: false,
    );

    // 4. Store compliance certificate temporarily
    await _storage.saveCertificate(
      storeId: '_compliance_temp',
      certificate: certificate,
    );

    return certificate;
  }

  /// Step 2: Run compliance check invoices
  ///
  /// Submits 6 test invoices to ZATCA for compliance validation:
  /// - Standard invoice (388) + Standard credit note (381)
  /// - Simplified invoice (388) + Simplified credit note (381)
  /// - Standard debit note (383) + Simplified debit note (383)
  ///
  /// Returns the list of responses from compliance checks.
  Future<List<ZatcaResponse>> runComplianceChecks({
    required CertificateInfo complianceCertificate,
    required ZatcaInvoiceService invoiceService,
    required ZatcaSeller seller,
  }) async {
    final responses = <ZatcaResponse>[];
    const uuid = Uuid();
    var invoiceCounter = 1;

    // Define the 6 compliance check invoice types
    final complianceInvoices = [
      // Standard invoice
      _ComplianceInvoiceSpec(
        typeCode: InvoiceTypeCode.standard,
        subType: '0100000',
        label: 'Standard Tax Invoice',
      ),
      // Standard credit note
      _ComplianceInvoiceSpec(
        typeCode: InvoiceTypeCode.creditNote,
        subType: '0100000',
        label: 'Standard Credit Note',
        billingRef: 'INV-COMP-1',
      ),
      // Standard debit note
      _ComplianceInvoiceSpec(
        typeCode: InvoiceTypeCode.debitNote,
        subType: '0100000',
        label: 'Standard Debit Note',
        billingRef: 'INV-COMP-1',
      ),
      // Simplified invoice
      _ComplianceInvoiceSpec(
        typeCode: InvoiceTypeCode.standard,
        subType: '0200000',
        label: 'Simplified Tax Invoice',
      ),
      // Simplified credit note
      _ComplianceInvoiceSpec(
        typeCode: InvoiceTypeCode.creditNote,
        subType: '0200000',
        label: 'Simplified Credit Note',
        billingRef: 'INV-COMP-4',
      ),
      // Simplified debit note
      _ComplianceInvoiceSpec(
        typeCode: InvoiceTypeCode.debitNote,
        subType: '0200000',
        label: 'Simplified Debit Note',
        billingRef: 'INV-COMP-4',
      ),
    ];

    for (final spec in complianceInvoices) {
      final invoiceNumber = 'INV-COMP-${invoiceCounter++}';
      final invoice = ZatcaInvoice(
        invoiceNumber: invoiceNumber,
        uuid: uuid.v4(),
        issueDate: DateTime.now(),
        issueTime: DateTime.now(),
        typeCode: spec.typeCode,
        subType: spec.subType,
        seller: seller,
        lines: [
          ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Compliance Test Item',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ],
        billingReferenceId: spec.billingRef,
        paymentMeansCode: '10',
      );

      try {
        // Process the invoice through the full pipeline
        final processed = await invoiceService.processInvoice(
          invoice: invoice,
          storeId: '_compliance_temp',
        );

        if (processed.signedXml == null || processed.invoiceHash == null) {
          responses.add(
            ZatcaResponse.failure(
              message: 'Failed to generate signed XML for ${spec.label}',
            ),
          );
          continue;
        }

        // Submit to compliance endpoint
        final response = await _complianceApi.submitComplianceInvoice(
          signedXmlBase64: base64Encode(utf8.encode(processed.signedXml!)),
          invoiceHash: processed.invoiceHash!,
          uuid: processed.uuid,
          complianceCertificate: complianceCertificate,
        );

        responses.add(response);

        if (!response.isSuccess) {
          throw OnboardingException(
            step: OnboardingStep.complianceCheck,
            message:
                'Compliance check failed for ${spec.label}: '
                '${response.errors.map((e) => e.message).join(', ')}',
          );
        }
      } catch (e) {
        if (e is OnboardingException) rethrow;
        responses.add(ZatcaResponse.failure(message: e.toString()));
      }
    }

    return responses;
  }

  /// Step 3: Exchange compliance CSID for production CSID
  ///
  /// Must be called after successful compliance checks (Step 2).
  Future<CertificateInfo> requestProductionCsid({
    required CertificateInfo complianceCertificate,
  }) async {
    final response = await _complianceApi.requestProductionCsid(
      complianceCsid: complianceCertificate.csid,
      complianceCertificate: complianceCertificate,
    );

    if (!response.isSuccess || response.binarySecurityToken == null) {
      throw OnboardingException(
        step: OnboardingStep.productionCsid,
        message:
            response.errorMessage ??
            'Failed to obtain production CSID from ZATCA',
      );
    }

    final productionCert = CertificateInfo(
      certificatePem: response.binarySecurityToken!,
      privateKeyPem: complianceCertificate.privateKeyPem,
      csid: response.csid!,
      secret: response.secret!,
      isProduction: true,
    );

    return productionCert;
  }

  /// Full onboarding: Steps 1-3 in sequence
  ///
  /// Runs the complete ZATCA onboarding flow:
  /// 1. Generate CSR + obtain Compliance CSID
  /// 2. Submit 6 compliance check invoices
  /// 3. Exchange for Production CSID
  /// 4. Store the production certificate
  Future<OnboardingResult> performFullOnboarding({
    required String otp,
    required CsrConfig config,
    required String storeId,
    required ZatcaInvoiceService invoiceService,
    required ZatcaSeller seller,
  }) async {
    // Step 1: Get Compliance CSID
    final complianceCert = await requestComplianceCsid(
      otp: otp,
      config: config,
    );

    // Step 2: Run compliance checks
    final complianceResults = await runComplianceChecks(
      complianceCertificate: complianceCert,
      invoiceService: invoiceService,
      seller: seller,
    );

    final allPassed = complianceResults.every((r) => r.isSuccess);
    if (!allPassed) {
      final failedCount = complianceResults.where((r) => !r.isSuccess).length;
      throw OnboardingException(
        step: OnboardingStep.complianceCheck,
        message:
            '$failedCount of ${complianceResults.length} compliance '
            'checks failed',
      );
    }

    // Step 3: Get Production CSID
    final productionCert = await requestProductionCsid(
      complianceCertificate: complianceCert,
    );

    // Store the production certificate
    await _storage.saveCertificate(
      storeId: storeId,
      certificate: productionCert,
    );

    // Clean up temporary compliance certificate
    await _storage.deleteCertificate(storeId: '_compliance_temp');

    return OnboardingResult(
      certificate: productionCert,
      complianceResponses: complianceResults,
    );
  }

  /// Check if a valid production certificate exists
  Future<bool> hasValidProductionCertificate({required String storeId}) async {
    final cert = await _storage.getCertificate(storeId: storeId);
    return cert != null && cert.isProduction && cert.isValid;
  }

  /// Extract base64 content from a PEM string (strip headers)
  String _extractBase64FromPem(String pem) {
    return pem
        .replaceAll(RegExp(r'-----BEGIN [A-Z\s]+-----'), '')
        .replaceAll(RegExp(r'-----END [A-Z\s]+-----'), '')
        .replaceAll(RegExp(r'\s'), '');
  }
}

/// Configuration for CSR generation
class CsrConfig {
  /// Solution/application name
  final String solutionName;

  /// Model version
  final String modelVersion;

  /// Device serial number
  final String serialNumber;

  /// Organization name
  final String organizationName;

  /// Branch identifier
  final String branchId;

  /// Branch location (city)
  final String branchLocation;

  /// Invoice types supported (1100 for standard+simplified)
  final String invoiceType;

  /// Industry business category
  final String industryCategory;

  const CsrConfig({
    required this.solutionName,
    required this.modelVersion,
    required this.serialNumber,
    required this.organizationName,
    required this.branchId,
    required this.branchLocation,
    this.invoiceType = '1100',
    this.industryCategory = 'Retail',
  });
}

/// Result of the complete onboarding process
class OnboardingResult {
  /// The production certificate
  final CertificateInfo certificate;

  /// Responses from compliance checks
  final List<ZatcaResponse> complianceResponses;

  const OnboardingResult({
    required this.certificate,
    required this.complianceResponses,
  });

  /// Whether all compliance checks passed
  bool get allChecksPassed => complianceResponses.every((r) => r.isSuccess);
}

/// Exception thrown during the onboarding process
class OnboardingException implements Exception {
  /// Which step failed
  final OnboardingStep step;

  /// Error message
  final String message;

  const OnboardingException({required this.step, required this.message});

  @override
  String toString() => 'OnboardingException(${step.name}): $message';
}

/// Steps of the ZATCA onboarding process
enum OnboardingStep {
  /// Step 1: Obtaining Compliance CSID
  complianceCsid,

  /// Step 2: Compliance invoice checks
  complianceCheck,

  /// Step 3: Obtaining Production CSID
  productionCsid,
}

/// Internal: spec for a compliance check invoice
class _ComplianceInvoiceSpec {
  final InvoiceTypeCode typeCode;
  final String subType;
  final String label;
  final String? billingRef;

  const _ComplianceInvoiceSpec({
    required this.typeCode,
    required this.subType,
    required this.label,
    this.billingRef,
  });
}
