import 'package:alhai_zatca/src/models/reporting_status.dart';

/// Response from ZATCA API after invoice submission
class ZatcaResponse {
  /// Whether the submission was accepted
  final bool isSuccess;

  /// HTTP status code
  final int statusCode;

  /// ZATCA reporting status
  final ReportingStatus reportingStatus;

  /// Clearance status (for standard invoices)
  final String? clearanceStatus;

  /// Signed invoice XML returned by ZATCA (for clearance)
  final String? clearedInvoiceXml;

  /// Validation results - warnings
  final List<ZatcaValidationResult> warnings;

  /// Validation results - errors
  final List<ZatcaValidationResult> errors;

  /// Raw response body for debugging
  final String? rawResponse;

  const ZatcaResponse({
    required this.isSuccess,
    required this.statusCode,
    required this.reportingStatus,
    this.clearanceStatus,
    this.clearedInvoiceXml,
    this.warnings = const [],
    this.errors = const [],
    this.rawResponse,
  });

  /// Parse from ZATCA API JSON response
  factory ZatcaResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    final validationResults =
        json['validationResults'] as Map<String, dynamic>?;

    final warnings = <ZatcaValidationResult>[];
    final errors = <ZatcaValidationResult>[];

    if (validationResults != null) {
      final warningMessages =
          validationResults['warningMessages'] as List<dynamic>? ?? [];
      for (final w in warningMessages) {
        warnings.add(ZatcaValidationResult.fromJson(w as Map<String, dynamic>));
      }
      final errorMessages =
          validationResults['errorMessages'] as List<dynamic>? ?? [];
      for (final e in errorMessages) {
        errors.add(ZatcaValidationResult.fromJson(e as Map<String, dynamic>));
      }
    }

    final isSuccess = statusCode == 200 || statusCode == 202;

    return ZatcaResponse(
      isSuccess: isSuccess,
      statusCode: statusCode,
      reportingStatus:
          isSuccess ? ReportingStatus.reported : ReportingStatus.rejected,
      clearanceStatus: json['clearanceStatus'] as String?,
      clearedInvoiceXml: json['clearedInvoice'] as String?,
      warnings: warnings,
      errors: errors,
    );
  }

  /// Create a failure response for network/parsing errors
  factory ZatcaResponse.failure({
    required String message,
    int statusCode = 0,
  }) {
    return ZatcaResponse(
      isSuccess: false,
      statusCode: statusCode,
      reportingStatus: ReportingStatus.failed,
      errors: [
        ZatcaValidationResult(
          type: 'ERROR',
          code: 'LOCAL_ERROR',
          message: message,
        ),
      ],
    );
  }
}

/// Individual validation result from ZATCA
class ZatcaValidationResult {
  final String type;
  final String code;
  final String? category;
  final String message;

  const ZatcaValidationResult({
    required this.type,
    required this.code,
    this.category,
    required this.message,
  });

  factory ZatcaValidationResult.fromJson(Map<String, dynamic> json) {
    return ZatcaValidationResult(
      type: json['type'] as String? ?? 'ERROR',
      code: json['code'] as String? ?? '',
      category: json['category'] as String?,
      message: json['message'] as String? ?? '',
    );
  }

  @override
  String toString() => '[$type] $code: $message';
}
