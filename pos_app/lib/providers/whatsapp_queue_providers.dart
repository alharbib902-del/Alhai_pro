/// WhatsApp Queue Providers - Database-backed
///
/// Riverpod providers for all WhatsApp services, using drift DAOs
/// for persistent queue storage instead of in-memory state.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/whatsapp_messages_dao.dart';
import 'package:pos_app/data/local/daos/whatsapp_templates_dao.dart';
import 'package:pos_app/di/injection.dart';
import 'package:pos_app/services/connectivity_service.dart';
import 'package:pos_app/services/whatsapp/wasender_api_client.dart';
import 'package:pos_app/services/whatsapp/phone_validation_service.dart';
import 'package:pos_app/services/whatsapp/whatsapp_queue_processor.dart';
import 'package:pos_app/services/whatsapp/bulk_messaging_service.dart';
import 'package:pos_app/services/whatsapp/template_service.dart';
import 'package:pos_app/services/whatsapp/webhook_handler.dart';
import 'package:pos_app/services/whatsapp/webhook_listener.dart';
import 'package:pos_app/services/whatsapp/models/wasender_models.dart';
import 'package:pos_app/services/whatsapp_service.dart';
import 'package:pos_app/services/whatsapp_receipt_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Core Service Providers
// ═══════════════════════════════════════════════════════════════════════════════

/// WaSender API Client - handles low-level HTTP calls to WaSender.
final waSenderApiClientProvider = Provider<WaSenderApiClient>((ref) {
  return WaSenderApiClient();
});

/// Phone Validation Service - normalises and validates phone numbers.
final phoneValidationServiceProvider = Provider<PhoneValidationService>((ref) {
  return PhoneValidationService(
    apiClient: ref.read(waSenderApiClientProvider),
  );
});

/// WhatsApp Messages DAO - drift DAO for the whatsapp_messages table.
final whatsappMessagesDaoProvider = Provider<WhatsAppMessagesDao>((ref) {
  return getIt<AppDatabase>().whatsAppMessagesDao;
});

/// WhatsApp Templates DAO - drift DAO for the whatsapp_templates table.
final whatsappTemplatesDaoProvider = Provider<WhatsAppTemplatesDao>((ref) {
  return getIt<AppDatabase>().whatsAppTemplatesDao;
});

// ═══════════════════════════════════════════════════════════════════════════════
// High-Level Service Providers
// ═══════════════════════════════════════════════════════════════════════════════

/// WhatsApp Service - main messaging facade (send, resend, etc.).
final whatsappServiceProvider = Provider<WhatsAppService>((ref) {
  return WhatsAppService(
    messagesDao: ref.read(whatsappMessagesDaoProvider),
    phoneValidator: ref.read(phoneValidationServiceProvider),
  );
});

/// WhatsApp Receipt Service - sends sale receipts via WhatsApp.
final whatsappReceiptServiceProvider = Provider<WhatsAppReceiptService>((ref) {
  return WhatsAppReceiptService(
    apiClient: ref.read(waSenderApiClientProvider),
    messagesDao: ref.read(whatsappMessagesDaoProvider),
  );
});

/// Bulk Messaging Service - campaign / batch sends.
final bulkMessagingServiceProvider = Provider<BulkMessagingService>((ref) {
  return BulkMessagingService(
    ref.read(whatsappMessagesDaoProvider),
    ref.read(phoneValidationServiceProvider),
    ref.read(whatsappTemplatesDaoProvider),
  );
});

/// Template Service - CRUD for WhatsApp message templates.
final whatsappTemplateServiceProvider =
    Provider<WhatsAppTemplateService>((ref) {
  return WhatsAppTemplateService(ref.read(whatsappTemplatesDaoProvider));
});

/// Queue Processor - drains the pending-messages table on a timer.
final whatsappQueueProcessorProvider =
    Provider<WhatsAppQueueProcessor>((ref) {
  return WhatsAppQueueProcessor(
    apiClient: ref.read(waSenderApiClientProvider),
    messagesDao: ref.read(whatsappMessagesDaoProvider),
    connectivity: getIt<ConnectivityService>(),
  );
});

/// Webhook Handler - processes inbound delivery-status webhooks.
final whatsappWebhookHandlerProvider =
    Provider<WhatsAppWebhookHandler>((ref) {
  return WhatsAppWebhookHandler(ref.read(whatsappMessagesDaoProvider));
});

/// Webhook Listener - HTTP server that receives webhook POSTs.
final whatsappWebhookListenerProvider =
    Provider<WhatsAppWebhookListener>((ref) {
  return WhatsAppWebhookListener(ref.read(whatsappWebhookHandlerProvider));
});

// ═══════════════════════════════════════════════════════════════════════════════
// UI State Providers
// ═══════════════════════════════════════════════════════════════════════════════

/// Watch pending message count (for badges).
/// NAME kept for backward compatibility with sidebar badge widgets.
final pendingWhatsAppCountProvider = StreamProvider<int>((ref) {
  return ref.read(whatsappMessagesDaoProvider).watchPendingCount();
});

/// Watch all messages with an optional filter (status / referenceType).
final whatsappMessagesProvider = StreamProvider.family<
    List<WhatsAppMessagesTableData>, WhatsAppMessageFilter?>((ref, filter) {
  return ref.read(whatsappMessagesDaoProvider).watchMessages(
        status: filter?.status,
        referenceType: filter?.referenceType,
      );
});

/// Watch message status counts for the dashboard overview cards.
final whatsappStatusCountsProvider = StreamProvider<Map<String, int>>((ref) {
  return ref.read(whatsappMessagesDaoProvider).watchStatusCounts();
});

/// Watch progress of a specific batch send.
final whatsappBatchProgressProvider =
    StreamProvider.family<Map<String, int>, String>((ref, batchId) {
  return ref.read(whatsappMessagesDaoProvider).watchBatchProgress(batchId);
});

/// Session status - checks WaSender connection health.
final whatsappSessionStatusProvider =
    FutureProvider<WaSenderSessionStatus>((ref) {
  return ref.read(waSenderApiClientProvider).getStatus();
});

/// Current receipt phone number (kept for backward compatibility).
final receiptPhoneProvider = StateProvider<String?>((ref) => null);
