// Barrel export for all services

// الخدمات الأساسية (الدفعة الأولى)
export 'auth_service.dart';
export 'product_service.dart';
export 'order_service.dart';
export 'payment_service.dart';
export 'debt_service.dart';
export 'report_service.dart';
export 'refund_service.dart';
export 'delivery_service.dart';
export 'supplier_service.dart';
export 'notification_service.dart';
export 'promotion_service.dart';

// خدمات إضافية (الدفعة الأولى - Repository جاهز)
export 'wholesale_service.dart';
export 'distributor_service.dart';
export 'store_service.dart';
export 'settings_service.dart';
export 'address_service.dart';
export 'analytics_service.dart';
export 'activity_log_service.dart';

// الدفعة الثانية (Repositories جديدة)
export 'transfer_service.dart';
export 'loyalty_service.dart';
export 'store_member_service.dart';
export 'rating_service.dart';
export 'chat_service.dart';

// الدفعة الثالثة (خدمات مساعدة - Logic فقط)
export 'receipt_service.dart';
export 'print_service.dart';
export 'barcode_service.dart';
export 'export_service.dart';
export 'import_service.dart';
export 'search_service.dart';
export 'cache_service.dart';
export 'config_service.dart';
export 'backup_service.dart';

// الدفعة الرابعة (خدمات خارجية - APIs)
// WhatsAppService موجود في alhai_core كـ interface
export 'ai_service.dart';
export 'geo_notification_service.dart';
export 'sms_service.dart';

// الدفعة الخامسة (خدمات Offline الحرجة - Implementations)
export 'pin_validation_service_impl.dart';
export 'sync_queue_service_impl.dart';
export 'whatsapp_service_impl.dart';
