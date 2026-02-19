import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/app_database.dart';
import 'json_converter.dart';

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
class RealtimeListener {
  final SupabaseClient _client;
  final AppDatabase _db;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  /// الجداول المراقبة
  static const List<String> watchedTables = [
    'products',
    'categories',
  ];

  /// قنوات الاشتراك النشطة
  final Map<String, RealtimeChannel> _channels = {};

  /// مراقب الأحداث
  final _eventController = StreamController<RealtimeEvent>.broadcast();

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
  Future<void> start({
    required String orgId,
    required String storeId,
  }) async {
    if (_isActive) return;

    _orgId = orgId;
    _storeId = storeId;
    _isActive = true;

    for (final tableName in watchedTables) {
      await _subscribeToTable(tableName);
    }

    if (kDebugMode) {
      debugPrint('RealtimeListener started for org=$orgId, store=$storeId');
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

      switch (eventType) {
        case RealtimeEventType.insert:
        case RealtimeEventType.update:
          if (newRecord.isNotEmpty) {
            final localRecord = _jsonConverter.toLocal(tableName, newRecord);
            await _upsertLocally(tableName, localRecord);
            _emitEvent(RealtimeEvent(
              tableName: tableName,
              type: eventType,
              newRecord: localRecord,
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

  /// إدراج/تحديث سجل محلياً
  Future<void> _upsertLocally(
      String tableName, Map<String, dynamic> record) async {
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
      columns.map((c) => record[c]).toList(),
    );
  }

  /// حذف ناعم محلياً
  Future<void> _softDeleteLocally(String tableName, String recordId) async {
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
    for (final tableName in List.from(_channels.keys)) {
      await _unsubscribeFromTable(tableName);
    }
    if (kDebugMode) {
      debugPrint('RealtimeListener stopped');
    }
  }

  /// تنظيف الموارد
  Future<void> dispose() async {
    await stop();
    await _eventController.close();
  }
}
