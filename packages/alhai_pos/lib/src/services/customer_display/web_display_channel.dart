/// Web BroadcastChannel implementation for customer display
///
/// Uses dart:js_interop to create a real BroadcastChannel that works
/// across browser windows/tabs on the same origin.
///
/// This file is only imported on web via conditional import in
/// [web_display_channel_factory.dart].
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';

import 'customer_display_service.dart';
import 'customer_display_state.dart';

// ============================================================================
// JS Interop bindings for BroadcastChannel & MessageEvent
// ============================================================================

/// JS BroadcastChannel binding via extension type.
@JS('BroadcastChannel')
extension type JsBroadcastChannel._(JSObject _) implements JSObject {
  /// Create a new BroadcastChannel with the given name.
  external JsBroadcastChannel(String name);

  /// Post a message to all other BroadcastChannel instances with the same name.
  external void postMessage(JSAny? message);

  /// Close the channel (no more messages will be sent or received).
  external void close();

  /// Callback for incoming messages.
  external set onmessage(JSFunction? handler);
}

/// JS MessageEvent binding.
@JS('MessageEvent')
extension type JsMessageEvent._(JSObject _) implements JSObject {
  /// The data payload of the message.
  external JSAny? get data;
}

// ============================================================================
// Factory function (called via conditional import)
// ============================================================================

/// Creates a [CustomerDisplayChannel] backed by the browser BroadcastChannel API.
///
/// Called from the conditional import factory. On non-web platforms the stub
/// version returns an [InMemoryDisplayChannel] instead.
CustomerDisplayChannel createWebDisplayChannel() {
  return WebBroadcastDisplayChannel();
}

// ============================================================================
// WebBroadcastDisplayChannel
// ============================================================================

/// Real BroadcastChannel-based channel for cross-window communication.
///
/// Sender (cashier window) and receiver (customer display window) both create
/// an instance on the same channel name. Messages sent via [sendState] are
/// received by all *other* windows listening on the same channel.
class WebBroadcastDisplayChannel implements CustomerDisplayChannel {
  static const _channelName = 'alhai_customer_display';

  /// The underlying JS BroadcastChannel object.
  JsBroadcastChannel? _channel;

  final StreamController<CustomerDisplayState> _controller =
      StreamController<CustomerDisplayState>.broadcast();

  bool _isConnected = false;

  WebBroadcastDisplayChannel() {
    _init();
  }

  void _init() {
    try {
      // Check if BroadcastChannel is available in this browser
      final bcConstructor = globalContext['BroadcastChannel'];
      if (bcConstructor == null) {
        debugPrint(
          '[CustomerDisplay] BroadcastChannel API not available in this browser',
        );
        _isConnected = false;
        return;
      }

      // Create a new BroadcastChannel
      _channel = JsBroadcastChannel(_channelName);

      // Listen for incoming messages from other windows
      _channel!.onmessage = (JsMessageEvent event) {
        try {
          final data = (event.data as JSString?)?.toDart;
          if (data != null && data.isNotEmpty) {
            final state = CustomerDisplayState.fromJsonString(data);
            if (!_controller.isClosed) {
              _controller.add(state);
            }
          }
        } catch (e) {
          debugPrint('[CustomerDisplay] Error parsing message: $e');
        }
      }.toJS;

      _isConnected = true;
      debugPrint(
        '[CustomerDisplay] BroadcastChannel initialized: $_channelName',
      );
    } catch (e) {
      debugPrint('[CustomerDisplay] BroadcastChannel init failed: $e');
      _isConnected = false;
    }
  }

  @override
  void sendState(CustomerDisplayState state) {
    if (!_isConnected || _channel == null) return;

    try {
      final jsonString = state.toJsonString();
      _channel!.postMessage(jsonString.toJS);

      if (kDebugMode) {
        debugPrint('[CustomerDisplay] Sent: ${state.phase.name}');
      }
    } catch (e) {
      debugPrint('[CustomerDisplay] Error sending state: $e');
    }
  }

  @override
  Stream<CustomerDisplayState> get stateStream => _controller.stream;

  @override
  bool get isConnected => _isConnected;

  @override
  void dispose() {
    try {
      _channel?.close();
    } catch (e) {
      debugPrint('[CustomerDisplay] BroadcastChannel close failed: $e');
    }
    _controller.close();
    _isConnected = false;
    _channel = null;
    debugPrint('[CustomerDisplay] BroadcastChannel disposed');
  }
}

// ============================================================================
// Window opener
// ============================================================================

/// Opens the customer display in a new browser window.
///
/// Uses window.open() via JS interop. The [path] should be the route
/// to the customer display screen (e.g. '/customer-display' or
/// '/#/customer-display' depending on the router's URL strategy).
void openCustomerDisplayWindow(String path) {
  try {
    final windowObj = globalContext['window'] as JSObject?;
    if (windowObj == null) return;

    windowObj.callMethod(
      'open'.toJS,
      path.toJS,
      'customer_display'.toJS,
      'width=1024,height=768,menubar=no,toolbar=no,location=no,status=no'.toJS,
    );
    debugPrint('[CustomerDisplay] Opened window: $path');
  } catch (e) {
    debugPrint('[CustomerDisplay] Failed to open window: $e');
  }
}
