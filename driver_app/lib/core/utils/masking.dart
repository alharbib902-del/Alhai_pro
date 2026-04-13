/// Utility functions for masking sensitive data in logs and debug output.
///
/// These helpers ensure that PII (phone numbers, addresses) is never
/// written in full to console logs, Sentry breadcrumbs, or any other
/// non-UI output channel.
library;

/// Masks a phone number, showing only the last 4 digits.
///
/// Example: `+966501234567` -> `*********4567`
///
/// Returns the original string unchanged if it is 4 characters or shorter.
String maskPhoneNumber(String phone) {
  if (phone.length <= 4) return phone;
  final visible = phone.substring(phone.length - 4);
  return '${'*' * (phone.length - 4)}$visible';
}

/// Masks an address, showing only the first 6 characters followed by `***`.
///
/// Example: `شارع الملك فهد، حي العليا` -> `شارع ال***`
///
/// Returns `***` for empty strings.
String maskAddress(String address) {
  if (address.isEmpty) return '***';
  if (address.length <= 6) return '$address***';
  return '${address.substring(0, 6)}***';
}
