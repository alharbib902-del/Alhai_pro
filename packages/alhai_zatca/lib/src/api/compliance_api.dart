import 'package:alhai_zatca/src/api/zatca_api_client.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';

/// Handles ZATCA compliance API operations
///
/// Used during the onboarding process to:
/// 1. Obtain a Compliance CSID (CCSID)
/// 2. Submit test invoices for compliance validation
/// 3. Obtain a Production CSID (PCSID)
class ComplianceApi {
  final ZatcaApiClient _client;

  ComplianceApi({required ZatcaApiClient client}) : _client = client;

  /// Request a Compliance CSID using a CSR (Certificate Signing Request)
  ///
  /// This is Step 1 of the onboarding process.
  /// Sends the CSR to ZATCA and receives back:
  /// - Compliance certificate (X.509) as binarySecurityToken
  /// - CSID (requestID)
  /// - Secret for API authentication
  ///
  /// [csrBase64] The base64-encoded PKCS#10 CSR
  /// [otp] One-time password provided by ZATCA during onboarding
  Future<ComplianceCsidResponse> requestComplianceCsid({
    required String csrBase64,
    required String otp,
  }) async {
    try {
      final response = await _client.requestComplianceCsid(
        csrBase64: csrBase64,
        otp: otp,
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      final statusCode = response.statusCode ?? 0;
      final isSuccess = statusCode == 200;

      if (isSuccess) {
        // ZATCA returns:
        // - binarySecurityToken: base64-encoded X.509 certificate
        // - requestID: the compliance CSID
        // - secret: API authentication secret
        // - tokenType: should be "http://docs.oasis-open.org/wss/2004/01/..."
        final binaryToken = data['binarySecurityToken'] as String?;
        final requestId = data['requestID'] as String?;
        final secret = data['secret'] as String?;

        // The binarySecurityToken is the base64 of the certificate DER bytes,
        // which also serves as the username for Basic auth
        return ComplianceCsidResponse(
          isSuccess: true,
          binarySecurityToken: binaryToken,
          csid: requestId,
          secret: secret,
          requestId: requestId,
        );
      }

      return ComplianceCsidResponse(
        isSuccess: false,
        errorMessage: _extractErrorMessage(data),
      );
    } on ZatcaApiException catch (e) {
      return ComplianceCsidResponse(isSuccess: false, errorMessage: e.message);
    } catch (e) {
      return ComplianceCsidResponse(
        isSuccess: false,
        errorMessage: 'Unexpected error during CSID request: $e',
      );
    }
  }

  /// Submit a test invoice for compliance validation
  ///
  /// This is Step 2 of the onboarding process.
  /// Must submit at least one of each invoice type:
  /// - Standard invoice (388, sub-type 0100000)
  /// - Simplified invoice (388, sub-type 0200000)
  /// - Standard credit note (381, sub-type 0100000)
  /// - Simplified credit note (381, sub-type 0200000)
  /// - Standard debit note (383, sub-type 0100000)
  /// - Simplified debit note (383, sub-type 0200000)
  Future<ZatcaResponse> submitComplianceInvoice({
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
    required CertificateInfo complianceCertificate,
  }) async {
    return _client.checkCompliance(
      signedXmlBase64: signedXmlBase64,
      invoiceHash: invoiceHash,
      uuid: uuid,
      certificate: complianceCertificate,
    );
  }

  /// Request a Production CSID after successful compliance checks
  ///
  /// This is Step 3 of the onboarding process.
  /// Exchanges the compliance CSID for a production CSID.
  /// The compliance certificate must have passed all invoice checks.
  Future<ProductionCsidResponse> requestProductionCsid({
    required String complianceCsid,
    required CertificateInfo complianceCertificate,
  }) async {
    try {
      final response = await _client.requestProductionCsid(
        complianceRequestId: complianceCsid,
        complianceCertificate: complianceCertificate,
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      final statusCode = response.statusCode ?? 0;
      final isSuccess = statusCode == 200;

      if (isSuccess) {
        final binaryToken = data['binarySecurityToken'] as String?;
        final requestId = data['requestID'] as String?;
        final secret = data['secret'] as String?;

        return ProductionCsidResponse(
          isSuccess: true,
          binarySecurityToken: binaryToken,
          csid: requestId,
          secret: secret,
          requestId: requestId,
        );
      }

      return ProductionCsidResponse(
        isSuccess: false,
        errorMessage: _extractErrorMessage(data),
      );
    } on ZatcaApiException catch (e) {
      return ProductionCsidResponse(isSuccess: false, errorMessage: e.message);
    } catch (e) {
      return ProductionCsidResponse(
        isSuccess: false,
        errorMessage: 'Unexpected error during production CSID request: $e',
      );
    }
  }

  /// Extract an error message from ZATCA error response JSON
  String _extractErrorMessage(Map<String, dynamic> data) {
    // ZATCA error responses may contain:
    // - message: top-level error message
    // - errors: list of detailed error objects
    final message = data['message'] as String?;
    if (message != null) return message;

    final errors = data['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      return errors
          .map((e) => e is Map ? e['message'] ?? e.toString() : e.toString())
          .join('; ');
    }

    return 'Unknown compliance API error';
  }
}

/// Response from Compliance CSID request
class ComplianceCsidResponse {
  final bool isSuccess;

  /// Base64-encoded X.509 certificate (also used as Basic auth username)
  final String? binarySecurityToken;

  /// Compliance Security Identifier (request ID)
  final String? csid;

  /// API authentication secret
  final String? secret;

  /// Request ID (same as csid, kept for clarity)
  final String? requestId;

  /// Error message if request failed
  final String? errorMessage;

  const ComplianceCsidResponse({
    required this.isSuccess,
    this.binarySecurityToken,
    this.csid,
    this.secret,
    this.requestId,
    this.errorMessage,
  });
}

/// Response from Production CSID request
class ProductionCsidResponse {
  final bool isSuccess;

  /// Base64-encoded X.509 production certificate
  final String? binarySecurityToken;

  /// Production Security Identifier
  final String? csid;

  /// API authentication secret
  final String? secret;

  /// Request ID
  final String? requestId;

  /// Error message if request failed
  final String? errorMessage;

  const ProductionCsidResponse({
    required this.isSuccess,
    this.binarySecurityToken,
    this.csid,
    this.secret,
    this.requestId,
    this.errorMessage,
  });
}
