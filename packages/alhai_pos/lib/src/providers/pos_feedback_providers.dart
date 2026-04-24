/// POS Feedback Hooks - override-able callbacks for sound + haptic feedback.
///
/// The POS package intentionally does NOT depend on any app-level audio/
/// haptic implementation. Instead, it exposes empty callbacks here which
/// the host app (cashier) overrides at `ProviderScope` creation to route
/// events to its `SoundService` / `HapticShim`.
///
/// Usage (cashier/main.dart):
///   ```dart
///   ProviderScope(
///     overrides: [
///       posBarcodeScanFeedbackProvider.overrideWithValue(() {
///         HapticShim.lightImpact();
///         SoundService.instance.barcodeBeep();
///       }),
///       posSaleSuccessFeedbackProvider.overrideWithValue(() {
///         HapticShim.heavyImpact();
///         SoundService.instance.saleSuccess();
///       }),
///       posErrorFeedbackProvider.overrideWithValue(() {
///         HapticShim.vibrate();
///         SoundService.instance.errorBuzz();
///       }),
///     ],
///     child: const CashierApp(),
///   );
///   ```
///
/// When not overridden, every callback is a no-op — tests and other hosts
/// continue to work without wiring audio/haptic plumbing.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Called when a barcode scan successfully adds a product to the cart.
final posBarcodeScanFeedbackProvider = Provider<void Function()>((ref) {
  return () {};
});

/// Called when a barcode scan fails (product not found).
final posBarcodeErrorFeedbackProvider = Provider<void Function()>((ref) {
  return () {};
});

/// Called when a sale/payment completes successfully.
final posSaleSuccessFeedbackProvider = Provider<void Function()>((ref) {
  return () {};
});

/// Called on a generic POS error (sale save failure, etc.).
final posErrorFeedbackProvider = Provider<void Function()>((ref) {
  return () {};
});

/// Called on a cart mutation (add/remove item via POS UI). Intended for a
/// subtle haptic tick, not sound.
final posCartMutationFeedbackProvider = Provider<void Function()>((ref) {
  return () {};
});
