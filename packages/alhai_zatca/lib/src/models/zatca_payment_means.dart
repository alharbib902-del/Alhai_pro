/// Wave 10 (P0-11): ZATCA-compliant per-tender payment-means entry.
///
/// ZATCA Phase 2 UBL XML expects one `<cac:PaymentMeans>` element per
/// payment method on the invoice. A mixed-payment sale (e.g. 50 cash
/// + 30 card + 20 credit) has THREE elements, one per tender. The
/// legacy `ZatcaInvoice.paymentMeansCode` was a single string — which
/// works for cash-only / card-only invoices but silently produces a
/// non-compliant XML for mixed-payment ones.
///
/// This model lets a caller pass a list of tenders. If
/// [ZatcaInvoice.paymentMeans] is null/empty the builder still emits a
/// single legacy element so existing callers keep working unchanged.
class ZatcaPaymentMeans {
  /// ZATCA payment means code (BT-81):
  ///   '10' = cash
  ///   '30' = credit transfer
  ///   '42' = bank account
  ///   '48' = card
  ///   '49' = direct debit
  /// Use the cash code for any "covered now" portion and 30 for "owed
  /// later" portions; the cashier app's mixed/credit semantics map
  /// straightforwardly.
  final String code;

  /// Optional: amount of the invoice's grand total this tender covers
  /// (gross, in the invoice's currency). Encoded as `cbc:PayableAmount`
  /// when set. ZATCA accepts the field but doesn't require it for
  /// Simplified invoices.
  final double? amount;

  /// Optional free-text instruction (BT-82) shown on the printed
  /// receipt and the portal entry.
  final String? note;

  const ZatcaPaymentMeans({
    required this.code,
    this.amount,
    this.note,
  });

  @override
  bool operator ==(Object other) =>
      other is ZatcaPaymentMeans &&
      other.code == code &&
      other.amount == amount &&
      other.note == note;

  @override
  int get hashCode => Object.hash(code, amount, note);

  @override
  String toString() =>
      'ZatcaPaymentMeans(code: $code, amount: $amount, note: $note)';
}
