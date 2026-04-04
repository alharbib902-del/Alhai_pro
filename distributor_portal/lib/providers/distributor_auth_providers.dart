/// Auth-related providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/supabase_client.dart';

// ─── Auth state ─────────────────────────────────────────────────

final authStateProvider = StreamProvider<AuthState>((ref) {
  return AppSupabase.client.auth.onAuthStateChange;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return AppSupabase.isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  // Watch auth state changes to recompute
  ref.watch(authStateProvider);
  return AppSupabase.client.auth.currentUser;
});
