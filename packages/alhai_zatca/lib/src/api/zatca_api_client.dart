import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:alhai_zatca/src/api/zatca_endpoints.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';

/// Low-level HTTP client for ZATCA API communication
///
/// Handles authentication, request formatting, and response parsing
/// for all ZATCA API endpoints.
class ZatcaApiClient {
  final Dio _dio;
  final ZatcaEnvironment _environment;

  ZatcaApiClient({required ZatcaEnvironment environment, Dio? dio})
    : _environment = environment,
      _dio = dio ?? Dio() {
    _dio.options.headers['Accept-Language'] = 'ar';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept-Version'] = 'V2';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// The current API environment
  ZatcaEnvironment get environment => _environment;

  /// Expose Dio for testing / interceptor attachment
  Dio get dio => _dio;

  // ─── Invoice Submission ─────────────────────────────────────

  /// Submit an invoice for reporting (simplified/B2C)
  Future<ZatcaResponse> reportInvoice({
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
    required CertificateInfo certificate,
  }) async {
    return _postInvoice(
      endpoint: ZatcaEndpoints.reporting,
      signedXmlBase64: signedXmlBase64,
      invoiceHash: invoiceHash,
      uuid: uuid,
      certificate: certificate,
    );
  }

  /// Submit an invoice for clearance (standard/B2B)
  Future<ZatcaResponse> clearInvoice({
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
    required CertificateInfo certificate,
  }) async {
    return _postInvoice(
      endpoint: ZatcaEndpoints.clearance,
      signedXmlBase64: signedXmlBase64,
      invoiceHash: invoiceHash,
      uuid: uuid,
      certificate: certificate,
      extraHeaders: {'Clearance-Status': '1'},
    );
  }

  /// Submit an invoice for compliance check
  Future<ZatcaResponse> checkCompliance({
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
    required CertificateInfo certificate,
  }) async {
    return _postInvoice(
      endpoint: ZatcaEndpoints.complianceCheck,
      signedXmlBase64: signedXmlBase64,
      invoiceHash: invoiceHash,
      uuid: uuid,
      certificate: certificate,
    );
  }

  // ─── CSID Operations ───────────────────────────────────────

  /// Request a Compliance CSID by submitting a CSR
  ///
  /// The OTP is a one-time password provided by ZATCA during onboarding.
  Future<Response> requestComplianceCsid({
    required String csrBase64,
    required String otp,
  }) async {
    final url = _url(ZatcaEndpoints.complianceCsid);
    try {
      final response = await _dio.post(
        url,
        data: {'csr': csrBase64},
        options: Options(
          headers: {
            'OTP': otp,
            'Accept-Version': 'V2',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw ZatcaApiException(
        message: 'Failed to request compliance CSID: ${e.message}',
        statusCode: e.response?.statusCode,
        responseData: e.response?.data,
      );
    }
  }

  /// Request a Production CSID using the compliance request ID
  Future<Response> requestProductionCsid({
    required String complianceRequestId,
    required CertificateInfo complianceCertificate,
  }) async {
    final url = _url(ZatcaEndpoints.productionCsid);
    try {
      final response = await _dio.post(
        url,
        data: {'compliance_request_id': complianceRequestId},
        options: Options(
          headers: {
            'Authorization': _buildAuthHeader(complianceCertificate),
            'Accept-Version': 'V2',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw ZatcaApiException(
        message: 'Failed to request production CSID: ${e.message}',
        statusCode: e.response?.statusCode,
        responseData: e.response?.data,
      );
    }
  }

  /// Renew a Production CSID before it expires
  Future<Response> renewProductionCsid({
    required String csrBase64,
    required String otp,
    required CertificateInfo currentCertificate,
  }) async {
    final url = _url(ZatcaEndpoints.renewProductionCsid);
    try {
      final response = await _dio.patch(
        url,
        data: {'csr': csrBase64},
        options: Options(
          headers: {
            'OTP': otp,
            'Authorization': _buildAuthHeader(currentCertificate),
            'Accept-Version': 'V2',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw ZatcaApiException(
        message: 'Failed to renew production CSID: ${e.message}',
        statusCode: e.response?.statusCode,
        responseData: e.response?.data,
      );
    }
  }

  // ─── Internal Helpers ──────────────────────────────────────

  /// Common POST logic for all invoice submission endpoints
  Future<ZatcaResponse> _postInvoice({
    required String endpoint,
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
    required CertificateInfo certificate,
    Map<String, String>? extraHeaders,
  }) async {
    final url = _url(endpoint);
    final body = _buildInvoiceBody(
      signedXmlBase64: signedXmlBase64,
      invoiceHash: invoiceHash,
      uuid: uuid,
    );

    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          headers: {
            'Authorization': _buildAuthHeader(certificate),
            ...?extraHeaders,
          },
          // Don't throw on 4xx so we can parse validation errors
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final jsonData = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      return ZatcaResponse.fromJson(jsonData, response.statusCode ?? 0);
    } on DioException catch (e) {
      // 5xx or network error
      return ZatcaResponse.failure(
        message: _formatDioError(e),
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  /// Build Basic Auth header from CSID binary token and secret
  ///
  /// ZATCA expects: `Basic base64(binarySecurityToken:secret)`
  /// where binarySecurityToken is the base64-encoded certificate (CSID).
  String _buildAuthHeader(CertificateInfo certificate) {
    final credentials = '${certificate.csid}:${certificate.secret}';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  /// Build the request body for invoice submission
  Map<String, dynamic> _buildInvoiceBody({
    required String signedXmlBase64,
    required String invoiceHash,
    required String uuid,
  }) {
    return {
      'invoiceHash': invoiceHash,
      'uuid': uuid,
      'invoice': signedXmlBase64,
    };
  }

  /// Get full URL for an endpoint
  String _url(String endpoint) =>
      ZatcaEndpoints.url(_environment.baseUrl, endpoint);

  /// Format a DioException into a readable error message
  String _formatDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout reaching ZATCA API';
      case DioExceptionType.sendTimeout:
        return 'Request timeout sending to ZATCA API';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout from ZATCA API';
      case DioExceptionType.connectionError:
        return 'Cannot connect to ZATCA API - check network';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        return 'ZATCA API returned error $status: ${e.response?.statusMessage}';
      default:
        return 'ZATCA API error: ${e.message}';
    }
  }
}

/// Exception thrown for ZATCA API errors that cannot be parsed
/// into a standard ZatcaResponse
class ZatcaApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  const ZatcaApiException({
    required this.message,
    this.statusCode,
    this.responseData,
  });

  @override
  String toString() => 'ZatcaApiException($statusCode): $message';
}
