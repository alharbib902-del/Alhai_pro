/// VAT calculation utilities for ZATCA invoices
///
/// Handles Saudi Arabia VAT calculations with proper rounding
/// per ZATCA requirements. All monetary amounts are rounded to
/// 2 decimal places using banker's rounding.
class VatCalculator {
  const VatCalculator._();

  /// Standard Saudi VAT rate (15%)
  static const double standardRate = 15.0;

  /// Zero rate (for zero-rated goods)
  static const double zeroRate = 0.0;

  // ─── Core Calculations ──────────────────────────────────────

  /// Add VAT to a net (exclusive) amount
  ///
  /// Example: addVat(100.0) => 115.00 (at 15%)
  static double addVat({
    required double netAmount,
    double vatRate = standardRate,
  }) {
    return _round2(netAmount * (1 + vatRate / 100.0));
  }

  /// Remove VAT from a gross (inclusive) amount to get the net
  ///
  /// Example: removeVat(115.0) => 100.00 (at 15%)
  static double removeVat({
    required double grossAmount,
    double vatRate = standardRate,
  }) {
    return _round2(grossAmount / (1 + vatRate / 100.0));
  }

  /// Extract just the VAT amount from a gross (inclusive) amount
  ///
  /// Example: extractVat(115.0) => 15.00 (at 15%)
  static double extractVat({
    required double grossAmount,
    double vatRate = standardRate,
  }) {
    final net = grossAmount / (1 + vatRate / 100.0);
    return _round2(grossAmount - net);
  }

  /// Calculate VAT amount from a net (exclusive) amount
  ///
  /// Example: vatFromNet(100.0) => 15.00 (at 15%)
  static double vatFromNet({
    required double netAmount,
    double vatRate = standardRate,
  }) {
    return _round2(netAmount * vatRate / 100.0);
  }

  /// Calculate VAT amount from a gross (inclusive) amount
  ///
  /// Example: vatFromGross(115.0) => 15.00 (at 15%)
  static double vatFromGross({
    required double grossAmount,
    double vatRate = standardRate,
  }) {
    return _round2(grossAmount -
        netFromGross(
          grossAmount: grossAmount,
          vatRate: vatRate,
        ));
  }

  /// Extract net amount from gross (VAT-inclusive) amount
  ///
  /// Example: netFromGross(115.0) => 100.00 (at 15%)
  static double netFromGross({
    required double grossAmount,
    double vatRate = standardRate,
  }) {
    return _round2(grossAmount / (1 + vatRate / 100.0));
  }

  /// Calculate gross amount from net amount
  ///
  /// Example: grossFromNet(100.0) => 115.00 (at 15%)
  static double grossFromNet({
    required double netAmount,
    double vatRate = standardRate,
  }) {
    return _round2(netAmount * (1 + vatRate / 100.0));
  }

  // ─── Breakdown ──────────────────────────────────────────────

  /// Get a full VAT breakdown from a net amount
  ///
  /// Returns net, VAT, and gross amounts.
  static VatBreakdown breakdownFromNet({
    required double netAmount,
    double vatRate = standardRate,
  }) {
    final net = _round2(netAmount);
    final vat = _round2(net * vatRate / 100.0);
    final gross = _round2(net + vat);

    return VatBreakdown(
      netAmount: net,
      vatAmount: vat,
      grossAmount: gross,
      vatRate: vatRate,
    );
  }

  /// Get a full VAT breakdown from a gross amount
  ///
  /// Returns net, VAT, and gross amounts.
  static VatBreakdown breakdownFromGross({
    required double grossAmount,
    double vatRate = standardRate,
  }) {
    final gross = _round2(grossAmount);
    final net = _round2(gross / (1 + vatRate / 100.0));
    final vat = _round2(gross - net);

    return VatBreakdown(
      netAmount: net,
      vatAmount: vat,
      grossAmount: gross,
      vatRate: vatRate,
    );
  }

  /// Calculate breakdown for a line item (quantity * unit price - discount)
  static VatBreakdown lineBreakdown({
    required double unitPrice,
    required double quantity,
    double discount = 0.0,
    double vatRate = standardRate,
  }) {
    final lineNet = _round2((unitPrice * quantity) - discount);
    return breakdownFromNet(netAmount: lineNet, vatRate: vatRate);
  }

  // ─── Validation ─────────────────────────────────────────────

  /// Validate that totals are consistent (net + vat = gross)
  ///
  /// Uses a tolerance of 0.01 SAR to account for rounding.
  static bool validateTotals({
    required double netAmount,
    required double vatAmount,
    required double grossAmount,
    double tolerance = 0.01,
  }) {
    final expected = netAmount + vatAmount;
    return (expected - grossAmount).abs() <= tolerance;
  }

  /// Validate that a VAT amount matches the expected rate
  static bool validateVatAmount({
    required double netAmount,
    required double vatAmount,
    double vatRate = standardRate,
    double tolerance = 0.01,
  }) {
    final expected = _round2(netAmount * vatRate / 100.0);
    return (expected - vatAmount).abs() <= tolerance;
  }

  // ─── Multi-line Totals ──────────────────────────────────────

  /// Sum up breakdowns from multiple line items
  ///
  /// Useful for computing invoice-level totals from individual lines.
  static VatBreakdown sumBreakdowns(List<VatBreakdown> breakdowns) {
    var totalNet = 0.0;
    var totalVat = 0.0;
    var totalGross = 0.0;

    for (final b in breakdowns) {
      totalNet += b.netAmount;
      totalVat += b.vatAmount;
      totalGross += b.grossAmount;
    }

    return VatBreakdown(
      netAmount: _round2(totalNet),
      vatAmount: _round2(totalVat),
      grossAmount: _round2(totalGross),
      vatRate: breakdowns.isNotEmpty ? breakdowns.first.vatRate : standardRate,
    );
  }

  // ─── Rounding ───────────────────────────────────────────────

  /// Round to 2 decimal places per ZATCA requirements
  ///
  /// Uses standard arithmetic rounding (0.5 rounds up).
  static double _round2(double value) => (value * 100).roundToDouble() / 100;
}

/// Complete VAT breakdown with net, VAT, and gross amounts
class VatBreakdown {
  /// Net amount (excluding VAT)
  final double netAmount;

  /// VAT amount
  final double vatAmount;

  /// Gross amount (including VAT)
  final double grossAmount;

  /// VAT rate applied (percentage)
  final double vatRate;

  const VatBreakdown({
    required this.netAmount,
    required this.vatAmount,
    required this.grossAmount,
    required this.vatRate,
  });

  @override
  String toString() => 'VatBreakdown(net: $netAmount, vat: $vatAmount, '
      'gross: $grossAmount, rate: $vatRate%)';
}
