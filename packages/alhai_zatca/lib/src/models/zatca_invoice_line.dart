/// A single line item in a ZATCA invoice
///
/// Maps to UBL InvoiceLine element.
class ZatcaInvoiceLine {
  /// Unique line ID within the invoice (BT-126)
  final String lineId;

  /// Product/item name (BT-153)
  final String itemName;

  /// Quantity (BT-129)
  final double quantity;

  /// Unit of measure code (BT-130), e.g. 'PCE' for piece
  final String unitCode;

  /// Net price per unit (BT-146) - price excluding VAT
  final double unitPrice;

  /// Gross price per unit before any discount
  final double? grossPrice;

  /// Line-level discount amount (BT-136)
  final double discountAmount;

  /// Line-level discount reason
  final String? discountReason;

  /// VAT rate as percentage, e.g. 15.0 for 15%
  final double vatRate;

  /// VAT category code (BT-151): S=Standard, Z=Zero, E=Exempt, O=OutOfScope
  final String vatCategoryCode;

  /// VAT exemption reason (required when vatCategoryCode is E or Z)
  final String? vatExemptionReason;

  /// VAT exemption reason code
  final String? vatExemptionReasonCode;

  /// Product barcode / GTIN
  final String? barcode;

  /// Seller's item identifier
  final String? sellerItemId;

  const ZatcaInvoiceLine({
    required this.lineId,
    required this.itemName,
    required this.quantity,
    this.unitCode = 'PCE',
    required this.unitPrice,
    this.grossPrice,
    this.discountAmount = 0.0,
    this.discountReason,
    required this.vatRate,
    this.vatCategoryCode = 'S',
    this.vatExemptionReason,
    this.vatExemptionReasonCode,
    this.barcode,
    this.sellerItemId,
  });

  /// Net amount before VAT = (unitPrice * quantity) - discountAmount
  double get lineNetAmount => (unitPrice * quantity) - discountAmount;

  /// VAT amount for this line
  double get vatAmount => lineNetAmount * (vatRate / 100.0);

  /// Total including VAT
  double get lineTotal => lineNetAmount + vatAmount;

  /// Rounding helper - returns value rounded to 2 decimal places
  static double _round2(double value) => (value * 100).roundToDouble() / 100;

  /// Net amount rounded to 2 decimal places
  double get lineNetAmountRounded => _round2(lineNetAmount);

  /// VAT amount rounded to 2 decimal places
  double get vatAmountRounded => _round2(vatAmount);

  ZatcaInvoiceLine copyWith({
    String? lineId,
    String? itemName,
    double? quantity,
    String? unitCode,
    double? unitPrice,
    double? grossPrice,
    double? discountAmount,
    String? discountReason,
    double? vatRate,
    String? vatCategoryCode,
    String? vatExemptionReason,
    String? vatExemptionReasonCode,
    String? barcode,
    String? sellerItemId,
  }) {
    return ZatcaInvoiceLine(
      lineId: lineId ?? this.lineId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitCode: unitCode ?? this.unitCode,
      unitPrice: unitPrice ?? this.unitPrice,
      grossPrice: grossPrice ?? this.grossPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      discountReason: discountReason ?? this.discountReason,
      vatRate: vatRate ?? this.vatRate,
      vatCategoryCode: vatCategoryCode ?? this.vatCategoryCode,
      vatExemptionReason: vatExemptionReason ?? this.vatExemptionReason,
      vatExemptionReasonCode:
          vatExemptionReasonCode ?? this.vatExemptionReasonCode,
      barcode: barcode ?? this.barcode,
      sellerItemId: sellerItemId ?? this.sellerItemId,
    );
  }

  Map<String, dynamic> toJson() => {
        'lineId': lineId,
        'itemName': itemName,
        'quantity': quantity,
        'unitCode': unitCode,
        'unitPrice': unitPrice,
        if (grossPrice != null) 'grossPrice': grossPrice,
        'discountAmount': discountAmount,
        if (discountReason != null) 'discountReason': discountReason,
        'vatRate': vatRate,
        'vatCategoryCode': vatCategoryCode,
        if (vatExemptionReason != null)
          'vatExemptionReason': vatExemptionReason,
        if (vatExemptionReasonCode != null)
          'vatExemptionReasonCode': vatExemptionReasonCode,
        if (barcode != null) 'barcode': barcode,
        if (sellerItemId != null) 'sellerItemId': sellerItemId,
      };

  factory ZatcaInvoiceLine.fromJson(Map<String, dynamic> json) =>
      ZatcaInvoiceLine(
        lineId: json['lineId'] as String,
        itemName: json['itemName'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unitCode: json['unitCode'] as String? ?? 'PCE',
        unitPrice: (json['unitPrice'] as num).toDouble(),
        grossPrice: (json['grossPrice'] as num?)?.toDouble(),
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
        discountReason: json['discountReason'] as String?,
        vatRate: (json['vatRate'] as num).toDouble(),
        vatCategoryCode: json['vatCategoryCode'] as String? ?? 'S',
        vatExemptionReason: json['vatExemptionReason'] as String?,
        vatExemptionReasonCode: json['vatExemptionReasonCode'] as String?,
        barcode: json['barcode'] as String?,
        sellerItemId: json['sellerItemId'] as String?,
      );
}
