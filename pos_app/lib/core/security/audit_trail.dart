/// Audit Trail Service
///
/// سجل تدقيق شامل لجميع العمليات الحساسة:
/// - تتبع جميع الإجراءات
/// - من قام بها ومتى
/// - البيانات قبل وبعد التغيير
/// - دعم التقارير والتحقيقات
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// نوع الحدث
enum AuditEventType {
  // Authentication
  login,
  logout,
  loginFailed,
  passwordChanged,
  pinChanged,

  // Data Operations
  create,
  read,
  update,
  delete,

  // Sales
  saleCreated,
  saleVoided,
  refundProcessed,
  discountApplied,

  // Inventory
  stockAdjusted,
  productCreated,
  productUpdated,
  productDeleted,

  // Financial
  cashDrawerOpened,
  cashDrawerClosed,
  paymentReceived,

  // System
  settingsChanged,
  permissionGranted,
  permissionRevoked,
  exportData,
  importData,

  // Security
  suspiciousActivity,
  accessDenied,
  rateLimitExceeded,
}

/// خطورة الحدث
enum AuditSeverity {
  low,      // قراءة بيانات
  medium,   // تعديل عادي
  high,     // تعديل مالي
  critical, // أمان وصلاحيات
}

/// سجل التدقيق
class AuditEntry {
  final String id;
  final DateTime timestamp;
  final AuditEventType eventType;
  final AuditSeverity severity;
  final String? userId;
  final String? userName;
  final String? entityType;
  final String? entityId;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final Map<String, dynamic>? metadata;
  final String? ipAddress;
  final String? deviceInfo;
  final String? description;

  AuditEntry({
    required this.id,
    required this.eventType,
    required this.severity,
    this.userId,
    this.userName,
    this.entityType,
    this.entityId,
    this.oldData,
    this.newData,
    this.metadata,
    this.ipAddress,
    this.deviceInfo,
    this.description,
  }) : timestamp = DateTime.now();

  /// الفرق بين البيانات القديمة والجديدة
  Map<String, dynamic>? get changes {
    if (oldData == null || newData == null) return null;

    final diff = <String, dynamic>{};
    for (final key in newData!.keys) {
      if (oldData![key] != newData![key]) {
        diff[key] = {
          'from': oldData![key],
          'to': newData![key],
        };
      }
    }
    return diff.isEmpty ? null : diff;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'eventType': eventType.name,
    'severity': severity.name,
    'userId': userId,
    'userName': userName,
    'entityType': entityType,
    'entityId': entityId,
    'oldData': oldData,
    'newData': newData,
    'changes': changes,
    'metadata': metadata,
    'ipAddress': ipAddress,
    'deviceInfo': deviceInfo,
    'description': description,
  };

  String toLogString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('[${severity.name.toUpperCase()}] ');
    buffer.write('${eventType.name} ');
    if (userName != null) buffer.write('by $userName ');
    if (entityType != null) buffer.write('on $entityType');
    if (entityId != null) buffer.write(':$entityId');
    if (description != null) buffer.write(' - $description');
    return buffer.toString();
  }
}

/// فلتر البحث في سجل التدقيق
class AuditFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<AuditEventType>? eventTypes;
  final List<AuditSeverity>? severities;
  final String? userId;
  final String? entityType;
  final String? entityId;
  final int? limit;
  final int? offset;

  const AuditFilter({
    this.startDate,
    this.endDate,
    this.eventTypes,
    this.severities,
    this.userId,
    this.entityType,
    this.entityId,
    this.limit,
    this.offset,
  });
}

/// Audit Trail Service
/// تم تحسينه لحفظ السجلات في قاعدة البيانات بالإضافة للذاكرة
class AuditTrail {
  AuditTrail._();

  static final List<AuditEntry> _entries = [];
  static const int _maxEntries = 10000;
  static int _idCounter = 0;

  // Sinks للتخزين
  static final List<Future<void> Function(AuditEntry)> _sinks = [];

  // Database Sink - للحفظ في قاعدة البيانات
  static Future<void> Function(AuditEntry)? _databaseSink;
  static String? _currentStoreId;

  // Context الحالي (user, device, etc.)
  static String? _currentUserId;
  static String? _currentUserName;
  static String? _deviceInfo;

  /// تعيين Context المستخدم الحالي
  static void setUserContext({
    required String userId,
    required String userName,
    String? storeId,
  }) {
    _currentUserId = userId;
    _currentUserName = userName;
    if (storeId != null) {
      _currentStoreId = storeId;
    }
  }

  /// تعيين معرّف المتجر
  static void setStoreId(String storeId) {
    _currentStoreId = storeId;
  }

  /// تعيين Database Sink للحفظ في قاعدة البيانات
  /// يجب استدعاء هذه الدالة عند بدء التطبيق مع تمرير دالة الحفظ
  static void setDatabaseSink(Future<void> Function(AuditEntry) sink) {
    _databaseSink = sink;
  }

  /// تعيين معلومات الجهاز
  static void setDeviceInfo(String info) {
    _deviceInfo = info;
  }

  /// مسح Context
  static void clearContext() {
    _currentUserId = null;
    _currentUserName = null;
    _currentStoreId = null;
  }

  /// الحصول على معرّف المتجر الحالي
  static String? get currentStoreId => _currentStoreId;

  /// إضافة Sink للتخزين
  static void addSink(Future<void> Function(AuditEntry) sink) {
    _sinks.add(sink);
  }

  /// تسجيل حدث
  static Future<String> log({
    required AuditEventType eventType,
    AuditSeverity? severity,
    String? userId,
    String? userName,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    Map<String, dynamic>? metadata,
    String? description,
  }) async {
    final id = 'audit_${++_idCounter}_${DateTime.now().millisecondsSinceEpoch}';

    final entry = AuditEntry(
      id: id,
      eventType: eventType,
      severity: severity ?? _getSeverity(eventType),
      userId: userId ?? _currentUserId,
      userName: userName ?? _currentUserName,
      entityType: entityType,
      entityId: entityId,
      oldData: _sanitizeData(oldData),
      newData: _sanitizeData(newData),
      metadata: metadata,
      deviceInfo: _deviceInfo,
      description: description,
    );

    // تخزين محلي (في الذاكرة)
    _entries.add(entry);
    while (_entries.length > _maxEntries) {
      _entries.removeAt(0);
    }

    // حفظ في قاعدة البيانات (إن وُجد)
    if (_databaseSink != null) {
      try {
        await _databaseSink!(entry);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Audit DB sink error: $e');
        }
      }
    }

    // إرسال للـ Sinks الإضافية
    for (final sink in _sinks) {
      try {
        await sink(entry);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Audit sink error: $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('📝 AUDIT: ${entry.toLogString()}');
    }

    return id;
  }

  // === Convenience Methods ===

  /// تسجيل دخول
  static Future<String> logLogin({
    required String userId,
    required String userName,
    Map<String, dynamic>? metadata,
  }) {
    return log(
      eventType: AuditEventType.login,
      userId: userId,
      userName: userName,
      metadata: metadata,
      description: 'User logged in',
    );
  }

  /// تسجيل خروج
  static Future<String> logLogout() {
    return log(
      eventType: AuditEventType.logout,
      description: 'User logged out',
    );
  }

  /// فشل تسجيل الدخول
  static Future<String> logLoginFailed({
    String? identifier,
    String? reason,
  }) {
    return log(
      eventType: AuditEventType.loginFailed,
      metadata: {'identifier': identifier, 'reason': reason},
      description: 'Login attempt failed: $reason',
    );
  }

  /// إنشاء عملية بيع
  static Future<String> logSaleCreated({
    required String saleId,
    required double total,
    required int itemCount,
  }) {
    return log(
      eventType: AuditEventType.saleCreated,
      entityType: 'sale',
      entityId: saleId,
      newData: {'total': total, 'itemCount': itemCount},
      description: 'Sale created: $total SAR',
    );
  }

  /// إلغاء عملية بيع
  static Future<String> logSaleVoided({
    required String saleId,
    required String reason,
  }) {
    return log(
      eventType: AuditEventType.saleVoided,
      entityType: 'sale',
      entityId: saleId,
      metadata: {'reason': reason},
      description: 'Sale voided: $reason',
    );
  }

  /// تعديل المخزون
  static Future<String> logStockAdjusted({
    required String productId,
    required int oldQty,
    required int newQty,
    required String reason,
  }) {
    return log(
      eventType: AuditEventType.stockAdjusted,
      entityType: 'product',
      entityId: productId,
      oldData: {'stockQty': oldQty},
      newData: {'stockQty': newQty},
      metadata: {'reason': reason},
      description: 'Stock adjusted: $oldQty → $newQty ($reason)',
    );
  }

  /// تغيير الإعدادات
  static Future<String> logSettingsChanged({
    required String setting,
    dynamic oldValue,
    dynamic newValue,
  }) {
    return log(
      eventType: AuditEventType.settingsChanged,
      entityType: 'settings',
      entityId: setting,
      oldData: {'value': oldValue},
      newData: {'value': newValue},
      description: 'Setting "$setting" changed',
    );
  }

  /// نشاط مشبوه
  static Future<String> logSuspiciousActivity({
    required String activity,
    Map<String, dynamic>? details,
  }) {
    return log(
      eventType: AuditEventType.suspiciousActivity,
      severity: AuditSeverity.critical,
      metadata: details,
      description: 'Suspicious activity: $activity',
    );
  }

  /// رفض الوصول
  static Future<String> logAccessDenied({
    required String resource,
    required String reason,
  }) {
    return log(
      eventType: AuditEventType.accessDenied,
      severity: AuditSeverity.high,
      entityType: 'resource',
      entityId: resource,
      metadata: {'reason': reason},
      description: 'Access denied to $resource: $reason',
    );
  }

  /// البحث في السجلات
  static List<AuditEntry> query(AuditFilter filter) {
    var results = _entries.toList();

    if (filter.startDate != null) {
      results = results.where((e) => e.timestamp.isAfter(filter.startDate!)).toList();
    }

    if (filter.endDate != null) {
      results = results.where((e) => e.timestamp.isBefore(filter.endDate!)).toList();
    }

    if (filter.eventTypes != null && filter.eventTypes!.isNotEmpty) {
      results = results.where((e) => filter.eventTypes!.contains(e.eventType)).toList();
    }

    if (filter.severities != null && filter.severities!.isNotEmpty) {
      results = results.where((e) => filter.severities!.contains(e.severity)).toList();
    }

    if (filter.userId != null) {
      results = results.where((e) => e.userId == filter.userId).toList();
    }

    if (filter.entityType != null) {
      results = results.where((e) => e.entityType == filter.entityType).toList();
    }

    if (filter.entityId != null) {
      results = results.where((e) => e.entityId == filter.entityId).toList();
    }

    // Sort by timestamp descending
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (filter.offset != null) {
      results = results.skip(filter.offset!).toList();
    }

    if (filter.limit != null) {
      results = results.take(filter.limit!).toList();
    }

    return results;
  }

  /// تصدير السجلات
  static String exportToJson(AuditFilter? filter) {
    final entries = filter != null ? query(filter) : _entries;
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }

  /// مسح السجلات (للاختبار فقط)
  @visibleForTesting
  static void clear() {
    _entries.clear();
    _idCounter = 0;
  }

  /// تحديد خطورة الحدث
  static AuditSeverity _getSeverity(AuditEventType type) {
    return switch (type) {
      AuditEventType.read => AuditSeverity.low,
      AuditEventType.login ||
      AuditEventType.logout => AuditSeverity.medium,
      AuditEventType.create ||
      AuditEventType.update ||
      AuditEventType.delete => AuditSeverity.medium,
      AuditEventType.saleCreated ||
      AuditEventType.saleVoided ||
      AuditEventType.refundProcessed ||
      AuditEventType.paymentReceived => AuditSeverity.high,
      AuditEventType.loginFailed ||
      AuditEventType.passwordChanged ||
      AuditEventType.pinChanged ||
      AuditEventType.permissionGranted ||
      AuditEventType.permissionRevoked ||
      AuditEventType.suspiciousActivity ||
      AuditEventType.accessDenied ||
      AuditEventType.rateLimitExceeded => AuditSeverity.critical,
      _ => AuditSeverity.medium,
    };
  }

  /// تنظيف البيانات الحساسة
  static Map<String, dynamic>? _sanitizeData(Map<String, dynamic>? data) {
    if (data == null) return null;

    const sensitiveKeys = ['password', 'pin', 'token', 'secret', 'key', 'cvv', 'card_number'];

    return data.map((key, value) {
      if (sensitiveKeys.any((k) => key.toLowerCase().contains(k))) {
        return MapEntry(key, '***REDACTED***');
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _sanitizeData(value));
      }
      return MapEntry(key, value);
    });
  }

  /// تحويل AuditEventType إلى AuditAction للتخزين في قاعدة البيانات
  static String eventTypeToActionName(AuditEventType type) {
    return switch (type) {
      AuditEventType.login => 'login',
      AuditEventType.logout => 'logout',
      AuditEventType.loginFailed => 'login', // سيتم تمييزه بالوصف
      AuditEventType.passwordChanged => 'settingsChange',
      AuditEventType.pinChanged => 'settingsChange',
      AuditEventType.create => 'productCreate',
      AuditEventType.read => 'productEdit',
      AuditEventType.update => 'productEdit',
      AuditEventType.delete => 'productDelete',
      AuditEventType.saleCreated => 'saleCreate',
      AuditEventType.saleVoided => 'saleCancel',
      AuditEventType.refundProcessed => 'saleRefund',
      AuditEventType.discountApplied => 'saleCreate',
      AuditEventType.stockAdjusted => 'stockAdjust',
      AuditEventType.productCreated => 'productCreate',
      AuditEventType.productUpdated => 'productEdit',
      AuditEventType.productDeleted => 'productDelete',
      AuditEventType.cashDrawerOpened => 'cashDrawerOpen',
      AuditEventType.cashDrawerClosed => 'shiftClose',
      AuditEventType.paymentReceived => 'paymentRecord',
      AuditEventType.settingsChanged => 'settingsChange',
      AuditEventType.permissionGranted => 'settingsChange',
      AuditEventType.permissionRevoked => 'settingsChange',
      AuditEventType.exportData => 'settingsChange',
      AuditEventType.importData => 'settingsChange',
      AuditEventType.suspiciousActivity => 'login',
      AuditEventType.accessDenied => 'login',
      AuditEventType.rateLimitExceeded => 'login',
    };
  }
}
