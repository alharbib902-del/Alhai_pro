/// Logout service — ensures full session cleanup on sign-out.
///
/// Clears: auth tokens (via AuthNotifier), store selection, cart state,
/// session timer, cached providers, and SharedPreferences session data.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_auth/alhai_auth.dart'
    show authStateProvider, currentStoreIdProvider;
import 'package:alhai_pos/alhai_pos.dart'
    show cartStateProvider, heldInvoicesProvider;
import 'package:alhai_shared_ui/alhai_shared_ui.dart'
    show performanceProvider;
import 'session_manager.dart';

/// Performs a full logout: auth + local state cleanup.
///
/// Call this instead of `authNotifier.logout()` directly to ensure
/// all cashier-app-specific caches are cleared.
Future<void> performFullLogout(WidgetRef ref) async {
  // 1. Stop inactivity timer
  ref.read(sessionManagerProvider).dispose();

  // 2. Clear store selection
  ref.read(currentStoreIdProvider.notifier).state = null;

  // 3. Clear cart state so it doesn't leak to the next user session
  ref.read(cartStateProvider.notifier).clear();

  // 4. Reset held invoices (in-memory) and performance metrics
  ref.invalidate(heldInvoicesProvider);
  ref.read(performanceProvider.notifier).resetSession();

  // 5. Clear session-related SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('selected_store_id');
  await prefs.remove('pref_auto_print');

  // 6. Sign out from auth (clears tokens, Supabase session, secure storage)
  await ref.read(authStateProvider.notifier).logout();
}
