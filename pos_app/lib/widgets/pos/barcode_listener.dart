// مكون مستمع الباركود - Barcode Listener
//
// يلتقط مدخلات لوحة المفاتيح السريعة من أجهزة مسح الباركود (barcode guns)
// ويبحث عن المنتج ويضيفه للسلة تلقائياً
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget يلف المحتوى ويستمع لمدخلات الباركود
///
/// أجهزة مسح الباركود ترسل أحرف بسرعة عالية (< 50ms بين كل حرف)
/// ثم ترسل Enter في النهاية. هذا المكون يميّز بين الكتابة العادية
/// ومسح الباركود بناءً على سرعة الإدخال.
class BarcodeListener extends StatefulWidget {
  final Widget child;
  final void Function(String barcode) onBarcodeScanned;

  /// الحد الأقصى للفاصل بين أحرف الباركود (بالميلي ثانية)
  final int maxIntervalMs;

  /// الحد الأدنى لطول الباركود للقبول
  final int minBarcodeLength;

  const BarcodeListener({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
    this.maxIntervalMs = 50,
    this.minBarcodeLength = 4,
  });

  @override
  State<BarcodeListener> createState() => _BarcodeListenerState();
}

class _BarcodeListenerState extends State<BarcodeListener> {
  final StringBuffer _buffer = StringBuffer();
  DateTime? _lastKeyTime;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    // فقط نستمع لأحداث الضغط (KeyDown)
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;

    final now = DateTime.now();
    final character = event.character;

    // Enter = نهاية الباركود
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _processBuffer();
      return;
    }

    // تجاهل مفاتيح التحكم (Ctrl, Alt, Shift وحدها)
    if (character == null || character.isEmpty) return;

    // التحقق من سرعة الإدخال
    if (_lastKeyTime != null) {
      final interval = now.difference(_lastKeyTime!).inMilliseconds;
      if (interval > widget.maxIntervalMs) {
        // الإدخال بطيء = كتابة يدوية، إعادة تعيين
        _buffer.clear();
      }
    }

    _buffer.write(character);
    _lastKeyTime = now;

    // إعادة تعيين تلقائي بعد فترة من عدم النشاط
    _resetTimer?.cancel();
    _resetTimer = Timer(Duration(milliseconds: widget.maxIntervalMs * 3), () {
      _processBuffer();
    });
  }

  void _processBuffer() {
    _resetTimer?.cancel();
    final barcode = _buffer.toString().trim();
    _buffer.clear();
    _lastKeyTime = null;

    if (barcode.length >= widget.minBarcodeLength) {
      widget.onBarcodeScanned(barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: false,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
