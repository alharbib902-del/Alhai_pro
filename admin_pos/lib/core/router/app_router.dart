import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Auth
      GoRoute(path: '/', name: 'splash', builder: (c, s) => const _Placeholder(title: 'Splash')),
      GoRoute(path: '/login', name: 'login', builder: (c, s) => const _Placeholder(title: 'تسجيل الدخول')),
      
      // Dashboard
      GoRoute(path: '/dashboard', name: 'dashboard', builder: (c, s) => const _Placeholder(title: 'لوحة التحكم')),
      
      // Products
      GoRoute(path: '/products', name: 'products', builder: (c, s) => const _Placeholder(title: 'المنتجات')),
      GoRoute(path: '/products/:id', name: 'productDetails', builder: (c, s) => _Placeholder(title: 'منتج ${s.pathParameters['id']}')),
      GoRoute(path: '/categories', name: 'categories', builder: (c, s) => const _Placeholder(title: 'الأقسام')),
      
      // Orders
      GoRoute(path: '/orders', name: 'orders', builder: (c, s) => const _Placeholder(title: 'الطلبات')),
      GoRoute(path: '/orders/:id', name: 'orderDetails', builder: (c, s) => _Placeholder(title: 'طلب ${s.pathParameters['id']}')),
      
      // Inventory
      GoRoute(path: '/inventory', name: 'inventory', builder: (c, s) => const _Placeholder(title: 'المخزون')),
      GoRoute(path: '/inventory/low-stock', name: 'lowStock', builder: (c, s) => const _Placeholder(title: 'مخزون منخفض')),
      
      // Reports
      GoRoute(path: '/reports', name: 'reports', builder: (c, s) => const _Placeholder(title: 'التقارير')),
      GoRoute(path: '/reports/sales', name: 'salesReport', builder: (c, s) => const _Placeholder(title: 'تقرير المبيعات')),
      GoRoute(path: '/reports/inventory', name: 'inventoryReport', builder: (c, s) => const _Placeholder(title: 'تقرير المخزون')),
      
      // Staff
      GoRoute(path: '/staff', name: 'staff', builder: (c, s) => const _Placeholder(title: 'الموظفين')),
      GoRoute(path: '/drivers', name: 'drivers', builder: (c, s) => const _Placeholder(title: 'السائقين')),
      
      // Customers
      GoRoute(path: '/customers', name: 'customers', builder: (c, s) => const _Placeholder(title: 'العملاء')),
      GoRoute(path: '/debts', name: 'debts', builder: (c, s) => const _Placeholder(title: 'الديون')),
      
      // Settings
      GoRoute(path: '/settings', name: 'settings', builder: (c, s) => const _Placeholder(title: 'الإعدادات')),
      GoRoute(path: '/settings/store', name: 'storeSettings', builder: (c, s) => const _Placeholder(title: 'إعدادات المتجر')),
    ],
  );
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('قيد التطوير', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}
