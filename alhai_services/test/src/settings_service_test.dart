import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

// ---------------------------------------------------------------------------
// Fake
// ---------------------------------------------------------------------------
class FakeStoreSettingsRepository implements StoreSettingsRepository {
  final Map<String, StoreSettings> _settings = {};

  @override
  Future<StoreSettings?> getSettings(String storeId) async {
    return _settings[storeId];
  }

  @override
  Future<StoreSettings> getOrCreateSettings(String storeId) async {
    return _settings.putIfAbsent(
      storeId,
      () => StoreSettings(id: 'settings-$storeId', storeId: storeId),
    );
  }

  @override
  Future<StoreSettings> createSettings({
    required String storeId,
    String? receiptHeader,
    String? receiptFooter,
    double? taxRate,
    int? lowStockThreshold,
    bool? enableLoyalty,
    int? loyaltyPointsPerRial,
    bool? autoPrintReceipt,
    String? currency,
  }) async {
    final s = StoreSettings(
      id: 'settings-$storeId',
      storeId: storeId,
      receiptHeader: receiptHeader,
      receiptFooter: receiptFooter,
      taxRate: taxRate ?? 15.0,
      lowStockThreshold: lowStockThreshold ?? 10,
      enableLoyalty: enableLoyalty ?? true,
      loyaltyPointsPerRial: loyaltyPointsPerRial ?? 1,
      autoPrintReceipt: autoPrintReceipt ?? true,
      currency: currency ?? 'SAR',
    );
    _settings[storeId] = s;
    return s;
  }

  @override
  Future<StoreSettings> updateSettings(
    String storeId, {
    String? receiptHeader,
    String? receiptFooter,
    double? taxRate,
    int? lowStockThreshold,
    bool? enableLoyalty,
    int? loyaltyPointsPerRial,
    bool? autoPrintReceipt,
    String? currency,
  }) async {
    final existing = _settings[storeId]!;
    final updated = StoreSettings(
      id: existing.id,
      storeId: storeId,
      receiptHeader: receiptHeader ?? existing.receiptHeader,
      receiptFooter: receiptFooter ?? existing.receiptFooter,
      taxRate: taxRate ?? existing.taxRate,
    );
    _settings[storeId] = updated;
    return updated;
  }

  @override
  Future<StoreSettings> resetToDefaults(String storeId) async {
    final s = StoreSettings(id: 'settings-$storeId', storeId: storeId);
    _settings[storeId] = s;
    return s;
  }
}

void main() {
  late SettingsService settingsService;
  late FakeStoreSettingsRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeStoreSettingsRepository();
    settingsService = SettingsService(fakeRepo);
  });

  group('SettingsService', () {
    test('should be created', () {
      expect(settingsService, isNotNull);
    });

    group('getSettings', () {
      test('should return null when no settings exist', () async {
        final result = await settingsService.getSettings('store-1');
        expect(result, isNull);
      });

      test('should return settings when they exist', () async {
        await fakeRepo.createSettings(storeId: 'store-1', taxRate: 15.0);

        final result = await settingsService.getSettings('store-1');
        expect(result, isNotNull);
        expect(result!.taxRate, equals(15.0));
      });
    });

    group('getOrCreateSettings', () {
      test('should create default settings when none exist', () async {
        final result = await settingsService.getOrCreateSettings('store-1');
        expect(result, isNotNull);
        expect(result.storeId, equals('store-1'));
      });

      test('should return existing settings', () async {
        await fakeRepo.createSettings(
          storeId: 'store-1',
          receiptHeader: 'Custom Header',
        );

        final result = await settingsService.getOrCreateSettings('store-1');
        expect(result.receiptHeader, equals('Custom Header'));
      });
    });

    group('createSettings', () {
      test('should create settings with custom values', () async {
        final result = await settingsService.createSettings(
          storeId: 'store-1',
          taxRate: 15.0,
          receiptHeader: 'Welcome',
          receiptFooter: 'Thank you',
          currency: 'SAR',
        );

        expect(result.taxRate, equals(15.0));
        expect(result.receiptHeader, equals('Welcome'));
        expect(result.currency, equals('SAR'));
      });
    });

    group('updateSettings', () {
      test('should update specific fields', () async {
        await fakeRepo.createSettings(
          storeId: 'store-1',
          taxRate: 15.0,
          receiptHeader: 'Old Header',
        );

        final result = await settingsService.updateSettings(
          'store-1',
          receiptHeader: 'New Header',
        );

        expect(result.receiptHeader, equals('New Header'));
      });
    });

    group('resetToDefaults', () {
      test('should reset all settings', () async {
        await fakeRepo.createSettings(
          storeId: 'store-1',
          taxRate: 20.0,
          receiptHeader: 'Custom',
        );

        final result = await settingsService.resetToDefaults('store-1');
        expect(result.receiptHeader, isNull);
      });
    });
  });
}
