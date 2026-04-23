/// Smart destination helper for the AppHeader notifications bell.
///
/// Closes §4f from the 2026-04-24 handover: every screen's bell used to
/// always push `/notifications`. When the active store has low-stock
/// products, the user's intent on tapping the bell is overwhelmingly to
/// see the inventory alerts — not the notifications list. This helper
/// reads the already-hosted [lowStockNotificationCountProvider] stream
/// and routes accordingly.
///
/// Non-breaking: callers that don't pass [lowStockRoute] keep the old
/// behavior (always push the notifications route).
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/products_providers.dart';

/// Push the right destination for a notifications bell tap.
///
/// - If [lowStockRoute] is non-null AND the current store has `> 0`
///   low-stock products, pushes there.
/// - Otherwise pushes [notificationsRoute] (defaults to `/notifications`).
///
/// Reads [lowStockNotificationCountProvider] non-blocking
/// (`.valueOrNull ?? 0`) — if the stream hasn't emitted yet (cold start,
/// missing DB, test harness) the helper falls through to the safe
/// [notificationsRoute] default. Never throws.
void smartNotificationsPush(
  BuildContext context,
  WidgetRef ref, {
  String? lowStockRoute,
  String notificationsRoute = '/notifications',
}) {
  final count = ref.read(lowStockNotificationCountProvider).valueOrNull ?? 0;
  final target = (lowStockRoute != null && count > 0)
      ? lowStockRoute
      : notificationsRoute;
  if (context.mounted) {
    context.push(target);
  }
}
