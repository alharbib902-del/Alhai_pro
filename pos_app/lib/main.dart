import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/monitoring/memory_monitor.dart';
import 'core/locale/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DI ضروري قبل runApp (Riverpod providers تستخدم getIt بشكل متزامن)
  await configureDependencies();

  // تحميل الثيم مسبقاً (سريع ~50ms)
  // باقي التهيئة (FTS, Seeder) تتم في SplashScreen
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('app_theme_mode');
  final initialThemeMode = switch (savedTheme) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) => ThemeNotifier(initialThemeMode)),
      ],
      child: const PosApp(),
    ),
  );
}

class PosApp extends ConsumerWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة حالة الثيم
    final themeState = ref.watch(themeProvider);

    // مراقبة حالة اللغة
    final localeState = ref.watch(localeProvider);

    return MemoryMonitor.instance.wrapWithMemoryMonitor(
      MaterialApp.router(
        title: 'Al-HAI POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // استخدام الثيم المحفوظ
        themeMode: themeState.themeMode,
        routerConfig: AppRouter.router,
        // دعم 6 لغات
        locale: localeState.locale,
        supportedLocales: SupportedLocales.all,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // تطبيق اتجاه النص
        builder: (context, child) {
          return Directionality(
            textDirection: localeState.textDirection,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
