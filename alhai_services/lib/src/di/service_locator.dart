import 'package:alhai_core/alhai_core.dart';
import '../services/services.dart';

/// Service Locator - يستخدم نفس GetIt instance من alhai_core
final serviceLocator = getIt;

/// تهيئة الخدمات
/// يجب استدعاء initializeCore() أولاً من alhai_core
Future<void> initializeServices() async {
  _registerCoreServices();
  _registerAdditionalServices();
}

void _registerCoreServices() {
  // Auth Service
  if (!serviceLocator.isRegistered<AuthService>()) {
    serviceLocator.registerLazySingleton<AuthService>(
      () => AuthService(serviceLocator<AuthRepository>()),
    );
  }

  // Product Service
  if (!serviceLocator.isRegistered<ProductService>()) {
    serviceLocator.registerLazySingleton<ProductService>(
      () => ProductService(
        serviceLocator<ProductsRepository>(),
        serviceLocator<InventoryRepository>(),
        serviceLocator<CategoriesRepository>(),
      ),
    );
  }

  // Order Service
  if (!serviceLocator.isRegistered<OrderService>()) {
    serviceLocator.registerLazySingleton<OrderService>(
      () => OrderService(
        serviceLocator<OrdersRepository>(),
        serviceLocator<OrderPaymentsRepository>(),
      ),
    );
  }

  // Payment Service
  if (!serviceLocator.isRegistered<PaymentService>()) {
    serviceLocator.registerLazySingleton<PaymentService>(
      () => PaymentService(
        serviceLocator<ShiftsRepository>(),
        serviceLocator<CashMovementsRepository>(),
        serviceLocator<OrderPaymentsRepository>(),
      ),
    );
  }

  // Debt Service
  if (!serviceLocator.isRegistered<DebtService>()) {
    serviceLocator.registerLazySingleton<DebtService>(
      () => DebtService(serviceLocator<DebtsRepository>()),
    );
  }

  // Report Service
  if (!serviceLocator.isRegistered<ReportService>()) {
    serviceLocator.registerLazySingleton<ReportService>(
      () => ReportService(serviceLocator<ReportsRepository>()),
    );
  }

  // Refund Service
  if (!serviceLocator.isRegistered<RefundService>()) {
    serviceLocator.registerLazySingleton<RefundService>(
      () => RefundService(serviceLocator<RefundsRepository>()),
    );
  }

  // Delivery Service
  if (!serviceLocator.isRegistered<DeliveryService>()) {
    serviceLocator.registerLazySingleton<DeliveryService>(
      () => DeliveryService(serviceLocator<DeliveryRepository>()),
    );
  }

  // Supplier Service
  if (!serviceLocator.isRegistered<SupplierService>()) {
    serviceLocator.registerLazySingleton<SupplierService>(
      () => SupplierService(
        serviceLocator<SuppliersRepository>(),
        serviceLocator<PurchasesRepository>(),
      ),
    );
  }

  // Notification Service
  if (!serviceLocator.isRegistered<NotificationService>()) {
    serviceLocator.registerLazySingleton<NotificationService>(
      () => NotificationService(serviceLocator<NotificationsRepository>()),
    );
  }

  // Promotion Service
  if (!serviceLocator.isRegistered<PromotionService>()) {
    serviceLocator.registerLazySingleton<PromotionService>(
      () => PromotionService(serviceLocator<PromotionsRepository>()),
    );
  }
}

void _registerAdditionalServices() {
  // Wholesale Service
  if (!serviceLocator.isRegistered<WholesaleService>()) {
    serviceLocator.registerLazySingleton<WholesaleService>(
      () => WholesaleService(serviceLocator<WholesaleOrdersRepository>()),
    );
  }

  // Distributor Service
  if (!serviceLocator.isRegistered<DistributorService>()) {
    serviceLocator.registerLazySingleton<DistributorService>(
      () => DistributorService(serviceLocator<DistributorsRepository>()),
    );
  }

  // Store Service
  if (!serviceLocator.isRegistered<StoreService>()) {
    serviceLocator.registerLazySingleton<StoreService>(
      () => StoreService(serviceLocator<StoresRepository>()),
    );
  }

  // Settings Service
  if (!serviceLocator.isRegistered<SettingsService>()) {
    serviceLocator.registerLazySingleton<SettingsService>(
      () => SettingsService(serviceLocator<StoreSettingsRepository>()),
    );
  }

  // Address Service
  if (!serviceLocator.isRegistered<AddressService>()) {
    serviceLocator.registerLazySingleton<AddressService>(
      () => AddressService(serviceLocator<AddressesRepository>()),
    );
  }

  // Analytics Service
  if (!serviceLocator.isRegistered<AnalyticsService>()) {
    serviceLocator.registerLazySingleton<AnalyticsService>(
      () => AnalyticsService(serviceLocator<AnalyticsRepository>()),
    );
  }

  // Activity Log Service
  if (!serviceLocator.isRegistered<ActivityLogService>()) {
    serviceLocator.registerLazySingleton<ActivityLogService>(
      () => ActivityLogService(serviceLocator<ActivityLogsRepository>()),
    );
  }

  // Transfer Service
  if (!serviceLocator.isRegistered<TransferService>()) {
    serviceLocator.registerLazySingleton<TransferService>(
      () => TransferService(serviceLocator<TransfersRepository>()),
    );
  }

  // Loyalty Service
  if (!serviceLocator.isRegistered<LoyaltyService>()) {
    serviceLocator.registerLazySingleton<LoyaltyService>(
      () => LoyaltyService(serviceLocator<LoyaltyRepository>()),
    );
  }

  // Store Member Service
  if (!serviceLocator.isRegistered<StoreMemberService>()) {
    serviceLocator.registerLazySingleton<StoreMemberService>(
      () => StoreMemberService(serviceLocator<StoreMembersRepository>()),
    );
  }

  // Rating Service
  if (!serviceLocator.isRegistered<RatingService>()) {
    serviceLocator.registerLazySingleton<RatingService>(
      () => RatingService(serviceLocator<RatingsRepository>()),
    );
  }

  // Chat Service
  if (!serviceLocator.isRegistered<ChatService>()) {
    serviceLocator.registerLazySingleton<ChatService>(
      () => ChatService(serviceLocator<ChatsRepository>()),
    );
  }

  // ==================== الدفعة الثالثة (Helper Services) ====================

  // Receipt Service
  if (!serviceLocator.isRegistered<ReceiptService>()) {
    serviceLocator.registerLazySingleton<ReceiptService>(
      () => ReceiptService(),
    );
  }

  // Print Service
  if (!serviceLocator.isRegistered<PrintService>()) {
    serviceLocator.registerLazySingleton<PrintService>(() => PrintService());
  }

  // Barcode Service
  if (!serviceLocator.isRegistered<BarcodeService>()) {
    serviceLocator.registerLazySingleton<BarcodeService>(
      () => BarcodeService(),
    );
  }

  // Export Service
  if (!serviceLocator.isRegistered<ExportService>()) {
    serviceLocator.registerLazySingleton<ExportService>(() => ExportService());
  }

  // Import Service
  if (!serviceLocator.isRegistered<ImportService>()) {
    serviceLocator.registerLazySingleton<ImportService>(() => ImportService());
  }

  // Search Service
  if (!serviceLocator.isRegistered<SearchService>()) {
    serviceLocator.registerLazySingleton<SearchService>(
      () => SearchService(
        serviceLocator<ProductsRepository>(),
        serviceLocator<OrdersRepository>(),
        serviceLocator<DebtsRepository>(),
      ),
    );
  }

  // Cache Service
  if (!serviceLocator.isRegistered<CacheService>()) {
    serviceLocator.registerLazySingleton<CacheService>(() => CacheService());
  }

  // Config Service
  if (!serviceLocator.isRegistered<ConfigService>()) {
    serviceLocator.registerLazySingleton<ConfigService>(() => ConfigService());
  }

  // Backup Service
  if (!serviceLocator.isRegistered<BackupService>()) {
    serviceLocator.registerLazySingleton<BackupService>(() => BackupService());
  }

  // ==================== الدفعة الرابعة (External Services) ====================
  // Note: WhatsAppService is an abstract class in alhai_core
  // Implementation should be registered by the app that uses it

  // AI Service
  if (!serviceLocator.isRegistered<AIService>()) {
    serviceLocator.registerLazySingleton<AIService>(() => AIService());
  }

  // Geo Notification Service
  if (!serviceLocator.isRegistered<GeoNotificationService>()) {
    serviceLocator.registerLazySingleton<GeoNotificationService>(
      () => GeoNotificationService(),
    );
  }

  // SMS Service
  if (!serviceLocator.isRegistered<SmsService>()) {
    serviceLocator.registerLazySingleton<SmsService>(() => SmsService());
  }

  // ==================== الدفعة الخامسة (Offline/Critical Services) ====================

  // PIN Validation Service Implementation
  if (!serviceLocator.isRegistered<PinValidationService>()) {
    serviceLocator.registerLazySingleton<PinValidationService>(
      () => PinValidationServiceImpl(
        membersRepository: serviceLocator<StoreMembersRepository>(),
      ),
    );
  }

  // Sync Queue Service Implementation
  if (!serviceLocator.isRegistered<SyncQueueService>()) {
    serviceLocator.registerLazySingleton<SyncQueueService>(
      () => SyncQueueServiceImpl(),
    );
  }

  // WhatsApp Service Implementation
  if (!serviceLocator.isRegistered<WhatsAppService>()) {
    serviceLocator.registerLazySingleton<WhatsAppService>(
      () => WhatsAppServiceImpl(),
    );
  }
}
