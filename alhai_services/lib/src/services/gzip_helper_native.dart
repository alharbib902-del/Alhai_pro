import 'dart:io' show gzip;

/// Native implementation using dart:io GZipCodec for gzip compression.

List<int> gzipEncode(List<int> bytes) {
  return gzip.encode(bytes);
}

List<int> gzipDecode(List<int> bytes) {
  return gzip.decode(bytes);
}
