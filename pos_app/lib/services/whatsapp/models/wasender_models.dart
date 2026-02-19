/// نماذج WaSenderAPI
///
/// تغطي جميع أنواع الطلبات والاستجابات من WaSenderAPI
library;

/// استجابة إرسال رسالة من WaSenderAPI
class WaSenderResponse {
  final bool success;
  final String? msgId;
  final String? jid;
  final String? status;
  final String? error;

  const WaSenderResponse({
    required this.success,
    this.msgId,
    this.jid,
    this.status,
    this.error,
  });

  factory WaSenderResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return WaSenderResponse(
      success: json['success'] as bool? ?? false,
      msgId: data?['msgId']?.toString(),
      jid: data?['jid'] as String?,
      status: data?['status'] as String?,
      error: json['error'] as String? ?? json['message'] as String?,
    );
  }

  factory WaSenderResponse.error(String message) {
    return WaSenderResponse(success: false, error: message);
  }
}

/// استجابة رفع ملف من WaSenderAPI
class WaSenderUploadResponse {
  final bool success;
  final String? publicUrl;
  final String? error;

  const WaSenderUploadResponse({
    required this.success,
    this.publicUrl,
    this.error,
  });

  factory WaSenderUploadResponse.fromJson(Map<String, dynamic> json) {
    return WaSenderUploadResponse(
      success: json['success'] as bool? ?? false,
      publicUrl: json['publicUrl'] as String?,
      error: json['error'] as String? ?? json['message'] as String?,
    );
  }

  factory WaSenderUploadResponse.error(String message) {
    return WaSenderUploadResponse(success: false, error: message);
  }
}

/// معلومات جهة اتصال واتساب
class WaSenderContact {
  final String phone;
  final String? name;
  final String? profilePictureUrl;

  const WaSenderContact({
    required this.phone,
    this.name,
    this.profilePictureUrl,
  });

  factory WaSenderContact.fromJson(Map<String, dynamic> json) {
    return WaSenderContact(
      phone: json['phone'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['notify'] as String?,
      profilePictureUrl: json['imgUrl'] as String?,
    );
  }
}

/// حالة الجلسة (الاتصال)
class WaSenderSessionStatus {
  final bool isConnected;
  final String? status;
  final String? deviceName;
  final String? phoneNumber;

  const WaSenderSessionStatus({
    required this.isConnected,
    this.status,
    this.deviceName,
    this.phoneNumber,
  });

  factory WaSenderSessionStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final status = data['status'] as String? ?? '';
    return WaSenderSessionStatus(
      isConnected: status == 'connected' || status == 'open',
      status: status,
      deviceName: data['deviceName'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
    );
  }

  factory WaSenderSessionStatus.disconnected() {
    return const WaSenderSessionStatus(
      isConnected: false,
      status: 'disconnected',
    );
  }
}

/// معلومات تفصيلية عن رسالة
class WaSenderMessageInfo {
  final String msgId;
  final String? status;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  const WaSenderMessageInfo({
    required this.msgId,
    this.status,
    this.deliveredAt,
    this.readAt,
  });

  factory WaSenderMessageInfo.fromJson(Map<String, dynamic> json) {
    return WaSenderMessageInfo(
      msgId: json['msgId']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status'] as String?,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'].toString())
          : null,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
    );
  }
}

/// سجل رسالة من API
class WaSenderMessageLog {
  final String msgId;
  final String to;
  final String? text;
  final String status;
  final DateTime timestamp;

  const WaSenderMessageLog({
    required this.msgId,
    required this.to,
    this.text,
    required this.status,
    required this.timestamp,
  });

  factory WaSenderMessageLog.fromJson(Map<String, dynamic> json) {
    return WaSenderMessageLog(
      msgId: json['msgId']?.toString() ?? json['id']?.toString() ?? '',
      to: json['to'] as String? ?? '',
      text: json['text'] as String?,
      status: json['status'] as String? ?? 'unknown',
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['timestamp'] as int) * 1000,
            )
          : DateTime.now(),
    );
  }
}

/// حدث Webhook من WaSenderAPI
class WaSenderWebhookEvent {
  final String event;
  final int timestamp;
  final Map<String, dynamic> data;

  const WaSenderWebhookEvent({
    required this.event,
    required this.timestamp,
    required this.data,
  });

  factory WaSenderWebhookEvent.fromJson(Map<String, dynamic> json) {
    return WaSenderWebhookEvent(
      event: json['event'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  /// هل هو حدث رسالة مُرسلة؟
  bool get isMessageSent => event == 'message.sent';

  /// هل هو حدث تحديث رسالة (delivered/read)؟
  bool get isMessageUpdate => event == 'message-update';

  /// هل هو حدث رسالة واردة؟
  bool get isMessageReceived => event == 'messages.received';

  /// هل هو حدث رسالة عام (وارد + صادر)؟
  bool get isMessageUpsert => event == 'messages.upsert';
}

/// نتيجة التحقق من رقم على واتساب
class WhatsAppNumberCheck {
  final String phone;
  final bool isOnWhatsApp;
  final DateTime checkedAt;

  const WhatsAppNumberCheck({
    required this.phone,
    required this.isOnWhatsApp,
    required this.checkedAt,
  });
}

/// مستلم للإرسال الجماعي
class BulkRecipient {
  final String phone;
  final String? name;
  final String? customerId;
  final Map<String, String>? templateVars;

  const BulkRecipient({
    required this.phone,
    this.name,
    this.customerId,
    this.templateVars,
  });
}

/// مستلم تذكير دين
class DebtRecipient {
  final String phone;
  final String customerName;
  final String customerId;
  final double amount;

  const DebtRecipient({
    required this.phone,
    required this.customerName,
    required this.customerId,
    required this.amount,
  });
}

/// نتيجة إرسال جماعي
class BulkBatchResult {
  final String batchId;
  final int totalMessages;
  final int validRecipients;
  final int invalidRecipients;

  const BulkBatchResult({
    required this.batchId,
    required this.totalMessages,
    required this.validRecipients,
    required this.invalidRecipients,
  });
}

/// تقدم الإرسال الجماعي
class BulkBatchProgress {
  final String batchId;
  final int total;
  final int sent;
  final int delivered;
  final int failed;
  final int pending;

  const BulkBatchProgress({
    required this.batchId,
    required this.total,
    this.sent = 0,
    this.delivered = 0,
    this.failed = 0,
    this.pending = 0,
  });

  double get progressPercent =>
      total > 0 ? (sent + delivered + failed) / total : 0.0;

  bool get isComplete => pending == 0;
}

/// نتيجة التحقق من مستلم
class BulkRecipientValidation {
  final String phone;
  final bool isValid;
  final bool isOnWhatsApp;
  final String? error;

  const BulkRecipientValidation({
    required this.phone,
    required this.isValid,
    required this.isOnWhatsApp,
    this.error,
  });
}

/// فلتر الرسائل للـ UI
class WhatsAppMessageFilter {
  final String? status;
  final String? referenceType;
  final String? customerId;
  final DateTime? fromDate;
  final DateTime? toDate;

  const WhatsAppMessageFilter({
    this.status,
    this.referenceType,
    this.customerId,
    this.fromDate,
    this.toDate,
  });
}
