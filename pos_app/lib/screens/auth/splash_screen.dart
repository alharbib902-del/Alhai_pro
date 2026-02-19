import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../di/injection.dart';
import '../../core/monitoring/memory_monitor.dart';
import '../../data/local/seeders/database_seeder.dart';

/// شاشة البداية - نقطة دخول التطبيق
///
/// تقوم بتهيئة التطبيق (DI, FTS, Database) مع عرض شاشة جميلة
/// ثم توجّه المستخدم لشاشة تسجيل الدخول
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _statusText = 'جاري التحميل...';

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    final stopwatch = Stopwatch()..start();
    debugPrint('⏱️ [SPLASH] بدء تهيئة التطبيق...');

    try {
      // DI تمت بالفعل في main.dart (ضرورية قبل runApp)
      // هنا فقط العمليات البطيئة

      // 1. FTS - تهيئة البحث السريع
      setState(() => _statusText = 'تهيئة البحث...');
      await _initializeFts();
      debugPrint('⏱️ [SPLASH] FTS: ${stopwatch.elapsedMilliseconds}ms');

      // 2. Database Seeding
      setState(() => _statusText = 'تحميل البيانات...');
      await _seedDatabaseIfNeeded();
      debugPrint('⏱️ [SPLASH] Seed: ${stopwatch.elapsedMilliseconds}ms');

      // 3. Memory Monitor
      MemoryMonitor.instance.startMonitoring();

      stopwatch.stop();
      debugPrint('⏱️ [SPLASH] ✅ المدة الكلية: ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ [SPLASH] خطأ في التهيئة: $e');
    }

    // التنقل لشاشة الدخول
    if (!mounted) return;
    context.go('/login');
  }

  /// تهيئة Full-Text Search
  Future<void> _initializeFts() async {
    try {
      await appDatabase.initializeFts();
      if (kDebugMode) {
        debugPrint('✅ تم تهيئة FTS للبحث السريع');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ FTS غير متاح: $e');
      }
    }
  }

  /// Seeds the database with demo data if it's empty
  Future<void> _seedDatabaseIfNeeded() async {
    try {
      final seeder = DatabaseSeeder(appDatabase);
      final isEmpty = await seeder.isDatabaseEmpty();

      if (isEmpty) {
        debugPrint('🌱 تهيئة قاعدة البيانات بالبيانات التجريبية...');
        if (mounted) setState(() => _statusText = 'تهيئة البيانات التجريبية...');
        await seeder.seedAll();
        debugPrint('✅ تم تهيئة قاعدة البيانات بنجاح!');
      } else {
        debugPrint('ℹ️ قاعدة البيانات تحتوي على بيانات - تخطي التهيئة');
      }
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة قاعدة البيانات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // اللون الأخضر الطازج
    const primaryGreen = Color(0xFF10B981);
    const darkGreen = Color(0xFF059669);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryGreen, darkGreen],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // صورة الروبوت 3D
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      blurRadius: 30,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/mascot_robot.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'نقاط البيع',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Al-HAI POS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              // نص الحالة
              Text(
                _statusText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
