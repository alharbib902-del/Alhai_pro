import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_zatca/src/certificate/certificate_renewal_service.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/certificate/csid_onboarding_service.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';

// ── Mocks ──────────────────────────────────────────────────

class MockCertificateStorage extends Mock implements CertificateStorage {}

class MockCsidOnboardingService extends Mock implements CsidOnboardingService {}

// ── Fakes ──────────────────────────────────────────────────

class FakeCertificateInfo extends Fake implements CertificateInfo {}

class FakeCsrConfig extends Fake implements CsrConfig {}

void main() {
  late CertificateRenewalService service;
  late MockCertificateStorage mockStorage;
  late MockCsidOnboardingService mockOnboardingService;

  const storeId = 'store-1';

  // Helper to create certificates with different expiry dates
  CertificateInfo certWithValidity({
    required int daysUntilExpiry,
    bool isProduction = true,
  }) {
    return CertificateInfo(
      certificatePem: 'cert-pem',
      privateKeyPem: 'key-pem',
      csid: 'csid',
      secret: 'secret',
      isProduction: isProduction,
      validTo: DateTime.now().add(Duration(days: daysUntilExpiry)),
    );
  }

  final validCert = certWithValidity(daysUntilExpiry: 180);
  final nearExpiryCert = certWithValidity(daysUntilExpiry: 15);
  final expiredCert = certWithValidity(daysUntilExpiry: -10);
  const noExpiryCert = CertificateInfo(
    certificatePem: 'cert-pem',
    privateKeyPem: 'key-pem',
    csid: 'csid',
    secret: 'secret',
    isProduction: true,
  );

  final renewedCert = CertificateInfo(
    certificatePem: 'renewed-cert-pem',
    privateKeyPem: 'renewed-key-pem',
    csid: 'new-csid',
    secret: 'new-secret',
    isProduction: true,
    validTo: DateTime.now().add(const Duration(days: 365)),
  );

  const testCsrConfig = CsrConfig(
    solutionName: 'AlhaiPOS',
    modelVersion: '1.0',
    serialNumber: 'SN-001',
    organizationName: 'Test Org',
    branchId: 'B001',
    branchLocation: 'Riyadh',
  );

  setUpAll(() {
    registerFallbackValue(FakeCertificateInfo());
    registerFallbackValue(FakeCsrConfig());
  });

  setUp(() {
    mockStorage = MockCertificateStorage();
    mockOnboardingService = MockCsidOnboardingService();

    service = CertificateRenewalService(
      storage: mockStorage,
      onboardingService: mockOnboardingService,
    );
  });

  tearDown(() {
    service.dispose();
  });

  group('CertificateRenewalService', () {
    // ── needsRenewal ─────────────────────────────────────

    group('needsRenewal', () {
      test('returns true when certificate is missing', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => null);

        final needs = await service.needsRenewal(storeId: storeId);
        expect(needs, isTrue);
      });

      test('returns true when certificate is expired', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => expiredCert);

        final needs = await service.needsRenewal(storeId: storeId);
        expect(needs, isTrue);
      });

      test('returns true when certificate is near expiry', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => nearExpiryCert);

        final needs = await service.needsRenewal(storeId: storeId);
        expect(needs, isTrue);
      });

      test('returns false when certificate is valid and not near expiry',
          () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => validCert);

        final needs = await service.needsRenewal(storeId: storeId);
        expect(needs, isFalse);
      });
    });

    // ── getStatus ────────────────────────────────────────

    group('getStatus', () {
      test('returns missing when no certificate exists', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => null);

        final status = await service.getStatus(storeId: storeId);
        expect(status, CertificateStatus.missing);
      });

      test('returns expired when certificate has expired', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => expiredCert);

        final status = await service.getStatus(storeId: storeId);
        expect(status, CertificateStatus.expired);
      });

      test('returns nearExpiry when certificate is close to expiration',
          () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => nearExpiryCert);

        final status = await service.getStatus(storeId: storeId);
        expect(status, CertificateStatus.nearExpiry);
      });

      test('returns valid when certificate is fresh', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => validCert);

        final status = await service.getStatus(storeId: storeId);
        expect(status, CertificateStatus.valid);
      });

      test('returns valid when certificate has no expiry date', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => noExpiryCert);

        final status = await service.getStatus(storeId: storeId);
        expect(status, CertificateStatus.valid);
      });
    });

    // ── getRenewalInfo ───────────────────────────────────

    group('getRenewalInfo', () {
      test('returns missing info when no certificate exists', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => null);

        final info = await service.getRenewalInfo(storeId: storeId);
        expect(info.status, CertificateStatus.missing);
        expect(info.daysUntilExpiry, isNull);
        expect(info.requiresOtp, isTrue);
      });

      test('returns detailed info for valid cert', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => validCert);

        final info = await service.getRenewalInfo(storeId: storeId);
        expect(info.status, CertificateStatus.valid);
        expect(info.daysUntilExpiry, greaterThan(0));
        expect(info.isProduction, isTrue);
        expect(info.requiresOtp, isFalse);
      });

      test('flags requiresOtp for expired certificate', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => expiredCert);

        final info = await service.getRenewalInfo(storeId: storeId);
        expect(info.status, CertificateStatus.expired);
        expect(info.requiresOtp, isTrue);
      });
    });

    // ── checkCertificate ─────────────────────────────────

    group('checkCertificate', () {
      test('reports missing status and needsAction when no cert', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => null);

        final result = await service.checkCertificate(storeId: storeId);
        expect(result.status, CertificateStatus.missing);
        expect(result.isHealthy, isFalse);
        expect(result.needsAction, isTrue);
        expect(result.message, contains('No certificate'));
      });

      test('reports expired status with renewal hint', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => expiredCert);

        final result = await service.checkCertificate(storeId: storeId);
        expect(result.status, CertificateStatus.expired);
        expect(result.isHealthy, isFalse);
        expect(result.needsAction, isTrue);
        expect(result.message.toLowerCase(), contains('expired'));
      });

      test('reports near expiry status with days remaining', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => nearExpiryCert);

        final result = await service.checkCertificate(storeId: storeId);
        expect(result.status, CertificateStatus.nearExpiry);
        expect(result.isHealthy, isFalse);
        expect(result.daysUntilExpiry, isNotNull);
        expect(result.message, contains('expires in'));
      });

      test('reports valid status as healthy', () async {
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => validCert);

        final result = await service.checkCertificate(storeId: storeId);
        expect(result.status, CertificateStatus.valid);
        expect(result.isHealthy, isTrue);
        expect(result.needsAction, isFalse);
        expect(result.message, contains('valid'));
      });
    });

    // ── renewCertificate ─────────────────────────────────

    group('renewCertificate', () {
      test('successful renewal triggers onRenewed callback', () async {
        when(() => mockOnboardingService.requestComplianceCsid(
              otp: any(named: 'otp'),
              config: any(named: 'config'),
            )).thenAnswer((_) async => validCert);
        when(() => mockOnboardingService.requestProductionCsid(
              complianceCertificate: any(named: 'complianceCertificate'),
            )).thenAnswer((_) async => renewedCert);
        when(() => mockStorage.saveCertificate(
              storeId: any(named: 'storeId'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async {});

        String? capturedStoreId;
        CertificateInfo? capturedCert;
        service.onRenewed = (sid, c) {
          capturedStoreId = sid;
          capturedCert = c;
        };

        final result = await service.renewCertificate(
          storeId: storeId,
          otp: '123456',
          csrConfig: testCsrConfig,
        );

        expect(result, renewedCert);
        expect(capturedStoreId, storeId);
        expect(capturedCert, renewedCert);
        verify(() => mockStorage.saveCertificate(
              storeId: storeId,
              certificate: renewedCert,
            )).called(1);
      });

      test('renewal failure propagates exception from onboarding', () async {
        when(() => mockOnboardingService.requestComplianceCsid(
              otp: any(named: 'otp'),
              config: any(named: 'config'),
            )).thenThrow(const OnboardingException(
          step: OnboardingStep.complianceCsid,
          message: 'Invalid OTP',
        ));

        expect(
          () => service.renewCertificate(
            storeId: storeId,
            otp: 'invalid',
            csrConfig: testCsrConfig,
          ),
          throwsA(isA<OnboardingException>()),
        );
      });

      test('does not trigger onRenewed when renewal fails', () async {
        when(() => mockOnboardingService.requestComplianceCsid(
              otp: any(named: 'otp'),
              config: any(named: 'config'),
            )).thenThrow(Exception('Network error'));

        var renewedCalled = false;
        service.onRenewed = (_, __) => renewedCalled = true;

        try {
          await service.renewCertificate(
            storeId: storeId,
            otp: '123456',
            csrConfig: testCsrConfig,
          );
        } catch (_) {
          // expected
        }

        expect(renewedCalled, isFalse);
      });
    });

    // ── Callbacks ────────────────────────────────────────

    group('callbacks', () {
      test('callbacks start null and can be assigned', () {
        expect(service.onNearExpiry, isNull);
        expect(service.onExpired, isNull);
        expect(service.onRenewed, isNull);
        expect(service.onRenewalFailed, isNull);

        service.onNearExpiry = (_, __) {};
        service.onExpired = (_) {};
        service.onRenewed = (_, __) {};
        service.onRenewalFailed = (_, __) {};

        expect(service.onNearExpiry, isNotNull);
        expect(service.onExpired, isNotNull);
        expect(service.onRenewed, isNotNull);
        expect(service.onRenewalFailed, isNotNull);
      });

      test('callbacks can be cleared by assigning null', () {
        service.onNearExpiry = (_, __) {};
        expect(service.onNearExpiry, isNotNull);

        service.onNearExpiry = null;
        expect(service.onNearExpiry, isNull);
      });
    });

    // ── startMonitoring ──────────────────────────────────

    group('startMonitoring', () {
      test('invokes onExpired for expired certificates', () async {
        when(() => mockStorage.listStoreIds())
            .thenAnswer((_) async => [storeId]);
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => expiredCert);

        String? expiredStoreId;
        service.onExpired = (sid) => expiredStoreId = sid;

        service.startMonitoring();
        // Give the immediate async check a chance to run
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        service.stopMonitoring();

        expect(expiredStoreId, storeId);
      });

      test('invokes onNearExpiry with days remaining', () async {
        when(() => mockStorage.listStoreIds())
            .thenAnswer((_) async => [storeId]);
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => nearExpiryCert);

        String? nearExpiryStoreId;
        int? daysRemaining;
        service.onNearExpiry = (sid, days) {
          nearExpiryStoreId = sid;
          daysRemaining = days;
        };

        service.startMonitoring();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        service.stopMonitoring();

        expect(nearExpiryStoreId, storeId);
        expect(daysRemaining, isNotNull);
        expect(daysRemaining, lessThan(30));
      });

      test('skips temporary compliance certificates (prefixed with _)',
          () async {
        when(() => mockStorage.listStoreIds())
            .thenAnswer((_) async => ['_compliance_temp']);
        when(() => mockStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => expiredCert);

        var onExpiredCalled = false;
        service.onExpired = (_) => onExpiredCalled = true;

        service.startMonitoring();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        service.stopMonitoring();

        expect(onExpiredCalled, isFalse);
      });

      test('does not throw when listStoreIds fails (silent monitoring)',
          () async {
        when(() => mockStorage.listStoreIds())
            .thenThrow(Exception('Storage corrupted'));

        // Should complete without throwing
        expect(() {
          service.startMonitoring();
          service.stopMonitoring();
        }, returnsNormally);
      });

      test('stopMonitoring cancels the timer', () {
        when(() => mockStorage.listStoreIds()).thenAnswer((_) async => []);

        service.startMonitoring();
        service.stopMonitoring();

        // Calling stop again should be safe
        expect(() => service.stopMonitoring(), returnsNormally);
      });
    });

    // ── dispose ──────────────────────────────────────────

    group('dispose', () {
      test('dispose stops monitoring', () {
        when(() => mockStorage.listStoreIds()).thenAnswer((_) async => []);

        service.startMonitoring();
        service.dispose();

        // After dispose, calling stopMonitoring is safe (no-op)
        expect(() => service.stopMonitoring(), returnsNormally);
      });

      test('dispose is safe to call without starting', () {
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}
