/// Organization settings model.
///
/// Maps to the Supabase `organizations` table.
library;

class OrgSettings {
  final String id;
  final String companyName;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? country;
  final String? taxNumber;
  final String? commercialReg;
  final String? deliveryZones;
  final double? minOrderAmount;
  final double? deliveryFee;
  final double? freeDeliveryMin;
  final bool freeDeliveryEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;

  const OrgSettings({
    required this.id,
    required this.companyName,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.country,
    this.taxNumber,
    this.commercialReg,
    this.deliveryZones,
    this.minOrderAmount,
    this.deliveryFee,
    this.freeDeliveryMin,
    this.freeDeliveryEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
  });

  factory OrgSettings.fromJson(Map<String, dynamic> json) {
    return OrgSettings(
      id: json['id'] as String,
      companyName: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      taxNumber: json['tax_number'] as String?,
      commercialReg: json['commercial_reg'] as String?,
      deliveryZones: json['delivery_zones'] as String?,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      freeDeliveryMin: (json['free_delivery_min'] as num?)?.toDouble(),
      freeDeliveryEnabled: json['free_delivery_enabled'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      smsNotifications: json['sms_notifications'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': companyName,
    'phone': phone,
    'email': email,
    'address': address,
    'city': city,
    'country': country,
    'tax_number': taxNumber,
    'commercial_reg': commercialReg,
    'delivery_zones': deliveryZones,
    'min_order_amount': minOrderAmount,
    'delivery_fee': deliveryFee,
    'free_delivery_min': freeDeliveryMin,
    'free_delivery_enabled': freeDeliveryEnabled,
    'email_notifications': emailNotifications,
    'push_notifications': pushNotifications,
    'sms_notifications': smsNotifications,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrgSettings &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          companyName == other.companyName &&
          phone == other.phone &&
          email == other.email &&
          address == other.address &&
          city == other.city &&
          country == other.country &&
          taxNumber == other.taxNumber &&
          commercialReg == other.commercialReg &&
          deliveryZones == other.deliveryZones &&
          minOrderAmount == other.minOrderAmount &&
          deliveryFee == other.deliveryFee &&
          freeDeliveryMin == other.freeDeliveryMin &&
          freeDeliveryEnabled == other.freeDeliveryEnabled &&
          emailNotifications == other.emailNotifications &&
          pushNotifications == other.pushNotifications &&
          smsNotifications == other.smsNotifications;

  @override
  int get hashCode => Object.hash(
    id,
    companyName,
    phone,
    email,
    address,
    city,
    country,
    taxNumber,
    commercialReg,
    deliveryZones,
    minOrderAmount,
    deliveryFee,
    freeDeliveryMin,
    freeDeliveryEnabled,
    emailNotifications,
    pushNotifications,
    smsNotifications,
  );
}
