/// مستمع أحداث Webhook لواتساب عبر Supabase Realtime
///
/// يستمع للأحداث الواردة من الـ backend (Supabase Edge Function)
/// التي تستقبل Webhooks من WaSenderAPI وتعيد توجيهها عبر Realtime.
///
/// المعمارية:
/// ```
/// WaSenderAPI -> Webhook URL (Supabase Edge Function)
///            -> يحفظ في جدول whatsapp_webhook_events
///            -> Supabase Realtime يبث الحدث
///            -> WhatsAppWebhookListener يستقبل ويعالج
/// ```
///
/// ملاحظة: هذا الملف مُعد للتكامل مع Supabase Realtime.
/// حالياً يوفر واجهة يمكن استخدامها يدوياً أو ربطها لاحقاً.
library;

import 'dart:async';

import 'package:pos_app/core/monitoring/production_logger.dart';
import 'package:pos_app/services/whatsapp/webhook_handler.dart';

/// مستمع أحداث Webhook لواتساب
///
/// يوفر آلية للاستماع المستمر لأحداث Webhook
/// عبر Supabase Realtime أو أي مصدر أحداث آخر.
///
/// الاستخدام:
/// ```dart
/// final handler = WhatsAppWebhookHandler(messagesDao);
/// final listener = WhatsAppWebhookListener(handler);
///
/// // بدء الاستماع
/// listener.start();
///
/// // معالجة حدث يدوياً (للاختبار أو من مصدر آخر)
/// await listener.processEvent({'event': 'message.sent', 'data': {...}});
///
/// // إيقاف الاستماع
/// listener.stop();
/// ```
class WhatsAppWebhookListener {
  final WhatsAppWebhookHandler _handler;
  StreamSubscription<dynamic>? _subscription;
  bool _isListening = false;

  /// عدد الأحداث المعالجة منذ بدء الاستماع
  int _processedCount = 0;

  /// عدد الأخطاء منذ بدء الاستماع
  int _errorCount = 0;

  /// وقت بدء الاستماع
  DateTime? _startedAt;

  WhatsAppWebhookListener(this._handler);

  /// هل المستمع يعمل حالياً؟
  bool get isListening => _isListening;

  /// عدد الأحداث المعالجة
  int get processedCount => _processedCount;

  /// عدد الأخطاء
  int get errorCount => _errorCount;

  /// وقت بدء الاستماع
  DateTime? get startedAt => _startedAt;

  /// مدة الاستماع
  Duration? get uptime =>
      _startedAt != null ? DateTime.now().difference(_startedAt!) : null;

  // ═══════════════════════════════════════════════════════
  // بدء وإيقاف الاستماع
  // ═══════════════════════════════════════════════════════

  /// بدء الاستماع لأحداث Webhook
  ///
  /// في الإنتاج، يتصل بـ Supabase Realtime channel 'whatsapp_webhook_events'.
  /// حالياً يُفعّل حالة الاستماع فقط ويمكن معالجة الأحداث يدوياً
  /// عبر [processEvent].
  void start() {
    if (_isListening) {
      AppLogger.debug(
        'WhatsApp webhook listener already running',
        tag: 'Webhook',
      );
      return;
    }

    _isListening = true;
    _startedAt = DateTime.now();
    _processedCount = 0;
    _errorCount = 0;

    AppLogger.info(
      'WhatsApp webhook listener started',
      tag: 'Webhook',
    );

    // TODO: التكامل مع Supabase Realtime عند جهوزية الـ backend
    //
    // المطلوب: إضافة supabase_flutter للـ pubspec.yaml ثم:
    //
    // final channel = supabase.channel('whatsapp_webhook_events');
    // channel.onPostgresChanges(
    //   event: PostgresChangeEvent.insert,
    //   schema: 'public',
    //   table: 'whatsapp_webhook_events',
    //   callback: (payload) {
    //     final record = payload.newRecord;
    //     if (record != null) {
    //       _onRealtimeEvent(record);
    //     }
    //   },
    // ).subscribe((status, [error]) {
    //   if (status == RealtimeSubscribeStatus.subscribed) {
    //     AppLogger.info(
    //       'Subscribed to whatsapp_webhook_events channel',
    //       tag: 'Webhook',
    //     );
    //   } else if (status == RealtimeSubscribeStatus.channelError) {
    //     AppLogger.error(
    //       'Realtime channel error: $error',
    //       tag: 'Webhook',
    //     );
    //   }
    // });
  }

  /// بدء الاستماع من Stream خارجي
  ///
  /// يسمح بربط المستمع بأي مصدر أحداث (Stream).
  /// مفيد للاختبارات أو لمصادر أحداث مخصصة.
  ///
  /// [eventStream] مصدر الأحداث
  void startFromStream(Stream<Map<String, dynamic>> eventStream) {
    if (_isListening) {
      AppLogger.debug(
        'WhatsApp webhook listener already running',
        tag: 'Webhook',
      );
      return;
    }

    _isListening = true;
    _startedAt = DateTime.now();
    _processedCount = 0;
    _errorCount = 0;

    _subscription = eventStream.listen(
      (eventData) => _onRealtimeEvent(eventData),
      onError: (Object error) {
        _errorCount++;
        AppLogger.error(
          'Webhook event stream error: $error',
          tag: 'Webhook',
        );
      },
      onDone: () {
        AppLogger.info(
          'Webhook event stream completed',
          tag: 'Webhook',
        );
        _isListening = false;
      },
    );

    AppLogger.info(
      'WhatsApp webhook listener started from stream',
      tag: 'Webhook',
    );
  }

  // ═══════════════════════════════════════════════════════
  // معالجة الأحداث
  // ═══════════════════════════════════════════════════════

  /// معالجة حدث Webhook
  ///
  /// يمكن استدعاء هذه الدالة:
  /// - من Supabase Realtime عبر [_onRealtimeEvent]
  /// - يدوياً للاختبار أو من مصدر أحداث آخر
  /// - من Push Notification payload
  ///
  /// [eventData] بيانات الحدث كـ Map
  Future<void> processEvent(Map<String, dynamic> eventData) async {
    try {
      await _handler.processEvent(eventData);
      _processedCount++;
    } catch (e, stackTrace) {
      _errorCount++;
      AppLogger.error(
        'Webhook event processing error: $e',
        tag: 'Webhook',
        error: e,
      );
      ProductionLogger.exception(e, stackTrace: stackTrace, tag: 'Webhook');
    }
  }

  /// معالجة حدث من Supabase Realtime
  ///
  /// يستخرج بيانات الحدث من الـ record ويمررها للمعالج.
  /// الـ record المتوقع يحتوي على:
  /// - event_type: نوع الحدث
  /// - payload: بيانات الحدث (jsonb)
  /// - created_at: وقت الإنشاء
  Future<void> _onRealtimeEvent(Map<String, dynamic> record) async {
    try {
      // استخراج الـ payload من الـ record
      final payload = record['payload'] as Map<String, dynamic>?;
      if (payload != null) {
        await processEvent(payload);
      } else {
        // إذا لم يكن هناك payload منفصل، نعالج الـ record نفسه
        await processEvent(record);
      }
    } catch (e, stackTrace) {
      _errorCount++;
      AppLogger.error(
        'Error processing realtime event: $e',
        tag: 'Webhook',
        error: e,
      );
      ProductionLogger.exception(e, stackTrace: stackTrace, tag: 'Webhook');
    }
  }

  // ═══════════════════════════════════════════════════════
  // إيقاف والتنظيف
  // ═══════════════════════════════════════════════════════

  /// إيقاف الاستماع
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;

    final duration = uptime;
    AppLogger.info(
      'WhatsApp webhook listener stopped '
      '(processed: $_processedCount, errors: $_errorCount, '
      'uptime: ${duration?.inMinutes ?? 0} min)',
      tag: 'Webhook',
    );
  }

  /// تنظيف الموارد
  ///
  /// يُستدعى عند التخلص من المستمع نهائياً.
  void dispose() {
    stop();
  }

  /// الحصول على إحصائيات المستمع
  Map<String, dynamic> getStats() {
    return {
      'isListening': _isListening,
      'processedCount': _processedCount,
      'errorCount': _errorCount,
      'startedAt': _startedAt?.toIso8601String(),
      'uptimeMinutes': uptime?.inMinutes,
    };
  }
}
