import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_zatca/src/api/compliance_api.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/certificate/csr_generator.dart';
import 'package:alhai_zatca/src/certificate/csid_onboarding_service.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/services/zatca_invoice_service.dart';

// ── Mocks ──────────────────────────────────────────────────

class MockCsrGenerator extends Mock implements CsrGenerator {}

class MockComplianceApi extends Mock implements ComplianceApi {}

class MockCertificateStorage extends Mock implements CertificateStorage {}

class MockZatcaInvoiceService extends Mock implements ZatcaInvoiceService {}

// ── Fakes ──────────────────────────────────────────────────

class FakeCertificateInfo extends Fake implements CertificateInfo {}

class FakeCsrConfig extends Fake implements CsrConfig {}

class FakeZatcaSeller extends Fake implements ZatcaSeller {}

void main() {
  late CsidOnboardingService service;
  late MockCsrGenerator mockCsrGenerator;
  late MockComplianceApi mockComplianceApi;
  late MockCertificateStorage mockStorage;

  const testConfig = CsrConfig(
    solutionName: 'AlhaiPOS',
    modelVersion: '1.0',
    serialNumber: 'SN-001',
    organizationName: 'Test Org',
    branchId: 'B001',
    branchLocation: 'Riyadh',
    invoiceType: '1100',
    industryCategory: 'Retail',
  );

  final testCsrResult = {
    'csr':
        '-----BEGIN CERTIFICATE REQUEST-----\nMIIBbase64content\n-----END CERTIFICATE REQUEST-----',
    'privateKey':
        '-----BEGIN EC PRIVATE KEY-----\nMIIBbase64key\n-----END EC PRIVATE KEY-----',
  };

  final complianceCert = CertificateInfo(
    certificatePem: 'compliance-cert-pem',
    privateKeyPem: 'private-key-pem',
    csid: 'compliance-csid-123',
    secret: 'compliance-secret',
    isProduction: false,
  );

  final productionCert = CertificateInfo(
    certificatePem: 'production-cert-pem',
    privateKeyPem: 'private-key-pem',
    csid: 'production-csid-456',
    secret: 'production-secret',
    isProduction: true,
  );

  setUpAll(() {
    registerFallbackValue(FakeCertificateInfo());
  });

  setUp(() {
    mockCsrGenerator = MockCsrGenerator();
    mockComplianceApi = MockComplianceApi();
    mockStorage = MockCertificateStorage();

    service = CsidOnboardingService(
      csrGenerator: mockCsrGenerator,
      complianceApi: mockComplianceApi,
      storage: mockStorage,
    );
  });

  group('CsidOnboardingService', () {
    // ── Step 1: requestComplianceCsid ───────────────────

    group('requestComplianceCsid', () {
      test('generates CSR and returns compliance certificate', () async {
        when(
          () => mockCsrGenerator.generateCsr(
            commonName: any(named: 'commonName'),
            organizationUnit: any(named: 'organizationUnit'),
            organizationName: any(named: 'organizationName'),
            country: any(named: 'country'),
            serialNumber: any(named: 'serialNumber'),
            invoiceType: any(named: 'invoiceType'),
            branchLocation: any(named: 'branchLocation'),
            industryBusinessCategory: any(named: 'industryBusinessCategory'),
          ),
        ).thenAnswer((_) async => testCsrResult);

        when(
          () => mockComplianceApi.requestComplianceCsid(
            csrBase64: any(named: 'csrBase64'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer(
          (_) async => const ComplianceCsidResponse(
            isSuccess: true,
            binarySecurityToken: 'compliance-cert-pem',
            csid: 'compliance-csid-123',
            secret: 'compliance-secret',
          ),
        );

        when(
          () => mockStorage.saveCertificate(
            storeId: any(named: 'storeId'),
            certificate: any(named: 'certificate'),
          ),
        ).thenAnswer((_) async {});

        final result = await service.requestComplianceCsid(
          otp: '123456',
          config: testConfig,
        );

        expect(result.csid, 'compliance-csid-123');
        expect(result.isProduction, isFalse);

        // Should save the compliance cert temporarily
        verify(
          () => mockStorage.saveCertificate(
            storeId: '_compliance_temp',
            certificate: any(named: 'certificate'),
          ),
        ).called(1);
      });

      test('throws OnboardingException when ZATCA rejects CSR', () async {
        when(
          () => mockCsrGenerator.generateCsr(
            commonName: any(named: 'commonName'),
            organizationUnit: any(named: 'organizationUnit'),
            organizationName: any(named: 'organizationName'),
            country: any(named: 'country'),
            serialNumber: any(named: 'serialNumber'),
            invoiceType: any(named: 'invoiceType'),
            branchLocation: any(named: 'branchLocation'),
            industryBusinessCategory: any(named: 'industryBusinessCategory'),
          ),
        ).thenAnswer((_) async => testCsrResult);

        when(
          () => mockComplianceApi.requestComplianceCsid(
            csrBase64: any(named: 'csrBase64'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer(
          (_) async => const ComplianceCsidResponse(
            isSuccess: false,
            errorMessage: 'Invalid OTP',
          ),
        );

        expect(
          () => service.requestComplianceCsid(
            otp: 'wrong-otp',
            config: testConfig,
          ),
          throwsA(
            isA<OnboardingException>().having(
              (e) => e.step,
              'step',
              OnboardingStep.complianceCsid,
            ),
          ),
        );
      });
    });

    // ── Step 3: requestProductionCsid ───────────────────

    group('requestProductionCsid', () {
      test('exchanges compliance cert for production cert', () async {
        when(
          () => mockComplianceApi.requestProductionCsid(
            complianceCsid: any(named: 'complianceCsid'),
            complianceCertificate: any(named: 'complianceCertificate'),
          ),
        ).thenAnswer(
          (_) async => const ProductionCsidResponse(
            isSuccess: true,
            binarySecurityToken: 'production-cert-pem',
            csid: 'production-csid-456',
            secret: 'production-secret',
          ),
        );

        final result = await service.requestProductionCsid(
          complianceCertificate: complianceCert,
        );

        expect(result.isProduction, isTrue);
        expect(result.csid, 'production-csid-456');
      });

      test(
        'throws OnboardingException when production CSID request fails',
        () async {
          when(
            () => mockComplianceApi.requestProductionCsid(
              complianceCsid: any(named: 'complianceCsid'),
              complianceCertificate: any(named: 'complianceCertificate'),
            ),
          ).thenAnswer(
            (_) async => const ProductionCsidResponse(
              isSuccess: false,
              errorMessage: 'Compliance checks not completed',
            ),
          );

          expect(
            () => service.requestProductionCsid(
              complianceCertificate: complianceCert,
            ),
            throwsA(
              isA<OnboardingException>().having(
                (e) => e.step,
                'step',
                OnboardingStep.productionCsid,
              ),
            ),
          );
        },
      );
    });

    // ── hasValidProductionCertificate ────────────────────

    group('hasValidProductionCertificate', () {
      test('returns true when valid production cert exists', () async {
        when(
          () => mockStorage.getCertificate(storeId: any(named: 'storeId')),
        ).thenAnswer((_) async => productionCert);

        final result = await service.hasValidProductionCertificate(
          storeId: 'store-1',
        );

        expect(result, isTrue);
      });

      test('returns false when no certificate exists', () async {
        when(
          () => mockStorage.getCertificate(storeId: any(named: 'storeId')),
        ).thenAnswer((_) async => null);

        final result = await service.hasValidProductionCertificate(
          storeId: 'store-1',
        );

        expect(result, isFalse);
      });

      test('returns false when certificate is not production', () async {
        when(
          () => mockStorage.getCertificate(storeId: any(named: 'storeId')),
        ).thenAnswer((_) async => complianceCert);

        final result = await service.hasValidProductionCertificate(
          storeId: 'store-1',
        );

        expect(result, isFalse);
      });

      test('returns false when production certificate is expired', () async {
        final expired = CertificateInfo(
          certificatePem: 'cert',
          privateKeyPem: 'key',
          csid: 'csid',
          secret: 'secret',
          isProduction: true,
          validTo: DateTime(2020, 1, 1),
        );
        when(
          () => mockStorage.getCertificate(storeId: any(named: 'storeId')),
        ).thenAnswer((_) async => expired);

        final result = await service.hasValidProductionCertificate(
          storeId: 'store-1',
        );

        expect(result, isFalse);
      });
    });
  });

  // ── OnboardingException ─────────────────────────────────

  group('OnboardingException', () {
    test('toString includes step name and message', () {
      const exception = OnboardingException(
        step: OnboardingStep.complianceCsid,
        message: 'Failed to connect',
      );

      expect(exception.toString(), contains('complianceCsid'));
      expect(exception.toString(), contains('Failed to connect'));
    });
  });

  // ── CsrConfig ───────────────────────────────────────────

  group('CsrConfig', () {
    test('has correct default values', () {
      const config = CsrConfig(
        solutionName: 'Test',
        modelVersion: '1.0',
        serialNumber: 'SN-1',
        organizationName: 'Org',
        branchId: 'B1',
        branchLocation: 'City',
      );

      expect(config.invoiceType, '1100');
      expect(config.industryCategory, 'Retail');
    });
  });

  // ── OnboardingResult ────────────────────────────────────

  group('OnboardingResult', () {
    test('allChecksPassed returns true when all responses succeed', () {
      final result = OnboardingResult(
        certificate: productionCert,
        complianceResponses: [
          const ZatcaResponse(
            isSuccess: true,
            statusCode: 200,
            reportingStatus: ReportingStatus.reported,
          ),
          const ZatcaResponse(
            isSuccess: true,
            statusCode: 200,
            reportingStatus: ReportingStatus.reported,
          ),
        ],
      );

      expect(result.allChecksPassed, isTrue);
    });

    test('allChecksPassed returns false when any response fails', () {
      final result = OnboardingResult(
        certificate: productionCert,
        complianceResponses: [
          const ZatcaResponse(
            isSuccess: true,
            statusCode: 200,
            reportingStatus: ReportingStatus.reported,
          ),
          ZatcaResponse.failure(message: 'Validation failed'),
        ],
      );

      expect(result.allChecksPassed, isFalse);
    });
  });
}
