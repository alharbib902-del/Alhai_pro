/// Holds ZATCA certificate details for signing and API authentication
class CertificateInfo {
  /// The X.509 certificate in PEM format
  final String certificatePem;

  /// The private key in PEM format
  final String privateKeyPem;

  /// Compliance Certificate Security Identifier (CSID)
  final String csid;

  /// Secret for API authentication (base64 encoded CSID:secret)
  final String secret;

  /// Certificate serial number
  final String? serialNumber;

  /// Certificate issuer name
  final String? issuerName;

  /// Certificate subject name
  final String? subjectName;

  /// Certificate valid from date
  final DateTime? validFrom;

  /// Certificate valid to date
  final DateTime? validTo;

  /// Whether this is a production or compliance certificate
  final bool isProduction;

  const CertificateInfo({
    required this.certificatePem,
    required this.privateKeyPem,
    required this.csid,
    required this.secret,
    this.serialNumber,
    this.issuerName,
    this.subjectName,
    this.validFrom,
    this.validTo,
    this.isProduction = false,
  });

  /// Whether the certificate is still valid (not expired)
  bool get isValid {
    if (validTo == null) return true;
    return DateTime.now().isBefore(validTo!);
  }

  /// Days until expiration, or null if no expiry date
  int? get daysUntilExpiry {
    if (validTo == null) return null;
    return validTo!.difference(DateTime.now()).inDays;
  }

  /// Whether the certificate is close to expiration (< 30 days)
  bool get isNearExpiry {
    final days = daysUntilExpiry;
    return days != null && days < 30;
  }

  CertificateInfo copyWith({
    String? certificatePem,
    String? privateKeyPem,
    String? csid,
    String? secret,
    String? serialNumber,
    String? issuerName,
    String? subjectName,
    DateTime? validFrom,
    DateTime? validTo,
    bool? isProduction,
  }) {
    return CertificateInfo(
      certificatePem: certificatePem ?? this.certificatePem,
      privateKeyPem: privateKeyPem ?? this.privateKeyPem,
      csid: csid ?? this.csid,
      secret: secret ?? this.secret,
      serialNumber: serialNumber ?? this.serialNumber,
      issuerName: issuerName ?? this.issuerName,
      subjectName: subjectName ?? this.subjectName,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      isProduction: isProduction ?? this.isProduction,
    );
  }

  Map<String, dynamic> toJson() => {
        'certificatePem': certificatePem,
        'privateKeyPem': privateKeyPem,
        'csid': csid,
        'secret': secret,
        if (serialNumber != null) 'serialNumber': serialNumber,
        if (issuerName != null) 'issuerName': issuerName,
        if (subjectName != null) 'subjectName': subjectName,
        if (validFrom != null) 'validFrom': validFrom!.toIso8601String(),
        if (validTo != null) 'validTo': validTo!.toIso8601String(),
        'isProduction': isProduction,
      };

  factory CertificateInfo.fromJson(Map<String, dynamic> json) =>
      CertificateInfo(
        certificatePem: json['certificatePem'] as String,
        privateKeyPem: json['privateKeyPem'] as String,
        csid: json['csid'] as String,
        secret: json['secret'] as String,
        serialNumber: json['serialNumber'] as String?,
        issuerName: json['issuerName'] as String?,
        subjectName: json['subjectName'] as String?,
        validFrom: json['validFrom'] != null
            ? DateTime.parse(json['validFrom'] as String)
            : null,
        validTo: json['validTo'] != null
            ? DateTime.parse(json['validTo'] as String)
            : null,
        isProduction: json['isProduction'] as bool? ?? false,
      );
}
