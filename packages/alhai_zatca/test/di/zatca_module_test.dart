import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_zatca/src/api/clearance_api.dart';
import 'package:alhai_zatca/src/api/compliance_api.dart';
import 'package:alhai_zatca/src/api/reporting_api.dart';
import 'package:alhai_zatca/src/api/zatca_api_client.dart';
import 'package:alhai_zatca/src/api/zatca_endpoints.dart';
import 'package:alhai_zatca/src/certificate/certificate_renewal_service.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/certificate/csid_onboarding_service.dart';
import 'package:alhai_zatca/src/certificate/csr_generator.dart';
import 'package:alhai_zatca/src/chaining/chain_store.dart';
import 'package:alhai_zatca/src/chaining/invoice_chain_service.dart';
import 'package:alhai_zatca/src/di/zatca_module.dart';
import 'package:alhai_zatca/src/qr/zatca_qr_service.dart';
import 'package:alhai_zatca/src/services/zatca_compliance_checker.dart';
import 'package:alhai_zatca/src/services/zatca_invoice_service.dart';
import 'package:alhai_zatca/src/services/zatca_offline_queue.dart';
import 'package:alhai_zatca/src/signing/xades_signer.dart';
import 'package:alhai_zatca/src/xml/ubl_invoice_builder.dart';

void main() {
  late GetIt getIt;

  setUp(() {
    // Use a fresh GetIt instance per test to avoid leakage from
    // any global GetIt.instance state.
    getIt = GetIt.asNewInstance();
  });

  tearDown(() {
    // Stop any monitoring timers and reset
    if (getIt.isRegistered<CertificateRenewalService>()) {
      try {
        getIt<CertificateRenewalService>().dispose();
      } catch (_) {}
    }
    getIt.reset();
  });

  group('ZatcaModule.register', () {
    test('registers core ZatcaApiClient', () {
      ZatcaModule.register(getIt: getIt);
      expect(getIt.isRegistered<ZatcaApiClient>(), isTrue);
      final client = getIt<ZatcaApiClient>();
      expect(client, isA<ZatcaApiClient>());
    });

    test('registers all API services (compliance, reporting, clearance)', () {
      ZatcaModule.register(getIt: getIt);
      expect(getIt.isRegistered<ComplianceApi>(), isTrue);
      expect(getIt.isRegistered<ReportingApi>(), isTrue);
      expect(getIt.isRegistered<ClearanceApi>(), isTrue);
    });

    test('registers ZatcaInvoiceService and resolves it', () {
      ZatcaModule.register(getIt: getIt);
      expect(getIt.isRegistered<ZatcaInvoiceService>(), isTrue);
      final service = getIt<ZatcaInvoiceService>();
      expect(service, isA<ZatcaInvoiceService>());
    });

    test('registers ZatcaQrService and resolves it', () {
      ZatcaModule.register(getIt: getIt);
      expect(getIt.isRegistered<ZatcaQrService>(), isTrue);
      final qr = getIt<ZatcaQrService>();
      expect(qr, isA<ZatcaQrService>());
    });

    test('registers ZatcaOfflineQueue and resolves it', () {
      ZatcaModule.register(getIt: getIt);
      expect(getIt.isRegistered<ZatcaOfflineQueue>(), isTrue);
      final queue = getIt<ZatcaOfflineQueue>();
      expect(queue, isA<ZatcaOfflineQueue>());
    });

    test('registers all signing & XML services', () {
      ZatcaModule.register(getIt: getIt);
      expect(getIt.isRegistered<XadesSigner>(), isTrue);
      expect(getIt.isRegistered<UblInvoiceBuilder>(), isTrue);
    });

    test('registers chain & certificate infrastructure', () {
      ZatcaModule.register(getIt: getIt);
      expect(getIt.isRegistered<ChainStore>(), isTrue);
      expect(getIt.isRegistered<CertificateStorage>(), isTrue);
      expect(getIt.isRegistered<InvoiceChainService>(), isTrue);
      expect(getIt.isRegistered<CsrGenerator>(), isTrue);
      expect(getIt.isRegistered<CsidOnboardingService>(), isTrue);
      expect(getIt.isRegistered<CertificateRenewalService>(), isTrue);
      expect(getIt.isRegistered<ZatcaComplianceChecker>(), isTrue);
    });

    test('uses InMemoryChainStore by default when no chainStore provided', () {
      ZatcaModule.register(getIt: getIt);
      final store = getIt<ChainStore>();
      expect(store, isA<InMemoryChainStore>());
    });

    test(
        'uses InMemoryCertificateStorage by default when no '
        'certificateStorage provided', () {
      ZatcaModule.register(getIt: getIt);
      final storage = getIt<CertificateStorage>();
      expect(storage, isA<InMemoryCertificateStorage>());
    });

    test('honours custom chainStore parameter', () {
      final customChain = InMemoryChainStore();
      ZatcaModule.register(getIt: getIt, chainStore: customChain);
      expect(identical(getIt<ChainStore>(), customChain), isTrue);
    });

    test('honours custom certificateStorage parameter', () {
      final customStorage = InMemoryCertificateStorage();
      ZatcaModule.register(getIt: getIt, certificateStorage: customStorage);
      expect(identical(getIt<CertificateStorage>(), customStorage), isTrue);
    });

    test('all services are registered as lazy singletons', () {
      ZatcaModule.register(getIt: getIt);

      // Resolving the same type twice should return the same instance
      final api1 = getIt<ZatcaApiClient>();
      final api2 = getIt<ZatcaApiClient>();
      expect(identical(api1, api2), isTrue);

      final qr1 = getIt<ZatcaQrService>();
      final qr2 = getIt<ZatcaQrService>();
      expect(identical(qr1, qr2), isTrue);

      final svc1 = getIt<ZatcaInvoiceService>();
      final svc2 = getIt<ZatcaInvoiceService>();
      expect(identical(svc1, svc2), isTrue);
    });

    test('register is idempotent (re-registering does not throw)', () {
      ZatcaModule.register(getIt: getIt);
      expect(() => ZatcaModule.register(getIt: getIt), returnsNormally);

      // After 2 calls everything should still resolve fine
      expect(getIt<ZatcaInvoiceService>(), isA<ZatcaInvoiceService>());
    });

    test('uses default sandbox environment when none specified', () {
      ZatcaModule.register(getIt: getIt);
      final client = getIt<ZatcaApiClient>();
      expect(client.environment, equals(ZatcaEnvironment.sandbox));
    });

    test('honours custom environment parameter', () {
      ZatcaModule.register(
        getIt: getIt,
        environment: ZatcaEnvironment.simulation,
      );
      final client = getIt<ZatcaApiClient>();
      expect(client.environment, equals(ZatcaEnvironment.simulation));
    });

    test(
        'all dependent services can be resolved without throwing '
        '(no circular deps)', () {
      ZatcaModule.register(getIt: getIt);

      // Resolve every registered type to make sure construction works
      expect(() => getIt<ZatcaApiClient>(), returnsNormally);
      expect(() => getIt<ComplianceApi>(), returnsNormally);
      expect(() => getIt<ReportingApi>(), returnsNormally);
      expect(() => getIt<ClearanceApi>(), returnsNormally);
      expect(() => getIt<ChainStore>(), returnsNormally);
      expect(() => getIt<CertificateStorage>(), returnsNormally);
      expect(() => getIt<XadesSigner>(), returnsNormally);
      expect(() => getIt<UblInvoiceBuilder>(), returnsNormally);
      expect(() => getIt<ZatcaQrService>(), returnsNormally);
      expect(() => getIt<InvoiceChainService>(), returnsNormally);
      expect(() => getIt<CsrGenerator>(), returnsNormally);
      expect(() => getIt<CsidOnboardingService>(), returnsNormally);
      expect(() => getIt<CertificateRenewalService>(), returnsNormally);
      expect(() => getIt<ZatcaComplianceChecker>(), returnsNormally);
      expect(() => getIt<ZatcaOfflineQueue>(), returnsNormally);
      expect(() => getIt<ZatcaInvoiceService>(), returnsNormally);
    });
  });

  group('ZatcaModule.unregister', () {
    test('completes without throwing after register', () {
      ZatcaModule.register(getIt: getIt);
      expect(getIt.isRegistered<ZatcaInvoiceService>(), isTrue);

      // Stop monitor before unregister
      getIt<CertificateRenewalService>().dispose();

      // Note: the source `unregister` uses `isRegistered(instance: type)`
      // which compares to a Type as if it were an instance — for un-
      // instantiated lazy singletons this is effectively a no-op, but
      // it must complete without error.
      expect(() => ZatcaModule.unregister(getIt: getIt), returnsNormally);
    });

    test('unregister is safe to call when nothing is registered', () {
      expect(() => ZatcaModule.unregister(getIt: getIt), returnsNormally);
    });

    test('after unregister, can re-register cleanly', () {
      ZatcaModule.register(getIt: getIt);
      getIt<CertificateRenewalService>().dispose();

      // Even if unregister is partially effective, calling register
      // again should not throw because each registerLazySingleton call
      // is guarded by `isRegistered<T>()`.
      ZatcaModule.unregister(getIt: getIt);

      expect(() => ZatcaModule.register(getIt: getIt), returnsNormally);
      expect(getIt.isRegistered<ZatcaInvoiceService>(), isTrue);
    });
  });

  group('ZatcaModule.switchEnvironment', () {
    test('changes the API client environment', () {
      ZatcaModule.register(getIt: getIt, environment: ZatcaEnvironment.sandbox);
      expect(
        getIt<ZatcaApiClient>().environment,
        equals(ZatcaEnvironment.sandbox),
      );

      ZatcaModule.switchEnvironment(
        getIt: getIt,
        environment: ZatcaEnvironment.simulation,
      );

      expect(
        getIt<ZatcaApiClient>().environment,
        equals(ZatcaEnvironment.simulation),
      );
    });

    test('keeps non-API services usable after switch', () {
      ZatcaModule.register(getIt: getIt, environment: ZatcaEnvironment.sandbox);

      ZatcaModule.switchEnvironment(
        getIt: getIt,
        environment: ZatcaEnvironment.simulation,
      );

      // QR service and other non-API services should still resolve
      expect(getIt<ZatcaQrService>(), isA<ZatcaQrService>());
      expect(getIt<ZatcaInvoiceService>(), isA<ZatcaInvoiceService>());
    });

    test('switchEnvironment can be called repeatedly', () {
      ZatcaModule.register(getIt: getIt, environment: ZatcaEnvironment.sandbox);

      expect(
        () => ZatcaModule.switchEnvironment(
          getIt: getIt,
          environment: ZatcaEnvironment.simulation,
        ),
        returnsNormally,
      );

      expect(
        () => ZatcaModule.switchEnvironment(
          getIt: getIt,
          environment: ZatcaEnvironment.sandbox,
        ),
        returnsNormally,
      );

      expect(
        getIt<ZatcaApiClient>().environment,
        equals(ZatcaEnvironment.sandbox),
      );
    });
  });
}
