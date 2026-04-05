/// Customer Display Service - خدمة شاشة العميل الثانية
///
/// تدير المزامنة بين شاشة الكاشير وشاشة العميل:
/// - BroadcastChannel للويب (cross-window communication)
/// - InMemoryDisplayChannel للعمليات داخل نفس النافذة / non-web
/// - تدعم فتح/إغلاق الشاشة الثانية
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'customer_display_state.dart';
import 'web_display_channel_factory.dart' as channel_factory;

// ============================================================================
// ABSTRACT CHANNEL (platform-agnostic)
// ============================================================================

/// قناة اتصال مع شاشة العميل (platform-agnostic)
abstract class CustomerDisplayChannel {
  /// إرسال حالة لشاشة العميل
  void sendState(CustomerDisplayState state);

  /// استقبال الحالات من الكاشير (للشاشة المستقبِلة)
  Stream<CustomerDisplayState> get stateStream;

  /// هل القناة متصلة
  bool get isConnected;

  /// إغلاق القناة
  void dispose();
}

// ============================================================================
// IN-MEMORY CHANNEL (fallback / desktop / testing)
// ============================================================================

/// قناة في الذاكرة - تعمل داخل نفس العملية
class InMemoryDisplayChannel implements CustomerDisplayChannel {
  static final _controller = StreamController<CustomerDisplayState>.broadcast();

  @override
  void sendState(CustomerDisplayState state) {
    if (!_controller.isClosed) {
      _controller.add(state);
    }
  }

  @override
  Stream<CustomerDisplayState> get stateStream => _controller.stream;

  @override
  bool get isConnected => !_controller.isClosed;

  @override
  void dispose() {
    // Don't close the static controller - it's shared
  }
}

// ============================================================================
// WEB BROADCAST CHANNEL (factory)
// ============================================================================

// The real WebBroadcastDisplayChannel is in web_display_channel.dart
// and is selected at compile time via conditional import in
// web_display_channel_factory.dart. See createWebDisplayChannel().

// ============================================================================
// CUSTOMER DISPLAY SERVICE
// ============================================================================

/// خدمة شاشة العميل الرئيسية
///
/// تُستخدم من الكاشير لإدارة شاشة العميل:
/// ```dart
/// final service = CustomerDisplayService();
/// service.showCart(items, subtotal, discount, tax, total);
/// service.showNfcWaiting(total);
/// service.showSuccess(total);
/// service.reset();
/// ```
class CustomerDisplayService {
  late final CustomerDisplayChannel _channel;
  bool _isEnabled = false;
  String _storeName = '';
  CustomerDisplayState _lastState = const CustomerDisplayState.idle();

  CustomerDisplayService({CustomerDisplayChannel? channel}) {
    _channel = channel ?? _createDefaultChannel();
  }

  /// Creates the platform-appropriate channel:
  /// - Web: real BroadcastChannel (cross-window)
  /// - Native: InMemoryDisplayChannel (same-process)
  static CustomerDisplayChannel _createDefaultChannel() {
    if (kIsWeb) {
      return channel_factory.createWebDisplayChannel();
    }
    return InMemoryDisplayChannel();
  }

  /// تفعيل الخدمة
  void enable({required String storeName}) {
    _isEnabled = true;
    _storeName = storeName;
    _send(CustomerDisplayState.idle(storeName: storeName));
  }

  /// تعطيل الخدمة
  void disable() {
    _isEnabled = false;
    _send(const CustomerDisplayState.idle());
  }

  /// هل الخدمة مفعّلة
  bool get isEnabled => _isEnabled;

  /// هل القناة متصلة
  bool get isConnected => _channel.isConnected;

  /// آخر حالة تم إرسالها
  CustomerDisplayState get lastState => _lastState;

  /// الاستماع للحالات (من جانب شاشة العميل)
  Stream<CustomerDisplayState> get stateStream => _channel.stateStream;

  // =========================================================================
  // State transitions
  // =========================================================================

  /// عرض شاشة الترحيب
  void showIdle() {
    _send(CustomerDisplayState.idle(storeName: _storeName));
  }

  /// عرض السلة / الفاتورة
  void showCart({
    required List<DisplayCartItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
  }) {
    _send(CustomerDisplayState.cart(
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      storeName: _storeName,
    ));
  }

  /// عرض خطوة إدخال رقم الجوال
  void showPhoneEntry({
    required List<DisplayCartItem> items,
    required double total,
  }) {
    _send(CustomerDisplayState.phoneEntry(
      items: items,
      total: total,
      storeName: _storeName,
    ));
  }

  /// عرض حالة الدفع
  void showPayment({
    required double total,
    required String paymentMethodName,
  }) {
    _send(CustomerDisplayState(
      phase: CustomerDisplayPhase.payment,
      storeName: _storeName,
      total: total,
      paymentMethodName: paymentMethodName,
    ));
  }

  /// عرض انتظار NFC
  void showNfcWaiting({
    required double total,
    NfcDisplayStatus status = NfcDisplayStatus.waitingForTap,
    String? message,
  }) {
    _send(CustomerDisplayState.nfcWaiting(
      total: total,
      nfcStatus: status,
      nfcMessage: message,
      storeName: _storeName,
    ));
  }

  /// تحديث حالة NFC
  void updateNfcStatus({
    required NfcDisplayStatus status,
    String? message,
  }) {
    _send(_lastState.copyWith(
      nfcStatus: status,
      nfcMessage: message,
    ));
  }

  /// عرض نجاح الدفع
  void showSuccess({
    required double total,
    String? message,
  }) {
    _send(CustomerDisplayState.success(
      total: total,
      resultMessage: message,
      storeName: _storeName,
    ));
  }

  /// عرض فشل الدفع
  void showFailure({String? message}) {
    _send(CustomerDisplayState.failure(
      resultMessage: message,
      storeName: _storeName,
    ));
  }

  /// إعادة تعيين للحالة الافتراضية
  void reset() {
    showIdle();
  }

  // =========================================================================
  // Internal
  // =========================================================================

  void _send(CustomerDisplayState state) {
    if (!_isEnabled) return;
    _lastState = state;
    _channel.sendState(state);
  }

  void dispose() {
    _channel.dispose();
  }
}
