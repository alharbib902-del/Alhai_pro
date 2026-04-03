import 'package:alhai_zatca/src/api/zatca_api_client.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';

/// Handles ZATCA invoice reporting (simplified/B2C invoices)
///
/// Simplified invoices are reported to ZATCA asynchronously.
/// ZATCA returns acceptance (200/202) or rejection with validation errors
/// but does not modify the invoice.
///
/// Reporting workflow:
/// 1. Sign the invoice locally (XML + XAdES)
/// 2. Encode the signed XML as base64
/// 3. POST to /invoices/reporting/single
/// 4. Check response for REPORTED / NOT_REPORTED status
class ReportingApi {
  final ZatcaApiClient _client;

  ReportingApi({required ZatcaApiClient client}) : _client = client;

  /// Report a simplified (B2C) invoice to ZATCA
  ///
  /// Returns [ZatcaResponse] with:
  /// - reportingStatus: REPORTED or NOT_REPORTED
  /// - validationResults: any warnings or errors
  /// - statusCode: 200 (accepted), 202 (accepted with warnings), 400 (rejected)
  Future<ZatcaResponse> reportInvoice({
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
    required CertificateInfo certificate,
  }) async {
    return _client.reportInvoice(
      signedXmlBase64: signedXmlBase64,
      invoiceHash: invoiceHash,
      uuid: uuid,
      certificate: certificate,
    );
  }

  /// Report a batch of simplified invoices sequentially
  ///
  /// Sends invoices one at a time, collecting responses. Continues
  /// even if individual invoices are rejected, so the caller can
  /// inspect per-invoice results.
  ///
  /// For offline queued invoices, use [reportBatchWithRetry] instead.
  Future<List<ZatcaResponse>> reportBatch({
    required List<ReportingRequest> requests,
    required CertificateInfo certificate,
  }) async {
    final responses = <ZatcaResponse>[];
    for (final request in requests) {
      try {
        final response = await reportInvoice(
          signedXmlBase64: request.signedXmlBase64,
          invoiceHash: request.invoiceHash,
          uuid: request.uuid,
          certificate: certificate,
        );
        responses.add(response);
      } catch (e) {
        responses.add(ZatcaResponse.failure(message: e.toString()));
      }
    }
    return responses;
  }

  /// Report a batch with retry logic for transient failures
  ///
  /// Retries failed requests (network errors, 5xx) up to [maxRetries] times
  /// with exponential backoff. Does NOT retry 4xx rejections (validation errors).
  Future<List<ReportingResult>> reportBatchWithRetry({
    required List<ReportingRequest> requests,
    required CertificateInfo certificate,
    int maxRetries = 3,
  }) async {
    final results = <ReportingResult>[];

    for (final request in requests) {
      var attempts = 0;
      ZatcaResponse? lastResponse;

      while (attempts <= maxRetries) {
        try {
          lastResponse = await reportInvoice(
            signedXmlBase64: request.signedXmlBase64,
            invoiceHash: request.invoiceHash,
            uuid: request.uuid,
            certificate: certificate,
          );

          // Success or validation rejection -- don't retry
          if (lastResponse.isSuccess || lastResponse.statusCode == 400) {
            break;
          }

          // Server error -- retry after delay
          attempts++;
          if (attempts <= maxRetries) {
            await Future<void>.delayed(
              Duration(seconds: _backoffSeconds(attempts)),
            );
          }
        } catch (e) {
          lastResponse = ZatcaResponse.failure(message: e.toString());
          attempts++;
          if (attempts <= maxRetries) {
            await Future<void>.delayed(
              Duration(seconds: _backoffSeconds(attempts)),
            );
          }
        }
      }

      results.add(ReportingResult(
        request: request,
        response: lastResponse ?? ZatcaResponse.failure(message: 'No response'),
        attempts: attempts,
      ));
    }

    return results;
  }

  /// Exponential backoff: 2^attempt seconds (2, 4, 8, ...)
  int _backoffSeconds(int attempt) => 1 << attempt;
}

/// Request data for reporting a single invoice
class ReportingRequest {
  final String signedXmlBase64;
  final String invoiceHash;
  final String uuid;

  const ReportingRequest({
    required this.signedXmlBase64,
    required this.invoiceHash,
    required this.uuid,
  });
}

/// Result of a single reporting attempt (includes retry info)
class ReportingResult {
  final ReportingRequest request;
  final ZatcaResponse response;
  final int attempts;

  const ReportingResult({
    required this.request,
    required this.response,
    required this.attempts,
  });

  bool get isSuccess => response.isSuccess;
  bool get wasRetried => attempts > 1;
}
