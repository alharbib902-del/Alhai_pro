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

/// L78: Placeholder screen for routes that haven't been implemented yet.
/// Shows a branded "Coming Soon" UI with app icon, title, and status indicator.
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

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
                  Icons.storefront_rounded,
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
