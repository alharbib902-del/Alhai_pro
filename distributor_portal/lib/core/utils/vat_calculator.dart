/// Saudi VAT (15%) calculation helper.
///
/// Used for order totals, pricing display, and report breakdowns.
/// Does NOT modify existing stored values — calculation only.
library;

class VatCalculator {
  VatCalculator._();

  /// Saudi Arabia standard VAT rate (15%).
  static const double saudiVatRate = 0.15;

  /// Calculate total with VAT from subtotal.
  static double withVat(double subtotal) {
    return subtotal * (1 + saudiVatRate);
  }

  /// Calculate the VAT amount from subtotal.
  static double vatAmount(double subtotal) {
    return subtotal * saudiVatRate;
  }

  /// Extract subtotal from a total that includes VAT.
  static double extractSubtotal(double total) {
    return total / (1 + saudiVatRate);
  }

  /// Full breakdown: subtotal, VAT, and total.
  static Map<String, double> breakdown(double subtotal) {
    return {
      'subtotal': subtotal,
      'vat': vatAmount(subtotal),
      'total': withVat(subtotal),
    };
  }
}
