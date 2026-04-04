/// Raw ESC/POS command builder for thermal printers
///
/// Generates byte sequences for ESC/POS compatible thermal printers.
/// Supports text formatting, alignment, Arabic UTF-8, QR codes,
/// barcodes, and cash drawer control without external dependencies.
library;

import 'dart:convert';
import 'dart:typed_data';

/// Text alignment for ESC/POS
enum EscPosAlign { left, center, right }

/// Text size multiplier
enum EscPosTextSize { normal, doubleWidth, doubleHeight, quadArea }

/// ESC/POS command builder
///
/// Builds a byte buffer of ESC/POS commands that can be sent to any
/// ESC/POS compatible thermal printer over Bluetooth, TCP, or USB.
class EscPosCommandBuilder {
  final List<int> _buffer = [];
  final int _charsPerLine;

  EscPosCommandBuilder({int charsPerLine = 48}) : _charsPerLine = charsPerLine;

  /// Characters per line for the current paper size
  int get charsPerLine => _charsPerLine;

  // ─── Initialization ────────────────────────────────────

  /// Initialize printer (ESC @)
  EscPosCommandBuilder initialize() {
    _buffer.addAll([0x1B, 0x40]); // ESC @
    return this;
  }

  // ─── Text Alignment ────────────────────────────────────

  /// Set text alignment (ESC a n)
  EscPosCommandBuilder setAlign(EscPosAlign align) {
    final n = switch (align) {
      EscPosAlign.left => 0,
      EscPosAlign.center => 1,
      EscPosAlign.right => 2,
    };
    _buffer.addAll([0x1B, 0x61, n]); // ESC a n
    return this;
  }

  // ─── Text Size ─────────────────────────────────────────

  /// Set text size (GS ! n)
  EscPosCommandBuilder setTextSize(EscPosTextSize size) {
    final n = switch (size) {
      EscPosTextSize.normal => 0x00,
      EscPosTextSize.doubleWidth => 0x10,
      EscPosTextSize.doubleHeight => 0x01,
      EscPosTextSize.quadArea => 0x11,
    };
    _buffer.addAll([0x1D, 0x21, n]); // GS ! n
    return this;
  }

  // ─── Text Style ────────────────────────────────────────

  /// Set bold on/off (ESC E n)
  EscPosCommandBuilder setBold(bool on) {
    _buffer.addAll([0x1B, 0x45, on ? 1 : 0]); // ESC E n
    return this;
  }

  /// Set underline on/off (ESC - n)
  EscPosCommandBuilder setUnderline(bool on) {
    _buffer.addAll([0x1B, 0x2D, on ? 1 : 0]); // ESC - n
    return this;
  }

  /// Set inverted (white on black) on/off (GS B n)
  EscPosCommandBuilder setInverted(bool on) {
    _buffer.addAll([0x1D, 0x42, on ? 1 : 0]); // GS B n
    return this;
  }

  // ─── Character Encoding ────────────────────────────────

  /// Select UTF-8 encoding mode
  ///
  /// Sends ESC t 28 to select code page UTF-8 on printers that support it.
  /// For printers using multilingual mode, sends FS & to enable Kanji/CJK.
  EscPosCommandBuilder setUtf8Mode() {
    // Select character code table: UTF-8 (code page 28 on many printers)
    _buffer.addAll([0x1B, 0x74, 0x1C]); // ESC t 28
    return this;
  }

  /// Set international character set (ESC R n)
  /// n=15 for Arabic on some printers
  EscPosCommandBuilder setInternationalCharSet(int n) {
    _buffer.addAll([0x1B, 0x52, n & 0xFF]); // ESC R n
    return this;
  }

  // ─── Text Output ───────────────────────────────────────

  /// Print a line of UTF-8 text followed by a newline
  EscPosCommandBuilder printLine(String text) {
    _buffer.addAll(utf8.encode(text));
    _buffer.add(0x0A); // LF
    return this;
  }

  /// Print text without a trailing newline
  EscPosCommandBuilder printText(String text) {
    _buffer.addAll(utf8.encode(text));
    return this;
  }

  /// Print an empty line
  EscPosCommandBuilder emptyLine() {
    _buffer.add(0x0A);
    return this;
  }

  /// Feed n lines (ESC d n)
  EscPosCommandBuilder feedLines(int n) {
    _buffer.addAll([0x1B, 0x64, n & 0xFF]); // ESC d n
    return this;
  }

  // ─── Separator Lines ───────────────────────────────────

  /// Print a dashed separator line
  EscPosCommandBuilder dashLine() {
    _buffer.addAll(utf8.encode('-' * _charsPerLine));
    _buffer.add(0x0A);
    return this;
  }

  /// Print a double-line separator
  EscPosCommandBuilder doubleLine() {
    _buffer.addAll(utf8.encode('=' * _charsPerLine));
    _buffer.add(0x0A);
    return this;
  }

  // ─── Columnar Text ─────────────────────────────────────

  /// Print two columns: left-aligned and right-aligned on the same line
  EscPosCommandBuilder printTwoColumns(String left, String right) {
    final totalWidth = _charsPerLine;
    final leftBytes = utf8.encode(left);
    final rightBytes = utf8.encode(right);

    // Estimate character widths (Arabic chars may be wider)
    final leftLen = _estimateWidth(left);
    final rightLen = _estimateWidth(right);
    final padding = totalWidth - leftLen - rightLen;

    if (padding > 0) {
      _buffer.addAll(leftBytes);
      _buffer.addAll(utf8.encode(' ' * padding));
      _buffer.addAll(rightBytes);
    } else {
      // Not enough space, just print with a single space
      _buffer.addAll(leftBytes);
      _buffer.add(0x20);
      _buffer.addAll(rightBytes);
    }
    _buffer.add(0x0A);
    return this;
  }

  /// Print three columns (left, center, right)
  EscPosCommandBuilder printThreeColumns(
    String left,
    String center,
    String right,
  ) {
    final totalWidth = _charsPerLine;
    final leftLen = _estimateWidth(left);
    final centerLen = _estimateWidth(center);
    final rightLen = _estimateWidth(right);

    final totalContent = leftLen + centerLen + rightLen;
    final remainingSpace = totalWidth - totalContent;

    if (remainingSpace >= 2) {
      final leftPad = remainingSpace ~/ 2;
      final rightPad = remainingSpace - leftPad;
      _buffer.addAll(utf8.encode(left));
      _buffer.addAll(utf8.encode(' ' * leftPad));
      _buffer.addAll(utf8.encode(center));
      _buffer.addAll(utf8.encode(' ' * rightPad));
      _buffer.addAll(utf8.encode(right));
    } else {
      _buffer.addAll(utf8.encode('$left $center $right'));
    }
    _buffer.add(0x0A);
    return this;
  }

  // ─── QR Code ───────────────────────────────────────────

  /// Print a QR code using GS ( k commands
  ///
  /// [data] is the content to encode (typically base64 ZATCA TLV).
  /// [moduleSize] controls the dot size (1-16, default 6).
  /// [errorCorrection] is the error correction level (48=L, 49=M, 50=Q, 51=H).
  EscPosCommandBuilder printQrCode(
    String data, {
    int moduleSize = 6,
    int errorCorrection = 49, // M
  }) {
    final dataBytes = utf8.encode(data);
    final storeLen = dataBytes.length + 3; // pL pH cn fn m d1...dk

    // GS ( k - Set QR model to Model 2
    _buffer.addAll([
      0x1D, 0x28, 0x6B, // GS ( k
      0x04, 0x00, // pL pH (4 bytes follow)
      0x31, // cn
      0x41, // fn (model)
      0x32, 0x00, // Model 2
    ]);

    // GS ( k - Set QR module size
    _buffer.addAll([
      0x1D, 0x28, 0x6B, // GS ( k
      0x03, 0x00, // pL pH (3 bytes follow)
      0x31, // cn
      0x43, // fn (module size)
      moduleSize & 0xFF,
    ]);

    // GS ( k - Set QR error correction level
    _buffer.addAll([
      0x1D, 0x28, 0x6B, // GS ( k
      0x03, 0x00, // pL pH (3 bytes follow)
      0x31, // cn
      0x45, // fn (error correction)
      errorCorrection & 0xFF,
    ]);

    // GS ( k - Store QR data
    _buffer.addAll([
      0x1D, 0x28, 0x6B, // GS ( k
      storeLen & 0xFF, (storeLen >> 8) & 0xFF, // pL pH
      0x31, // cn
      0x50, // fn (store)
      0x30, // m
    ]);
    _buffer.addAll(dataBytes);

    // GS ( k - Print QR code
    _buffer.addAll([
      0x1D, 0x28, 0x6B, // GS ( k
      0x03, 0x00, // pL pH
      0x31, // cn
      0x51, // fn (print)
      0x30, // m
    ]);

    return this;
  }

  // ─── Barcode ───────────────────────────────────────────

  /// Print a Code128 barcode
  EscPosCommandBuilder printBarcode128(String data, {int height = 60}) {
    // Set barcode height
    _buffer.addAll([0x1D, 0x68, height & 0xFF]); // GS h n

    // Set barcode width (module)
    _buffer.addAll([0x1D, 0x77, 0x02]); // GS w 2

    // Set HRI print position below barcode
    _buffer.addAll([0x1D, 0x48, 0x02]); // GS H 2

    // Print Code128
    final barcodeBytes = utf8.encode(data);
    _buffer.addAll([
      0x1D, 0x6B, 73, // GS k 73 (Code128)
      barcodeBytes.length & 0xFF,
    ]);
    _buffer.addAll(barcodeBytes);

    return this;
  }

  // ─── Paper Control ─────────────────────────────────────

  /// Cut paper (GS V m)
  /// [partial] = true for partial cut, false for full cut
  EscPosCommandBuilder cutPaper({bool partial = true}) {
    if (partial) {
      _buffer.addAll([0x1D, 0x56, 0x01]); // GS V 1 (partial)
    } else {
      _buffer.addAll([0x1D, 0x56, 0x00]); // GS V 0 (full)
    }
    return this;
  }

  // ─── Cash Drawer ───────────────────────────────────────

  /// Send cash drawer kick pulse (ESC p m t1 t2)
  /// Pin 2: m=0, Pin 5: m=1
  EscPosCommandBuilder kickCashDrawer({int pin = 0}) {
    _buffer.addAll([
      0x1B, 0x70, // ESC p
      pin & 0x01, // m (pin)
      0x19, // t1 (25 * 2ms = 50ms)
      0xFA, // t2 (250 * 2ms = 500ms)
    ]);
    return this;
  }

  // ─── Build ─────────────────────────────────────────────

  /// Get the built byte buffer as Uint8List
  Uint8List build() => Uint8List.fromList(_buffer);

  /// Get the current byte count
  int get length => _buffer.length;

  /// Estimate the display width of a string on a thermal printer
  ///
  /// ASCII characters are 1 unit wide. Multi-byte UTF-8 characters
  /// (like Arabic) are estimated as 1 unit wide on most thermal printers
  /// since they use a monospaced bitmap font.
  int _estimateWidth(String text) {
    // For thermal printers with UTF-8 support, each character
    // typically occupies one column regardless of byte count
    return text.length;
  }
}
