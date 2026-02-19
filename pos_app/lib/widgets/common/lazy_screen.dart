/// Lazy Screen Wrapper
library lazy_screen;

/// يوفر تحميل متأخر للشاشات مع shimmer loading
///
/// الميزات:
/// - تحميل الشاشة عند الطلب فقط
/// - عرض shimmer أثناء التحميل
/// - دعم error handling
/// - دعم retry
/// - قابل للتخصيص

import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

/// Widget لتحميل الشاشات بشكل متأخر
class LazyScreen extends StatefulWidget {
  /// دالة إنشاء الشاشة
  final Future<Widget> Function() screenBuilder;

  /// widget للعرض أثناء التحميل (اختياري)
  final Widget? loadingWidget;

  /// widget للعرض عند حدوث خطأ (اختياري)
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;

  /// مدة التحميل القصوى قبل timeout
  final Duration timeout;

  /// هل يتم تحميل الشاشة مسبقاً
  final bool preload;

  const LazyScreen({
    super.key,
    required this.screenBuilder,
    this.loadingWidget,
    this.errorBuilder,
    this.timeout = const Duration(seconds: 30),
    this.preload = false,
  });

  @override
  State<LazyScreen> createState() => _LazyScreenState();
}

class _LazyScreenState extends State<LazyScreen> {
  late Future<Widget> _screenFuture;

  @override
  void initState() {
    super.initState();
    _loadScreen();
  }

  void _loadScreen() {
    _screenFuture = widget.screenBuilder().timeout(
      widget.timeout,
      onTimeout: () {
        throw const TimeoutException('تجاوز وقت تحميل الشاشة');
      },
    );
  }

  void _retry() {
    setState(() {
      _loadScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _screenFuture,
      builder: (context, snapshot) {
        // حالة التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingWidget ?? const _DefaultLoadingScreen();
        }

        // حالة الخطأ
        if (snapshot.hasError) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(snapshot.error!, _retry);
          }
          return _DefaultErrorScreen(
            error: snapshot.error!,
            onRetry: _retry,
          );
        }

        // حالة النجاح
        if (snapshot.hasData) {
          return snapshot.data!;
        }

        // حالة غير متوقعة
        return const _DefaultLoadingScreen();
      },
    );
  }
}

/// شاشة التحميل الافتراضية
class _DefaultLoadingScreen extends StatelessWidget {
  const _DefaultLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Shimmer للـ AppBar
              ShimmerPlaceholder.text(width: 150, height: 28),
              const SizedBox(height: 24),

              // Shimmer للمحتوى
              Expanded(
                child: ShimmerLoading(
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة الخطأ الافتراضية
class _DefaultErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ أثناء تحميل الشاشة',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _getErrorMessage(error),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error is TimeoutException) {
      return 'انتهى وقت الانتظار. تحقق من اتصالك بالإنترنت.';
    }
    return 'يرجى المحاولة مرة أخرى لاحقاً.';
  }
}

/// Exception للـ timeout
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);

  @override
  String toString() => message;
}

/// Preloader للشاشات - يحمل الشاشات مسبقاً في الخلفية
class ScreenPreloader {
  static final Map<String, Widget> _cache = {};
  static final Set<String> _loading = {};

  /// تحميل شاشة مسبقاً
  static Future<void> preload(
    String key,
    Future<Widget> Function() builder,
  ) async {
    if (_cache.containsKey(key) || _loading.contains(key)) {
      return;
    }

    _loading.add(key);
    try {
      final widget = await builder();
      _cache[key] = widget;
    } catch (e) {
      // تجاهل الأخطاء في التحميل المسبق
      debugPrint('Failed to preload screen: $key - $e');
    } finally {
      _loading.remove(key);
    }
  }

  /// الحصول على شاشة محملة مسبقاً
  static Widget? get(String key) => _cache[key];

  /// مسح الـ cache
  static void clear() {
    _cache.clear();
    _loading.clear();
  }

  /// مسح شاشة محددة
  static void remove(String key) {
    _cache.remove(key);
  }

  /// هل الشاشة محملة
  static bool isLoaded(String key) => _cache.containsKey(key);

  /// هل الشاشة قيد التحميل
  static bool isLoading(String key) => _loading.contains(key);
}

/// Extension لسهولة الاستخدام مع GoRouter
extension LazyRouteExtension on Widget {
  /// تحويل Widget إلى lazy-loaded
  static LazyScreen lazy(Future<Widget> Function() builder) {
    return LazyScreen(screenBuilder: builder);
  }
}

/// مساعد لإنشاء routes مع lazy loading
class LazyRouteHelper {
  /// إنشاء builder function للـ GoRoute
  static Widget Function(BuildContext, dynamic) lazyBuilder(
    Future<Widget> Function() screenBuilder, {
    Widget? loadingWidget,
  }) {
    return (context, state) => LazyScreen(
          screenBuilder: screenBuilder,
          loadingWidget: loadingWidget,
        );
  }
}

/// شاشة تحميل مخصصة للـ POS
class PosLoadingScreen extends StatelessWidget {
  const PosLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Products Panel Shimmer
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    ShimmerPlaceholder.card(height: 48),
                    const SizedBox(height: 16),
                    // Categories
                    SizedBox(
                      height: 40,
                      child: ShimmerLoading(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              width: 80,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Products Grid
                    const Expanded(
                      child: ShimmerGrid(
                        crossAxisCount: 3,
                        itemCount: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Cart Panel Shimmer
            Container(
              width: 350,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Column(
                children: [
                  ShimmerPlaceholder.text(width: 100, height: 24),
                  const SizedBox(height: 16),
                  const Expanded(
                    child: ShimmerList(itemCount: 4, itemHeight: 60),
                  ),
                  const SizedBox(height: 16),
                  ShimmerPlaceholder.card(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شاشة تحميل مخصصة للتقارير
class ReportsLoadingScreen extends StatelessWidget {
  const ReportsLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              ShimmerPlaceholder.text(width: 150, height: 28),
              const SizedBox(height: 24),
              // Stats Cards
              Row(
                children: List.generate(
                  3,
                  (_) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ShimmerPlaceholder.card(height: 100),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Chart
              ShimmerPlaceholder.card(height: 200),
              const SizedBox(height: 24),
              // Table
              const Expanded(
                child: ShimmerList(itemCount: 5, itemHeight: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة تحميل مخصصة للمنتجات
class ProductsLoadingScreen extends StatelessWidget {
  const ProductsLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search & Filter
              Row(
                children: [
                  Expanded(child: ShimmerPlaceholder.card(height: 48)),
                  const SizedBox(width: 16),
                  ShimmerPlaceholder.card(width: 48, height: 48),
                ],
              ),
              const SizedBox(height: 16),
              // Categories
              SizedBox(
                height: 40,
                child: ShimmerLoading(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Products List
              const Expanded(
                child: ShimmerList(itemCount: 8, itemHeight: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة تحميل مخصصة للمخزون
class InventoryLoadingScreen extends StatelessWidget {
  const InventoryLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              ShimmerPlaceholder.text(width: 120, height: 28),
              const SizedBox(height: 16),
              // Summary Cards
              Row(
                children: List.generate(
                  3,
                  (_) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ShimmerPlaceholder.card(height: 80),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Search
              ShimmerPlaceholder.card(height: 48),
              const SizedBox(height: 16),
              // Inventory List
              const Expanded(
                child: ShimmerList(itemCount: 6, itemHeight: 72),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة تحميل مخصصة للعملاء
class CustomersLoadingScreen extends StatelessWidget {
  const CustomersLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search & Add Button
              Row(
                children: [
                  Expanded(child: ShimmerPlaceholder.card(height: 48)),
                  const SizedBox(width: 16),
                  ShimmerPlaceholder.card(width: 48, height: 48),
                ],
              ),
              const SizedBox(height: 16),
              // Filters
              SizedBox(
                height: 36,
                child: ShimmerLoading(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Customers List
              const Expanded(
                child: ShimmerList(itemCount: 8, itemHeight: 72),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة تحميل مخصصة للموردين
class SuppliersLoadingScreen extends StatelessWidget {
  const SuppliersLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search
              ShimmerPlaceholder.card(height: 48),
              const SizedBox(height: 16),
              // Suppliers List
              const Expanded(
                child: ShimmerList(itemCount: 6, itemHeight: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
