/// WaSender API Client الموحّد
///
/// جميع استدعاءات WaSenderAPI تمر من هنا.
/// يستخدم SecureHttpClient مع Certificate Pinning و Retry Logic.
///
/// Endpoints المدعومة:
/// - POST /api/send-message (نص، صورة، فيديو، مستند، صوت، موقع، بطاقة اتصال)
/// - POST /api/upload (رفع ملفات Binary أو Base64)
/// - PUT /api/messages/{msgId} (تعديل رسالة)
/// - DELETE /api/messages/{msgId} (حذف رسالة)
/// - POST /api/messages/{msgId}/resend (إعادة إرسال)
/// - GET /api/messages/{msgId}/info (معلومات الرسالة)
/// - GET /api/contacts (جهات الاتصال)
/// - GET /api/on-whatsapp/{phone} (التحقق من وجود الرقم)
/// - GET /api/status (حالة الجلسة)
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/whatsapp_config.dart';
import '../../core/monitoring/production_logger.dart';
import '../../core/network/secure_http_client.dart';

import 'models/wasender_models.dart';

/// عميل WaSenderAPI الموحّد
class WaSenderApiClient {
  late final Dio _dio;

  WaSenderApiClient() {
    _dio = SecureDioExtensions.createWaSenderClient();
  }

  /// Constructor للاختبارات
  @visibleForTesting
  WaSenderApiClient.withDio(this._dio);

  // ═══════════════════════════════════════════════════════
  // إرسال الرسائل
  // ═══════════════════════════════════════════════════════

  /// إرسال رسالة نصية
  Future<WaSenderResponse> sendText({
    required String to,
    required String text,
  }) async {
    return _sendMessage({'to': to, 'text': text});
  }

  /// إرسال صورة
  Future<WaSenderResponse> sendImage({
    required String to,
    required String imageUrl,
    String? caption,
  }) async {
    return _sendMessage({
      'to': to,
      'imageUrl': imageUrl,
      if (caption != null) 'text': caption,
    });
  }

  /// إرسال فيديو
  Future<WaSenderResponse> sendVideo({
    required String to,
    required String videoUrl,
    String? caption,
  }) async {
    return _sendMessage({
      'to': to,
      'videoUrl': videoUrl,
      if (caption != null) 'text': caption,
    });
  }

  /// إرسال مستند (PDF, DOCX, XLSX, etc.)
  Future<WaSenderResponse> sendDocument({
    required String to,
    required String documentUrl,
    required String fileName,
    String? caption,
  }) async {
    return _sendMessage({
      'to': to,
      'documentUrl': documentUrl,
      'fileName': fileName,
      if (caption != null) 'text': caption,
    });
  }

  /// إرسال ملف صوتي
  Future<WaSenderResponse> sendAudio({
    required String to,
    required String audioUrl,
  }) async {
    return _sendMessage({'to': to, 'audioUrl': audioUrl});
  }

  /// إرسال ملصق
  Future<WaSenderResponse> sendSticker({
    required String to,
    required String stickerUrl,
  }) async {
    return _sendMessage({'to': to, 'stickerUrl': stickerUrl});
  }

  /// إرسال بطاقة اتصال
  Future<WaSenderResponse> sendContactCard({
    required String to,
    required String name,
    required String phone,
  }) async {
    return _sendMessage({
      'to': to,
      'contact': {'name': name, 'phone': phone},
    });
  }

  /// إرسال موقع
  Future<WaSenderResponse> sendLocation({
    required String to,
    required double latitude,
    required double longitude,
    String? name,
    String? address,
  }) async {
    return _sendMessage({
      'to': to,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        if (name != null) 'name': name,
        if (address != null) 'address': address,
      },
    });
  }

  /// إرسال رسالة لمجموعة
  Future<WaSenderResponse> sendGroupMessage({
    required String groupId,
    required String text,
  }) async {
    return _sendMessage({'to': groupId, 'text': text});
  }

  /// الإرسال الأساسي
  Future<WaSenderResponse> _sendMessage(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post('/send-message', data: body);
      return WaSenderResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      AppLogger.error('WaSender send error: $e', tag: 'WaSender');
      return WaSenderResponse.error('خطأ في الإرسال: $e');
    }
  }

  // ═══════════════════════════════════════════════════════
  // رفع الملفات
  // ═══════════════════════════════════════════════════════

  /// رفع ملف كـ Binary
  Future<WaSenderUploadResponse> uploadMedia({
    required Uint8List data,
    required String mimeType,
  }) async {
    try {
      final response = await _dio.post(
        '/upload',
        data: Stream.fromIterable([data]),
        options: Options(
          headers: {
            'Content-Type': mimeType,
            'Content-Length': data.length,
          },
        ),
      );
      return WaSenderUploadResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return WaSenderUploadResponse.error(_getErrorMessage(e));
    } catch (e) {
      return WaSenderUploadResponse.error('خطأ في الرفع: $e');
    }
  }

  /// رفع ملف كـ Base64
  Future<WaSenderUploadResponse> uploadMediaBase64({
    required String base64Data,
    required String mimeType,
  }) async {
    try {
      final response = await _dio.post(
        '/upload',
        data: {
          'mimetype': mimeType,
          'base64': base64Data,
        },
      );
      return WaSenderUploadResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return WaSenderUploadResponse.error(_getErrorMessage(e));
    } catch (e) {
      return WaSenderUploadResponse.error('خطأ في الرفع: $e');
    }
  }

  /// رفع ملف من bytes مع تحويل تلقائي لـ Base64
  Future<WaSenderUploadResponse> uploadBytes({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final base64 = base64Encode(bytes);
    return uploadMediaBase64(base64Data: base64, mimeType: mimeType);
  }

  // ═══════════════════════════════════════════════════════
  // عمليات الرسائل
  // ═══════════════════════════════════════════════════════

  /// تعديل رسالة
  Future<void> editMessage({
    required String msgId,
    required String text,
  }) async {
    try {
      await _dio.put('/messages/$msgId', data: {'text': text});
    } on DioException catch (e) {
      AppLogger.error('WaSender edit error: ${e.message}', tag: 'WaSender');
      rethrow;
    }
  }

  /// حذف رسالة
  Future<void> deleteMessage({required String msgId}) async {
    try {
      await _dio.delete('/messages/$msgId');
    } on DioException catch (e) {
      AppLogger.error('WaSender delete error: ${e.message}', tag: 'WaSender');
      rethrow;
    }
  }

  /// إعادة إرسال رسالة فاشلة
  Future<WaSenderResponse> resendMessage({required String msgId}) async {
    try {
      final response = await _dio.post('/messages/$msgId/resend');
      return WaSenderResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  /// الحصول على معلومات رسالة
  Future<WaSenderMessageInfo> getMessageInfo({required String msgId}) async {
    try {
      final response = await _dio.get('/messages/$msgId/info');
      return WaSenderMessageInfo.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      AppLogger.error('WaSender info error: ${e.message}', tag: 'WaSender');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  // جهات الاتصال
  // ═══════════════════════════════════════════════════════

  /// الحصول على جميع جهات الاتصال
  Future<List<WaSenderContact>> getContacts() async {
    try {
      final response = await _dio.get('/contacts');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((c) => WaSenderContact.fromJson(c as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'WaSender contacts error: ${e.message}',
        tag: 'WaSender',
      );
      return [];
    }
  }

  /// الحصول على معلومات جهة اتصال
  Future<WaSenderContact?> getContact({required String phone}) async {
    try {
      final response = await _dio.get('/contacts/$phone');
      return WaSenderContact.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      return null;
    }
  }

  /// الحصول على صورة البروفايل
  Future<String?> getContactPicture({required String phone}) async {
    try {
      final response = await _dio.get('/contacts/$phone/picture');
      final data = response.data as Map<String, dynamic>?;
      return data?['imgUrl'] as String? ?? data?['url'] as String?;
    } on DioException {
      return null;
    }
  }

  /// التحقق هل الرقم على واتساب
  Future<bool> isOnWhatsApp({required String phone}) async {
    try {
      final response = await _dio.get('/on-whatsapp/$phone');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['exists'] as bool? ??
            data['onWhatsApp'] as bool? ??
            (data['data'] != null);
      }
      return false;
    } on DioException {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════
  // الجلسة
  // ═══════════════════════════════════════════════════════

  /// الحصول على حالة الجلسة
  Future<WaSenderSessionStatus> getStatus() async {
    try {
      final response = await _dio.get('/status');
      return WaSenderSessionStatus.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      AppLogger.error('WaSender status error: ${e.message}', tag: 'WaSender');
      return WaSenderSessionStatus.disconnected();
    }
  }

  /// إرسال تحديث الحضور (typing/recording)
  Future<void> sendPresenceUpdate({
    required String to,
    String type = 'composing', // 'composing' or 'recording'
  }) async {
    try {
      await _dio.post('/send-presence-update', data: {
        'to': to,
        'type': type,
      });
    } on DioException {
      // نتجاهل أخطاء الحضور
    }
  }

  // ═══════════════════════════════════════════════════════
  // معالجة الأخطاء
  // ═══════════════════════════════════════════════════════

  WaSenderResponse _handleDioError(DioException e) {
    final message = _getErrorMessage(e);
    AppLogger.error('WaSender error: $message', tag: 'WaSender');
    return WaSenderResponse.error(message);
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة الاتصال';
      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final data = e.response?.data;
        if (statusCode == 401) return 'غير مصرح: تحقق من API Token';
        if (statusCode == 429) return 'تم تجاوز حد الطلبات، حاول لاحقاً';
        if (statusCode == 404) return 'الخدمة غير متوفرة';
        if (data is Map<String, dynamic>) {
          return data['message'] as String? ??
              data['error'] as String? ??
              'خطأ من الخادم ($statusCode)';
        }
        return 'خطأ من الخادم ($statusCode)';
      default:
        return e.message ?? 'خطأ غير معروف';
    }
  }

  /// التحقق من أن الإعدادات مكتملة
  static bool get isConfigured => WhatsAppConfig.isConfigured;

  /// تنظيف الموارد
  void dispose() {
    _dio.close();
  }
}
