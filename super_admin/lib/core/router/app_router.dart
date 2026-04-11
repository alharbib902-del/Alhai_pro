import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_core/alhai_core.dart' show UserRole;

import '../../ui/super_admin_shell.dart';
import '../../screens/auth/sa_login_screen.dart';
import '../../screens/dashboard/sa_dashboard_screen.dart';
import '../../screens/stores/sa_stores_list_screen.dart';
import '../../screens/stores/sa_store_detail_screen.dart';
import '../../screens/stores/sa_create_store_screen.dart';
import '../../screens/stores/sa_store_settings_screen.dart';
import '../../screens/subscriptions/sa_plans_screen.dart';
import '../../screens/subscriptions/sa_subscriptions_list_screen.dart';
import '../../screens/users/sa_users_list_screen.dart';
import '../../screens/users/sa_user_detail_screen.dart';
import '../../screens/settings/sa_platform_settings_screen.dart';
import '../../screens/logs/sa_logs_screen.dart';
import '../../screens/reports/sa_reports_screen.dart';

// Deferred imports for heavy screens (analytics, billing, system health)
import '../../screens/analytics/sa_revenue_analytics_screen.dart'
    deferred as revenue;
import '../../screens/analytics/sa_usage_analytics_screen.dart'
    deferred as usage;
import '../../screens/subscriptions/sa_billing_screen.dart' deferred as billing;
import '../../screens/settings/sa_system_health_screen.dart' deferred as health;

/// Route paths
class SuperAdminRoutes {
  static const splash = '/';
  static const login = '/login';

  // Dashboard
  static const dashboard = '/dashboard';

  // Stores
  static const stores = '/stores';
  static const storeDetail = '/stores/:id';
  static const storeSettings = '/stores/:id/settings';
  static const createStore = '/stores/new';

  // Subscriptions
  static const subscriptions = '/subscriptions';
  static const plans = '/subscriptions/plans';
  static const billing = '/subscriptions/billing';

  // Users
  static const users = '/users';
  static const userDetail = '/users/:id';

  // Analytics
  static const revenueAnalytics = '/analytics/revenue';
  static const usageAnalytics = '/analytics/usage';

  // Settings
  static const platformSettings = '/settings/platform';
  static const systemHealth = '/settings/health';

  // Logs & Reports
  static const logs = '/logs';
  static const reports = '/reports';
}

/// Auth notifier that triggers GoRouter redirect on auth changes
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    _subs = [ref.listen(authStateProvider, (_, __) => notifyListeners())];
  }
  late final List<ProviderSubscription> _subs;

  @override
  void dispose() {
    for (final s in _subs) {
      s.close();
    }
    super.dispose();
  }
}

/// Auth guard redirect logic
String? _guardRedirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authStateProvider);
  final path = state.uri.path;

  const publicPaths = [SuperAdminRoutes.splash, SuperAdminRoutes.login];
  final isPublic = publicPaths.contains(path);

  // Still resolving -> stay on current page
  if (authState.status == AuthStatus.unknown) return null;

  // Not authenticated -> login
  if (authState.status == AuthStatus.unauthenticated ||
      authState.status == AuthStatus.sessionExpired) {
    return isPublic ? null : SuperAdminRoutes.login;
  }

  // Authenticated: check super_admin role
  if (authState.status == AuthStatus.authenticated) {
    // Redirect to dashboard if on public page
    if (isPublic) return SuperAdminRoutes.dashboard;

    // Enforce super_admin role for all protected routes
    final role = authState.user?.role;
    if (role != UserRole.superAdmin) {
      return SuperAdminRoutes.login;
    }
  }

  return null;
}

/// Navigation shell key for the ShellRoute
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Routes list
final List<RouteBase> _routes = [
  // Public routes (no shell)
  GoRoute(
    path: SuperAdminRoutes.splash,
    builder: (c, s) => const _Placeholder(title: 'Splash'),
  ),
  GoRoute(
    path: SuperAdminRoutes.login,
    builder: (c, s) => const SALoginScreen(),
  ),

  // Shell route with sidebar navigation
  ShellRoute(
    navigatorKey: _shellNavigatorKey,
    builder: (context, state, child) => SuperAdminShell(child: child),
    routes: [
      // Dashboard
      GoRoute(
        path: SuperAdminRoutes.dashboard,
        builder: (c, s) => const SADashboardScreen(),
      ),

      // Stores
      GoRoute(
        path: SuperAdminRoutes.createStore,
        builder: (c, s) => const SACreateStoreScreen(),
      ),
      GoRoute(
        path: SuperAdminRoutes.storeSettings,
        builder: (c, s) =>
            SAStoreSettingsScreen(storeId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: SuperAdminRoutes.storeDetail,
        builder: (c, s) =>
            SAStoreDetailScreen(storeId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: SuperAdminRoutes.stores,
        builder: (c, s) => const SAStoresListScreen(),
      ),

      // Subscriptions
      GoRoute(
        path: SuperAdminRoutes.plans,
        builder: (c, s) => const SAPlansScreen(),
      ),
      GoRoute(
        path: SuperAdminRoutes.billing,
        builder: (c, s) => DeferredWidget(
          libraryLoader: billing.loadLibrary,
          builder: () => billing.SABillingScreen(),
        ),
      ),
      GoRoute(
        path: SuperAdminRoutes.subscriptions,
        builder: (c, s) => const SASubscriptionsListScreen(),
      ),

      // Users
      GoRoute(
        path: SuperAdminRoutes.userDetail,
        builder: (c, s) => SAUserDetailScreen(userId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: SuperAdminRoutes.users,
        builder: (c, s) => const SAUsersListScreen(),
      ),

      // Analytics
      GoRoute(
        path: SuperAdminRoutes.revenueAnalytics,
        builder: (c, s) => DeferredWidget(
          libraryLoader: revenue.loadLibrary,
          builder: () => revenue.SARevenueAnalyticsScreen(),
        ),
      ),
      GoRoute(
        path: SuperAdminRoutes.usageAnalytics,
        builder: (c, s) => DeferredWidget(
          libraryLoader: usage.loadLibrary,
          builder: () => usage.SAUsageAnalyticsScreen(),
        ),
      ),

      // Settings
      GoRoute(
        path: SuperAdminRoutes.platformSettings,
        builder: (c, s) => const SAPlatformSettingsScreen(),
      ),
      GoRoute(
        path: SuperAdminRoutes.systemHealth,
        builder: (c, s) => DeferredWidget(
          libraryLoader: health.loadLibrary,
          builder: () => health.SASystemHealthScreen(),
        ),
      ),

      // Logs
      GoRoute(
        path: SuperAdminRoutes.logs,
        builder: (c, s) => const SALogsScreen(),
      ),

      // Reports
      GoRoute(
        path: SuperAdminRoutes.reports,
        builder: (c, s) => const SAReportsScreen(),
      ),
    ],
  ),
];

/// Error page builder
Widget _errorBuilder(BuildContext context, GoRouterState state) {
  return Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text('Page not found: ${state.uri.path}')),
  );
}

/// Super Admin Router Provider (with auth redirect)
final superAdminRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);
  return GoRouter(
    initialLocation: SuperAdminRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) => _guardRedirect(ref, state),
    routes: _routes,
    errorBuilder: _errorBuilder,
  );
});

/// Widget that handles deferred import loading with a loading indicator
/// and error state. Used for lazy-loaded route screens.
class DeferredWidget extends StatefulWidget {
  final Future<void> Function() libraryLoader;
  final Widget Function() builder;

  const DeferredWidget({
    super.key,
    required this.libraryLoader,
    required this.builder,
  });

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  bool _loaded = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await widget.libraryLoader();
      if (mounted) setState(() => _loaded = true);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '\u0641\u0634\u0644 \u062A\u062D\u0645\u064A\u0644 \u0627\u0644\u0635\u0641\u062D\u0629',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return widget.builder();
  }
}

/// L78: Placeholder screen for routes that haven't been implemented yet.
/// Shows a branded "Coming Soon" UI with app icon, title, and status indicator.
class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final amberColor = isDark
        ? const Color(0xFFFBBF24)
        : const Color(0xFFD97706);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: amberColor.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: amberColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      size: 18,
                      color: amberColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Coming Soon',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: amberColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
