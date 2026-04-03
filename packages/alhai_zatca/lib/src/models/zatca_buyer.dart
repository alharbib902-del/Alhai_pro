/// Buyer (customer) information for ZATCA invoice
///
/// Maps to UBL AccountingCustomerParty.
/// For simplified invoices (B2C), buyer info is optional.
/// For standard invoices (B2B), buyer info is mandatory.
class ZatcaBuyer {
  /// Buyer name (BT-44)
  final String? name;

  /// Buyer VAT number (BT-48) - required for B2B
  final String? vatNumber;

  /// Buyer ID value (e.g., National ID, Iqama, etc.)
  final String? buyerId;

  /// Buyer ID scheme (NAT, IQA, TIN, CRN, PAS, OTH)
  final String? buyerIdScheme;

  /// Street name (BT-50)
  final String? streetName;

  /// Building number
  final String? buildingNumber;

  /// City (BT-52)
  final String? city;

  /// District
  final String? district;

  /// Postal code (BT-53)
  final String? postalCode;

  /// Country code (BT-55)
  final String? countryCode;

  const ZatcaBuyer({
    this.name,
    this.vatNumber,
    this.buyerId,
    this.buyerIdScheme,
    this.streetName,
    this.buildingNumber,
    this.city,
    this.district,
    this.postalCode,
    this.countryCode,
  });

  /// Whether this buyer has enough info for a standard (B2B) invoice
  bool get isValidForStandard =>
      name != null &&
      name!.isNotEmpty &&
      vatNumber != null &&
      vatNumber!.isNotEmpty;

  ZatcaBuyer copyWith({
    String? name,
    String? vatNumber,
    String? buyerId,
    String? buyerIdScheme,
    String? streetName,
    String? buildingNumber,
    String? city,
    String? district,
    String? postalCode,
    String? countryCode,
  }) {
    return ZatcaBuyer(
      name: name ?? this.name,
      vatNumber: vatNumber ?? this.vatNumber,
      buyerId: buyerId ?? this.buyerId,
      buyerIdScheme: buyerIdScheme ?? this.buyerIdScheme,
      streetName: streetName ?? this.streetName,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      city: city ?? this.city,
      district: district ?? this.district,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (vatNumber != null) 'vatNumber': vatNumber,
        if (buyerId != null) 'buyerId': buyerId,
        if (buyerIdScheme != null) 'buyerIdScheme': buyerIdScheme,
        if (streetName != null) 'streetName': streetName,
        if (buildingNumber != null) 'buildingNumber': buildingNumber,
        if (city != null) 'city': city,
        if (district != null) 'district': district,
        if (postalCode != null) 'postalCode': postalCode,
        if (countryCode != null) 'countryCode': countryCode,
      };

  factory ZatcaBuyer.fromJson(Map<String, dynamic> json) => ZatcaBuyer(
        name: json['name'] as String?,
        vatNumber: json['vatNumber'] as String?,
        buyerId: json['buyerId'] as String?,
        buyerIdScheme: json['buyerIdScheme'] as String?,
        streetName: json['streetName'] as String?,
        buildingNumber: json['buildingNumber'] as String?,
        city: json['city'] as String?,
        district: json['district'] as String?,
        postalCode: json['postalCode'] as String?,
        countryCode: json['countryCode'] as String?,
      );
}
