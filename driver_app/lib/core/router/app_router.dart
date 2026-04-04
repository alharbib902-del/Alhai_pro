import 'package:flutter/foundation.dart';
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
    debugLogDiagnostics: kDebugMode,
    refreshListenable: authNotifier,
    redirect: (context, state) => _guardRedirect(ref, state),
    routes: [
      // Auth routes (no bottom nav)
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profileSetup',
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const ProfileSetupScreen(),
        ),
      ),

      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DriverNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home — use pageBuilder with fade for tab switches
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) => _fadeTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          // Tab 1: Deliveries
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/deliveries',
                name: 'activeDeliveries',
                pageBuilder: (context, state) => _fadeTransitionPage(
                  key: state.pageKey,
                  child: const DeliveriesListScreen(),
                ),
              ),
            ],
          ),
          // Tab 2: Earnings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/earnings',
                name: 'earnings',
                pageBuilder: (context, state) => _fadeTransitionPage(
                  key: state.pageKey,
                  child: const EarningsScreen(),
                ),
              ),
            ],
          ),
          // Tab 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) => _fadeTransitionPage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Full-screen routes (outside bottom nav) — slide from bottom
      GoRoute(
        path: '/orders/:id',
        name: 'orderDetails',
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: OrderDetailsScreen(
            deliveryId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/orders/:id/navigate',
        name: 'navigation',
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: NavigationScreen(
            deliveryId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/orders/:id/proof',
        name: 'deliveryProof',
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: DeliveryProofScreen(
            deliveryId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/chat/:orderId',
        name: 'chat',
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: ChatScreen(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/orders/new',
        name: 'newOrder',
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const NewOrderScreen(),
        ),
      ),
    ],
  );
});

// ─── Page transition helpers ───────────────────────────────────────────────

/// Fade transition — used for tab-level screens so switching tabs feels instant
/// yet polished.
CustomTransitionPage<void> _fadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: child,
      );
    },
  );
}

/// Slide-from-bottom + fade — used for pushed detail screens (order details,
/// navigation, proof capture, chat) to communicate hierarchy clearly.
CustomTransitionPage<void> _slideTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideTween = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(
        position: slideTween,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
      );
    },
  );
}

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
