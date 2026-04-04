/// Memory Monitor - مراقبة وإدارة الذاكرة
///
/// يوفر:
/// - مراقبة استخدام الذاكرة
/// - تنظيف تلقائي عند الضغط
/// - تحذيرات عند الاستخدام العالي
/// - تقارير الذاكرة
library memory_monitor;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// مستوى ضغط الذاكرة
enum MemoryPressureLevel {
  /// استخدام عادي
  normal,

  /// ضغط متوسط - يجب تنظيف الـ cache
  moderate,

  /// ضغط عالي - يجب تحرير الذاكرة فوراً
  critical,
}

/// نوع الإجراء عند ضغط الذاكرة
typedef MemoryCleanupCallback = Future<void> Function(
    MemoryPressureLevel level);

/// خدمة مراقبة الذاكرة
class MemoryMonitor {
  MemoryMonitor._();

  static MemoryMonitor? _instance;
  static MemoryMonitor get instance => _instance ??= MemoryMonitor._();

  /// قائمة callbacks للتنظيف
  final List<MemoryCleanupCallback> _cleanupCallbacks = [];

  /// Timer للمراقبة الدورية
  Timer? _monitorTimer;

  /// آخر مستوى ضغط
  MemoryPressureLevel _lastPressureLevel = MemoryPressureLevel.normal;

  /// عدد مرات الضغط العالي
  int _criticalPressureCount = 0;

  /// هل المراقبة نشطة
  bool _isMonitoring = false;

  /// الحد الأقصى المسموح للذاكرة (MB)
  static const int maxMemoryMB = 150;

  /// حد التحذير (MB)
  static const int warningMemoryMB = 100;

  /// حد الضغط العالي (MB)
  static const int criticalMemoryMB = 130;

  /// بدء المراقبة
  void startMonitoring({
    Duration interval = const Duration(seconds: 30),
  }) {
    if (_isMonitoring) return;

    _isMonitoring = true;

    // مراقبة دورية
    _monitorTimer = Timer.periodic(interval, (_) {
      _checkMemoryUsage();
    });

    // الاستماع لضغط النظام
    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message == AppLifecycleState.paused.toString()) {
        // التطبيق في الخلفية - تنظيف خفيف
        await _cleanup(MemoryPressureLevel.moderate);
      }
      return null;
    });

    debugPrint('[MemoryMonitor] Started monitoring');
  }

  /// إيقاف المراقبة
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    SystemChannels.lifecycle.setMessageHandler(null);
    _isMonitoring = false;
    debugPrint('[MemoryMonitor] Stopped monitoring');
  }

  /// تسجيل callback للتنظيف
  void registerCleanupCallback(MemoryCleanupCallback callback) {
    _cleanupCallbacks.add(callback);
  }

  /// إلغاء تسجيل callback
  void unregisterCleanupCallback(MemoryCleanupCallback callback) {
    _cleanupCallbacks.remove(callback);
  }

  /// التحقق من استخدام الذاكرة
  void _checkMemoryUsage() {
    final level = _getCurrentPressureLevel();

    if (level != _lastPressureLevel) {
      _lastPressureLevel = level;

      if (level == MemoryPressureLevel.critical) {
        _criticalPressureCount++;
        debugPrint('[MemoryMonitor] ⚠️ Critical memory pressure detected!');
      }

      if (level != MemoryPressureLevel.normal) {
        _cleanup(level);
      }
    }
  }

  /// الحصول على مستوى الضغط الحالي
  MemoryPressureLevel _getCurrentPressureLevel() {
    // استخدام حجم cache الصور كمؤشر
    final imageCacheSize = PaintingBinding.instance.imageCache.currentSizeBytes;
    final imageCacheMB = imageCacheSize / (1024 * 1024);

    if (imageCacheMB > criticalMemoryMB) {
      return MemoryPressureLevel.critical;
    } else if (imageCacheMB > warningMemoryMB) {
      return MemoryPressureLevel.moderate;
    }
    return MemoryPressureLevel.normal;
  }

  /// تنظيف الذاكرة
  Future<void> _cleanup(MemoryPressureLevel level) async {
    debugPrint('[MemoryMonitor] Cleaning up at level: $level');

    // تنظيف cache الصور حسب المستوى
    if (level == MemoryPressureLevel.critical) {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } else if (level == MemoryPressureLevel.moderate) {
      // تقليل حجم الـ cache بدلاً من مسحه بالكامل
      PaintingBinding.instance.imageCache.maximumSize = 50;
      // استعادة الحد بعد فترة
      Future.delayed(const Duration(minutes: 2), () {
        PaintingBinding.instance.imageCache.maximumSize = 100;
      });
    }

    // استدعاء callbacks المسجلة
    for (final callback in _cleanupCallbacks) {
      try {
        await callback(level);
      } catch (e) {
        debugPrint('[MemoryMonitor] Error in cleanup callback: $e');
      }
    }
  }

  /// تنظيف يدوي
  Future<void> forceCleanup() async {
    await _cleanup(MemoryPressureLevel.critical);
  }

  /// الحصول على تقرير الذاكرة
  MemoryReport getReport() {
    final imageCache = PaintingBinding.instance.imageCache;

    return MemoryReport(
      imageCacheSize: imageCache.currentSizeBytes,
      imageCacheCount: imageCache.liveImageCount,
      maxImageCacheSize: imageCache.maximumSizeBytes,
      maxImageCacheCount: imageCache.maximumSize,
      pressureLevel: _lastPressureLevel,
      criticalPressureCount: _criticalPressureCount,
      isMonitoring: _isMonitoring,
    );
  }

  /// مراقب للـ Widget
  Widget wrapWithMemoryMonitor(Widget child) {
    if (kReleaseMode) return child; // No-op in production
    return _MemoryMonitorWidget(child: child);
  }
}

/// تقرير الذاكرة
class MemoryReport {
  /// حجم cache الصور (bytes)
  final int imageCacheSize;

  /// عدد الصور في الـ cache
  final int imageCacheCount;

  /// الحد الأقصى لحجم cache الصور
  final int maxImageCacheSize;

  /// الحد الأقصى لعدد الصور
  final int maxImageCacheCount;

  /// مستوى الضغط الحالي
  final MemoryPressureLevel pressureLevel;

  /// عدد مرات الضغط العالي
  final int criticalPressureCount;

  /// هل المراقبة نشطة
  final bool isMonitoring;

  const MemoryReport({
    required this.imageCacheSize,
    required this.imageCacheCount,
    required this.maxImageCacheSize,
    required this.maxImageCacheCount,
    required this.pressureLevel,
    required this.criticalPressureCount,
    required this.isMonitoring,
  });

  /// حجم الـ cache بالميغابايت
  double get imageCacheSizeMB => imageCacheSize / (1024 * 1024);

  /// نسبة استخدام الـ cache
  double get cacheUsagePercent =>
      maxImageCacheSize > 0 ? (imageCacheSize / maxImageCacheSize) * 100 : 0;

  @override
  String toString() {
    return '''
MemoryReport:
  Image Cache: ${imageCacheSizeMB.toStringAsFixed(2)} MB ($imageCacheCount images)
  Max Cache: ${(maxImageCacheSize / (1024 * 1024)).toStringAsFixed(2)} MB ($maxImageCacheCount images)
  Usage: ${cacheUsagePercent.toStringAsFixed(1)}%
  Pressure Level: $pressureLevel
  Critical Count: $criticalPressureCount
  Monitoring: $isMonitoring
''';
  }
}

/// Widget للمراقبة التلقائية
class _MemoryMonitorWidget extends StatefulWidget {
  final Widget child;

  const _MemoryMonitorWidget({required this.child});

  @override
  State<_MemoryMonitorWidget> createState() => _MemoryMonitorWidgetState();
}

class _MemoryMonitorWidgetState extends State<_MemoryMonitorWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // تنظيف عند انتقال التطبيق للخلفية
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      debugPrint('[MemoryMonitor] App going to background, cleaning up...');
      MemoryMonitor.instance.forceCleanup();
    }
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    debugPrint('[MemoryMonitor] Received memory pressure from system');
    MemoryMonitor.instance.forceCleanup();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Mixin لإضافة إدارة الذاكرة للـ StatefulWidgets
mixin MemoryAwareMixin<T extends StatefulWidget> on State<T> {
  /// قائمة الموارد للتنظيف
  final List<VoidCallback> _disposables = [];

  /// تسجيل مورد للتنظيف
  void registerDisposable(VoidCallback dispose) {
    _disposables.add(dispose);
  }

  /// تسجيل Timer للإلغاء التلقائي
  void registerTimer(Timer timer) {
    _disposables.add(timer.cancel);
  }

  /// تسجيل StreamSubscription للإلغاء التلقائي
  void registerSubscription(StreamSubscription subscription) {
    _disposables.add(subscription.cancel);
  }

  /// تسجيل ScrollController للتنظيف
  void registerScrollController(ScrollController controller) {
    _disposables.add(controller.dispose);
  }

  /// تسجيل TextEditingController للتنظيف
  void registerTextController(TextEditingController controller) {
    _disposables.add(controller.dispose);
  }

  /// تسجيل AnimationController للتنظيف
  void registerAnimationController(AnimationController controller) {
    _disposables.add(controller.dispose);
  }

  @override
  void dispose() {
    // تنظيف جميع الموارد المسجلة
    for (final dispose in _disposables) {
      try {
        dispose();
      } catch (e) {
        debugPrint('[MemoryAware] Error disposing resource: $e');
      }
    }
    _disposables.clear();
    super.dispose();
  }
}

/// Extension لتسهيل التنظيف
extension DisposableExtension on dynamic {
  /// تنظيف آمن
  void safeDispose() {
    try {
      if (this is Timer) {
        (this as Timer).cancel();
      } else if (this is StreamSubscription) {
        (this as StreamSubscription).cancel();
      } else if (this is ChangeNotifier) {
        (this as ChangeNotifier).dispose();
      }
    } catch (e) {
      debugPrint('[Dispose] Error: $e');
    }
  }
}

/// Widget للكشف عن تسرب الذاكرة في Debug mode
class MemoryLeakDetector extends StatefulWidget {
  final Widget child;
  final String name;

  const MemoryLeakDetector({
    super.key,
    required this.child,
    required this.name,
  });

  @override
  State<MemoryLeakDetector> createState() => _MemoryLeakDetectorState();
}

class _MemoryLeakDetectorState extends State<MemoryLeakDetector> {
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('[MemoryLeak] 📥 ${widget.name} created');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('[MemoryLeak] 📤 ${widget.name} disposed');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
