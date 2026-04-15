/// Invoice-related providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/invoice_service.dart';
import '../data/models.dart';
import 'distributor_datasource_provider.dart';

// ─── Invoice Service ────────────────────────────────────────────

/// Provides the [InvoiceService] singleton.
///
/// Currently wired without ZatcaInvoiceService — invoices are generated
/// locally. Wire in ZatcaInvoiceService via GetIt once ZATCA certificates
/// are configured.
final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final ds = ref.watch(distributorDatasourceProvider);
  return InvoiceService(datasource: ds);
});

// ─── Invoice Queries ────────────────────────────────────────────

/// All invoices — pass status filter via family (null = all).
final invoicesProvider =
    FutureProvider.family<List<DistributorInvoice>, String?>((
      ref,
      status,
    ) async {
      final ds = ref.watch(distributorDatasourceProvider);
      return ds.getInvoices(status: status);
    });

/// Single invoice by ID.
final invoiceByIdProvider =
    FutureProvider.family<DistributorInvoice?, String>((
      ref,
      invoiceId,
    ) async {
      final ds = ref.watch(distributorDatasourceProvider);
      return ds.getInvoiceById(invoiceId);
    });

/// Check if an order already has an invoice.
final invoiceByOrderProvider =
    FutureProvider.family<DistributorInvoice?, String>((
      ref,
      orderId,
    ) async {
      final ds = ref.watch(distributorDatasourceProvider);
      return ds.getInvoiceByOrderId(orderId);
    });
