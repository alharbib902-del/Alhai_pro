import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_zatca/src/certificate/certificate_renewal_service.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/certificate/csid_onboarding_service.dart';
import 'package:alhai_zatca/src/chaining/invoice_chain_service.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/services/zatca_compliance_checker.dart';
import 'package:alhai_zatca/src/services/zatca_invoice_service.dart';
import 'package:alhai_zatca/src/services/zatca_offline_queue.dart';

// ─── Service Providers ──────────────────────────────────────

/// Provider for the main ZATCA invoice service
final zatcaInvoiceServiceProvider = Provider<ZatcaInvoiceService>((ref) {
  return GetIt.instance<ZatcaInvoiceService>();
});

/// Provider for the CSID onboarding service
final csidOnboardingServiceProvider = Provider<CsidOnboardingService>((ref) {
  return GetIt.instance<CsidOnboardingService>();
});

/// Provider for certificate renewal
final certificateRenewalServiceProvider =
    Provider<CertificateRenewalService>((ref) {
  return GetIt.instance<CertificateRenewalService>();
});

/// Provider for compliance checking
final zatcaComplianceCheckerProvider = Provider<ZatcaComplianceChecker>((ref) {
  return GetIt.instance<ZatcaComplianceChecker>();
});

/// Provider for the offline queue
final zatcaOfflineQueueProvider = Provider<ZatcaOfflineQueue>((ref) {
  return GetIt.instance<ZatcaOfflineQueue>();
});

/// Provider for certificate storage
final certificateStorageProvider = Provider<CertificateStorage>((ref) {
  return GetIt.instance<CertificateStorage>();
});

/// Provider for invoice chain service
final invoiceChainServiceProvider = Provider<InvoiceChainService>((ref) {
  return GetIt.instance<InvoiceChainService>();
});

// ─── Async State Providers ──────────────────────────────────

/// Provider for pending offline invoice count
final zatcaPendingCountProvider = FutureProvider<int>((ref) async {
  final queue = ref.watch(zatcaOfflineQueueProvider);
  return queue.pendingCount;
});

/// Provider for certificate status of a specific store
final certificateStatusProvider =
    FutureProvider.family<CertificateStatus, String>((ref, storeId) async {
  final renewal = ref.watch(certificateRenewalServiceProvider);
  return renewal.getStatus(storeId: storeId);
});

/// Provider for detailed renewal info for a specific store
final certificateRenewalInfoProvider =
    FutureProvider.family<RenewalInfo, String>((ref, storeId) async {
  final renewal = ref.watch(certificateRenewalServiceProvider);
  return renewal.getRenewalInfo(storeId: storeId);
});

/// Provider for certificate health check result
final certificateCheckProvider =
    FutureProvider.family<CertificateCheckResult, String>((ref, storeId) async {
  final renewal = ref.watch(certificateRenewalServiceProvider);
  return renewal.checkCertificate(storeId: storeId);
});

/// Provider for the actual certificate info (without private key)
final certificateInfoProvider =
    FutureProvider.family<CertificateInfo?, String>((ref, storeId) async {
  final storage = ref.watch(certificateStorageProvider);
  return storage.getCertificateMetadata(storeId: storeId);
});

/// Provider for whether a valid production certificate exists
final hasValidCertificateProvider =
    FutureProvider.family<bool, String>((ref, storeId) async {
  final onboarding = ref.watch(csidOnboardingServiceProvider);
  return onboarding.hasValidProductionCertificate(storeId: storeId);
});

/// Provider for failed queue items
final zatcaFailedQueueProvider =
    FutureProvider<List<QueuedInvoice>>((ref) async {
  final queue = ref.watch(zatcaOfflineQueueProvider);
  return queue.getFailedInvoices();
});

// ─── Action Providers ───────────────────────────────────────

/// Provider to validate an invoice without submitting
final invoiceValidationProvider =
    Provider.family<ComplianceResult, ZatcaInvoice>((ref, invoice) {
  final checker = ref.watch(zatcaComplianceCheckerProvider);
  return checker.check(invoice);
});

/// Provider to process an invoice (call .processInvoice)
final processInvoiceProvider = FutureProvider.family<ZatcaInvoice,
    ({ZatcaInvoice invoice, String storeId})>((ref, params) async {
  final service = ref.watch(zatcaInvoiceServiceProvider);
  return service.processInvoice(
    invoice: params.invoice,
    storeId: params.storeId,
  );
});

/// Provider to retry the offline queue
final retryQueueProvider =
    FutureProvider.family<List<QueueProcessResult>, String>(
        (ref, storeId) async {
  final service = ref.watch(zatcaInvoiceServiceProvider);
  return service.retryQueue(storeId: storeId);
});
