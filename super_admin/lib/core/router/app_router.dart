import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';

/// Route paths
class SuperAdminRoutes {
  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const stores = '/stores';
  static const storeDetail = '/stores/:id';
  static const users = '/users';
  static const analytics = '/analytics';
  static const billing = '/billing';
  static const settings = '/settings';
}

/// Auth notifier that triggers GoRouter redirect on auth changes
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    _subs = [
      ref.listen(authStateProvider, (_, __) => notifyListeners()),
    ];
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

  // Still resolving → stay on current page
  if (authState.status == AuthStatus.unknown) return null;

  // Not authenticated → login
  if (authState.status == AuthStatus.unauthenticated ||
      authState.status == AuthStatus.sessionExpired) {
    return isPublic ? null : SuperAdminRoutes.login;
  }

  // Already logged in, trying to access login/splash → dashboard
  if (isPublic && authState.status == AuthStatus.authenticated) {
    return SuperAdminRoutes.dashboard;
  }

  return null;
}

/// Routes list
final List<RouteBase> _routes = [
  GoRoute(
    path: SuperAdminRoutes.splash,
    builder: (c, s) => const _Placeholder(title: 'Splash'),
  ),
  GoRoute(
    path: SuperAdminRoutes.login,
    builder: (c, s) => const _Placeholder(title: 'تسجيل الدخول'),
  ),
  GoRoute(
    path: SuperAdminRoutes.dashboard,
    builder: (c, s) => const _Placeholder(title: 'لوحة التحكم'),
  ),
  GoRoute(
    path: SuperAdminRoutes.stores,
    builder: (c, s) => const _Placeholder(title: 'المتاجر'),
  ),
  GoRoute(
    path: SuperAdminRoutes.storeDetail,
    builder: (c, s) => _Placeholder(title: 'متجر ${s.pathParameters['id']}'),
  ),
  GoRoute(
    path: SuperAdminRoutes.users,
    builder: (c, s) => const _Placeholder(title: 'المستخدمين'),
  ),
  GoRoute(
    path: SuperAdminRoutes.analytics,
    builder: (c, s) => const _Placeholder(title: 'التحليلات'),
  ),
  GoRoute(
    path: SuperAdminRoutes.billing,
    builder: (c, s) => const _Placeholder(title: 'الفوترة'),
  ),
  GoRoute(
    path: SuperAdminRoutes.settings,
    builder: (c, s) => const _Placeholder(title: 'الإعدادات'),
  ),
];

/// Error page builder
Widget _errorBuilder(BuildContext context, GoRouterState state) {
  return Scaffold(
    appBar: AppBar(title: const Text('خطأ')),
    body: Center(
      child: Text('الصفحة غير موجودة: ${state.uri.path}'),
    ),
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

/// L78: Placeholder screen for routes that haven't been implemented yet.
/// Shows a branded "Coming Soon" UI with app icon, title, and status indicator.
class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  color: isDark
                      ? Colors.amber.withValues(alpha: 0.15)
                      : Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      size: 18,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'قريباً - قيد التطوير',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'هذه الشاشة قيد التطوير وستكون متاحة قريباً',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
