import 'dart:async';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alhai_database/alhai_database.dart';
import 'json_converter.dart';
import 'sync_payload_utils.dart';
import 'sync_table_validator.dart';

/// أنواع أحداث Realtime
enum RealtimeEventType { insert, update, delete }

/// حدث Realtime
class RealtimeEvent {
  final String tableName;
  final RealtimeEventType type;
  final Map<String, dynamic>? newRecord;
  final Map<String, dynamic>? oldRecord;
  final DateTime timestamp;

  RealtimeEvent({
    required this.tableName,
    required this.type,
    this.newRecord,
    this.oldRecord,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();
}

/// مستمع Supabase Realtime
/// يستقبل التحديثات الفورية من السيرفر ويطبقها محلياً
///
/// الجداول المراقبة:
/// - products: تغييرات الأسعار، منتجات جديدة
/// - categories: تصنيفات جديدة/محدثة
/// - inventory_movements: تحديثات المخزون من أجهزة أخرى
///
/// آلية العمل:
/// 1. الاشتراك في قنوات Supabase Realtime لكل جدول
/// 2. عند INSERT/UPDATE: إدراج/تحديث محلياً فوراً
/// 3. عند DELETE: حذف ناعم محلياً
/// 4. فلترة حسب org_id و store_id
/// 5. إعادة الاتصال تلقائياً عند انقطاع الاتصال
///
/// للجداول ثنائية الاتجاه: يتم التحقق من وجود تغييرات محلية معلقة
/// في sync_queue قبل تطبيق تحديث Realtime لمنع الكتابة فوق بيانات لم تُدفع بعد.
class RealtimeListener {
  final SupabaseClient _client;
  final AppDatabase _db;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  /// الجداول ثنائية الاتجاه (من BidirectionalStrategy.tableConfigs)
  /// هذه الجداول قد تحتوي على تغييرات محلية معلقة يجب عدم الكتابة فوقها
  static const Set<String> _bidirectionalTables = {
    'customers', 'expenses', 'returns', 'return_items',
    'purchases', 'purchase_items', 'shifts', 'suppliers',
    'notifications', 'loyalty_points', 'loyalty_transactions',
    'customer_addresses', 'accounts', 'transactions',
    'product_expiry', 'stock_takes', 'stock_transfers',
    'whatsapp_templates',
  };

  /// الجداول المراقبة بالـ Realtime
  /// ترتيب حسب الأولوية: stock_deltas أولاً (تعدد كاشير)
  static const List<String> watchedTables = [
    'stock_deltas',    // أولوية قصوى: تزامن مخزون بين أجهزة الكاشير
    'orders',          // طلبات أونلاين + تحديث حالة فوري
    'sales',           // مبيعات POS - تحديث لوحة التحكم فوري
    'sale_items',      // عناصر المبيعات - تفاصيل لوحة التحكم
    'products',        // أسعار + حالة + مخزون
    'notifications',   // إشعارات نفاد مخزون + طلبات جديدة
    'categories',      // تصنيفات
    'stock_transfers', // نقل مخزون بين الفروع
    'invoices',        // فواتير رسمية (ZATCA)
    'shifts',
    'inventory_movements',
  ];

  /// معرف الجهاز الحالي (لتجاهل أحداث الجهاز نفسه في stock_deltas)
  String? _deviceId;

  /// قنوات الاشتراك النشطة
  final Map<String, RealtimeChannel> _channels = {};

  /// مراقب الأحداث
  final _eventController = StreamController<RealtimeEvent>.broadcast();

  /// مؤقت تجديد JWT تلقائياً قبل انتهاء صلاحيته (كل 45 دقيقة)
  Timer? _jwtRefreshTimer;

  /// معرفات الفلترة
  String? _orgId;
  String? _storeId;

  /// هل المستمع نشط؟
  bool _isActive = false;

  RealtimeListener({
    required SupabaseClient client,
    required AppDatabase db,
  })  : _client = client,
        _db = db;

  /// Stream لأحداث Realtime
  Stream<RealtimeEvent> get events => _eventController.stream;

  /// هل المستمع نشط؟
  bool get isActive => _isActive;

  /// بدء الاستماع
  /// [deviceId]: معرف الجهاز الحالي لتجاهل stock_deltas الخاصة بنفس الجهاز
  Future<void> start({
    required String orgId,
    required String storeId,
    String? deviceId,
  }) async {
    if (_isActive) return;

    // M149: Validate JWT session before connecting to Realtime
    final session = _client.auth.currentSession;
    if (session == null) {
      if (kDebugMode) {
        debugPrint('RealtimeListener: No active session, cannot start');
      }
      return;
    }

    // If token is expired, try refreshing before proceeding
    if (session.isExpired) {
      if (kDebugMode) {
        debugPrint('RealtimeListener: Session expired, attempting refresh');
      }
      try {
        await _client.auth.refreshSession();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('RealtimeListener: Session refresh failed: $e');
        }
        return;
      }

      // Verify the refresh succeeded
      final refreshed = _client.auth.currentSession;
      if (refreshed == null || refreshed.isExpired) {
        if (kDebugMode) {
          debugPrint('RealtimeListener: Session still invalid after refresh');
        }
        return;
      }
    }

    _orgId = orgId;
    _storeId = storeId;
    _deviceId = deviceId;
    _isActive = true;

    for (final tableName in watchedTables) {
      await _subscribeToTable(tableName);
    }

    // Start periodic JWT refresh to prevent silent disconnects after ~1 hour
    _startJwtRefreshTimer();

    if (kDebugMode) {
      debugPrint('RealtimeListener started for org=$orgId, store=$storeId');
    }
  }

  /// بدء مؤقت تجديد JWT الدوري
  ///
  /// JWT ينتهي بعد ~1 ساعة. نجدده كل 45 دقيقة لتجنب انقطاع Realtime الصامت.
  void _startJwtRefreshTimer() {
    _jwtRefreshTimer?.cancel();
    _jwtRefreshTimer = Timer.periodic(
      const Duration(minutes: 45), // Refresh before 1-hour expiry
      (_) async {
        try {
          await _client.auth.refreshSession();
          // Reconnect realtime channels with the new token
          await _reconnectChannels();
          if (kDebugMode) {
            debugPrint('[Realtime] JWT refreshed and channels reconnected');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[Realtime] JWT refresh failed: $e');
          }
        }
      },
    );
  }

  /// إعادة الاتصال بجميع القنوات بعد تجديد JWT
  Future<void> _reconnectChannels() async {
    if (!_isActive) return;
    final tableNames = List<String>.from(_channels.keys);
    for (final tableName in tableNames) {
      try {
        await _subscribeToTable(tableName);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[Realtime] Failed to reconnect channel $tableName: $e');
        }
      }
    }
  }

  /// الاشتراك في جدول معين
  Future<void> _subscribeToTable(String tableName) async {
    // إلغاء الاشتراك السابق إن وجد
    await _unsubscribeFromTable(tableName);

    final channelName = 'sync_$tableName';

    final channel = _client.channel(channelName);

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: tableName,
          filter: _orgId != null
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'store_id',
                  value: _storeId!,
                )
              : null,
          callback: (payload) {
            _handleChange(tableName, payload);
          },
        )
        .subscribe((status, [error]) {
      if (kDebugMode) {
        debugPrint(
            'Realtime $tableName: $status${error != null ? ' ($error)' : ''}');
      }
    });

    _channels[tableName] = channel;
  }

  /// معالجة تغيير من Realtime
  Future<void> _handleChange(
      String tableName, PostgresChangePayload payload) async {
    try {
      final eventType = _mapEventType(payload.eventType);
      if (eventType == null) return;

      // فلترة حسب org_id
      final newRecord = payload.newRecord;
      if (newRecord.isNotEmpty && _orgId != null) {
        final recordOrgId = newRecord['org_id'] as String?;
        if (recordOrgId != null && recordOrgId != _orgId) return;
      }

      // تجاهل stock_deltas من نفس الجهاز (لتجنب التكرار)
      if (tableName == 'stock_deltas' && _deviceId != null && newRecord.isNotEmpty) {
        final deltaDeviceId = newRecord['device_id'] as String?;
        if (deltaDeviceId == _deviceId) return;
      }

      switch (eventType) {
        case RealtimeEventType.insert:
        case RealtimeEventType.update:
          if (newRecord.isNotEmpty) {
            final localRecord = _jsonConverter.toLocal(tableName, newRecord);
            // M36: إعادة تسمية أعمدة Supabase لتتوافق مع مخطط Drift المحلي
            final mappedRecord = mapColumnsToLocal(tableName, localRecord);
            await _upsertLocally(tableName, mappedRecord);
            _emitEvent(RealtimeEvent(
              tableName: tableName,
              type: eventType,
              newRecord: mappedRecord,
            ));
          }
          break;

        case RealtimeEventType.delete:
          final oldRecord = payload.oldRecord;
          if (oldRecord.isNotEmpty) {
            final recordId = oldRecord['id'] as String?;
            if (recordId != null) {
              await _softDeleteLocally(tableName, recordId);
              _emitEvent(RealtimeEvent(
                tableName: tableName,
                type: eventType,
                oldRecord: oldRecord,
              ));
            }
          }
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RealtimeListener error handling $tableName change: $e');
      }
    }
  }

  /// أعمدة التواريخ التي تحتاج تحويل من ISO 8601 إلى Unix seconds
  static const Set<String> _dateTimeColumns = {
    'created_at', 'updated_at', 'synced_at', 'deleted_at',
    'opened_at', 'closed_at', 'issued_at', 'due_at', 'paid_at',
    'expires_at', 'start_date', 'end_date', 'last_login',
    'completed_at', 'confirmed_at', 'cancelled_at', 'delivered_at',
    'shipped_at', 'refunded_at', 'voided_at', 'activated_at',
    'deactivated_at', 'last_sync_at', 'last_pull_at', 'last_push_at',
    // Additional datetime columns from database tables
    'order_date', 'preparing_at', 'ready_at', 'delivering_at',
    'received_at', 'approved_at', 'started_at', 'expiry_date',
    'expense_date', 'read_at', 'sent_at', 'last_attempt_at',
    'last_transaction_at', 'trial_ends_at', 'last_heartbeat_at',
    'current_period_start', 'current_period_end',
    'invited_at', 'joined_at', 'last_login_at',
  };

  /// تحويل القيمة حسب نوع العمود
  dynamic _convertValue(String column, dynamic value) {
    if (value == null) return null;
    if (!_dateTimeColumns.contains(column)) return value;
    if (value is int) return value;
    if (value is String) {
      try {
        return DateTime.parse(value).millisecondsSinceEpoch ~/ 1000;
      } catch (_) {
        return null;
      }
    }
    return value;
  }

  /// إدراج/تحديث سجل محلياً
  ///
  /// للجداول ثنائية الاتجاه: يتحقق أولاً من وجود تغييرات محلية معلقة
  /// في sync_queue. إذا وُجدت، يتجاهل تحديث Realtime لحماية البيانات المحلية.
  Future<void> _upsertLocally(
      String tableName, Map<String, dynamic> record) async {
    validateTableName(tableName);

    // للجداول ثنائية الاتجاه: تحقق من وجود تغييرات محلية معلقة
    if (_bidirectionalTables.contains(tableName)) {
      final recordId = record['id'] as String?;
      if (recordId != null) {
        final pending = await _db.customSelect(
          "SELECT COUNT(*) as cnt FROM sync_queue "
          "WHERE table_name = ? AND record_id = ? "
          "AND status IN ('pending', 'syncing')",
          variables: [
            Variable.withString(tableName),
            Variable.withString(recordId),
          ],
        ).getSingle();
        final count = pending.data['cnt'] as int? ?? 0;
        if (count > 0) {
          if (kDebugMode) {
            debugPrint(
                '[Realtime] Skipping upsert for $tableName/$recordId - pending local changes');
          }
          return;
        }
      }
    }

    final columns = record.keys.toList();
    final placeholders = columns.map((_) => '?').join(', ');
    final updates = columns
        .where((c) => c != 'id')
        .map((c) => '$c = excluded.$c')
        .join(', ');

    await _db.customStatement(
      'INSERT INTO $tableName (${columns.join(', ')}) '
      'VALUES ($placeholders) '
      'ON CONFLICT(id) DO UPDATE SET $updates',
      columns.map((c) => _convertValue(c, record[c])).toList(),
    );
  }

  /// حذف ناعم محلياً
  Future<void> _softDeleteLocally(String tableName, String recordId) async {
    validateTableName(tableName);
    // نحذف السجل محلياً (الحذف الناعم يكون على السيرفر)
    await _db.customStatement(
      'DELETE FROM $tableName WHERE id = ?',
      [recordId],
    );
  }

  /// تحويل نوع الحدث
  RealtimeEventType? _mapEventType(PostgresChangeEvent event) {
    switch (event) {
      case PostgresChangeEvent.insert:
        return RealtimeEventType.insert;
      case PostgresChangeEvent.update:
        return RealtimeEventType.update;
      case PostgresChangeEvent.delete:
        return RealtimeEventType.delete;
      default:
        return null;
    }
  }

  /// إرسال حدث
  void _emitEvent(RealtimeEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  /// إلغاء الاشتراك من جدول
  Future<void> _unsubscribeFromTable(String tableName) async {
    final channel = _channels.remove(tableName);
    if (channel != null) {
      await _client.removeChannel(channel);
    }
  }

  /// إيقاف جميع الاشتراكات
  Future<void> stop() async {
    _isActive = false;
    _jwtRefreshTimer?.cancel();
    _jwtRefreshTimer = null;
    for (final tableName in List.from(_channels.keys)) {
      await _unsubscribeFromTable(tableName);
    }
    if (kDebugMode) {
      debugPrint('RealtimeListener stopped');
    }
  }

  /// تنظيف الموارد
  Future<void> dispose() async {
    _jwtRefreshTimer?.cancel();
    _jwtRefreshTimer = null;
    await stop();
    await _eventController.close();
  }
}
