import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const _P(t: 'Splash')),
      GoRoute(path: '/login', builder: (c, s) => const _P(t: 'تسجيل الدخول')),
      GoRoute(path: '/home', builder: (c, s) => const _P(t: 'الرئيسية')),
      GoRoute(path: '/sales', builder: (c, s) => const _P(t: 'المبيعات')),
      GoRoute(path: '/inventory', builder: (c, s) => const _P(t: 'المخزون')),
      GoRoute(path: '/reorder', builder: (c, s) => const _P(t: 'إعادة الطلب الذكي')),
      GoRoute(path: '/alerts', builder: (c, s) => const _P(t: 'التنبيهات')),
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
