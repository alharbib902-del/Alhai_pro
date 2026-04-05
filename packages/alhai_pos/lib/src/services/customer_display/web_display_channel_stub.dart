/// Stub for non-web platforms
///
/// Returns [InMemoryDisplayChannel] when not running on web.
/// The real implementation is in [web_display_channel.dart].
library;

import 'package:flutter/foundation.dart';

import 'customer_display_service.dart';

/// Returns an [InMemoryDisplayChannel] on non-web platforms.
CustomerDisplayChannel createWebDisplayChannel() {
  return InMemoryDisplayChannel();
}

/// No-op on non-web platforms.
void openCustomerDisplayWindow(String path) {
  debugPrint('[CustomerDisplay] openCustomerDisplayWindow is web-only');
}
