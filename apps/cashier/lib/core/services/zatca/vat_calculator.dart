/// حاسبة ضريبة القيمة المضافة (VAT) السعودية
///
/// النسبة الافتراضية: 15%
class VatCalculator {
  /// نسبة ضريبة القيمة المضافة الافتراضية
  static const double defaultRate = 0.15;

  /// حساب مبلغ الضريبة من المبلغ قبل الضريبة
  ///
  /// مثال: calculateVat(100) = 15.0
  static double calculateVat(double amountBeforeVat,
      {double rate = defaultRate}) {
    return amountBeforeVat * rate;
  }

  /// إضافة الضريبة للمبلغ (المبلغ + الضريبة)
  ///
  /// مثال: addVat(100) = 115.0
  static double addVat(double amountBeforeVat, {double rate = defaultRate}) {
    return amountBeforeVat * (1 + rate);
  }

  /// استخراج المبلغ قبل الضريبة من الإجمالي شامل الضريبة
  ///
  /// مثال: removeVat(115) = 100.0
  static double removeVat(double amountWithVat, {double rate = defaultRate}) {
    return amountWithVat / (1 + rate);
  }

  /// استخراج مبلغ الضريبة من الإجمالي شامل الضريبة
  ///
  /// مثال: extractVat(115) = 15.0
  static double extractVat(double amountWithVat, {double rate = defaultRate}) {
    return amountWithVat - removeVat(amountWithVat, rate: rate);
  }

  /// حساب تفاصيل الفاتورة الكاملة
  static VatBreakdown breakdown(double subtotal,
      {double discount = 0, double rate = defaultRate}) {
    final taxableAmount = subtotal - discount;
    final vatAmount = taxableAmount * rate;
    final total = taxableAmount + vatAmount;

    return VatBreakdown(
      subtotal: subtotal,
      discount: discount,
      taxableAmount: taxableAmount,
      vatRate: rate,
      vatAmount: vatAmount,
      total: total,
    );
  }
}

/// تفاصيل حساب الضريبة
class VatBreakdown {
  final double subtotal;
  final double discount;
  final double taxableAmount;
  final double vatRate;
  final double vatAmount;
  final double total;

  const VatBreakdown({
    required this.subtotal,
    required this.discount,
    required this.taxableAmount,
    required this.vatRate,
    required this.vatAmount,
    required this.total,
  });
}
