/// ESC/POS receipt builder stub for web builds
///
/// The actual esc_pos_utils package is not available on web due to
/// dependency conflicts. This stub returns empty bytes for all operations.
library;

import 'dart:typed_data';

import 'receipt_data.dart';
import 'print_service.dart' show PaperSize;

/// Builds ESC/POS byte commands for a thermal receipt (stub for web)
class ReceiptBuilder {
  ReceiptBuilder._();

  /// Build complete receipt bytes from structured data
  static Future<Uint8List> build(
    ReceiptData receipt, {
    PaperSize size = PaperSize.mm80,
  }) async =>
      Uint8List(0);

  /// Build test page bytes
  static Future<Uint8List> buildTestPage({
    PaperSize size = PaperSize.mm80,
  }) async =>
      Uint8List(0);

  /// Build cash drawer kick bytes
  static Future<Uint8List> buildCashDrawerKick({
    PaperSize size = PaperSize.mm80,
  }) async =>
      Uint8List(0);
}
