import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  group('CacheService Tests', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
    });

    test('should store and retrieve string value', () {
      cacheService.set('test_key', 'test_value');
      final result = cacheService.get<String>('test_key');
      expect(result, equals('test_value'));
    });

    test('should return null for non-existent key', () {
      final result = cacheService.get<String>('non_existent');
      expect(result, isNull);
    });

    test('should remove value', () {
      cacheService.set('key_to_remove', 'value');
      cacheService.remove('key_to_remove');
      final result = cacheService.get<String>('key_to_remove');
      expect(result, isNull);
    });

    test('should clear all values', () {
      cacheService.set('key1', 'value1');
      cacheService.set('key2', 'value2');
      cacheService.clear();
      expect(cacheService.get<String>('key1'), isNull);
      expect(cacheService.get<String>('key2'), isNull);
    });

    test('should check if key exists', () {
      cacheService.set('existing', 'value');
      expect(cacheService.containsKey('existing'), isTrue);
      expect(cacheService.containsKey('non_existing'), isFalse);
    });
  });

  group('ConfigService Tests', () {
    late ConfigService configService;

    setUp(() {
      configService = ConfigService();
    });

    test('should set and get config value', () {
      configService.set('app_name', 'Alhai');
      final result = configService.get<String>('app_name');
      expect(result, equals('Alhai'));
    });

    test('should return default value for non-existent key', () {
      final result = configService.get<int>('non_existent', defaultValue: 100);
      expect(result, equals(100));
    });

    test('should check if key exists', () {
      configService.set('existing_key', 'value');
      expect(configService.containsKey('existing_key'), isTrue);
      expect(configService.containsKey('non_existing'), isFalse);
    });
  });

  group('BarcodeService Tests', () {
    late BarcodeService barcodeService;

    setUp(() {
      barcodeService = BarcodeService();
    });

    test('should validate EAN-13 barcode', () {
      // Valid EAN-13: 5901234123457
      expect(barcodeService.validateEan13('5901234123457'), isTrue);
      expect(barcodeService.validateEan13('123'), isFalse);
    });

    test('should generate EAN-13 barcode', () {
      final barcode = barcodeService.generateEan13();
      expect(barcode, hasLength(13));
      expect(barcodeService.validateEan13(barcode), isTrue);
    });

    test('should detect barcode format', () {
      final format = barcodeService.detectFormat('5901234123457');
      expect(format, equals(BarcodeFormat.ean13));
    });
  });

  group('ReceiptService Tests', () {
    test('service can be instantiated', () {
      final receiptService = ReceiptService();
      expect(receiptService, isNotNull);
    });
  });

  group('SyncQueueServiceImpl Tests', () {
    late SyncQueueServiceImpl syncService;

    setUp(() {
      syncService = SyncQueueServiceImpl();
      syncService.clearQueue();
    });

    test('should enqueue item', () async {
      final item = await syncService.enqueue(
        entityType: SyncEntityType.order,
        entityId: 'order_123',
        operation: SyncOperationType.create,
        payload: {'total': 100},
      );
      expect(item.id, isNotEmpty);
      expect(item.status, equals(SyncStatus.pending));
    });

    test('should get pending items', () async {
      await syncService.enqueue(
        entityType: SyncEntityType.product,
        entityId: 'product_1',
        operation: SyncOperationType.update,
        payload: {'name': 'Test'},
      );

      final pending = await syncService.getPendingItems();
      expect(pending, isNotEmpty);
    });

    test('should get summary', () async {
      await syncService.enqueue(
        entityType: SyncEntityType.sale,
        entityId: 'sale_1',
        operation: SyncOperationType.create,
        payload: {},
      );

      final summary = await syncService.getSummary();
      expect(summary.pendingCount, greaterThan(0));
    });

    test('should clear queue', () async {
      syncService.clearQueue();
      final summary = await syncService.getSummary();
      expect(summary.pendingCount, equals(0));
    });
  });

  group('WhatsAppServiceImpl Tests', () {
    late WhatsAppServiceImpl whatsAppService;

    setUp(() {
      whatsAppService = WhatsAppServiceImpl();
    });

    test('should validate Saudi phone numbers', () {
      // Valid formats
      expect(whatsAppService.isValidWhatsAppNumber('0512345678'), isTrue);
      expect(whatsAppService.isValidWhatsAppNumber('966512345678'), isTrue);
      expect(whatsAppService.isValidWhatsAppNumber('+966512345678'), isTrue);

      // Invalid
      expect(whatsAppService.isValidWhatsAppNumber('123'), isFalse);
    });

    test('should format phone number', () {
      final formatted = whatsAppService.formatPhoneNumber('0512345678');
      expect(formatted, equals('966512345678'));
    });
  });
}
