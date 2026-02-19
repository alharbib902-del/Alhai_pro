/// مزود الإشعارات - Notifications Provider
///
/// يدير إشعارات التطبيق مثل:
/// - طلبات جديدة
/// - تنبيهات المخزون
/// - تحديثات المبيعات
/// - اقتراحات AI
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ============================================================================
// NOTIFICATION MODEL
// ============================================================================

/// أنواع الإشعارات
enum NotificationType {
  /// طلب جديد
  newOrder,
  /// تنبيه مخزون منخفض
  lowStock,
  /// تنبيه نفاد المخزون
  outOfStock,
  /// بيع جديد
  newSale,
  /// دين جديد
  newDebt,
  /// تذكير دفع
  paymentReminder,
  /// اقتراح AI
  aiSuggestion,
  /// تحديث النظام
  systemUpdate,
  /// عام
  general,
}

/// أولوية الإشعار
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// نموذج الإشعار
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? actionRoute;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.createdAt,
    this.isRead = false,
    this.data,
    this.actionRoute,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? actionRoute,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type.index,
        'priority': priority.index,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'data': data,
        'actionRoute': actionRoute,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values[json['type']],
      priority: NotificationPriority.values[json['priority']],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
      actionRoute: json['actionRoute'],
    );
  }

  /// أيقونة الإشعار
  IconData get icon {
    switch (type) {
      case NotificationType.newOrder:
        return Icons.shopping_bag;
      case NotificationType.lowStock:
        return Icons.inventory;
      case NotificationType.outOfStock:
        return Icons.warning;
      case NotificationType.newSale:
        return Icons.point_of_sale;
      case NotificationType.newDebt:
        return Icons.account_balance_wallet;
      case NotificationType.paymentReminder:
        return Icons.payment;
      case NotificationType.aiSuggestion:
        return Icons.auto_awesome;
      case NotificationType.systemUpdate:
        return Icons.system_update;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  /// لون الإشعار
  Color get color {
    switch (type) {
      case NotificationType.newOrder:
        return Colors.blue;
      case NotificationType.lowStock:
        return Colors.orange;
      case NotificationType.outOfStock:
        return Colors.red;
      case NotificationType.newSale:
        return Colors.green;
      case NotificationType.newDebt:
        return Colors.purple;
      case NotificationType.paymentReminder:
        return Colors.amber;
      case NotificationType.aiSuggestion:
        return Colors.teal;
      case NotificationType.systemUpdate:
        return Colors.indigo;
      case NotificationType.general:
        return Colors.grey;
    }
  }
}

// ============================================================================
// NOTIFICATIONS STATE
// ============================================================================

/// حالة الإشعارات
class NotificationsState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// عدد الإشعارات غير المقروءة
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// هل هناك إشعارات غير مقروءة؟
  bool get hasUnread => unreadCount > 0;

  /// الإشعارات غير المقروءة
  List<AppNotification> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  /// الإشعارات العاجلة
  List<AppNotification> get urgentNotifications => notifications
      .where((n) =>
          !n.isRead && n.priority == NotificationPriority.urgent)
      .toList();
}

// ============================================================================
// NOTIFICATIONS NOTIFIER
// ============================================================================

/// مُدير الإشعارات
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(const NotificationsState(isLoading: true)) {
    _loadNotifications();
  }

  static const String _storageKey = 'app_notifications';
  static const int _maxNotifications = 100;

  /// تحميل الإشعارات المحفوظة
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final notifications = jsonList
            .map((json) => AppNotification.fromJson(json))
            .toList();

        // ترتيب حسب التاريخ (الأحدث أولاً)
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        state = state.copyWith(
          notifications: notifications,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// حفظ الإشعارات
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      // تجاهل أخطاء الحفظ
    }
  }

  /// إضافة إشعار جديد
  Future<void> addNotification(AppNotification notification) async {
    final notifications = [notification, ...state.notifications];

    // الاحتفاظ بآخر 100 إشعار فقط
    if (notifications.length > _maxNotifications) {
      notifications.removeRange(_maxNotifications, notifications.length);
    }

    state = state.copyWith(notifications: notifications);
    await _saveNotifications();
  }

  /// إضافة إشعار سريع
  Future<void> notify({
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
    String? actionRoute,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      priority: priority,
      createdAt: DateTime.now(),
      data: data,
      actionRoute: actionRoute,
    );
    await addNotification(notification);
  }

  /// تعيين كمقروء
  Future<void> markAsRead(String notificationId) async {
    final index = state.notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notifications = [...state.notifications];
      notifications[index] = notifications[index].copyWith(isRead: true);
      state = state.copyWith(notifications: notifications);
      await _saveNotifications();
    }
  }

  /// تعيين الكل كمقروء
  Future<void> markAllAsRead() async {
    final notifications = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: notifications);
    await _saveNotifications();
  }

  /// حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    final notifications =
        state.notifications.where((n) => n.id != notificationId).toList();
    state = state.copyWith(notifications: notifications);
    await _saveNotifications();
  }

  /// حذف كل الإشعارات
  Future<void> clearAll() async {
    state = state.copyWith(notifications: []);
    await _saveNotifications();
  }

  /// حذف الإشعارات المقروءة
  Future<void> clearRead() async {
    final notifications =
        state.notifications.where((n) => !n.isRead).toList();
    state = state.copyWith(notifications: notifications);
    await _saveNotifications();
  }

  // ==========================================================================
  // إشعارات مخصصة
  // ==========================================================================

  /// إشعار طلب جديد
  Future<void> notifyNewOrder({
    required String orderNumber,
    required double total,
    String? customerName,
  }) async {
    await notify(
      title: '🛒 طلب جديد',
      message: customerName != null
          ? 'طلب جديد #$orderNumber من $customerName بقيمة ${total.toStringAsFixed(2)} ر.س'
          : 'طلب جديد #$orderNumber بقيمة ${total.toStringAsFixed(2)} ر.س',
      type: NotificationType.newOrder,
      priority: NotificationPriority.high,
      data: {'orderNumber': orderNumber, 'total': total},
      actionRoute: '/orders/$orderNumber',
    );
  }

  /// إشعار مخزون منخفض
  Future<void> notifyLowStock({
    required String productName,
    required int currentStock,
    required int minStock,
  }) async {
    await notify(
      title: '⚠️ مخزون منخفض',
      message: '$productName - الكمية المتبقية: $currentStock (الحد الأدنى: $minStock)',
      type: NotificationType.lowStock,
      priority: NotificationPriority.high,
      data: {'productName': productName, 'currentStock': currentStock},
      actionRoute: '/inventory',
    );
  }

  /// إشعار نفاد المخزون
  Future<void> notifyOutOfStock({
    required String productName,
  }) async {
    await notify(
      title: '🚨 نفاد المخزون',
      message: '$productName - نفد من المخزون!',
      type: NotificationType.outOfStock,
      priority: NotificationPriority.urgent,
      data: {'productName': productName},
      actionRoute: '/inventory',
    );
  }

  /// إشعار بيع جديد
  Future<void> notifyNewSale({
    required String invoiceNumber,
    required double total,
  }) async {
    await notify(
      title: '✅ بيع جديد',
      message: 'فاتورة #$invoiceNumber - ${total.toStringAsFixed(2)} ر.س',
      type: NotificationType.newSale,
      data: {'invoiceNumber': invoiceNumber, 'total': total},
    );
  }

  /// إشعار اقتراح AI
  Future<void> notifyAiSuggestion({
    required String title,
    required String suggestion,
    Map<String, dynamic>? data,
  }) async {
    await notify(
      title: '🤖 $title',
      message: suggestion,
      type: NotificationType.aiSuggestion,
      priority: NotificationPriority.normal,
      data: data,
    );
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود الإشعارات
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});

/// مزود عدد الإشعارات غير المقروءة
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});

/// مزود هل هناك إشعارات غير مقروءة
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(notificationsProvider).hasUnread;
});
