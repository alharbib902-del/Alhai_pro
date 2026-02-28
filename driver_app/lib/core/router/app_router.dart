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
                  Icons.local_shipping_rounded,
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
