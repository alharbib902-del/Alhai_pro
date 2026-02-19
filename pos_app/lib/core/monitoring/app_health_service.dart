/// App Health Service
///
/// خدمة مراقبة صحة التطبيق وأدائه:
/// - مراقبة حالة الاتصال
/// - مراقبة حالة قاعدة البيانات
/// - مراقبة طابور المزامنة
/// - تشخيص المشاكل
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

/// حالة صحة التطبيق
enum HealthStatus {
  healthy,    // كل شيء يعمل بشكل جيد
  degraded,   // بعض المشاكل البسيطة
  unhealthy,  // مشاكل خطيرة
  unknown,    // لم يتم الفحص بعد
}

/// نتيجة فحص صحة مكون
class ComponentHealth {
  final String name;
  final HealthStatus status;
  final String? message;
  final Map<String, dynamic>? details;
  final DateTime checkedAt;

  ComponentHealth({
    required this.name,
    required this.status,
    this.message,
    this.details,
  }) : checkedAt = DateTime.now();

  bool get isHealthy => status == HealthStatus.healthy;
  bool get isDegraded => status == HealthStatus.degraded;
  bool get isUnhealthy => status == HealthStatus.unhealthy;

  Map<String, dynamic> toJson() => {
    'name': name,
    'status': status.name,
    'message': message,
    'details': details,
    'checkedAt': checkedAt.toIso8601String(),
  };
}

/// نتيجة فحص صحة التطبيق الكاملة
class AppHealthReport {
  final HealthStatus overallStatus;
  final List<ComponentHealth> components;
  final DateTime generatedAt;
  final Duration checkDuration;

  AppHealthReport({
    required this.overallStatus,
    required this.components,
    required this.checkDuration,
  }) : generatedAt = DateTime.now();

  /// عدد المكونات السليمة
  int get healthyCount => components.where((c) => c.isHealthy).length;

  /// عدد المكونات المتدهورة
  int get degradedCount => components.where((c) => c.isDegraded).length;

  /// عدد المكونات غير السليمة
  int get unhealthyCount => components.where((c) => c.isUnhealthy).length;

  /// هل كل شيء سليم؟
  bool get isAllHealthy => overallStatus == HealthStatus.healthy;

  Map<String, dynamic> toJson() => {
    'overallStatus': overallStatus.name,
    'components': components.map((c) => c.toJson()).toList(),
    'generatedAt': generatedAt.toIso8601String(),
    'checkDurationMs': checkDuration.inMilliseconds,
    'summary': {
      'healthy': healthyCount,
      'degraded': degradedCount,
      'unhealthy': unhealthyCount,
      'total': components.length,
    },
  };
}

/// فحص صحة مكون معين
typedef HealthCheck = Future<ComponentHealth> Function();

/// خدمة صحة التطبيق
class AppHealthService {
  AppHealthService._();

  static final Map<String, HealthCheck> _healthChecks = {};
  static Timer? _periodicCheckTimer;
  static AppHealthReport? _lastReport;

  /// تسجيل فحص صحة جديد
  static void registerCheck(String name, HealthCheck check) {
    _healthChecks[name] = check;
    if (kDebugMode) {
      debugPrint('🏥 Health check registered: $name');
    }
  }

  /// إزالة فحص صحة
  static void unregisterCheck(String name) {
    _healthChecks.remove(name);
  }

  /// تنفيذ جميع فحوصات الصحة
  static Future<AppHealthReport> checkHealth() async {
    final stopwatch = Stopwatch()..start();
    final components = <ComponentHealth>[];

    for (final entry in _healthChecks.entries) {
      ComponentHealth health;
      try {
        health = await Future.any([
          entry.value(),
          Future.delayed(
            const Duration(seconds: 10),
            () => ComponentHealth(
              name: entry.key,
              status: HealthStatus.unhealthy,
              message: 'Health check timed out',
            ),
          ),
        ]);
      } catch (e) {
        health = ComponentHealth(
          name: entry.key,
          status: HealthStatus.unhealthy,
          message: 'Health check failed: $e',
        );
      }
      components.add(health);
    }

    stopwatch.stop();

    // حساب الحالة العامة
    final overallStatus = _calculateOverallStatus(components);

    final report = AppHealthReport(
      overallStatus: overallStatus,
      components: components,
      checkDuration: stopwatch.elapsed,
    );

    _lastReport = report;

    if (kDebugMode) {
      debugPrint('🏥 Health check completed: ${overallStatus.name} '
          '(${components.length} components, ${stopwatch.elapsedMilliseconds}ms)');
    }

    return report;
  }

  /// الحصول على آخر تقرير
  static AppHealthReport? get lastReport => _lastReport;

  /// بدء الفحص الدوري
  static void startPeriodicCheck({
    Duration interval = const Duration(minutes: 5),
    void Function(AppHealthReport)? onReport,
  }) {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(interval, (_) async {
      final report = await checkHealth();
      onReport?.call(report);
    });

    if (kDebugMode) {
      debugPrint('🏥 Periodic health check started (every ${interval.inMinutes} min)');
    }
  }

  /// إيقاف الفحص الدوري
  static void stopPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
  }

  /// حساب الحالة العامة
  static HealthStatus _calculateOverallStatus(List<ComponentHealth> components) {
    if (components.isEmpty) return HealthStatus.unknown;

    final hasUnhealthy = components.any((c) => c.isUnhealthy);
    final hasDegraded = components.any((c) => c.isDegraded);

    if (hasUnhealthy) return HealthStatus.unhealthy;
    if (hasDegraded) return HealthStatus.degraded;
    return HealthStatus.healthy;
  }

  /// مسح جميع الفحوصات
  static void clear() {
    _healthChecks.clear();
    _periodicCheckTimer?.cancel();
    _lastReport = null;
  }
}

/// فحوصات صحة جاهزة للاستخدام
class HealthChecks {
  HealthChecks._();

  /// فحص الاتصال بالإنترنت
  static HealthCheck connectivity(Future<bool> Function() checkOnline) {
    return () async {
      final isOnline = await checkOnline();
      return ComponentHealth(
        name: 'connectivity',
        status: isOnline ? HealthStatus.healthy : HealthStatus.degraded,
        message: isOnline ? 'Online' : 'Offline - working in offline mode',
        details: {'isOnline': isOnline},
      );
    };
  }

  /// فحص قاعدة البيانات
  static HealthCheck database(Future<bool> Function() checkDatabase) {
    return () async {
      try {
        final isHealthy = await checkDatabase();
        return ComponentHealth(
          name: 'database',
          status: isHealthy ? HealthStatus.healthy : HealthStatus.unhealthy,
          message: isHealthy ? 'Database operational' : 'Database error',
        );
      } catch (e) {
        return ComponentHealth(
          name: 'database',
          status: HealthStatus.unhealthy,
          message: 'Database check failed: $e',
        );
      }
    };
  }

  /// فحص طابور المزامنة
  static HealthCheck syncQueue({
    required Future<int> Function() getPendingCount,
    required Future<int> Function() getFailedCount,
    int warningThreshold = 50,
    int criticalThreshold = 200,
  }) {
    return () async {
      final pendingCount = await getPendingCount();
      final failedCount = await getFailedCount();

      HealthStatus status;
      String message;

      if (failedCount > 10 || pendingCount > criticalThreshold) {
        status = HealthStatus.unhealthy;
        message = 'Sync queue critical: $pendingCount pending, $failedCount failed';
      } else if (pendingCount > warningThreshold || failedCount > 0) {
        status = HealthStatus.degraded;
        message = 'Sync queue warning: $pendingCount pending, $failedCount failed';
      } else {
        status = HealthStatus.healthy;
        message = 'Sync queue healthy: $pendingCount pending';
      }

      return ComponentHealth(
        name: 'sync_queue',
        status: status,
        message: message,
        details: {
          'pendingCount': pendingCount,
          'failedCount': failedCount,
        },
      );
    };
  }

  /// فحص الذاكرة
  static HealthCheck memory({
    int warningThresholdMB = 200,
    int criticalThresholdMB = 400,
  }) {
    return () async {
      // ملاحظة: هذا تقدير بسيط، للحصول على قيم دقيقة استخدم native code
      final currentUsage = ProcessInfo.currentRss ~/ (1024 * 1024); // MB

      HealthStatus status;
      String message;

      if (currentUsage > criticalThresholdMB) {
        status = HealthStatus.unhealthy;
        message = 'High memory usage: ${currentUsage}MB';
      } else if (currentUsage > warningThresholdMB) {
        status = HealthStatus.degraded;
        message = 'Elevated memory usage: ${currentUsage}MB';
      } else {
        status = HealthStatus.healthy;
        message = 'Normal memory usage: ${currentUsage}MB';
      }

      return ComponentHealth(
        name: 'memory',
        status: status,
        message: message,
        details: {'usageMB': currentUsage},
      );
    };
  }

  /// فحص مساحة التخزين (placeholder - يحتاج native implementation)
  static HealthCheck storage({
    double warningThresholdPercent = 80,
    double criticalThresholdPercent = 95,
  }) {
    return () async {
      // Placeholder - في التطبيق الفعلي، استخدم path_provider + disk_space
      return ComponentHealth(
        name: 'storage',
        status: HealthStatus.healthy,
        message: 'Storage check not fully implemented',
        details: {'note': 'Requires native implementation'},
      );
    };
  }
}

/// معلومات العملية (للذاكرة)
class ProcessInfo {
  ProcessInfo._();

  /// الذاكرة المستخدمة (تقريبي)
  static int get currentRss {
    // هذا تقدير - للقيم الدقيقة استخدم native code
    return 100 * 1024 * 1024; // 100MB placeholder
  }
}
