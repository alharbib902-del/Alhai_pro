import 'package:freezed_annotation/freezed_annotation.dart';

part 'whatsapp_service.freezed.dart';
part 'whatsapp_service.g.dart';

/// WhatsApp message status enum (v2.5.0)
enum WhatsAppMessageStatus {
  @JsonValue('QUEUED')
  queued,
  @JsonValue('SENT')
  sent,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('FAILED')
  failed,
}

/// WhatsApp receipt request model
@freezed
class WhatsAppReceiptRequest with _$WhatsAppReceiptRequest {
  const factory WhatsAppReceiptRequest({
    required String orderId,
    required String phone,
    required String customerName,
    String? language,
  }) = _WhatsAppReceiptRequest;

  factory WhatsAppReceiptRequest.fromJson(Map<String, dynamic> json) =>
      _$WhatsAppReceiptRequestFromJson(json);
}

/// WhatsApp receipt response model
@freezed
class WhatsAppReceiptResponse with _$WhatsAppReceiptResponse {
  const factory WhatsAppReceiptResponse({
    required String messageId,
    required WhatsAppMessageStatus status,
    required String receiptUrl,
    String? errorMessage,
  }) = _WhatsAppReceiptResponse;

  factory WhatsAppReceiptResponse.fromJson(Map<String, dynamic> json) =>
      _$WhatsAppReceiptResponseFromJson(json);
}

/// WhatsApp Service interface (v2.5.0)
/// Referenced by: US-3.4 (WhatsApp Receipt)
abstract class WhatsAppService {
  /// Sends a receipt via WhatsApp
  /// Returns message ID and status
  Future<WhatsAppReceiptResponse> sendReceipt(WhatsAppReceiptRequest request);

  /// Checks message delivery status
  Future<WhatsAppMessageStatus> checkStatus(String messageId);

  /// Validates phone number format for WhatsApp
  bool isValidWhatsAppNumber(String phone);

  /// Gets the receipt URL for a given order
  Future<String> getReceiptUrl(String orderId);

  /// Checks if WhatsApp is configured for the store
  Future<bool> isConfigured(String storeId);

  /// Gets daily send limit remaining
  Future<int> getRemainingDailyLimit(String storeId);
}
