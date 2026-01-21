import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const _P(t: 'Splash')),
      GoRoute(path: '/login', builder: (c, s) => const _P(t: 'تسجيل الدخول')),
      GoRoute(path: '/dashboard', builder: (c, s) => const _P(t: 'لوحة التحكم')),
      GoRoute(path: '/products', builder: (c, s) => const _P(t: 'المنتجات')),
      GoRoute(path: '/orders', builder: (c, s) => const _P(t: 'الطلبات')),
      GoRoute(path: '/stores', builder: (c, s) => const _P(t: 'المتاجر')),
      GoRoute(path: '/pricing', builder: (c, s) => const _P(t: 'الأسعار')),
      GoRoute(path: '/reports', builder: (c, s) => const _P(t: 'التقارير')),
      GoRoute(path: '/settings', builder: (c, s) => const _P(t: 'الإعدادات')),
    ],
  );
}

class _P extends StatelessWidget {
  final String t;
  const _P({required this.t});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(t)),
    body: Center(child: Text(t, style: Theme.of(context).textTheme.headlineMedium)),
  );
}
