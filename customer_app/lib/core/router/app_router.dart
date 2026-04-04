import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/catalog/screens/catalog_screen.dart';
import '../../features/catalog/screens/product_detail_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/addresses/screens/addresses_screen.dart';
import '../../shared/widgets/bottom_nav_shell.dart';

// FIX 2: Deferred imports for heavy/rarely-used screens
import '../../features/tracking/screens/order_tracking_screen.dart' deferred as tracking;
import '../../features/settings/screens/settings_screen.dart' deferred as settings;
import '../../features/stores/screens/nearby_stores_screen.dart' deferred as nearby_stores;

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Validates that an ID path parameter is a valid UUID v4 format.
bool _isValidUuid(String? id) =>
    id != null && RegExp(r'^[0-9a-f-]{36}$', caseSensitive: false).hasMatch(id);

/// Shown when a deep link contains an invalid ID parameter.
Widget _invalidLinkScreen() =>
    const Scaffold(body: Center(child: Text('رابط غير صالح')));

/// Loading placeholder shown while deferred libraries load.
Widget _deferredLoadingScreen() =>
    const Scaffold(body: Center(child: CircularProgressIndicator()));

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // ==========================================
      // Auth routes (no bottom nav)
      // ==========================================
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        name: 'otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phone: phone);
        },
      ),

      // ==========================================
      // Main app with bottom navigation
      // ==========================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _MainShell(navigationShell: navigationShell);
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
          // Tab 1: Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          // Tab 2: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                name: 'cart',
                builder: (context, state) => const CartScreen(),
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

      // ==========================================
      // Full-screen routes (on top of bottom nav)
      // ==========================================
      GoRoute(
        path: '/catalog',
        name: 'catalog',
        builder: (context, state) => const CatalogScreen(),
      ),
      GoRoute(
        path: '/products/:id',
        name: 'productDetails',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (!_isValidUuid(id)) return _invalidLinkScreen();
          return ProductDetailScreen(productId: id!);
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        name: 'orderDetails',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (!_isValidUuid(id)) return _invalidLinkScreen();
          return OrderDetailScreen(orderId: id!);
        },
      ),
      // Deferred: Order tracking (has Google Maps ~8MB)
      GoRoute(
        path: '/orders/:id/track',
        name: 'trackOrder',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (!_isValidUuid(id)) return _invalidLinkScreen();
          return FutureBuilder(
            future: tracking.loadLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return tracking.OrderTrackingScreen(orderId: id!);
              }
              return _deferredLoadingScreen();
            },
          );
        },
      ),
      GoRoute(
        path: '/profile/addresses',
        name: 'addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      // Deferred: Settings screen
      GoRoute(
        path: '/profile/settings',
        name: 'settings',
        builder: (context, state) => FutureBuilder(
          future: settings.loadLibrary(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return settings.SettingsScreen();
            }
            return _deferredLoadingScreen();
          },
        ),
      ),
      // Deferred: Nearby stores screen
      GoRoute(
        path: '/stores/nearby',
        name: 'nearbyStores',
        builder: (context, state) => FutureBuilder(
          future: nearby_stores.loadLibrary(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return nearby_stores.NearbyStoresScreen();
            }
            return _deferredLoadingScreen();
          },
        ),
      ),
    ],
  );
}

/// Main shell with bottom navigation.
class _MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _MainShell({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isConnected = ref.watch(connectivityProvider).valueOrNull ?? true;

    return Scaffold(
      body: Column(
        children: [
          if (!isConnected)
            MaterialBanner(
              content: const Text('أنت غير متصل بالإنترنت'),
              leading: const Icon(Icons.wifi_off),
              backgroundColor: theme.colorScheme.errorContainer,
              actions: const [SizedBox.shrink()],
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
