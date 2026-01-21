import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Driver App Router Configuration
/// 
/// Routes reference: See PRD_FINAL.md for complete route dictionary
class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // ==========================================
      // 🏠 SPLASH & AUTH
      // ==========================================
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const _PlaceholderScreen(title: 'Splash'),
      ),
      GoRoute(
        path: '/language',
        name: 'languageSelection',
        builder: (context, state) => const _PlaceholderScreen(title: 'اختيار اللغة'),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const _PlaceholderScreen(title: 'تسجيل الدخول'),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profileSetup',
        builder: (context, state) => const _PlaceholderScreen(title: 'إعداد الملف الشخصي'),
      ),

      // ==========================================
      // 📊 DASHBOARD
      // ==========================================
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen(title: 'الرئيسية'),
      ),
      GoRoute(
        path: '/deliveries',
        name: 'activeDeliveries',
        builder: (context, state) => const _PlaceholderScreen(title: 'التوصيلات النشطة'),
      ),
      GoRoute(
        path: '/shifts',
        name: 'shifts',
        builder: (context, state) => const _PlaceholderScreen(title: 'جدول الورديات'),
      ),
      GoRoute(
        path: '/earnings',
        name: 'earnings',
        builder: (context, state) => const _PlaceholderScreen(title: 'الأرباح'),
      ),

      // ==========================================
      // 📦 ORDERS
      // ==========================================
      GoRoute(
        path: '/orders/new',
        name: 'newOrder',
        builder: (context, state) => const _PlaceholderScreen(title: 'طلب جديد'),
      ),
      GoRoute(
        path: '/orders/:id',
        name: 'orderDetails',
        builder: (context, state) => _PlaceholderScreen(
          title: 'تفاصيل الطلب ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: '/orders/:id/navigate',
        name: 'navigation',
        builder: (context, state) => _PlaceholderScreen(
          title: 'الملاحة ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: '/orders/:id/proof',
        name: 'deliveryProof',
        builder: (context, state) => _PlaceholderScreen(
          title: 'إثبات التسليم ${state.pathParameters['id']}',
        ),
      ),

      // ==========================================
      // 💬 COMMUNICATION
      // ==========================================
      GoRoute(
        path: '/chat/:orderId',
        name: 'chat',
        builder: (context, state) => _PlaceholderScreen(
          title: 'المحادثة ${state.pathParameters['orderId']}',
        ),
      ),
      GoRoute(
        path: '/quick-messages',
        name: 'quickMessages',
        builder: (context, state) => const _PlaceholderScreen(title: 'رسائل سريعة'),
      ),

      // ==========================================
      // 📈 REPORTS
      // ==========================================
      GoRoute(
        path: '/reports/daily',
        name: 'dailyReport',
        builder: (context, state) => const _PlaceholderScreen(title: 'التقرير اليومي'),
      ),
      GoRoute(
        path: '/reports/weekly',
        name: 'weeklyReport',
        builder: (context, state) => const _PlaceholderScreen(title: 'التقرير الأسبوعي'),
      ),
      GoRoute(
        path: '/reports/monthly',
        name: 'monthlyReport',
        builder: (context, state) => const _PlaceholderScreen(title: 'التقرير الشهري'),
      ),

      // ==========================================
      // ⚙️ SETTINGS
      // ==========================================
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const _PlaceholderScreen(title: 'الملف الشخصي'),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const _PlaceholderScreen(title: 'المساعدة'),
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
              Icons.local_shipping,
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
