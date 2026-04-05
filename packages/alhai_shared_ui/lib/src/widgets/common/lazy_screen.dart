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
import '../../core/responsive/responsive_utils.dart';
import 'shimmer_loading.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// L62: This widget is not currently used in any router configuration.
/// It is kept for future web code-splitting via deferred loading.
/// If you need lazy-loaded routes, wire this into GoRouter builders.
///
/// Example usage with GoRouter:
/// ```dart
/// GoRoute(
///   path: '/heavy-screen',
///   builder: (context, state) => LazyScreen(
///     screenBuilder: () async {
///       // Use deferred import for code splitting on web
///       await Future.delayed(Duration.zero);
///       return const HeavyScreen();
///     },
///   ),
/// )
/// ```
@Deprecated(
  'L62: Not currently wired into any router. '
  'Wire into GoRouter with deferred imports for web code-splitting, '
  'or remove if lazy loading is not needed. '
  'See class docs for usage example.',
)
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
        throw const TimeoutException('Screen loading timed out');
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
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            children: [
              // Shimmer للـ AppBar
              ShimmerPlaceholder.text(width: 150, height: 28),
              SizedBox(height: AlhaiSpacing.lg),

              // Shimmer للمحتوى
              Expanded(
                child: ShimmerLoading(
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: AlhaiSpacing.md),
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
            padding: const EdgeInsets.all(AlhaiSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                SizedBox(height: AlhaiSpacing.md),
                Text(
                  AppLocalizations.of(context).screenLoadError,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AlhaiSpacing.xs),
                Text(
                  _getErrorMessage(error, context),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AlhaiSpacing.lg),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(Object error, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (error is TimeoutException) {
      return l10n.timeoutCheckConnection;
    }
    return l10n.retryLaterMessage;
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
  static const int _maxCacheSize = 20;

  /// تحميل شاشة مسبقاً
  static Future<void> preload(
    String key,
    Future<Widget> Function() builder,
  ) async {
    if (_cache.containsKey(key) || _loading.contains(key)) {
      return;
    }

    // حد أقصى لحجم الكاش لمنع تسرب الذاكرة (M98 fix)
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
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
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Column(
                  children: [
                    // Search Bar
                    ShimmerPlaceholder.card(height: 48),
                    SizedBox(height: AlhaiSpacing.md),
                    // Categories
                    SizedBox(
                      height: 40,
                      child: ShimmerLoading(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (_, __) => Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8),
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
                    SizedBox(height: AlhaiSpacing.md),
                    // Products Grid
                    Expanded(
                      child: ShimmerGrid(
                        crossAxisCount: getResponsiveGridColumns(context,
                            mobile: 2, desktop: 4),
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
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Column(
                children: [
                  ShimmerPlaceholder.text(width: 100, height: 24),
                  SizedBox(height: AlhaiSpacing.md),
                  const Expanded(
                    child: ShimmerList(itemCount: 4, itemHeight: 60),
                  ),
                  SizedBox(height: AlhaiSpacing.md),
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
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              ShimmerPlaceholder.text(width: 150, height: 28),
              SizedBox(height: AlhaiSpacing.lg),
              // Stats Cards
              Row(
                children: List.generate(
                  3,
                  (_) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.xs),
                      child: ShimmerPlaceholder.card(height: 100),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AlhaiSpacing.lg),
              // Chart
              ShimmerPlaceholder.card(height: 200),
              SizedBox(height: AlhaiSpacing.lg),
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
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            children: [
              // Search & Filter
              Row(
                children: [
                  Expanded(child: ShimmerPlaceholder.card(height: 48)),
                  SizedBox(width: AlhaiSpacing.md),
                  ShimmerPlaceholder.card(width: 48, height: 48),
                ],
              ),
              SizedBox(height: AlhaiSpacing.md),
              // Categories
              SizedBox(
                height: 40,
                child: ShimmerLoading(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
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
              SizedBox(height: AlhaiSpacing.md),
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
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              ShimmerPlaceholder.text(width: 120, height: 28),
              SizedBox(height: AlhaiSpacing.md),
              // Summary Cards
              Row(
                children: List.generate(
                  3,
                  (_) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.xxs),
                      child: ShimmerPlaceholder.card(height: 80),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AlhaiSpacing.lg),
              // Search
              ShimmerPlaceholder.card(height: 48),
              SizedBox(height: AlhaiSpacing.md),
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
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            children: [
              // Search & Add Button
              Row(
                children: [
                  Expanded(child: ShimmerPlaceholder.card(height: 48)),
                  SizedBox(width: AlhaiSpacing.md),
                  ShimmerPlaceholder.card(width: 48, height: 48),
                ],
              ),
              SizedBox(height: AlhaiSpacing.md),
              // Filters
              SizedBox(
                height: 36,
                child: ShimmerLoading(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
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
              SizedBox(height: AlhaiSpacing.md),
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
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            children: [
              // Search
              ShimmerPlaceholder.card(height: 48),
              SizedBox(height: AlhaiSpacing.md),
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
