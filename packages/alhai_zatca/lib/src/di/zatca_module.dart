import 'package:get_it/get_it.dart';

import 'package:alhai_zatca/src/api/clearance_api.dart';
import 'package:alhai_zatca/src/api/compliance_api.dart';
import 'package:alhai_zatca/src/api/reporting_api.dart';
import 'package:alhai_zatca/src/api/zatca_api_client.dart';
import 'package:alhai_zatca/src/api/zatca_endpoints.dart';
import 'package:alhai_zatca/src/certificate/certificate_renewal_service.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/certificate/csr_generator.dart';
import 'package:alhai_zatca/src/certificate/csid_onboarding_service.dart';
import 'package:alhai_zatca/src/chaining/chain_store.dart';
import 'package:alhai_zatca/src/chaining/invoice_chain_service.dart';
import 'package:alhai_zatca/src/qr/zatca_qr_service.dart';
import 'package:alhai_zatca/src/services/zatca_compliance_checker.dart';
import 'package:alhai_zatca/src/services/zatca_invoice_service.dart';
import 'package:alhai_zatca/src/services/zatca_offline_queue.dart';
import 'package:alhai_zatca/src/signing/xades_signer.dart';
import 'package:alhai_zatca/src/xml/ubl_invoice_builder.dart';

/// Registers all ZATCA dependencies in the GetIt service locator
class ZatcaModule {
  const ZatcaModule._();

  /// Register all ZATCA services
  ///
  /// [environment] - API environment (sandbox, simulation, production)
  /// [chainStore] - persistence for invoice hash chain
  /// [certificateStorage] - secure storage for certificates
  static void register({
    required GetIt getIt,
    ZatcaEnvironment environment = ZatcaEnvironment.sandbox,
    ChainStore? chainStore,
    CertificateStorage? certificateStorage,
  }) {
    // ─── Core ────────────────────────────────────────────
    if (!getIt.isRegistered<ZatcaApiClient>()) {
      getIt.registerLazySingleton<ZatcaApiClient>(
        () => ZatcaApiClient(environment: environment),
      );
    }

    // ─── API Services ────────────────────────────────────
    if (!getIt.isRegistered<ComplianceApi>()) {
      getIt.registerLazySingleton<ComplianceApi>(
        () => ComplianceApi(client: getIt<ZatcaApiClient>()),
      );
    }
    if (!getIt.isRegistered<ReportingApi>()) {
      getIt.registerLazySingleton<ReportingApi>(
        () => ReportingApi(client: getIt<ZatcaApiClient>()),
      );
    }
    if (!getIt.isRegistered<ClearanceApi>()) {
      getIt.registerLazySingleton<ClearanceApi>(
        () => ClearanceApi(client: getIt<ZatcaApiClient>()),
      );
    }

    // ─── Storage ─────────────────────────────────────────
    if (!getIt.isRegistered<ChainStore>()) {
      if (chainStore != null) {
        getIt.registerLazySingleton<ChainStore>(() => chainStore);
      } else {
        getIt.registerLazySingleton<ChainStore>(() => InMemoryChainStore());
      }
    }

    if (!getIt.isRegistered<CertificateStorage>()) {
      if (certificateStorage != null) {
        getIt.registerLazySingleton<CertificateStorage>(
            () => certificateStorage);
      } else {
        getIt.registerLazySingleton<CertificateStorage>(
          () => InMemoryCertificateStorage(),
        );
      }
    }

    // ─── Signing & XML ──────────────────────────────────
    if (!getIt.isRegistered<XadesSigner>()) {
      getIt.registerLazySingleton<XadesSigner>(() => XadesSigner());
    }
    if (!getIt.isRegistered<UblInvoiceBuilder>()) {
      getIt.registerLazySingleton<UblInvoiceBuilder>(() => UblInvoiceBuilder());
    }
    if (!getIt.isRegistered<ZatcaQrService>()) {
      getIt.registerLazySingleton<ZatcaQrService>(() => ZatcaQrService());
    }

    // ─── Chain ──────────────────────────────────────────
    if (!getIt.isRegistered<InvoiceChainService>()) {
      getIt.registerLazySingleton<InvoiceChainService>(
        () => InvoiceChainService(store: getIt<ChainStore>()),
      );
    }

    // ─── Certificate ─────────────────────────────────────
    if (!getIt.isRegistered<CsrGenerator>()) {
      getIt.registerLazySingleton<CsrGenerator>(() => CsrGenerator());
    }
    if (!getIt.isRegistered<CsidOnboardingService>()) {
      getIt.registerLazySingleton<CsidOnboardingService>(
        () => CsidOnboardingService(
          csrGenerator: getIt<CsrGenerator>(),
          complianceApi: getIt<ComplianceApi>(),
          storage: getIt<CertificateStorage>(),
        ),
      );
    }
    if (!getIt.isRegistered<CertificateRenewalService>()) {
      getIt.registerLazySingleton<CertificateRenewalService>(
        () => CertificateRenewalService(
          storage: getIt<CertificateStorage>(),
          onboardingService: getIt<CsidOnboardingService>(),
        ),
      );
    }

    // ─── Services ────────────────────────────────────────
    if (!getIt.isRegistered<ZatcaComplianceChecker>()) {
      getIt.registerLazySingleton<ZatcaComplianceChecker>(
        () => ZatcaComplianceChecker(),
      );
    }
    if (!getIt.isRegistered<ZatcaOfflineQueue>()) {
      getIt.registerLazySingleton<ZatcaOfflineQueue>(
        () => ZatcaOfflineQueue(),
      );
    }
    if (!getIt.isRegistered<ZatcaInvoiceService>()) {
      getIt.registerLazySingleton<ZatcaInvoiceService>(
        () => ZatcaInvoiceService(
          xmlBuilder: getIt<UblInvoiceBuilder>(),
          signer: getIt<XadesSigner>(),
          qrService: getIt<ZatcaQrService>(),
          chainService: getIt<InvoiceChainService>(),
          reportingApi: getIt<ReportingApi>(),
          clearanceApi: getIt<ClearanceApi>(),
          certStorage: getIt<CertificateStorage>(),
          offlineQueue: getIt<ZatcaOfflineQueue>(),
          complianceChecker: getIt<ZatcaComplianceChecker>(),
          renewalService: getIt<CertificateRenewalService>(),
        ),
      );
    }

    // Start automatic certificate expiry monitoring
    getIt<CertificateRenewalService>().startMonitoring();
  }

  /// Unregister all ZATCA services (for testing or hot-reload)
  static void unregister({required GetIt getIt}) {
    final types = <Type>[
      ZatcaInvoiceService,
      ZatcaOfflineQueue,
      ZatcaComplianceChecker,
      CertificateRenewalService,
      CsidOnboardingService,
      CsrGenerator,
      InvoiceChainService,
      ZatcaQrService,
      UblInvoiceBuilder,
      XadesSigner,
      CertificateStorage,
      ChainStore,
      ClearanceApi,
      ReportingApi,
      ComplianceApi,
      ZatcaApiClient,
    ];
    for (final type in types) {
      if (getIt.isRegistered(instance: type)) {
        try {
          getIt.unregister(instance: type);
        } catch (_) {
          // Ignore if not registered
        }
      }
    }
  }

  /// Re-register with a different environment (e.g., switching to production)
  static void switchEnvironment({
    required GetIt getIt,
    required ZatcaEnvironment environment,
    ChainStore? chainStore,
    CertificateStorage? certificateStorage,
  }) {
    // Dispose the renewal service timer if active
    if (getIt.isRegistered<CertificateRenewalService>()) {
      getIt<CertificateRenewalService>().dispose();
    }

    // Reset all registrations
    _safeUnregister<ZatcaInvoiceService>(getIt);
    _safeUnregister<ZatcaApiClient>(getIt);
    _safeUnregister<ComplianceApi>(getIt);
    _safeUnregister<ReportingApi>(getIt);
    _safeUnregister<ClearanceApi>(getIt);
    _safeUnregister<CertificateRenewalService>(getIt);
    _safeUnregister<CsidOnboardingService>(getIt);

    // Re-register with new environment
    register(
      getIt: getIt,
      environment: environment,
      chainStore: chainStore,
      certificateStorage: certificateStorage,
    );
  }

  static void _safeUnregister<T extends Object>(GetIt getIt) {
    if (getIt.isRegistered<T>()) {
      getIt.unregister<T>();
    }
  }
}
