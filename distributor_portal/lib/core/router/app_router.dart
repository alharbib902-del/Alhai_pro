import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/distributor_shell.dart';
import '../../screens/auth/distributor_login_screen.dart';
import '../../screens/dashboard/distributor_dashboard_screen.dart';
import '../../screens/orders/distributor_orders_screen.dart';
import '../../screens/orders/distributor_order_detail_screen.dart';
import '../../screens/invoices/invoice_list_screen.dart';
import '../../screens/invoices/invoice_detail_screen.dart';
import '../../screens/products/distributor_products_screen.dart';
import '../../screens/pricing/distributor_pricing_screen.dart'
    deferred as pricing;
import '../../screens/reports/distributor_reports_screen.dart'
    deferred as reports;
import '../../screens/settings/distributor_settings_screen.dart';
import '../supabase/supabase_client.dart';

/// Router provider that rebuilds when auth state changes.
final distributorRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = AppSupabase.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'distributor-login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DistributorLoginScreen(),
          transitionsBuilder: (c, a, sa, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => DistributorShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'distributor-dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DistributorDashboardScreen(),
              transitionsBuilder: (c, a, sa, child) =>
                  FadeTransition(opacity: a, child: child),
            ),
          ),
          GoRoute(
            path: '/orders',
            name: 'distributor-orders',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DistributorOrdersScreen(),
              transitionsBuilder: (c, a, sa, child) =>
                  FadeTransition(opacity: a, child: child),
            ),
          ),
          GoRoute(
            path: '/orders/:id',
            name: 'distributor-order-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return CustomTransitionPage(
                key: state.pageKey,
                child: DistributorOrderDetailScreen(orderId: id),
                transitionsBuilder: (c, a, sa, child) =>
                    FadeTransition(opacity: a, child: child),
              );
            },
          ),
          GoRoute(
            path: '/invoices',
            name: 'distributor-invoices',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const InvoiceListScreen(),
              transitionsBuilder: (c, a, sa, child) =>
                  FadeTransition(opacity: a, child: child),
            ),
          ),
          GoRoute(
            path: '/invoices/:id',
            name: 'distributor-invoice-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return CustomTransitionPage(
                key: state.pageKey,
                child: InvoiceDetailScreen(invoiceId: id),
                transitionsBuilder: (c, a, sa, child) =>
                    FadeTransition(opacity: a, child: child),
              );
            },
          ),
          GoRoute(
            path: '/products',
            name: 'distributor-products',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DistributorProductsScreen(),
              transitionsBuilder: (c, a, sa, child) =>
                  FadeTransition(opacity: a, child: child),
            ),
          ),
          GoRoute(
            path: '/pricing',
            name: 'distributor-pricing',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _DeferredScreen(
                loader: pricing.loadLibrary,
                builder: () => pricing.DistributorPricingScreen(),
              ),
              transitionsBuilder: (c, a, sa, child) =>
                  FadeTransition(opacity: a, child: child),
            ),
          ),
          GoRoute(
            path: '/reports',
            name: 'distributor-reports',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _DeferredScreen(
                loader: reports.loadLibrary,
                builder: () => reports.DistributorReportsScreen(),
              ),
              transitionsBuilder: (c, a, sa, child) =>
                  FadeTransition(opacity: a, child: child),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'distributor-settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DistributorSettingsScreen(),
              transitionsBuilder: (c, a, sa, child) =>
                  FadeTransition(opacity: a, child: child),
            ),
          ),
        ],
      ),
    ],
  );
});

/// A helper widget that loads a deferred library and shows a spinner until ready.
class _DeferredScreen extends StatelessWidget {
  final Future<void> Function() loader;
  final Widget Function() builder;

  const _DeferredScreen({required this.loader, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Failed to load screen: ${snapshot.error}'),
              ),
            );
          }
          return builder();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
