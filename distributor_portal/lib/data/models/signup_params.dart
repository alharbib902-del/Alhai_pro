/// Parameters for distributor self-service signup.
class SignupParams {
  final String email;
  final String password;
  final String companyName;
  final String? companyNameEn;
  final String phoneNumber;
  final String commercialRegister;
  final String vatNumber;
  final String city;
  final String address;
  final bool acceptedTerms;

  const SignupParams({
    required this.email,
    required this.password,
    required this.companyName,
    this.companyNameEn,
    required this.phoneNumber,
    required this.commercialRegister,
    required this.vatNumber,
    required this.city,
    required this.address,
    required this.acceptedTerms,
  });
}

/// Result of a successful distributor signup.
class DistributorSignupResult {
  final String distributorId;
  final String email;
  final bool requiresEmailVerification;

  const DistributorSignupResult({
    required this.distributorId,
    required this.email,
    required this.requiresEmailVerification,
  });
}
