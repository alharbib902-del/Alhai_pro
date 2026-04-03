import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/deliveries/screens/deliveries_list_screen.dart';
import '../../features/deliveries/screens/order_details_screen.dart';
import '../../features/deliveries/screens/new_order_screen.dart';
import '../../features/navigation/screens/navigation_screen.dart';
import '../../features/proof/screens/delivery_proof_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/earnings/screens/earnings_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/driver_navigation_shell.dart';
import '../providers/app_providers.dart';

/// Router provider with auth guard and bottom navigation shell.
final driverRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) => _guardRedirect(ref, state),
    routes: [
      // Auth routes (no bottom nav)
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profileSetup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DriverNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 1: Deliveries
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/deliveries',
                name: 'activeDeliveries',
                builder: (context, state) =>
                    const DeliveriesListScreen(),
              ),
            ],
          ),
          // Tab 2: Earnings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/earnings',
                name: 'earnings',
                builder: (context, state) => const EarningsScreen(),
              ),
            ],
          ),
          // Tab 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen routes (outside bottom nav)
      GoRoute(
        path: '/orders/:id',
        name: 'orderDetails',
        builder: (context, state) => OrderDetailsScreen(
          deliveryId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/navigate',
        name: 'navigation',
        builder: (context, state) => NavigationScreen(
          deliveryId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/proof',
        name: 'deliveryProof',
        builder: (context, state) => DeliveryProofScreen(
          deliveryId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/chat/:orderId',
        name: 'chat',
        builder: (context, state) => ChatScreen(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '/orders/new',
        name: 'newOrder',
        builder: (context, state) => const NewOrderScreen(),
      ),
    ],
  );
});

/// Auth guard redirect logic.
String? _guardRedirect(Ref ref, GoRouterState state) {
  final isAuth = ref.read(isAuthenticatedProvider);
  final currentPath = state.uri.path;

  // Public routes that don't need auth
  const publicRoutes = ['/', '/login'];
  if (publicRoutes.contains(currentPath)) {
    if (isAuth && currentPath == '/login') {
      return '/home';
    }
    return null;
  }

  // Redirect to login if not authenticated
  if (!isAuth) return '/login';

  return null;
}

/// Notifies GoRouter when auth state changes.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._ref) {
    _ref.listen(isAuthenticatedProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

/// Placeholder screen for routes not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.xl),
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
                  Icons.local_shipping_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.lg),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.construction_rounded,
                        size: 18, color: Colors.amber.shade700),
                    const SizedBox(width: AlhaiSpacing.xs),
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
            ],
          ),
        ),
      ),
    );
  }
}
