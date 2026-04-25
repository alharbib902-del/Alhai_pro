/// P0-31: Riverpod wiring for [ReceiptSettings].
///
/// Two providers:
///   - [receiptSettingsRepositoryProvider] — singleton repository
///     bound to the app database.
///   - [receiptSettingsProvider] — `FutureProvider.family<ReceiptSettings,String>`
///     keyed on storeId, so multi-store apps don't cross-contaminate.
///     `ref.invalidate(receiptSettingsProvider(storeId))` after a save
///     forces a re-fetch and re-publishes the new value to listeners.
library;

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show appDatabaseProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/receipt_settings.dart';
import '../services/receipt_settings_repository.dart';

final receiptSettingsRepositoryProvider =
    Provider<ReceiptSettingsRepository>((ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return ReceiptSettingsRepository(db);
});

/// Per-store receipt settings. Family parameter is the storeId so
/// each store stays isolated. The receipt-PDF generator's settings
/// argument is read via `ref.read(receiptSettingsProvider(storeId).future)`
/// in service code that doesn't have a `WidgetRef` of its own.
final receiptSettingsProvider =
    FutureProvider.family<ReceiptSettings, String>((ref, storeId) async {
  final repo = ref.watch(receiptSettingsRepositoryProvider);
  return repo.loadForStore(storeId);
});
