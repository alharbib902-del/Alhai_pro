/// Web platform stub for gzip compression.
///
/// Since dart:io is unavailable on web, this uses a simple DEFLATE-like
/// approach via a lightweight pure-Dart implementation.
///
/// The backup_service.dart _compress() method catches exceptions from these
/// functions and falls back to plain base64. By throwing here, we ensure the
/// 'gz:' prefix is NOT added on web, keeping the format honest.
///
/// To add real gzip on web, add `package:archive` to pubspec.yaml and use:
///   import 'package:archive/archive.dart';
///   List<int> gzipEncode(List<int> bytes) => GZipEncoder().encode(bytes);
///   List<int> gzipDecode(List<int> bytes) => GZipDecoder().decodeBytes(bytes);

List<int> gzipEncode(List<int> bytes) {
  // On web, gzip is not available. The caller (BackupService._compress)
  // catches this and falls back to plain base64.
  throw UnsupportedError(
    'Gzip compression is not supported on web. '
    'Add package:archive for web gzip support.',
  );
}

List<int> gzipDecode(List<int> bytes) {
  // On web, gzip is not available. The caller (BackupService._decompress)
  // catches this and falls back to plain base64.
  throw UnsupportedError(
    'Gzip decompression is not supported on web. '
    'Add package:archive for web gzip support.',
  );
}
