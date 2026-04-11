/// Seller (supplier) information for ZATCA invoice
///
/// Maps to UBL AccountingSupplierParty
class ZatcaSeller {
  /// Seller's registered name (BT-27)
  final String name;

  /// VAT registration number (BT-31) - 15 digits starting with 3
  final String vatNumber;

  /// Commercial Registration Number
  final String? crNumber;

  /// Street name (BT-35)
  final String streetName;

  /// Building number (KSA-17)
  final String buildingNumber;

  /// Plot identification / additional street (KSA-23)
  final String? plotIdentification;

  /// City (BT-37)
  final String city;

  /// City sub-division / district (KSA-3)
  final String? district;

  /// Postal code (BT-38)
  final String postalCode;

  /// Country code (BT-40), always 'SA' for Saudi Arabia
  final String countryCode;

  /// Additional ID (e.g., 10-digit TIN)
  final String? additionalId;

  /// Additional ID scheme (e.g., 'CRN', 'MOM', 'MLS', '700', 'SAG', 'NAT', 'GCC', 'IQA', 'OTH')
  final String? additionalIdScheme;

  const ZatcaSeller({
    required this.name,
    required this.vatNumber,
    this.crNumber,
    required this.streetName,
    required this.buildingNumber,
    this.plotIdentification,
    required this.city,
    this.district,
    required this.postalCode,
    this.countryCode = 'SA',
    this.additionalId,
    this.additionalIdScheme,
  });

  /// Validate VAT number format (15 digits, starts with 3)
  bool get isVatValid =>
      vatNumber.length == 15 &&
      vatNumber.startsWith('3') &&
      RegExp(r'^\d+$').hasMatch(vatNumber);

  /// Create a copy with modified fields
  ZatcaSeller copyWith({
    String? name,
    String? vatNumber,
    String? crNumber,
    String? streetName,
    String? buildingNumber,
    String? plotIdentification,
    String? city,
    String? district,
    String? postalCode,
    String? countryCode,
    String? additionalId,
    String? additionalIdScheme,
  }) {
    return ZatcaSeller(
      name: name ?? this.name,
      vatNumber: vatNumber ?? this.vatNumber,
      crNumber: crNumber ?? this.crNumber,
      streetName: streetName ?? this.streetName,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      plotIdentification: plotIdentification ?? this.plotIdentification,
      city: city ?? this.city,
      district: district ?? this.district,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      additionalId: additionalId ?? this.additionalId,
      additionalIdScheme: additionalIdScheme ?? this.additionalIdScheme,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'vatNumber': vatNumber,
    if (crNumber != null) 'crNumber': crNumber,
    'streetName': streetName,
    'buildingNumber': buildingNumber,
    if (plotIdentification != null) 'plotIdentification': plotIdentification,
    'city': city,
    if (district != null) 'district': district,
    'postalCode': postalCode,
    'countryCode': countryCode,
    if (additionalId != null) 'additionalId': additionalId,
    if (additionalIdScheme != null) 'additionalIdScheme': additionalIdScheme,
  };

  factory ZatcaSeller.fromJson(Map<String, dynamic> json) => ZatcaSeller(
    name: json['name'] as String,
    vatNumber: json['vatNumber'] as String,
    crNumber: json['crNumber'] as String?,
    streetName: json['streetName'] as String,
    buildingNumber: json['buildingNumber'] as String,
    plotIdentification: json['plotIdentification'] as String?,
    city: json['city'] as String,
    district: json['district'] as String?,
    postalCode: json['postalCode'] as String,
    countryCode: json['countryCode'] as String? ?? 'SA',
    additionalId: json['additionalId'] as String?,
    additionalIdScheme: json['additionalIdScheme'] as String?,
  );
}
