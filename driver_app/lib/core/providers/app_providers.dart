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

/// Current authenticated user (Supabase Auth user).
///
/// Uses .select() so downstream providers only rebuild when the user ID
/// actually changes (sign-in / sign-out), not on every token refresh or
/// other AuthState event that keeps the same user.
final currentSupabaseUserProvider = Provider<User?>((ref) {
  ref.watch(
    authStateChangesProvider.select(
      (value) => value.asData?.value.session?.user.id,
    ),
  );
  return AppSupabase.client.auth.currentUser;
});

/// Whether user is currently authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentSupabaseUserProvider) != null;
});

/// Current driver profile (loaded from `users` table).
final currentDriverProvider = StateProvider<core.User?>((ref) => null);

/// Whether the driver profile has been set up (name, vehicle).
final isProfileCompleteProvider = Provider<bool>((ref) {
  final driver = ref.watch(currentDriverProvider);
  return driver != null && driver.name.isNotEmpty;
});

/// Connectivity state stream.
///
/// connectivity_plus v5+ emits List<ConnectivityResult>; we're online if
/// at least one result is not ConnectivityResult.none.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
});
