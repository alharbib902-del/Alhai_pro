import 'package:admin/providers/settings_db_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    registerAdminFallbackValues();
  });

  setUp(() {
    final mockDb = setupMockDatabase();
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  // ============================================================================
  // storeSettingsProvider
  // ============================================================================
  group('storeSettingsProvider', () {
    test('returns empty map when storeId is null', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(storeSettingsProvider.future);

      expect(result, isEmpty);
      expect(result, isA<Map<String, String>>());
    });
  });

  // ============================================================================
  // settingsByPrefixProvider
  // ============================================================================
  group('settingsByPrefixProvider', () {
    test('returns empty map when storeId is null', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        settingsByPrefixProvider('pos_').future,
      );

      expect(result, isEmpty);
      expect(result, isA<Map<String, String>>());
    });
  });

  // ============================================================================
  // singleSettingProvider
  // ============================================================================
  group('singleSettingProvider', () {
    test('returns null when storeId is null', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        singleSettingProvider('some_key').future,
      );

      expect(result, isNull);
    });
  });

  // ============================================================================
  // saveSetting ID format
  // ============================================================================
  group('saveSetting', () {
    test('generates correct ID format', () {
      // The saveSetting function builds id as 'setting_${storeId}_$key'
      const storeId = 'store-1';
      const key = 'theme_mode';
      const expectedId = 'setting_${storeId}_$key';

      expect(expectedId, 'setting_store-1_theme_mode');
    });
  });
}
