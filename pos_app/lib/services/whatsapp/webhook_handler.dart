/// معالج أحداث Webhook من WaSenderAPI
///
/// يعالج إشعارات التسليم وتحديثات حالة الرسائل والرسائل الواردة
/// من WaSenderAPI عبر Webhook.
///
/// الأحداث المدعومة:
/// - message.sent: تأكيد إرسال الرسالة
/// - message-update: تحديث حالة الرسالة (delivered/read)
/// - messages.received: رسالة واردة من عميل
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pos_app/core/monitoring/production_logger.dart';
import 'package:pos_app/data/local/daos/whatsapp_messages_dao.dart';
import 'package:pos_app/services/whatsapp/models/wasender_models.dart';

/// معالج أحداث Webhook من WaSenderAPI
class WhatsAppWebhookHandler {
  final WhatsAppMessagesDao _messagesDao;

  WhatsAppWebhookHandler(this._messagesDao);

  // ═══════════════════════════════════════════════════════
  // التحقق من التوقيع
  // ═══════════════════════════════════════════════════════

  /// التحقق من توقيع Webhook باستخدام HMAC-SHA256
  ///
  /// يتحقق من صحة التوقيع عبر حساب HMAC-SHA256 لجسم الطلب
  /// ومقارنته مع التوقيع المُرسل في الـ header باستخدام
  /// مقارنة ثابتة الوقت لمنع timing attacks.
  ///
  /// [payload] جسم الطلب الخام كـ String
  /// [signature] التوقيع المُرسل في X-Webhook-Signature header
  /// [secret] المفتاح السري للتوقيع
  ///
  /// يُرجع true إذا كان التوقيع صحيحاً
  static bool verifySignature(
    String payload,
    String signature,
    String secret,
  ) {
    if (payload.isEmpty || signature.isEmpty || secret.isEmpty) return false;

    final key = utf8.encode(secret);
    final bytes = utf8.encode(payload);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    final computed = digest.toString();

    // مقارنة آمنة ضد timing attacks
    return _constantTimeEquals(computed, signature);
  }

  /// التحقق من أن timestamp الحدث ضمن النطاق المقبول
  ///
  /// يمنع replay attacks بالتأكد من أن الحدث أُرسل خلال
  /// [tolerance] من الوقت الحالي (افتراضي: 5 دقائق).
  ///
  /// [eventTimestamp] وقت الحدث كـ Unix timestamp (ثواني) أو ISO 8601
  /// [tolerance] الحد الأقصى للفرق الزمني المقبول
  ///
  /// يُرجع true إذا كان الوقت ضمن النطاق المقبول
  static bool verifyTimestamp(
    dynamic eventTimestamp, {
    Duration tolerance = const Duration(minutes: 5),
  }) {
    if (eventTimestamp == null) return false;

    DateTime eventTime;
    if (eventTimestamp is int) {
      eventTime = DateTime.fromMillisecondsSinceEpoch(eventTimestamp * 1000);
    } else if (eventTimestamp is String) {
      final parsed = DateTime.tryParse(eventTimestamp);
      if (parsed == null) return false;
      eventTime = parsed;
    } else {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(eventTime).abs();
    return difference <= tolerance;
  }

  /// مقارنة آمنة ثابتة الوقت لمنع timing attacks
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // ═══════════════════════════════════════════════════════
  // معالجة الأحداث
  // ═══════════════════════════════════════════════════════

  /// معالجة حدث Webhook وارد
  ///
  /// يُحلل البيانات ويوجّهها للمعالج المناسب بناءً على نوع الحدث.
  /// يتحقق من timestamp الحدث لمنع replay attacks.
  ///
  /// [eventData] بيانات الحدث كـ Map
  Future<void> processEvent(Map<String, dynamic> eventData) async {
    // التحقق من timestamp لمنع replay attacks
    final timestamp = eventData['timestamp'] ?? eventData['t'];
    if (timestamp != null && !verifyTimestamp(timestamp)) {
      AppLogger.warning(
        'Webhook event rejected: timestamp out of range',
        tag: 'Webhook',
      );
      return;
    }

    final event = WaSenderWebhookEvent.fromJson(eventData);

    AppLogger.info(
      'WaSender webhook received: ${event.event}',
      tag: 'Webhook',
    );

    if (event.isMessageSent) {
      await _handleMessageSent(event.data);
    } else if (event.isMessageUpdate) {
      await _handleMessageUpdate(event.data);
    } else if (event.isMessageReceived) {
      await _handleIncomingMessage(event.data);
    } else if (event.isMessageUpsert) {
      // messages.upsert يمكن أن يحتوي على رسائل صادرة أو واردة
      await _handleMessageUpsert(event.data);
    } else {
      AppLogger.debug(
        'Unhandled webhook event type: ${event.event}',
        tag: 'Webhook',
      );
    }
  }

  // ═══════════════════════════════════════════════════════
  // تأكيد الإرسال
  // ═══════════════════════════════════════════════════════

  /// معالجة تأكيد إرسال الرسالة (message.sent)
  ///
  /// يبحث عن الرسالة في قاعدة البيانات المحلية ويحدّث حالتها إلى 'sent'.
  ///
  /// هيكل البيانات المتوقع من WaSenderAPI:
  /// ```json
  /// {
  ///   "key": { "id": "msg_external_id" },
  ///   "status": 1,
  ///   "message": { "extendedTextMessage": { "text": "..." } }
  /// }
  /// ```
  Future<void> _handleMessageSent(Map<String, dynamic> data) async {
    try {
      final externalMsgId = _extractMessageId(data);
      if (externalMsgId == null || externalMsgId.isEmpty) {
        AppLogger.warning(
          'message.sent webhook missing message ID',
          tag: 'Webhook',
        );
        return;
      }

      AppLogger.debug(
        'Processing message.sent for ID: $externalMsgId',
        tag: 'Webhook',
      );

      // البحث عن الرسالة بالمعرف الخارجي
      var localMessage = await _messagesDao.findByExternalMsgId(externalMsgId);

      if (localMessage == null) {
        // محاولة البحث برقم الهاتف والحالة 'sending' إذا لم يُعثر عليها
        AppLogger.debug(
          'Message not found by externalMsgId: $externalMsgId, '
          'may have been set during send',
          tag: 'Webhook',
        );
        return;
      }

      // تحديث الحالة إلى 'sent' فقط إذا كانت 'sending'
      if (localMessage.status == 'sending') {
        await _messagesDao.markAsSent(localMessage.id, externalMsgId);
        AppLogger.info(
          'Message ${localMessage.id} marked as sent '
          '(external: $externalMsgId)',
          tag: 'Webhook',
        );
      } else {
        AppLogger.debug(
          'Message ${localMessage.id} already in status: '
          '${localMessage.status}, skipping sent update',
          tag: 'Webhook',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error handling message.sent webhook: $e',
        tag: 'Webhook',
        error: e,
      );
      ProductionLogger.exception(e, stackTrace: stackTrace, tag: 'Webhook');
    }
  }

  // ═══════════════════════════════════════════════════════
  // تحديث حالة التسليم / القراءة
  // ═══════════════════════════════════════════════════════

  /// معالجة تحديث حالة الرسالة (message-update)
  ///
  /// يتعامل مع تحديثات التسليم والقراءة:
  /// - delivery_ack / 3: تم التوصيل
  /// - read / 4: تمت القراءة
  /// - played / 5: تم تشغيل الوسائط
  ///
  /// هيكل البيانات المتوقع:
  /// ```json
  /// {
  ///   "key": { "id": "msg_external_id" },
  ///   "update": { "status": 3 }
  /// }
  /// ```
  Future<void> _handleMessageUpdate(Map<String, dynamic> data) async {
    try {
      final externalMsgId = _extractMessageId(data);
      if (externalMsgId == null || externalMsgId.isEmpty) {
        AppLogger.warning(
          'message-update webhook missing message ID',
          tag: 'Webhook',
        );
        return;
      }

      final newStatus = _extractUpdateStatus(data);

      AppLogger.debug(
        'Processing message-update for ID: $externalMsgId, '
        'status: $newStatus',
        tag: 'Webhook',
      );

      // البحث عن الرسالة في قاعدة البيانات المحلية
      final localMessage =
          await _messagesDao.findByExternalMsgId(externalMsgId);

      if (localMessage == null) {
        AppLogger.debug(
          'Message not found for update: $externalMsgId',
          tag: 'Webhook',
        );
        return;
      }

      // تطبيق التحديث المناسب
      switch (newStatus) {
        case 'delivery_ack' || 'delivered':
          await _messagesDao.markAsDelivered(localMessage.id);
          AppLogger.info(
            'Message ${localMessage.id} marked as delivered',
            tag: 'Webhook',
          );

        case 'read':
          await _messagesDao.markAsRead(localMessage.id);
          AppLogger.info(
            'Message ${localMessage.id} marked as read',
            tag: 'Webhook',
          );

        case 'played':
          // تشغيل الوسائط يُعامل كقراءة
          await _messagesDao.markAsRead(localMessage.id);
          AppLogger.info(
            'Message ${localMessage.id} marked as read (media played)',
            tag: 'Webhook',
          );

        case 'failed' || 'error':
          final errorMsg =
              data['error'] as String? ?? 'Failed via webhook update';
          await _messagesDao.markAsFailed(localMessage.id, errorMsg);
          AppLogger.warning(
            'Message ${localMessage.id} failed: $errorMsg',
            tag: 'Webhook',
          );

        default:
          AppLogger.debug(
            'Unhandled message update status: $newStatus '
            'for message: ${localMessage.id}',
            tag: 'Webhook',
          );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error handling message-update webhook: $e',
        tag: 'Webhook',
        error: e,
      );
      ProductionLogger.exception(e, stackTrace: stackTrace, tag: 'Webhook');
    }
  }

  // ═══════════════════════════════════════════════════════
  // الرسائل الواردة
  // ═══════════════════════════════════════════════════════

  /// معالجة رسالة واردة من عميل (messages.received)
  ///
  /// حالياً يتم تسجيل الرسالة فقط.
  /// مستقبلاً: يمكن تشغيل إشعار أو رد تلقائي.
  ///
  /// هيكل البيانات المتوقع:
  /// ```json
  /// {
  ///   "cleanedSenderPn": "966501234567",
  ///   "cleanedParticipantPn": "966501234567",
  ///   "messageBody": "نص الرسالة",
  ///   "key": { "id": "msg_id", "fromMe": false }
  /// }
  /// ```
  Future<void> _handleIncomingMessage(Map<String, dynamic> data) async {
    try {
      // استخراج رقم المرسل
      final senderPhone = (data['cleanedSenderPn'] as String?) ??
          (data['cleanedParticipantPn'] as String?) ??
          _extractPhoneFromKey(data);

      // استخراج محتوى الرسالة
      final messageBody = (data['messageBody'] as String?) ??
          (data['body'] as String?) ??
          _extractTextFromMessage(data);

      // استخراج معرف الرسالة
      final msgId = _extractMessageId(data);

      AppLogger.info(
        'Incoming WhatsApp message from: '
        '${_maskPhone(senderPhone ?? 'unknown')}',
        tag: 'Webhook',
      );

      if (messageBody != null && messageBody.isNotEmpty) {
        AppLogger.debug(
          'Message content length: ${messageBody.length} chars '
          '(ID: ${msgId ?? 'unknown'})',
          tag: 'Webhook',
        );
      }

      // TODO: مستقبلاً - إرسال إشعار للمستخدم
      // TODO: مستقبلاً - الرد التلقائي على الرسائل
      // TODO: مستقبلاً - حفظ الرسائل الواردة في جدول منفصل
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error handling incoming message webhook: $e',
        tag: 'Webhook',
        error: e,
      );
      ProductionLogger.exception(e, stackTrace: stackTrace, tag: 'Webhook');
    }
  }

  // ═══════════════════════════════════════════════════════
  // messages.upsert (حدث عام للرسائل)
  // ═══════════════════════════════════════════════════════

  /// معالجة حدث messages.upsert
  ///
  /// هذا الحدث يشمل كلا الرسائل الصادرة والواردة.
  /// نتحقق من fromMe لتوجيه المعالجة.
  Future<void> _handleMessageUpsert(Map<String, dynamic> data) async {
    try {
      final key = data['key'] as Map<String, dynamic>?;
      final fromMe = key?['fromMe'] as bool? ?? false;

      if (fromMe) {
        // رسالة صادرة - نعاملها كتأكيد إرسال
        await _handleMessageSent(data);
      } else {
        // رسالة واردة
        await _handleIncomingMessage(data);
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error handling messages.upsert webhook: $e',
        tag: 'Webhook',
        error: e,
      );
      ProductionLogger.exception(e, stackTrace: stackTrace, tag: 'Webhook');
    }
  }

  // ═══════════════════════════════════════════════════════
  // أدوات مساعدة لاستخراج البيانات
  // ═══════════════════════════════════════════════════════

  /// استخراج معرف الرسالة من بيانات الحدث
  ///
  /// يبحث في المواقع المحتملة:
  /// - data.key.id (الأكثر شيوعاً)
  /// - data.msgId
  /// - data.id
  String? _extractMessageId(Map<String, dynamic> data) {
    // الموقع الرئيسي: key.id
    final key = data['key'] as Map<String, dynamic>?;
    if (key != null) {
      final keyId = key['id']?.toString();
      if (keyId != null && keyId.isNotEmpty) return keyId;
    }

    // مواقع بديلة
    final msgId = data['msgId']?.toString();
    if (msgId != null && msgId.isNotEmpty) return msgId;

    final id = data['id']?.toString();
    if (id != null && id.isNotEmpty) return id;

    return null;
  }

  /// استخراج حالة التحديث من بيانات message-update
  ///
  /// يدعم الصيغ المختلفة:
  /// - رقمية: 2=sent, 3=delivered, 4=read, 5=played
  /// - نصية: 'delivery_ack', 'read', 'played'
  String _extractUpdateStatus(Map<String, dynamic> data) {
    // صيغة update.status (الأكثر شيوعاً)
    final update = data['update'] as Map<String, dynamic>?;
    if (update != null) {
      final statusValue = update['status'];
      if (statusValue is int) {
        return _mapNumericStatus(statusValue);
      }
      if (statusValue is String) {
        return statusValue;
      }
    }

    // صيغة status مباشرة
    final directStatus = data['status'];
    if (directStatus is int) {
      return _mapNumericStatus(directStatus);
    }
    if (directStatus is String) {
      return directStatus;
    }

    return 'unknown';
  }

  /// تحويل حالة رقمية لنصية
  ///
  /// حسب توثيق WhatsApp Web API:
  /// - 0: ERROR
  /// - 1: PENDING
  /// - 2: SERVER_ACK (sent)
  /// - 3: DELIVERY_ACK (delivered)
  /// - 4: READ
  /// - 5: PLAYED
  String _mapNumericStatus(int status) {
    return switch (status) {
      0 => 'error',
      1 => 'pending',
      2 => 'sent',
      3 => 'delivery_ack',
      4 => 'read',
      5 => 'played',
      _ => 'unknown',
    };
  }

  /// استخراج رقم الهاتف من key.remoteJid
  String? _extractPhoneFromKey(Map<String, dynamic> data) {
    final key = data['key'] as Map<String, dynamic>?;
    final remoteJid = key?['remoteJid'] as String?;
    if (remoteJid == null) return null;

    // remoteJid بصيغة: 966501234567@s.whatsapp.net
    final atIndex = remoteJid.indexOf('@');
    if (atIndex > 0) {
      return remoteJid.substring(0, atIndex);
    }
    return remoteJid;
  }

  /// استخراج نص الرسالة من بيانات الحدث
  String? _extractTextFromMessage(Map<String, dynamic> data) {
    // محاولة استخراج من message.conversation
    final message = data['message'] as Map<String, dynamic>?;
    if (message != null) {
      final conversation = message['conversation'] as String?;
      if (conversation != null) return conversation;

      // extendedTextMessage.text
      final extended = message['extendedTextMessage'] as Map<String, dynamic>?;
      if (extended != null) {
        return extended['text'] as String?;
      }
    }

    return null;
  }

  /// إخفاء رقم الهاتف للتسجيل (حماية الخصوصية)
  ///
  /// يعرض أول 4 أرقام والأخيرين فقط.
  /// مثال: 966501234567 -> 9665****67
  String _maskPhone(String phone) {
    if (phone.length <= 6) return '****';
    return '${phone.substring(0, 4)}****${phone.substring(phone.length - 2)}';
  }
}
