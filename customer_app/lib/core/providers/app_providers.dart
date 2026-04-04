import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:alhai_core/alhai_core.dart' as core;

import '../supabase/supabase_client.dart';

/// Provides the Supabase client instance.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return AppSupabase.client;
});

/// Streams auth state changes from Supabase.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.read(supabaseClientProvider).auth.onAuthStateChange;
});

/// Current authenticated user (Supabase Auth user, not app User model).
final currentSupabaseUserProvider = Provider<User?>((ref) {
  // Re-evaluate when auth state changes
  ref.watch(authStateChangesProvider);
  return AppSupabase.client.auth.currentUser;
});

/// Whether user is currently authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentSupabaseUserProvider) != null;
});

/// Current app User model (loaded from `users` table).
final currentUserProvider = StateProvider<core.User?>((ref) => null);

/// Selected store for browsing.
final selectedStoreProvider = StateProvider<core.Store?>((ref) => null);

/// Connectivity state stream.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((result) => result != ConnectivityResult.none);
});
