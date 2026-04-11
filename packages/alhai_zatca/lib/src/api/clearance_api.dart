import 'package:alhai_zatca/src/api/zatca_api_client.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';

/// Handles ZATCA invoice clearance (standard/B2B invoices)
///
/// Standard invoices must be cleared by ZATCA before being
/// shared with the buyer. ZATCA validates the invoice and, if accepted,
/// returns a cryptographically stamped version that replaces the original.
///
/// Clearance workflow:
/// 1. Sign the invoice locally (XML + XAdES)
/// 2. Encode the signed XML as base64
/// 3. POST to /invoices/clearance/single with Clearance-Status: 1
/// 4. On success, ZATCA returns the stamped XML in clearedInvoice field
/// 5. The stamped XML must be used for all downstream operations (print, share, QR)
class ClearanceApi {
  final ZatcaApiClient _client;

  ClearanceApi({required ZatcaApiClient client}) : _client = client;

  /// Submit a standard (B2B) invoice for clearance
  ///
  /// Returns [ZatcaResponse] with:
  /// - clearanceStatus: CLEARED or NOT_CLEARED
  /// - clearedInvoiceXml: the ZATCA-stamped invoice (base64 XML)
  /// - validationResults: any warnings or errors
  /// - statusCode: 200 (cleared), 202 (cleared with warnings), 400 (rejected)
  Future<ZatcaResponse> clearInvoice({
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
    required CertificateInfo certificate,
  }) async {
    return _client.clearInvoice(
      signedXmlBase64: signedXmlBase64,
      invoiceHash: invoiceHash,
      uuid: uuid,
      certificate: certificate,
    );
  }

  /// Submit a standard invoice and extract the cleared XML
  ///
  /// Returns the ZATCA-stamped invoice XML (base64) if clearance succeeds,
  /// or null if rejected.
  Future<ClearanceResult> clearAndGetStampedXml({
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
    required CertificateInfo certificate,
  }) async {
    final response = await clearInvoice(
      signedXmlBase64: signedXmlBase64,
      invoiceHash: invoiceHash,
      uuid: uuid,
      certificate: certificate,
    );

    return ClearanceResult(
      response: response,
      stampedXmlBase64: response.isSuccess ? response.clearedInvoiceXml : null,
    );
  }

  /// Submit with retry for transient failures (5xx, network errors)
  ///
  /// Does NOT retry 4xx rejections. Uses exponential backoff.
  Future<ClearanceResult> clearWithRetry({
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
    required CertificateInfo certificate,
    int maxRetries = 3,
  }) async {
    var attempts = 0;
    ZatcaResponse? lastResponse;

    while (attempts <= maxRetries) {
      try {
        lastResponse = await clearInvoice(
          signedXmlBase64: signedXmlBase64,
          invoiceHash: invoiceHash,
          uuid: uuid,
          certificate: certificate,
        );

        // Success or validation rejection -- don't retry
        if (lastResponse.isSuccess || lastResponse.statusCode == 400) {
          break;
        }

        // Server error -- retry after delay
        attempts++;
        if (attempts <= maxRetries) {
          await Future<void>.delayed(Duration(seconds: 1 << attempts));
        }
      } catch (e) {
        lastResponse = ZatcaResponse.failure(message: e.toString());
        attempts++;
        if (attempts <= maxRetries) {
          await Future<void>.delayed(Duration(seconds: 1 << attempts));
        }
      }
    }

    final finalResponse =
        lastResponse ?? ZatcaResponse.failure(message: 'No response');

    return ClearanceResult(
      response: finalResponse,
      stampedXmlBase64: finalResponse.isSuccess
          ? finalResponse.clearedInvoiceXml
          : null,
    );
  }
}

/// Result of a clearance operation
class ClearanceResult {
  /// Full ZATCA response
  final ZatcaResponse response;

  /// The ZATCA-stamped invoice XML (base64), or null if not cleared
  final String? stampedXmlBase64;

  const ClearanceResult({required this.response, this.stampedXmlBase64});

  /// Whether the invoice was successfully cleared
  bool get isCleared => response.isSuccess && stampedXmlBase64 != null;

  /// Validation warnings (invoice cleared but with notes)
  List<ZatcaValidationResult> get warnings => response.warnings;

  /// Validation errors (invoice NOT cleared)
  List<ZatcaValidationResult> get errors => response.errors;
}
