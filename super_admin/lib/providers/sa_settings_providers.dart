import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/sa_analytics_model.dart';

import 'sa_dashboard_providers.dart' show saSupabaseClientProvider;

// ============================================================================
// PLATFORM SETTINGS
// ============================================================================

/// Platform settings from store_settings or a platform_settings table.
final saPlatformSettingsProvider =
    FutureProvider.autoDispose<SAPlatformSettings>((ref) async {
  final client = ref.watch(saSupabaseClientProvider);
  try {
    final data = await client.from('platform_settings').select('*').single();
    return SAPlatformSettings.fromJson(data);
  } catch (_) {
    // Table may not exist yet, return defaults
    return const SAPlatformSettings();
  }
});
