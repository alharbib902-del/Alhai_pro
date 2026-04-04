/// Riverpod providers for the Distributor Portal.
///
/// Wraps [DistributorDatasource] queries into async providers
/// that screens can watch for loading / data / error states.
/// Includes activity-based session timeout (30 min idle).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/supabase_client.dart';
import '../data/distributor_datasource.dart';
import '../data/models.dart';

// ─── Datasource singleton ───────────────────────────────────────

final distributorDatasourceProvider = Provider<DistributorDatasource>((ref) {
  return DistributorDatasource();
});

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

// ─── Dashboard ──────────────────────────────────────────────────

final dashboardKpisProvider = FutureProvider<DashboardKpis>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getDashboardKpis();
});

// ─── Orders ─────────────────────────────────────────────────────

/// All orders — pass status filter via family.
final ordersProvider =
    FutureProvider.family<List<DistributorOrder>, String?>((ref, status) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrders(status: status);
});

/// Single order by ID.
final orderDetailProvider =
    FutureProvider.family<DistributorOrder?, String>((ref, orderId) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrderById(orderId);
});

/// Order items for a given order.
final orderItemsProvider =
    FutureProvider.family<List<DistributorOrderItem>, String>(
        (ref, orderId) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrderItems(orderId);
});

// ─── Products ───────────────────────────────────────────────────

final productsProvider =
    FutureProvider<List<DistributorProduct>>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getProducts();
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getCategories();
});

// ─── Reports ────────────────────────────────────────────────────

/// Report data — period is one of: day, week, month, year
final reportDataProvider =
    FutureProvider.family<ReportData, String>((ref, period) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getReportData(period: period);
});

// ─── Settings ───────────────────────────────────────────────────

final orgSettingsProvider = FutureProvider<OrgSettings?>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrgSettings();
});

// ─── Theme Mode ────────────────────────────────────────────────

const String _kThemeModeKey = 'distributor_theme_mode';

/// ThemeMode notifier with SharedPreferences persistence.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeModeKey);
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_kThemeModeKey, 'light');
      case ThemeMode.dark:
        await prefs.setString(_kThemeModeKey, 'dark');
      case ThemeMode.system:
        await prefs.remove(_kThemeModeKey);
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// ─── Session Timeout (30 min idle) ─────────────────────────────

/// Duration before an idle session is automatically logged out.
const Duration sessionTimeoutDuration = Duration(minutes: 30);

/// Manages activity-based session timeout.
/// Call [recordActivity] on user interactions (taps, navigation, etc.).
/// When idle for [sessionTimeoutDuration], fires [onTimeout].
class SessionTimeoutManager {
  SessionTimeoutManager({required this.onTimeout});

  final VoidCallback onTimeout;
  Timer? _timer;

  /// Record user activity and reset the idle timer.
  void recordActivity() {
    _timer?.cancel();
    _timer = Timer(sessionTimeoutDuration, _handleTimeout);
  }

  void _handleTimeout() {
    onTimeout();
  }

  /// Start the idle timer. Call after login.
  void start() {
    recordActivity();
  }

  /// Stop and clean up the timer. Call on logout or dispose.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// A widget that wraps the app to detect user activity and enforce session timeout.
class SessionTimeoutWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const SessionTimeoutWrapper({super.key, required this.child});

  @override
  ConsumerState<SessionTimeoutWrapper> createState() =>
      _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends ConsumerState<SessionTimeoutWrapper> {
  late final SessionTimeoutManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = SessionTimeoutManager(onTimeout: _onSessionTimeout);
    // Start only if authenticated
    if (AppSupabase.isAuthenticated) {
      _manager.start();
    }
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  void _onSessionTimeout() {
    if (!mounted) return;
    // Clear datasource cache
    ref.read(distributorDatasourceProvider).clearCache();
    AppSupabase.client.auth.signOut();
    // Navigate to login (use a post-frame callback to avoid issues)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired due to inactivity. Please log in again.'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state to start/stop timer
    final authState = ref.watch(authStateProvider);
    authState.whenData((state) {
      if (state.event == AuthChangeEvent.signedIn) {
        _manager.start();
      } else if (state.event == AuthChangeEvent.signedOut) {
        _manager.dispose();
      }
    });

    return Listener(
      onPointerDown: (_) => _manager.recordActivity(),
      onPointerMove: (_) => _manager.recordActivity(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
