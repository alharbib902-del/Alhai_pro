import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';

void main() {
  group('ZatcaResponse', () {
    // ── Construction ─────────────────────────────────────

    group('construction', () {
      test('creates with minimal required fields', () {
        const response = ZatcaResponse(
          isSuccess: true,
          statusCode: 200,
          reportingStatus: ReportingStatus.reported,
        );

        expect(response.isSuccess, isTrue);
        expect(response.statusCode, 200);
        expect(response.reportingStatus, ReportingStatus.reported);
        expect(response.clearanceStatus, isNull);
        expect(response.clearedInvoiceXml, isNull);
        expect(response.warnings, isEmpty);
        expect(response.errors, isEmpty);
        expect(response.rawResponse, isNull);
      });

      test('stores optional fields when provided', () {
        const response = ZatcaResponse(
          isSuccess: true,
          statusCode: 200,
          reportingStatus: ReportingStatus.cleared,
          clearanceStatus: 'CLEARED',
          clearedInvoiceXml: '<Invoice/>',
          rawResponse: '{"ok": true}',
        );

        expect(response.clearanceStatus, 'CLEARED');
        expect(response.clearedInvoiceXml, '<Invoice/>');
        expect(response.rawResponse, '{"ok": true}');
      });

      test('default warnings and errors are empty const lists', () {
        const response = ZatcaResponse(
          isSuccess: true,
          statusCode: 200,
          reportingStatus: ReportingStatus.reported,
        );
        expect(response.warnings, isA<List<ZatcaValidationResult>>());
        expect(response.errors, isA<List<ZatcaValidationResult>>());
      });
    });

    // ── fromJson ─────────────────────────────────────────

    group('fromJson', () {
      test('treats HTTP 200 as success and reports as reported', () {
        final response = ZatcaResponse.fromJson({}, 200);
        expect(response.isSuccess, isTrue);
        expect(response.statusCode, 200);
        expect(response.reportingStatus, ReportingStatus.reported);
      });

      test('treats HTTP 202 as success', () {
        final response = ZatcaResponse.fromJson({}, 202);
        expect(response.isSuccess, isTrue);
        expect(response.reportingStatus, ReportingStatus.reported);
      });

      test('treats HTTP 400 as rejection', () {
        final response = ZatcaResponse.fromJson({}, 400);
        expect(response.isSuccess, isFalse);
        expect(response.statusCode, 400);
        expect(response.reportingStatus, ReportingStatus.rejected);
      });

      test('treats HTTP 500 as rejection', () {
        final response = ZatcaResponse.fromJson({}, 500);
        expect(response.isSuccess, isFalse);
        expect(response.reportingStatus, ReportingStatus.rejected);
      });

      test('parses warning messages into warnings list', () {
        final json = {
          'validationResults': {
            'warningMessages': [
              {
                'type': 'WARNING',
                'code': 'W-001',
                'category': 'BR',
                'message': 'Minor issue',
              },
              {
                'type': 'WARNING',
                'code': 'W-002',
                'message': 'Another warning',
              },
            ],
          },
        };
        final response = ZatcaResponse.fromJson(json, 200);

        expect(response.warnings.length, 2);
        expect(response.warnings[0].code, 'W-001');
        expect(response.warnings[0].category, 'BR');
        expect(response.warnings[0].message, 'Minor issue');
        expect(response.warnings[1].code, 'W-002');
        expect(response.errors, isEmpty);
      });

      test('parses error messages into errors list', () {
        final json = {
          'validationResults': {
            'errorMessages': [
              {
                'type': 'ERROR',
                'code': 'E-001',
                'message': 'Invalid VAT number',
              },
            ],
          },
        };
        final response = ZatcaResponse.fromJson(json, 400);

        expect(response.errors.length, 1);
        expect(response.errors[0].code, 'E-001');
        expect(response.errors[0].message, 'Invalid VAT number');
        expect(response.warnings, isEmpty);
      });

      test('parses both warnings and errors', () {
        final json = {
          'validationResults': {
            'warningMessages': [
              {'type': 'WARNING', 'code': 'W-001', 'message': 'Warn'},
            ],
            'errorMessages': [
              {'type': 'ERROR', 'code': 'E-001', 'message': 'Err'},
            ],
          },
        };
        final response = ZatcaResponse.fromJson(json, 400);
        expect(response.warnings.length, 1);
        expect(response.errors.length, 1);
      });

      test('handles missing validationResults gracefully', () {
        final response = ZatcaResponse.fromJson({'foo': 'bar'}, 200);
        expect(response.warnings, isEmpty);
        expect(response.errors, isEmpty);
      });

      test('handles missing warningMessages and errorMessages keys', () {
        final json = {
          'validationResults': <String, dynamic>{},
        };
        final response = ZatcaResponse.fromJson(json, 200);
        expect(response.warnings, isEmpty);
        expect(response.errors, isEmpty);
      });

      test('parses clearanceStatus and clearedInvoice', () {
        final json = {
          'clearanceStatus': 'CLEARED',
          'clearedInvoice': '<Invoice xmlns="..."/>',
        };
        final response = ZatcaResponse.fromJson(json, 200);
        expect(response.clearanceStatus, 'CLEARED');
        expect(response.clearedInvoiceXml, '<Invoice xmlns="..."/>');
      });
    });

    // ── failure factory ──────────────────────────────────

    group('failure factory', () {
      test('creates a failed response with the given message', () {
        final response =
            ZatcaResponse.failure(message: 'Connection timed out');

        expect(response.isSuccess, isFalse);
        expect(response.statusCode, 0);
        expect(response.reportingStatus, ReportingStatus.failed);
        expect(response.errors.length, 1);
        expect(response.errors[0].type, 'ERROR');
        expect(response.errors[0].code, 'LOCAL_ERROR');
        expect(response.errors[0].message, 'Connection timed out');
      });

      test('allows custom status code', () {
        final response = ZatcaResponse.failure(
          message: 'Not found',
          statusCode: 404,
        );
        expect(response.statusCode, 404);
        expect(response.reportingStatus, ReportingStatus.failed);
      });

      test('failure response has no warnings', () {
        final response = ZatcaResponse.failure(message: 'Oops');
        expect(response.warnings, isEmpty);
      });
    });
  });

  group('ZatcaValidationResult', () {
    // ── Construction ─────────────────────────────────────

    group('construction', () {
      test('stores all fields correctly', () {
        const result = ZatcaValidationResult(
          type: 'ERROR',
          code: 'E-001',
          category: 'BR',
          message: 'Invalid value',
        );
        expect(result.type, 'ERROR');
        expect(result.code, 'E-001');
        expect(result.category, 'BR');
        expect(result.message, 'Invalid value');
      });

      test('category is optional', () {
        const result = ZatcaValidationResult(
          type: 'WARNING',
          code: 'W-002',
          message: 'Hint',
        );
        expect(result.category, isNull);
      });
    });

    // ── fromJson ─────────────────────────────────────────

    group('fromJson', () {
      test('parses all fields from complete JSON', () {
        final result = ZatcaValidationResult.fromJson({
          'type': 'ERROR',
          'code': 'E-999',
          'category': 'BR-KSA',
          'message': 'Bad data',
        });
        expect(result.type, 'ERROR');
        expect(result.code, 'E-999');
        expect(result.category, 'BR-KSA');
        expect(result.message, 'Bad data');
      });

      test('defaults type to ERROR when missing', () {
        final result = ZatcaValidationResult.fromJson({
          'code': 'X',
          'message': 'Y',
        });
        expect(result.type, 'ERROR');
      });

      test('defaults code to empty string when missing', () {
        final result = ZatcaValidationResult.fromJson({
          'type': 'WARNING',
          'message': 'Hint',
        });
        expect(result.code, '');
      });

      test('defaults message to empty string when missing', () {
        final result = ZatcaValidationResult.fromJson({
          'type': 'ERROR',
          'code': 'E-001',
        });
        expect(result.message, '');
      });

      test('category stays null when missing', () {
        final result = ZatcaValidationResult.fromJson({
          'type': 'ERROR',
          'code': 'E-001',
          'message': 'm',
        });
        expect(result.category, isNull);
      });
    });

    // ── toString ─────────────────────────────────────────

    group('toString', () {
      test('formats as [type] code: message', () {
        const result = ZatcaValidationResult(
          type: 'ERROR',
          code: 'E-001',
          message: 'Invalid VAT number',
        );
        expect(result.toString(), '[ERROR] E-001: Invalid VAT number');
      });

      test('does not throw for minimal values', () {
        const result = ZatcaValidationResult(
          type: 'WARNING',
          code: '',
          message: '',
        );
        expect(result.toString(), '[WARNING] : ');
      });
    });
  });
}
