import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_zatca/src/certificate/certificate_renewal_service.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/certificate/csid_onboarding_service.dart';
import 'package:alhai_zatca/src/chaining/invoice_chain_service.dart';
import 'package:alhai_zatca/src/di/zatca_module.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/providers/zatca_providers.dart';
import 'package:alhai_zatca/src/services/zatca_compliance_checker.dart';
import 'package:alhai_zatca/src/services/zatca_invoice_service.dart';
import 'package:alhai_zatca/src/services/zatca_offline_queue.dart';

// ── Mocks ──────────────────────────────────────────────────

class MockZatcaInvoiceService extends Mock implements ZatcaInvoiceService {}

class MockCsidOnboardingService extends Mock implements CsidOnboardingService {}

class MockCertificateRenewalService extends Mock
    implements CertificateRenewalService {}

class MockZatcaComplianceChecker extends Mock
    implements ZatcaComplianceChecker {}

class MockZatcaOfflineQueue extends Mock implements ZatcaOfflineQueue {}

class MockCertificateStorage extends Mock implements CertificateStorage {}

class MockInvoiceChainService extends Mock implements InvoiceChainService {}

// ── Test helpers ───────────────────────────────────────────

ZatcaInvoice buildInvoice({
  String subType = '0200000',
  String invoiceNumber = 'INV-001',
}) {
  return ZatcaInvoice(
    invoiceNumber: invoiceNumber,
    uuid: '550e8400-e29b-41d4-a716-446655440000',
    issueDate: DateTime(2026, 1, 15),
    issueTime: DateTime(2026, 1, 15, 14, 30),
    typeCode: InvoiceTypeCode.standard,
    subType: subType,
    seller: const ZatcaSeller(
      name: 'Test Store',
      vatNumber: '300000000000003',
      streetName: 'King Fahd Road',
      buildingNumber: '1234',
      city: 'Riyadh',
      postalCode: '12345',
    ),
    lines: [
      const ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Product',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      ),
    ],
  );
}

void main() {
  // Providers in `zatca_providers.dart` read from `GetIt.instance` (the
  // global singleton). Each test registers mocks on `GetIt.instance`,
  // resolves the provider via a fresh ProviderContainer, then resets
  // GetIt to avoid state leakage between tests.

  setUpAll(() {
    registerFallbackValue(buildInvoice());
  });

  setUp(() {
    // Start from a clean global GetIt instance
    GetIt.instance.reset();
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('zatcaInvoiceServiceProvider', () {
    test('resolves the service registered in GetIt', () {
      final mockService = MockZatcaInvoiceService();
      GetIt.instance.registerSingleton<ZatcaInvoiceService>(mockService);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final resolved = container.read(zatcaInvoiceServiceProvider);
      expect(identical(resolved, mockService), isTrue);
    });

    test('providers can be overridden in ProviderContainer', () {
      // Register one instance in GetIt
      final getItService = MockZatcaInvoiceService();
      GetIt.instance.registerSingleton<ZatcaInvoiceService>(getItService);

      // Override with a different instance via riverpod overrides
      final overrideService = MockZatcaInvoiceService();
      final container = ProviderContainer(
        overrides: [
          zatcaInvoiceServiceProvider.overrideWithValue(overrideService),
        ],
      );
      addTearDown(container.dispose);

      final resolved = container.read(zatcaInvoiceServiceProvider);
      expect(identical(resolved, overrideService), isTrue);
      expect(identical(resolved, getItService), isFalse);
    });
  });

  group('csidOnboardingServiceProvider', () {
    test('resolves CsidOnboardingService from GetIt', () {
      final mockService = MockCsidOnboardingService();
      GetIt.instance.registerSingleton<CsidOnboardingService>(mockService);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(csidOnboardingServiceProvider), mockService);
    });
  });

  group('certificateRenewalServiceProvider', () {
    test('resolves CertificateRenewalService from GetIt', () {
      final mockService = MockCertificateRenewalService();
      GetIt.instance.registerSingleton<CertificateRenewalService>(mockService);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(certificateRenewalServiceProvider), mockService);
    });
  });

  group('zatcaComplianceCheckerProvider', () {
    test('resolves ZatcaComplianceChecker from GetIt', () {
      final mockChecker = MockZatcaComplianceChecker();
      GetIt.instance.registerSingleton<ZatcaComplianceChecker>(mockChecker);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(zatcaComplianceCheckerProvider), mockChecker);
    });
  });

  group('zatcaOfflineQueueProvider', () {
    test('resolves ZatcaOfflineQueue from GetIt', () {
      final mockQueue = MockZatcaOfflineQueue();
      GetIt.instance.registerSingleton<ZatcaOfflineQueue>(mockQueue);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(zatcaOfflineQueueProvider), mockQueue);
    });
  });

  group('certificateStorageProvider', () {
    test('resolves CertificateStorage from GetIt', () {
      final mockStorage = MockCertificateStorage();
      GetIt.instance.registerSingleton<CertificateStorage>(mockStorage);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(certificateStorageProvider), mockStorage);
    });
  });

  group('invoiceChainServiceProvider', () {
    test('resolves InvoiceChainService from GetIt', () {
      final mockChain = MockInvoiceChainService();
      GetIt.instance.registerSingleton<InvoiceChainService>(mockChain);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(invoiceChainServiceProvider), mockChain);
    });
  });

  // ─── Async state providers ────────────────────────────────

  group('zatcaPendingCountProvider', () {
    test('returns pending count from queue', () async {
      final mockQueue = MockZatcaOfflineQueue();
      when(() => mockQueue.pendingCount).thenAnswer((_) async => 7);
      GetIt.instance.registerSingleton<ZatcaOfflineQueue>(mockQueue);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final count = await container.read(zatcaPendingCountProvider.future);
      expect(count, equals(7));
    });

    test('returns zero when queue is empty', () async {
      final mockQueue = MockZatcaOfflineQueue();
      when(() => mockQueue.pendingCount).thenAnswer((_) async => 0);
      GetIt.instance.registerSingleton<ZatcaOfflineQueue>(mockQueue);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final count = await container.read(zatcaPendingCountProvider.future);
      expect(count, equals(0));
    });
  });

  group('certificateStatusProvider (family)', () {
    test('passes storeId parameter to renewal service', () async {
      final mockRenewal = MockCertificateRenewalService();
      when(
        () => mockRenewal.getStatus(storeId: any(named: 'storeId')),
      ).thenAnswer((_) async => CertificateStatus.valid);
      GetIt.instance.registerSingleton<CertificateRenewalService>(mockRenewal);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final status = await container.read(
        certificateStatusProvider('store-abc').future,
      );
      expect(status, equals(CertificateStatus.valid));
      verify(() => mockRenewal.getStatus(storeId: 'store-abc')).called(1);
    });

    test('different storeIds produce independent results', () async {
      final mockRenewal = MockCertificateRenewalService();
      when(
        () => mockRenewal.getStatus(storeId: 'store-a'),
      ).thenAnswer((_) async => CertificateStatus.valid);
      when(
        () => mockRenewal.getStatus(storeId: 'store-b'),
      ).thenAnswer((_) async => CertificateStatus.expired);
      GetIt.instance.registerSingleton<CertificateRenewalService>(mockRenewal);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final a = await container.read(
        certificateStatusProvider('store-a').future,
      );
      final b = await container.read(
        certificateStatusProvider('store-b').future,
      );

      expect(a, equals(CertificateStatus.valid));
      expect(b, equals(CertificateStatus.expired));
    });
  });

  group('hasValidCertificateProvider (family)', () {
    test('delegates to CsidOnboardingService with storeId', () async {
      final mockOnboarding = MockCsidOnboardingService();
      when(
        () => mockOnboarding.hasValidProductionCertificate(
          storeId: any(named: 'storeId'),
        ),
      ).thenAnswer((_) async => true);
      GetIt.instance.registerSingleton<CsidOnboardingService>(mockOnboarding);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final hasValid = await container.read(
        hasValidCertificateProvider('main').future,
      );
      expect(hasValid, isTrue);
      verify(
        () => mockOnboarding.hasValidProductionCertificate(storeId: 'main'),
      ).called(1);
    });
  });

  group('zatcaFailedQueueProvider', () {
    test('returns failed invoices from queue', () async {
      final mockQueue = MockZatcaOfflineQueue();
      final failed = <QueuedInvoice>[
        QueuedInvoice(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'base64xml',
          invoiceHash: 'hash',
          uuid: 'uuid-1',
          isStandard: false,
          storeId: 'store-1',
          queuedAt: DateTime(2024, 1, 1),
          retryCount: 5,
        ),
      ];
      when(() => mockQueue.getFailedInvoices()).thenAnswer((_) async => failed);
      GetIt.instance.registerSingleton<ZatcaOfflineQueue>(mockQueue);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(zatcaFailedQueueProvider.future);
      expect(result, hasLength(1));
      expect(result.first.invoiceNumber, equals('INV-001'));
    });
  });

  // ─── Action providers ─────────────────────────────────────

  group('invoiceValidationProvider (family)', () {
    test('delegates to compliance checker with invoice', () {
      final mockChecker = MockZatcaComplianceChecker();
      const result = ComplianceResult(isValid: true, errors: []);
      when(() => mockChecker.check(any())).thenReturn(result);
      GetIt.instance.registerSingleton<ZatcaComplianceChecker>(mockChecker);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final invoice = buildInvoice();
      final got = container.read(invoiceValidationProvider(invoice));

      expect(got.isValid, isTrue);
      verify(() => mockChecker.check(invoice)).called(1);
    });

    test('returns errors from compliance checker', () {
      final mockChecker = MockZatcaComplianceChecker();
      const result = ComplianceResult(
        isValid: false,
        errors: [
          ComplianceError(
            code: 'BT-1',
            field: 'invoiceNumber',
            message: 'Invoice number is required',
            severity: ComplianceSeverity.error,
          ),
        ],
      );
      when(() => mockChecker.check(any())).thenReturn(result);
      GetIt.instance.registerSingleton<ZatcaComplianceChecker>(mockChecker);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final invoice = buildInvoice();
      final got = container.read(invoiceValidationProvider(invoice));

      expect(got.isValid, isFalse);
      expect(got.errors, isNotEmpty);
    });
  });

  // ─── Full DI wiring via ZatcaModule ───────────────────────

  group('integration: providers with full ZatcaModule registration', () {
    test('providers resolve when ZatcaModule.register is used', () {
      ZatcaModule.register(getIt: GetIt.instance);

      final container = ProviderContainer();
      addTearDown(() {
        container.dispose();
        if (GetIt.instance.isRegistered<CertificateRenewalService>()) {
          try {
            GetIt.instance<CertificateRenewalService>().dispose();
          } catch (_) {}
        }
      });

      expect(
        container.read(zatcaInvoiceServiceProvider),
        isA<ZatcaInvoiceService>(),
      );
      expect(
        container.read(zatcaOfflineQueueProvider),
        isA<ZatcaOfflineQueue>(),
      );
      expect(
        container.read(zatcaComplianceCheckerProvider),
        isA<ZatcaComplianceChecker>(),
      );
      expect(
        container.read(certificateStorageProvider),
        isA<CertificateStorage>(),
      );
      expect(
        container.read(invoiceChainServiceProvider),
        isA<InvoiceChainService>(),
      );
    });

    test('ProviderContainer dispose works cleanly with module', () {
      ZatcaModule.register(getIt: GetIt.instance);

      final container = ProviderContainer();
      container.read(zatcaInvoiceServiceProvider);
      // Dispose should not throw
      expect(() => container.dispose(), returnsNormally);

      // Cleanup the renewal monitor timer
      if (GetIt.instance.isRegistered<CertificateRenewalService>()) {
        GetIt.instance<CertificateRenewalService>().dispose();
      }
    });
  });

  // ─── Test the helper QueuedInvoice model ─────────────────

  group('unused types smoke', () {
    test('ZatcaResponse is available to providers', () {
      // Just verify the import works - no runtime check needed
      const response = ZatcaResponse(
        isSuccess: true,
        statusCode: 200,
        reportingStatus: ReportingStatus.reported,
      );
      expect(response.isSuccess, isTrue);
    });

    test('CertificateInfo is available to providers', () {
      final info = CertificateInfo(
        certificatePem: 'pem',
        privateKeyPem: 'key',
        csid: 'csid',
        secret: 'secret',
      );
      expect(info.certificatePem, equals('pem'));
    });
  });
}
