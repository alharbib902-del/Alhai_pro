/// Money — integer-minor-units value type for safe financial arithmetic.
///
/// ## Why
///
/// IEEE 754 doubles cannot represent decimal fractions exactly: a value like
/// `37.8` SAR is stored internally as `37.79999999999999715…`. Multiplying,
/// summing, or comparing such values accumulates error. Storing the value as
/// an integer count of minor units (halalas for SAR, cents for USD, etc.)
/// eliminates this class of bug at the type boundary.
///
/// ## Currency awareness (plan D2)
///
/// Every [Money] carries an ISO-4217 `currencyCode`, defaulting to `'SAR'`.
/// Arithmetic operators assert matching currencies at runtime and throw
/// [ArgumentError] on mismatch. This prevents silent SAR+USD additions when
/// multi-currency data enters the system later; nothing in the current
/// SAR-only workflow changes.
///
/// ## Rounding policy (plan D1)
///
/// Conversions from a `double` major-unit amount (e.g. [Money.fromDouble]) use
/// **ROUND_HALF_UP**: halves round away from zero (2.5 → 3, -2.5 → -3). This
/// is the Java `BigDecimal.HALF_UP` / ZATCA reference convention. Dart's
/// built-in `round` uses round-half-to-even (banker's); we override explicitly.
library;

class Money implements Comparable<Money> {
  /// Amount in minor units. For SAR, 100 halalas = 1 SAR.
  final int cents;

  /// ISO-4217 currency code (e.g. 'SAR', 'USD'). Defaults to 'SAR'.
  final String currencyCode;

  /// Build from a minor-units integer amount.
  const Money.fromCents(this.cents, {this.currencyCode = 'SAR'});

  /// Convenience constructor for the overwhelmingly-common SAR case.
  const Money.sar(this.cents) : currencyCode = 'SAR';

  /// Zero value in the given currency.
  const Money.zero({this.currencyCode = 'SAR'}) : cents = 0;

  /// Build from a double major-unit amount (e.g. 37.8 SAR → 3780 cents).
  ///
  /// Uses ROUND_HALF_UP: halves round away from zero (plan D1).
  factory Money.fromDouble(double d, {String currencyCode = 'SAR'}) {
    return Money.fromCents(
      _roundHalfUp(d * 100),
      currencyCode: currencyCode,
    );
  }

  /// Convert back to double major units. Use only at display / boundary sites.
  double toDouble() => cents / 100.0;

  // ── Arithmetic ─────────────────────────────────────────────────────────────

  Money operator +(Money other) {
    _assertSameCurrency(other, '+');
    return Money.fromCents(cents + other.cents, currencyCode: currencyCode);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other, '-');
    return Money.fromCents(cents - other.cents, currencyCode: currencyCode);
  }

  Money operator -() =>
      Money.fromCents(-cents, currencyCode: currencyCode);

  /// Multiply by a scalar. Rounds ROUND_HALF_UP.
  /// Common use: `unitPrice * quantity`.
  Money operator *(num factor) => Money.fromCents(
        _roundHalfUp(cents * factor),
        currencyCode: currencyCode,
      );

  /// Divide by a scalar. Rounds ROUND_HALF_UP.
  /// Throws [ArgumentError] on divide-by-zero.
  Money operator /(num divisor) {
    if (divisor == 0) {
      throw ArgumentError('Cannot divide Money by zero');
    }
    return Money.fromCents(
      _roundHalfUp(cents / divisor),
      currencyCode: currencyCode,
    );
  }

  // ── Comparison ─────────────────────────────────────────────────────────────

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other, 'compareTo');
    return cents.compareTo(other.cents);
  }

  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;
  bool operator >(Money other) => compareTo(other) > 0;
  bool operator >=(Money other) => compareTo(other) >= 0;

  // ── Predicates ─────────────────────────────────────────────────────────────

  bool get isZero => cents == 0;
  bool get isPositive => cents > 0;
  bool get isNegative => cents < 0;

  Money abs() =>
      Money.fromCents(cents.abs(), currencyCode: currencyCode);

  // ── JSON ───────────────────────────────────────────────────────────────────

  /// Wire format `{"cents": 9999, "currency": "SAR"}`. Extensible without
  /// breaking: adding USD/AED rows requires no schema change.
  Map<String, dynamic> toJson() => {
        'cents': cents,
        'currency': currencyCode,
      };

  factory Money.fromJson(Map<String, dynamic> json) {
    final rawCents = json['cents'];
    if (rawCents is! int) {
      throw FormatException(
        'Money.fromJson: "cents" must be int, got ${rawCents.runtimeType}',
      );
    }
    final rawCurrency = json['currency'];
    if (rawCurrency is! String) {
      throw FormatException(
        'Money.fromJson: "currency" must be String, got ${rawCurrency.runtimeType}',
      );
    }
    return Money.fromCents(rawCents, currencyCode: rawCurrency);
  }

  // ── Equality / Hash / String ───────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.cents == cents &&
      other.currencyCode == currencyCode;

  @override
  int get hashCode => Object.hash(cents, currencyCode);

  @override
  String toString() => 'Money($cents $currencyCode)';

  // ── Internal ───────────────────────────────────────────────────────────────

  /// ROUND_HALF_UP: halves round away from zero (2.5 → 3, -2.5 → -3).
  static int _roundHalfUp(num raw) {
    if (raw >= 0) return (raw + 0.5).floor();
    return -((-raw) + 0.5).floor();
  }

  void _assertSameCurrency(Money other, String op) {
    if (currencyCode != other.currencyCode) {
      throw ArgumentError(
        'Currency mismatch on $op: '
        'cannot combine $currencyCode and ${other.currencyCode}',
      );
    }
  }
}
