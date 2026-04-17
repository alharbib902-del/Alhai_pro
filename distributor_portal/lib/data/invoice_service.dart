/// Invoice generation service for the Distributor Portal.
///
/// Orchestrates order→invoice conversion, ZATCA processing, and DB persistence.
library;

import 'package:alhai_zatca/alhai_zatca.dart';
import 'package:uuid/uuid.dart';

import 'distributor_datasource.dart';
import 'models.dart';

/// Generates ZATCA-compliant invoices from distributor orders.
class InvoiceService {
  final DistributorDatasource _datasource;
  final ZatcaInvoiceService? _zatcaService;

  /// Creates an InvoiceService.
  ///
  /// [zatcaService] is optional — if null, invoices are created locally
  /// without ZATCA signing/submission. ZATCA fields will be null.
  InvoiceService({
    required DistributorDatasource datasource,
    ZatcaInvoiceService? zatcaService,
  }) : _datasource = datasource,
       _zatcaService = zatcaService;

  static const double _saudiVatRate = 15.0;

  /// Generate an invoice from a completed order.
  ///
  /// Builds a ZATCA invoice from the order items, processes it through
  /// the ZATCA pipeline (if available), and saves to the `invoices` table.
  ///
  /// Throws [DatasourceError] if the order already has an invoice.
  Future<DistributorInvoice> generateInvoiceFromOrder({
    required DistributorOrder order,
    required List<DistributorOrderItem> items,
    required OrgSettings orgSettings,
    String invoiceType = 'standard_tax',
    String? customerName,
    String? customerVatNumber,
    String? customerAddress,
    String? notes,
  }) async {
    // Guard: prevent duplicate invoices for the same order
    final existing = await _datasource.getInvoiceByOrderId(order.id);
    if (existing != null) {
      throw DatasourceError(
        type: DatasourceErrorType.validation,
        message:
            'Order ${order.purchaseNumber} already has invoice ${existing.invoiceNumber}.',
      );
    }

    if (items.isEmpty) {
      throw const DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'Cannot create invoice for order with no items.',
      );
    }

    final invoiceNumber = await _datasource.getNextInvoiceNumber();
    final uuid = const Uuid().v4();
    final now = DateTime.now();

    // Build line items with 15% VAT
    final lines = _buildInvoiceLines(items);

    // Compute totals from lines
    final subtotal = lines.fold<double>(0, (s, l) => s + l.lineNetAmount);
    final taxAmount = lines.fold<double>(0, (s, l) => s + l.vatAmount);
    final total = subtotal + taxAmount;

    // ZATCA processing (if service available)
    String? zatcaHash;
    String? zatcaQr;
    String? zatcaUuid;

    if (_zatcaService != null) {
      final seller = _buildSeller(orgSettings);
      final buyer = _buildBuyer(
        storeName: customerName ?? order.storeName,
        vatNumber: customerVatNumber,
        address: customerAddress,
      );

      final isStandard = invoiceType == 'standard_tax';
      final zatcaInvoice = ZatcaInvoice(
        invoiceNumber: invoiceNumber,
        uuid: uuid,
        issueDate: now,
        issueTime: now,
        typeCode: InvoiceTypeCode.standard,
        subType: isStandard ? '0100000' : '0200000',
        seller: seller,
        buyer: isStandard ? buyer : null,
        lines: lines,
        paymentMeansCode: '30', // credit (B2B default)
      );

      final processed = await _zatcaService.processInvoice(
        invoice: zatcaInvoice,
        storeId: order.storeId,
      );

      zatcaHash = processed.invoiceHash;
      zatcaQr = processed.qrCode;
      zatcaUuid = processed.uuid;
    }

    // Build and save the invoice record
    final invoice = DistributorInvoice(
      id: uuid,
      storeId: order.storeId,
      invoiceNumber: invoiceNumber,
      invoiceType: invoiceType,
      status: 'issued',
      saleId: order.id,
      customerName: customerName ?? order.storeName,
      customerVatNumber: customerVatNumber,
      customerAddress: customerAddress,
      subtotal: _round2(subtotal),
      discount: 0,
      taxRate: _saudiVatRate,
      taxAmount: _round2(taxAmount),
      total: _round2(total),
      amountDue: _round2(total),
      currency: 'SAR',
      zatcaHash: zatcaHash,
      zatcaQr: zatcaQr,
      zatcaUuid: zatcaUuid,
      notes: notes,
      issuedAt: now,
      createdAt: now,
    );

    return _datasource.createInvoice(invoice);
  }

  /// Convert order items to ZATCA invoice lines.
  List<ZatcaInvoiceLine> _buildInvoiceLines(List<DistributorOrderItem> items) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final unitPrice = item.distributorPrice ?? item.suggestedPrice;

      return ZatcaInvoiceLine(
        lineId: '${index + 1}',
        itemName: item.productName,
        quantity: item.quantity.toDouble(),
        unitPrice: unitPrice,
        vatRate: _saudiVatRate,
        barcode: item.barcode,
        sellerItemId: item.productId,
      );
    }).toList();
  }

  /// Build ZATCA seller from org settings.
  ZatcaSeller _buildSeller(OrgSettings org) {
    return ZatcaSeller(
      name: org.companyName,
      vatNumber: org.taxNumber ?? '',
      streetName: org.address ?? '',
      buildingNumber: '',
      city: org.city ?? '',
      postalCode: '',
      crNumber: org.commercialReg,
    );
  }

  /// Build ZATCA buyer from store/customer info.
  ZatcaBuyer _buildBuyer({
    required String storeName,
    String? vatNumber,
    String? address,
  }) {
    return ZatcaBuyer(
      name: storeName,
      vatNumber: vatNumber,
      streetName: address,
    );
  }

  static double _round2(double value) => (value * 100).roundToDouble() / 100;
}
