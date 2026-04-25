import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_zatca/alhai_zatca.dart';
import 'package:uuid/uuid.dart';

import 'invoice_service.dart' show InvoiceType;

/// Wave 3b-2b: bridges local Drift rows (int cents, free-text store
/// address) to the `ZatcaInvoice` model `ZatcaInvoiceService.processInvoice`
/// expects (SAR doubles, structured address).
///
/// **Why a dedicated mapper:** the wire format `alhai_zatca` requires
/// is meaningfully different from what `alhai_pos` and `alhai_database`
/// store today:
///   - money: int cents → SAR doubles (cents / 100.0)
///   - tax rate: derived from `sale.tax / sale.subtotal` (per Sprint 1 / P0-03,
///     it's no longer a hardcoded 15%)
///   - payment means: a single legacy `paymentMethod` string OR per-tender
///     amounts (`cashAmount`/`cardAmount`/`creditAmount`) → list of
///     `ZatcaPaymentMeans` with ZATCA codes 10/48/30
///   - seller: a flat `StoreInfo` snapshot OR the extended `StoresTableData`
///     with structured fields → `ZatcaSeller` with required street/building/
///     city/postal-code
///
/// All conversions are pure — no DB or service calls — so the mapper is
/// trivially unit-testable.
class ZatcaInvoiceMapper {
  ZatcaInvoiceMapper._();

  static const _uuid = Uuid();

  /// ZATCA payment-means code for the cash tender of a sale.
  static const _zatcaPaymentCash = '10';

  /// ZATCA payment-means code for the card tender of a sale.
  static const _zatcaPaymentCard = '48';

  /// ZATCA payment-means code for the credit (deferred) tender.
  static const _zatcaPaymentCredit = '30';

  /// VAT rate ZATCA expects when the legacy `paymentMethod` is the only
  /// signal we have for the seller. Sprint 1 / P0-03 removed the hardcoded
  /// 15% from the cashier flow, but the ZATCA service still needs a number
  /// per line — derive it from the sale totals so it matches what was
  /// actually charged.
  static const _zatcaDefaultVatRatePercent = 15.0;

  /// Convert `cents` to SAR. Integer `/ 100.0` is exact for cents up to
  /// 2^53 (well past any realistic invoice total), so no extra rounding
  /// is needed at conversion time. Compound arithmetic on the SAR
  /// values (e.g. `unitPrice * qty`) goes through `ZatcaInvoiceLine`
  /// which already exposes rounded helpers.
  static double _centsToSar(int cents) => cents / 100.0;

  // ─── Public API ────────────────────────────────────────────

  /// Build a `ZatcaInvoice` for a freshly-finalised POS sale (B2C
  /// simplified by default; B2B standard when [customerVatNumber] is
  /// passed).
  ///
  /// The caller is responsible for getting [invoiceCounterValue] from
  /// `InvoiceCounterDao.nextIcv` — the mapper itself stays pure so
  /// tests can drive every branch without a DB.
  ///
  /// All money arithmetic is converted from int cents (Drift's storage
  /// format) to SAR doubles (ZATCA's wire format) inside this method.
  /// Callers must NOT pre-divide.
  static ZatcaInvoice fromSale({
    required SalesTableData sale,
    required List<SaleItemsTableData> items,
    required StoresTableData store,
    required String invoiceNumber,
    required int invoiceCounterValue,
    required InvoiceType type,
    required DateTime issuedAt,
    String? customerVatNumber,
    String? customerName,
    String? customerAddress,
  }) {
    return _buildInvoice(
      typeCode: _typeCodeFor(type),
      subType: _subTypeFor(type, customerVatNumber: customerVatNumber),
      invoiceNumber: invoiceNumber,
      invoiceCounterValue: invoiceCounterValue,
      issuedAt: issuedAt,
      store: store,
      // Total from the sale table
      subtotalCents: sale.subtotal,
      discountCents: sale.discount,
      taxCents: sale.tax,
      totalCents: sale.total,
      // Per-tender breakdown (multi-tender path; null/empty falls back
      // to a single legacy element)
      cashCents: sale.cashAmount,
      cardCents: sale.cardAmount,
      creditCents: sale.creditAmount,
      paymentMethodLegacy: sale.paymentMethod,
      // Lines
      lines: _mapLines(items, sale: sale),
      // Buyer (only when B2B)
      customerVatNumber: customerVatNumber,
      customerName: customerName ?? sale.customerName,
      customerAddress: customerAddress,
    );
  }

  /// Build a `ZatcaInvoice` for a credit note that references an existing
  /// invoice. Credit notes use UBL type code `381` and reference the
  /// original via `billingReferenceId` (BT-25).
  ///
  /// Tax for partial refunds is split proportionally — caller passes
  /// `subtotalCents` (net) and `taxCents` (tax owed back) directly so the
  /// mapper doesn't have to re-derive the rate from the source invoice.
  static ZatcaInvoice fromCreditNote({
    required StoresTableData store,
    required String invoiceNumber,
    required int invoiceCounterValue,
    required DateTime issuedAt,
    required String refInvoiceNumber,
    required String reason,
    required int subtotalCents,
    required int taxCents,
    String? customerVatNumber,
    String? customerName,
    String? customerAddress,
    List<SaleItemsTableData>? originalLines,
  }) {
    final totalCents = subtotalCents + taxCents;

    // ZATCA still expects at least one InvoiceLine on a credit note.
    // When the caller passes the original sale's lines, we mirror them
    // (the portal links the refund back to the original via
    // billingReferenceId). When they don't, we synthesise a single
    // summary line covering the refunded subtotal — better than emitting
    // an empty-lines invoice the portal will reject.
    final lines = (originalLines != null && originalLines.isNotEmpty)
        ? _mapLines(
            originalLines,
            taxCentsOverride: taxCents,
            subtotalCentsOverride: subtotalCents,
          )
        : <ZatcaInvoiceLine>[
            ZatcaInvoiceLine(
              lineId: '1',
              itemName: reason.isEmpty ? 'Credit note' : reason,
              quantity: 1,
              unitPrice: _centsToSar(subtotalCents),
              vatRate: subtotalCents > 0
                  ? _ratePercent(taxCents: taxCents, subtotalCents: subtotalCents)
                  : _zatcaDefaultVatRatePercent,
            ),
          ];

    return _buildInvoice(
      typeCode: InvoiceTypeCode.creditNote,
      subType: customerVatNumber != null && customerVatNumber.isNotEmpty
          ? InvoiceSubType.standardB2B
          : InvoiceSubType.simplifiedB2C,
      invoiceNumber: invoiceNumber,
      invoiceCounterValue: invoiceCounterValue,
      issuedAt: issuedAt,
      store: store,
      subtotalCents: subtotalCents,
      discountCents: 0,
      taxCents: taxCents,
      totalCents: totalCents,
      cashCents: null,
      cardCents: null,
      creditCents: null,
      paymentMethodLegacy: 'cash',
      lines: lines,
      customerVatNumber: customerVatNumber,
      customerName: customerName,
      customerAddress: customerAddress,
      billingReferenceId: refInvoiceNumber,
      documentDiscountReason: reason,
    );
  }

  // ─── Internal builders ─────────────────────────────────────

  static ZatcaInvoice _buildInvoice({
    required InvoiceTypeCode typeCode,
    required String subType,
    required String invoiceNumber,
    required int invoiceCounterValue,
    required DateTime issuedAt,
    required StoresTableData store,
    required int subtotalCents,
    required int discountCents,
    required int taxCents,
    required int totalCents,
    required int? cashCents,
    required int? cardCents,
    required int? creditCents,
    required String? paymentMethodLegacy,
    required List<ZatcaInvoiceLine> lines,
    String? customerVatNumber,
    String? customerName,
    String? customerAddress,
    String? billingReferenceId,
    String? documentDiscountReason,
  }) {
    final paymentMeans = _mapPaymentMeans(
      cashCents: cashCents,
      cardCents: cardCents,
      creditCents: creditCents,
      totalCents: totalCents,
      legacyMethod: paymentMethodLegacy,
    );
    final fallbackPaymentCode = paymentMeans.isEmpty
        ? _legacyPaymentCode(paymentMethodLegacy)
        : paymentMeans.first.code;

    final buyer = _buildBuyer(
      vatNumber: customerVatNumber,
      name: customerName,
      address: customerAddress,
    );

    return ZatcaInvoice(
      invoiceNumber: invoiceNumber,
      uuid: _uuid.v4(),
      issueDate: issuedAt,
      issueTime: issuedAt,
      typeCode: typeCode,
      subType: subType,
      seller: _buildSeller(store),
      buyer: buyer,
      lines: lines,
      documentDiscount: _centsToSar(discountCents),
      documentDiscountReason: documentDiscountReason,
      paymentMeansCode: fallbackPaymentCode,
      paymentMeans: paymentMeans.isEmpty ? null : paymentMeans,
      billingReferenceId: billingReferenceId,
      invoiceCounterValue: invoiceCounterValue,
    );
  }

  // ─── Seller ───────────────────────────────────────────────

  static ZatcaSeller _buildSeller(StoresTableData store) {
    return ZatcaSeller(
      name: store.name,
      vatNumber: store.taxNumber ?? '',
      crNumber: store.commercialReg,
      streetName: store.streetName ?? store.address ?? '',
      buildingNumber: store.buildingNumber ?? '0000',
      plotIdentification: store.plotIdentification,
      city: store.city ?? '',
      district: store.district,
      postalCode: store.postalCode ?? '00000',
      additionalId: store.additionalAddressNumber,
    );
  }

  // ─── Buyer ────────────────────────────────────────────────

  static ZatcaBuyer? _buildBuyer({
    String? vatNumber,
    String? name,
    String? address,
  }) {
    if ((vatNumber == null || vatNumber.isEmpty) &&
        (name == null || name.isEmpty)) {
      return null;
    }
    return ZatcaBuyer(
      name: name,
      vatNumber: vatNumber,
      streetName: address,
      countryCode: 'SA',
    );
  }

  // ─── Lines ────────────────────────────────────────────────

  /// Map sale items to ZATCA invoice lines.
  ///
  /// `taxCentsOverride` and `subtotalCentsOverride` are only used by the
  /// credit-note path when the caller passes the original sale's lines
  /// but a different (partial-refund) total — the rate has to be
  /// re-derived from the override pair so each line's vatRate matches.
  static List<ZatcaInvoiceLine> _mapLines(
    List<SaleItemsTableData> items, {
    SalesTableData? sale,
    int? taxCentsOverride,
    int? subtotalCentsOverride,
  }) {
    if (items.isEmpty) {
      return const [];
    }

    final saleSubtotal = subtotalCentsOverride ?? sale?.subtotal ?? 0;
    final saleTax = taxCentsOverride ?? sale?.tax ?? 0;
    final ratePercent = saleSubtotal > 0
        ? _ratePercent(taxCents: saleTax, subtotalCents: saleSubtotal)
        : _zatcaDefaultVatRatePercent;

    var lineId = 1;
    return items.map((item) {
      // Item-level discount lives on the line, not the document, when
      // it came from the cashier's inline-discount widget. Document-
      // level discounts (rare in B2C) ride `sale.discount`.
      final discountSar = _centsToSar(item.discount);
      return ZatcaInvoiceLine(
        lineId: '${lineId++}',
        itemName: item.productName,
        quantity: item.qty,
        unitPrice: _centsToSar(item.unitPrice),
        discountAmount: discountSar,
        vatRate: ratePercent,
        sellerItemId: item.productSku,
        barcode: item.productBarcode,
      );
    }).toList(growable: false);
  }

  // ─── Payment Means ────────────────────────────────────────

  /// Translate the sale's per-tender amounts into ZATCA payment-means
  /// entries. Returns an empty list when the sale only has a single
  /// legacy `paymentMethod` (no per-tender breakdown) — the caller
  /// then falls back to the single-element legacy XML path.
  static List<ZatcaPaymentMeans> _mapPaymentMeans({
    required int? cashCents,
    required int? cardCents,
    required int? creditCents,
    required int totalCents,
    required String? legacyMethod,
  }) {
    final out = <ZatcaPaymentMeans>[];
    if (cashCents != null && cashCents > 0) {
      out.add(
        ZatcaPaymentMeans(
          code: _zatcaPaymentCash,
          amount: _centsToSar(cashCents),
        ),
      );
    }
    if (cardCents != null && cardCents > 0) {
      out.add(
        ZatcaPaymentMeans(
          code: _zatcaPaymentCard,
          amount: _centsToSar(cardCents),
        ),
      );
    }
    if (creditCents != null && creditCents > 0) {
      out.add(
        ZatcaPaymentMeans(
          code: _zatcaPaymentCredit,
          amount: _centsToSar(creditCents),
        ),
      );
    }
    return out;
  }

  /// Map the legacy `paymentMethod` string to a ZATCA code. Used as a
  /// fallback when no per-tender amounts are recorded on the sale.
  static String _legacyPaymentCode(String? method) {
    switch (method) {
      case 'card':
        return _zatcaPaymentCard;
      case 'credit':
        return _zatcaPaymentCredit;
      case 'cash':
      default:
        return _zatcaPaymentCash;
    }
  }

  // ─── Type Code & Sub-Type ─────────────────────────────────

  static InvoiceTypeCode _typeCodeFor(InvoiceType type) {
    switch (type) {
      case InvoiceType.creditNote:
        return InvoiceTypeCode.creditNote;
      case InvoiceType.debitNote:
        return InvoiceTypeCode.debitNote;
      case InvoiceType.simplifiedTax:
      case InvoiceType.standardTax:
        return InvoiceTypeCode.standard;
    }
  }

  /// Sub-type flags. B2C/B2B is the high-bit decision — B2B if a buyer
  /// VAT number is present (matches what the cashier flow already does
  /// for the legacy QR), else simplified.
  static String _subTypeFor(
    InvoiceType type, {
    String? customerVatNumber,
  }) {
    final isB2B = customerVatNumber != null && customerVatNumber.isNotEmpty;
    if (type == InvoiceType.standardTax || isB2B) {
      return InvoiceSubType.standardB2B;
    }
    return InvoiceSubType.simplifiedB2C;
  }

  // ─── Helpers ──────────────────────────────────────────────

  /// Effective VAT rate as a percentage (e.g. 15.0 for 15%) derived
  /// from the cents totals. Sprint 1 / P0-03 made the rate configurable;
  /// instead of re-reading TaxSettings here we infer it from what was
  /// actually charged so the mapper stays pure.
  static double _ratePercent({
    required int taxCents,
    required int subtotalCents,
  }) {
    if (subtotalCents <= 0) return 0;
    final raw = taxCents * 100.0 / subtotalCents;
    // Snap to 2 dp so a 0.01 cent round-off doesn't make ZATCA reject
    // the line as "rate doesn't match tax amount".
    return double.parse(raw.toStringAsFixed(2));
  }
}
