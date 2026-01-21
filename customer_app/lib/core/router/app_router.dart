import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Customer App Router Configuration
/// 
/// Routes reference: See PRD_FINAL.md for complete route dictionary
class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // ==========================================
      // 🏠 HOME & ONBOARDING
      // ==========================================
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const _PlaceholderScreen(title: 'Splash'),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const _PlaceholderScreen(title: 'Onboarding'),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
      ),

      // ==========================================
      // 🔐 AUTH
      // ==========================================
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const _PlaceholderScreen(title: 'Register'),
      ),
      GoRoute(
        path: '/auth/otp',
        name: 'otp',
        builder: (context, state) => const _PlaceholderScreen(title: 'OTP Verification'),
      ),

      // ==========================================
      // 🛒 CATALOG & PRODUCTS
      // ==========================================
      GoRoute(
        path: '/catalog',
        name: 'catalog',
        builder: (context, state) => const _PlaceholderScreen(title: 'Catalog'),
      ),
      GoRoute(
        path: '/products/:id',
        name: 'productDetails',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Product ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const _PlaceholderScreen(title: 'Search'),
      ),

      // ==========================================
      // 🛍️ CART & CHECKOUT
      // ==========================================
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const _PlaceholderScreen(title: 'Cart'),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const _PlaceholderScreen(title: 'Checkout'),
      ),
      GoRoute(
        path: '/checkout/payment',
        name: 'payment',
        builder: (context, state) => const _PlaceholderScreen(title: 'Payment'),
      ),

      // ==========================================
      // 📦 ORDERS
      // ==========================================
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const _PlaceholderScreen(title: 'Orders'),
      ),
      GoRoute(
        path: '/orders/:id',
        name: 'orderDetails',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Order ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: '/orders/:id/track',
        name: 'trackOrder',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Track Order ${state.pathParameters['id']}',
        ),
      ),

      // ==========================================
      // 👤 PROFILE
      // ==========================================
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const _PlaceholderScreen(title: 'Profile'),
      ),
      GoRoute(
        path: '/profile/addresses',
        name: 'addresses',
        builder: (context, state) => const _PlaceholderScreen(title: 'Addresses'),
      ),
      GoRoute(
        path: '/profile/settings',
        name: 'settings',
        builder: (context, state) => const _PlaceholderScreen(title: 'Settings'),
      ),

      // ==========================================
      // 🏪 STORE
      // ==========================================
      GoRoute(
        path: '/store/:id',
        name: 'storeDetails',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Store ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: '/stores/nearby',
        name: 'nearbyStores',
        builder: (context, state) => const _PlaceholderScreen(title: 'Nearby Stores'),
      ),
    ],
  );
}

/// Placeholder screen for routes that haven't been implemented yet
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'قيد التطوير',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
