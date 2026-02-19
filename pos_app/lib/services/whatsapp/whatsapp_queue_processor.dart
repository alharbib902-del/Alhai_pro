/// WhatsApp Queue Processor
///
/// معالج طابور رسائل واتساب في الخلفية.
/// يقرأ الرسائل المعلّقة من جدول whatsapp_messages ويرسلها عبر WaSenderApiClient.
///
/// يعمل بشكل دوري عبر Timer ويدعم:
/// - رفع الوسائط المحلية قبل الإرسال
/// - إعادة المحاولة مع Exponential Backoff
/// - التحقق من الاتصال قبل المعالجة
/// - التأخير بين الرسائل لتجنب Rate Limiting
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:pos_app/core/config/whatsapp_config.dart';
import 'package:pos_app/core/monitoring/production_logger.dart';
import 'package:pos_app/data/local/daos/whatsapp_messages_dao.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/services/connectivity_service.dart';
import 'package:pos_app/services/whatsapp/models/wasender_models.dart';
import 'package:pos_app/services/whatsapp/wasender_api_client.dart';

/// معالج طابور رسائل واتساب
///
/// يعمل في الخلفية ويفرغ الطابور بشكل دوري.
/// يتعامل مع رفع الوسائط والإرسال وإعادة المحاولة عند الفشل.
class WhatsAppQueueProcessor {
  final WaSenderApiClient _apiClient;
  final WhatsAppMessagesDao _messagesDao;
  final ConnectivityService _connectivity;

  Timer? _processingTimer;
  Timer? _cleanupTimer;
  bool _isProcessing = false;

  static const String _tag = 'WhatsAppQueue';

  WhatsAppQueueProcessor({
    required WaSenderApiClient apiClient,
    required WhatsAppMessagesDao messagesDao,
    required ConnectivityService connectivity,
  })  : _apiClient = apiClient,
        _messagesDao = messagesDao,
        _connectivity = connectivity;

  /// هل المعالج يعمل حاليا؟
  bool get isRunning => _processingTimer?.isActive ?? false;

  /// هل يوجد معالجة جارية الآن؟
  bool get isProcessing => _isProcessing;

  // ═══════════════════════════════════════════════════════
  // التشغيل والإيقاف
  // ═══════════════════════════════════════════════════════

  /// بدء المعالجة الدورية
  ///
  /// [interval] الفاصل الزمني بين كل دورة معالجة (افتراضي: 5 ثوان)
  void start({Duration interval = const Duration(seconds: 5)}) {
    if (isRunning) {
      AppLogger.debug('Queue processor already running', tag: _tag);
      return;
    }

    if (!WhatsAppConfig.isConfigured) {
      AppLogger.warning(
        'WhatsApp not configured, queue processor will not start',
        tag: _tag,
      );
      return;
    }

    AppLogger.info(
      'Starting queue processor (interval: ${interval.inSeconds}s)',
      tag: _tag,
    );

    // معالجة فورية عند البدء
    processQueue();

    // جدولة المعالجة الدورية
    _processingTimer = Timer.periodic(interval, (_) => processQueue());

    // تنظيف الرسائل القديمة كل 24 ساعة
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 24),
      (_) => _runRetentionCleanup(),
    );
  }

  /// إيقاف المعالجة الدورية
  void stop() {
    if (!isRunning) return;

    AppLogger.info('Stopping queue processor', tag: _tag);
    _processingTimer?.cancel();
    _processingTimer = null;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  // ═══════════════════════════════════════════════════════
  // معالجة الطابور
  // ═══════════════════════════════════════════════════════

  /// معالجة جميع الرسائل المعلّقة في الطابور
  ///
  /// يتخطى المعالجة إذا:
  /// - لا يوجد اتصال بالإنترنت
  /// - معالجة سابقة لا تزال جارية
  Future<void> processQueue() async {
    // تجنب التشغيل المتزامن
    if (_isProcessing) return;

    // التحقق من الاتصال
    if (_connectivity.isOffline) {
      AppLogger.debug('Offline - skipping queue processing', tag: _tag);
      return;
    }

    _isProcessing = true;

    try {
      final pendingMessages = await _messagesDao.getPendingMessages();

      if (pendingMessages.isEmpty) return;

      AppLogger.info(
        'Processing ${pendingMessages.length} pending messages',
        tag: _tag,
      );

      for (final message in pendingMessages) {
        // التحقق من الاتصال قبل كل رسالة
        if (_connectivity.isOffline) {
          AppLogger.debug(
            'Lost connectivity during processing, stopping',
            tag: _tag,
          );
          break;
        }

        // التحقق من تأخير إعادة المحاولة
        if (message.retryCount > 0 && message.lastAttemptAt != null) {
          final retryDelay = _getRetryDelay(message.retryCount);
          final elapsed =
              DateTime.now().difference(message.lastAttemptAt!);
          if (elapsed < retryDelay) {
            continue; // لم يحن وقت إعادة المحاولة بعد
          }
        }

        await _processMessage(message);

        // تأخير بين الرسائل لتجنب Rate Limiting
        await Future<void>.delayed(
          const Duration(milliseconds: WhatsAppConfig.batchDelayMs),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Queue processing error: $e',
        tag: _tag,
        error: e,
      );
      ProductionLogger.exception(e, stackTrace: stackTrace, tag: _tag);
    } finally {
      _isProcessing = false;
    }
  }

  // ═══════════════════════════════════════════════════════
  // معالجة رسالة واحدة
  // ═══════════════════════════════════════════════════════

  /// معالجة رسالة واحدة: رفع الوسائط (إن وجدت) ثم الإرسال
  Future<void> _processMessage(WhatsAppMessagesTableData message) async {
    try {
      AppLogger.debug(
        'Processing message ${message.id} (type: ${message.messageType}, '
        'retry: ${message.retryCount})',
        tag: _tag,
      );

      // 1. رفع الوسائط إن كان هناك ملف محلي
      String? mediaUrl = message.mediaUrl;
      if (message.mediaLocalPath != null &&
          message.mediaLocalPath!.isNotEmpty &&
          (mediaUrl == null || mediaUrl.isEmpty)) {
        await _messagesDao.markAsUploading(message.id);

        mediaUrl = await _uploadMediaIfNeeded(message);

        if (mediaUrl == null) {
          // فشل الرفع - تم تسجيل الخطأ في _uploadMediaIfNeeded
          return;
        }

        // تحديث رابط الوسائط في قاعدة البيانات
        await _messagesDao.updateMediaUrl(message.id, mediaUrl);
      }

      // 2. تحديث الحالة إلى "جاري الإرسال"
      await _messagesDao.markAsSending(message.id);

      // 3. الإرسال حسب نوع الرسالة
      final response = await _sendByType(message, mediaUrl);

      // 4. معالجة النتيجة
      if (response.success && response.msgId != null) {
        await _messagesDao.markAsSent(message.id, response.msgId!);

        // تنظيف الملف المحلي بعد الإرسال الناجح
        await _cleanupLocalFile(message.mediaLocalPath);

        AppLogger.info(
          'Message ${message.id} sent successfully '
          '(externalId: ${response.msgId})',
          tag: _tag,
        );
      } else {
        final error = response.error ?? 'Unknown send error';
        await _messagesDao.markAsFailed(message.id, error);
        AppLogger.warning(
          'Message ${message.id} failed: $error',
          tag: _tag,
        );
      }
    } catch (e, stackTrace) {
      final errorMsg = e.toString();
      await _messagesDao.markAsFailed(message.id, errorMsg);
      AppLogger.error(
        'Message ${message.id} exception: $errorMsg',
        tag: _tag,
        error: e,
      );
      ProductionLogger.exception(
        e,
        stackTrace: stackTrace,
        tag: _tag,
        context: {'messageId': message.id, 'type': message.messageType},
      );
    }
  }

  /// إرسال الرسالة حسب نوعها عبر الـ API
  Future<WaSenderResponse> _sendByType(
    WhatsAppMessagesTableData message,
    String? mediaUrl,
  ) async {
    final phone = message.phone;
    final text = message.textContent;

    switch (message.messageType) {
      case 'text':
        return _apiClient.sendText(
          to: phone,
          text: text ?? '',
        );

      case 'image':
        if (mediaUrl == null || mediaUrl.isEmpty) {
          return WaSenderResponse.error(
            'Image URL is required for image message',
          );
        }
        return _apiClient.sendImage(
          to: phone,
          imageUrl: mediaUrl,
          caption: text,
        );

      case 'video':
        if (mediaUrl == null || mediaUrl.isEmpty) {
          return WaSenderResponse.error(
            'Video URL is required for video message',
          );
        }
        return _apiClient.sendVideo(
          to: phone,
          videoUrl: mediaUrl,
          caption: text,
        );

      case 'document':
        if (mediaUrl == null || mediaUrl.isEmpty) {
          return WaSenderResponse.error(
            'Document URL is required for document message',
          );
        }
        return _apiClient.sendDocument(
          to: phone,
          documentUrl: mediaUrl,
          fileName: message.fileName ?? 'document',
          caption: text,
        );

      case 'audio':
        if (mediaUrl == null || mediaUrl.isEmpty) {
          return WaSenderResponse.error(
            'Audio URL is required for audio message',
          );
        }
        return _apiClient.sendAudio(
          to: phone,
          audioUrl: mediaUrl,
        );

      case 'location':
        // يتوقع textContent بصيغة "lat,lng" أو "lat,lng|name|address"
        final locationParts = (text ?? '').split('|');
        final coords = locationParts[0].split(',');
        if (coords.length < 2) {
          return WaSenderResponse.error(
            'Invalid location format. Expected: lat,lng',
          );
        }
        final lat = double.tryParse(coords[0].trim());
        final lng = double.tryParse(coords[1].trim());
        if (lat == null || lng == null) {
          return WaSenderResponse.error('Invalid latitude/longitude values');
        }
        return _apiClient.sendLocation(
          to: phone,
          latitude: lat,
          longitude: lng,
          name: locationParts.length > 1 ? locationParts[1] : null,
          address: locationParts.length > 2 ? locationParts[2] : null,
        );

      case 'contact':
        // يتوقع textContent بصيغة "name|phone"
        final contactParts = (text ?? '').split('|');
        if (contactParts.length < 2) {
          return WaSenderResponse.error(
            'Invalid contact format. Expected: name|phone',
          );
        }
        return _apiClient.sendContactCard(
          to: phone,
          name: contactParts[0].trim(),
          phone: contactParts[1].trim(),
        );

      default:
        // نوع غير معروف - نحاول إرسال كنص
        AppLogger.warning(
          'Unknown message type "${message.messageType}", '
          'falling back to text',
          tag: _tag,
        );
        return _apiClient.sendText(
          to: phone,
          text: text ?? '',
        );
    }
  }

  // ═══════════════════════════════════════════════════════
  // رفع الوسائط
  // ═══════════════════════════════════════════════════════

  /// رفع ملف وسائط محلي إلى WaSender والحصول على الرابط العام
  ///
  /// يرجع null إذا فشل الرفع (ويسجّل الخطأ في قاعدة البيانات).
  Future<String?> _uploadMediaIfNeeded(
    WhatsAppMessagesTableData message,
  ) async {
    final localPath = message.mediaLocalPath;
    if (localPath == null || localPath.isEmpty) return message.mediaUrl;

    try {
      final file = File(localPath);

      if (!await file.exists()) {
        final error = 'Local file not found: $localPath';
        await _messagesDao.markAsFailed(message.id, error);
        AppLogger.error(error, tag: _tag);
        return null;
      }

      // التحقق من حجم الملف
      final fileSize = await file.length();
      final maxSize = _getMaxFileSize(message.messageType);
      if (fileSize > maxSize) {
        final sizeMb = (fileSize / (1024 * 1024)).toStringAsFixed(1);
        final maxMb = (maxSize / (1024 * 1024)).toStringAsFixed(0);
        final error =
            'File too large (${sizeMb}MB). Max for ${message.messageType}: ${maxMb}MB';
        await _messagesDao.markAsFailed(message.id, error);
        AppLogger.error(error, tag: _tag);
        return null;
      }

      // قراءة الملف
      final Uint8List bytes = await file.readAsBytes();
      final mimeType = _getMimeType(localPath, message.messageType);

      AppLogger.debug(
        'Uploading media: $localPath (${(fileSize / 1024).toStringAsFixed(0)}KB, $mimeType)',
        tag: _tag,
      );

      // رفع الملف
      final uploadResponse = await _apiClient.uploadBytes(
        bytes: bytes,
        mimeType: mimeType,
      );

      if (uploadResponse.success && uploadResponse.publicUrl != null) {
        AppLogger.debug(
          'Upload successful: ${uploadResponse.publicUrl}',
          tag: _tag,
        );
        return uploadResponse.publicUrl;
      }

      final error = uploadResponse.error ?? 'Upload failed with no error message';
      await _messagesDao.markAsFailed(message.id, error);
      AppLogger.error('Upload failed for ${message.id}: $error', tag: _tag);
      return null;
    } catch (e, stackTrace) {
      final error = 'Upload exception: $e';
      await _messagesDao.markAsFailed(message.id, error);
      AppLogger.error(error, tag: _tag, error: e);
      ProductionLogger.exception(
        e,
        stackTrace: stackTrace,
        tag: _tag,
        context: {'messageId': message.id, 'path': localPath},
      );
      return null;
    }
  }

  /// الحصول على الحد الأقصى لحجم الملف حسب النوع
  int _getMaxFileSize(String messageType) {
    return switch (messageType) {
      'image' => WhatsAppConfig.maxImageSize,
      'video' => WhatsAppConfig.maxVideoSize,
      'document' => WhatsAppConfig.maxDocumentSize,
      'audio' => WhatsAppConfig.maxAudioSize,
      _ => WhatsAppConfig.maxDocumentSize, // الافتراضي
    };
  }

  /// تحديد MIME Type من امتداد الملف ونوع الرسالة
  String _getMimeType(String filePath, String messageType) {
    final extension = filePath.split('.').last.toLowerCase();

    // MIME types حسب الامتداد
    final mimeTypes = <String, String>{
      // صور
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      // فيديو
      'mp4': 'video/mp4',
      'avi': 'video/avi',
      'mov': 'video/quicktime',
      '3gp': 'video/3gpp',
      // صوت
      'mp3': 'audio/mpeg',
      'ogg': 'audio/ogg',
      'wav': 'audio/wav',
      'aac': 'audio/aac',
      'm4a': 'audio/mp4',
      // مستندات
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'csv': 'text/csv',
      'txt': 'text/plain',
      'zip': 'application/zip',
    };

    if (mimeTypes.containsKey(extension)) {
      return mimeTypes[extension]!;
    }

    // Fallback حسب نوع الرسالة
    return switch (messageType) {
      'image' => 'image/jpeg',
      'video' => 'video/mp4',
      'audio' => 'audio/mpeg',
      'document' => 'application/octet-stream',
      _ => 'application/octet-stream',
    };
  }

  // ═══════════════════════════════════════════════════════
  // إعادة المحاولة
  // ═══════════════════════════════════════════════════════

  /// حساب تأخير إعادة المحاولة بـ Exponential Backoff
  ///
  /// retryCount=1 -> 5 ثواني
  /// retryCount=2 -> 15 ثانية
  /// retryCount=3 -> 45 ثانية
  Duration _getRetryDelay(int retryCount) {
    if (retryCount <= 0) return Duration.zero;

    // 5s * 3^(retryCount-1)
    final seconds = 5 * _pow(3, retryCount - 1);
    return Duration(seconds: seconds);
  }

  /// حساب الأس (بدون مكتبة math)
  int _pow(int base, int exponent) {
    if (exponent <= 0) return 1;
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  // ═══════════════════════════════════════════════════════
  // Retention Policy - حذف الرسائل القديمة
  // ═══════════════════════════════════════════════════════

  /// حذف الرسائل القديمة (أكثر من 90 يوم) المكتملة أو الفاشلة نهائياً
  Future<void> _runRetentionCleanup() async {
    try {
      final deleted = await _messagesDao.deleteOlderThan(
        olderThan: const Duration(days: 90),
      );
      if (deleted > 0) {
        AppLogger.info(
          'Retention cleanup: deleted $deleted old messages',
          tag: _tag,
        );
      }
    } catch (e) {
      AppLogger.debug('Retention cleanup failed: $e', tag: _tag);
    }
  }

  // ═══════════════════════════════════════════════════════
  // تنظيف الملفات المؤقتة
  // ═══════════════════════════════════════════════════════

  /// حذف الملف المحلي المؤقت بعد الإرسال الناجح
  Future<void> _cleanupLocalFile(String? localPath) async {
    if (localPath == null || localPath.isEmpty) return;

    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.debug('Cleaned up temp file: $localPath', tag: _tag);
      }
    } catch (e) {
      // تجاهل أخطاء الحذف - الملفات المؤقتة ستُحذف لاحقاً من النظام
      AppLogger.debug('Failed to cleanup temp file: $localPath', tag: _tag);
    }
  }

  // ═══════════════════════════════════════════════════════
  // التنظيف
  // ═══════════════════════════════════════════════════════

  /// إيقاف المعالج وتنظيف الموارد
  void dispose() {
    stop();
    AppLogger.debug('Queue processor disposed', tag: _tag);
  }
}
